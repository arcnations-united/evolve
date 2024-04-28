import 'dart:io';
import 'package:card_swiper/card_swiper.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gtkthememanager/back_end/app_data.dart';
import 'package:gtkthememanager/back_end/gtk_theme_manager.dart';
import 'package:gtkthememanager/front_end/edit_colours.dart';
import 'package:gtkthememanager/front_end/main_page.dart';
import 'package:gtkthememanager/front_end/new_theme.dart';
import 'package:gtkthememanager/theme_manager/atplus_themes.dart';
import 'package:gtkthememanager/theme_manager/gtk_to_theme.dart';
import 'package:gtkthememanager/theme_manager/gtk_widgets.dart';
import 'package:gtkthememanager/theme_manager/tab_manage.dart';
import 'package:mesh_gradient/mesh_gradient.dart';
import 'package:process_run/process_run.dart';

import '../back_end/adaptive_theming.dart';

class Appearances extends StatefulWidget {
  final Function() state;
  const Appearances({super.key, required this.state});

  @override
  State<Appearances> createState() => _AppearancesState();
}

class _AppearancesState extends State<Appearances> {
  late SwiperController swipCtrl;
  Widget wall = const CircularProgressIndicator();

  bool checkGlobal(name) {
    if (!(ThemeManager.themeSupport[name]?["gtk3"] ?? false)) return false;
    if (!(ThemeManager.themeSupport[name]?["gtk4"] ?? false)) return false;
    if (!(ThemeManager.themeSupport[name]?["shell"] ?? false)) return false;
    return true;
  }

  @override
  void initState() {
    // TODO: implement initState
    swipCtrl = SwiperController();
    setVals();
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    swipCtrl.dispose();
    super.dispose();
  }
  bool settingColour=false;

  String globalAppliedThemePath = "";
  String globalAppliedTheme = "";
  List wallList = [];
  List<Color>oldCol=[];
  List<Color>col=[];
  setVals() async {

    wall = await WidsManager().getWallpaperSample();
    await getWallList();
    globalAppliedThemePath = await ThemeDt().getGTKThemePath();
    ThemeDt.isThemeFolderMade = await ThemeManager().populateThemeList();
    globalAppliedTheme = globalAppliedThemePath.split("/").last;
    ThemeDt.GTK3 = globalAppliedTheme;
    ThemeDt.ShellName = await ThemeDt().getShellThemeName();
    if (ThemeDt.ShellName == "") ThemeDt.ShellName = "Default";
    await ThemeDt().getGTK4ThemeName();
    try {
      await PThemes().populatePThemes();
    } catch (e) {
      print("Error while getting AT+ Themes");
      print(e);
    }
    ThemeDt.ThemeNamePath = globalAppliedThemePath;
    setState(() {
      opacity = 1.0;
    });
  }

  getWallList({String? path}) async {
    if (path == null) {
      String wallPath = (await Shell().run("""
    gsettings get org.gnome.desktop.background picture-uri
    """)).outText.replaceAll("file://", "").replaceAll("'", "");
      File wl = File(wallPath);
      if (await wl.exists()) {
        wallList = wl.parent.listSync();
      }
    } else {
      wallList = Directory(path).listSync();
    }
    List wallLstCopy = [];
    for (int i = 0; i < wallList.length; i++) {
      if (wallList[i].path.endsWith(".jpg") ||
          wallList[i].path.endsWith(".png") ||
          wallList[i].path.endsWith(".jpeg")) {
        wallLstCopy.add(wallList[i]);
      }
    }
    wallList = wallLstCopy;
  }
bool largeAlbum=false;
  double opacity = 0.0;
  //ensure smooth transition with controlled opacity
  bool isDark = true;
  @override
  Widget build(BuildContext context) {
    if (!ThemeDt.isThemeFolderMade) {
      return AnimatedOpacity(
        duration: ThemeDt.d,
        opacity: opacity,
        child: Center(
          child: WidsManager().getContainer(
            height: 220,
            width: 220,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Icon(
                  Icons.warning_rounded,
                  color: ThemeDt.themeColors["fg"],
                  size: 100,
                ),
                WidsManager().getText(
                    "Theme folder not found! Create theme folder and unpack themes into\n${SystemInfo.home}/.themes",
                    size: 10,
                    center: true),
                const SizedBox(
                  height: 10,
                ),
                GetButtons(
                  onTap: () async {
                    Directory theme = Directory("${SystemInfo.home}/.themes");
                    if (!(await theme.exists())) {
                      await theme.create();
                    }
                    ThemeDt.IconName = "";
                    setVals();
                  },
                  text: "Create theme folder",
                  light: true,
                )
              ],
            ),
          ),
        ),
      );
    }
    if (ThemeManager.GTKThemeList.isEmpty) {
      return AnimatedOpacity(
        duration: ThemeDt.d,
        opacity: opacity,
        child: Center(
          child: WidsManager().getContainer(
            height: 220,
            width: 170,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Icon(
                  Icons.warning_rounded,
                  color: ThemeDt.themeColors["fg"],
                  size: 100,
                ),
                WidsManager().getText(
                    "No theme(s) installed yet! Unpack themes into\n${SystemInfo.home}/.themes",
                    size: 10,
                    center: true),
                GetButtons(
                  onTap: () async {
                    setVals();
                  },
                  text: "Refresh",
                  light: true,
                )
              ],
            ),
          ),
        ),
      );
    }
    return AnimatedOpacity(
      duration: ThemeDt.d,
      opacity: opacity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(
            height: 10,
          ),
          AnimatedContainer(
            height:(largeAlbum)?MediaQuery.sizeOf(context).height / 2: MediaQuery.sizeOf(context).height / 3.8,
            duration: ThemeDt.d,
            curve: ThemeDt.c,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                WidsManager().getTooltip(
                  text: "Click to set wallpaper",

                  child: GestureDetector(
                    onTap: () async {
                      FilePickerResult? result =
                          await FilePicker.platform.pickFiles();

                      if (result != null) {
                        await ThemeDt().setWallpaper(result.files.single.path!);
                        wall = await WidsManager().getWallpaperSample();
                        File f = File(result.files.single.path!);
                        await getWallList(path: f.parent.path);
                        await setAdaptiveTheme();
                        widget.state();
                      }
                    },
                    child: AnimatedContainer(
                        duration: ThemeDt.d,
                        curve: ThemeDt.c,
                        width:(largeAlbum)?100: MediaQuery.sizeOf(context).width / 3,
                        child: wall).animate(
                      effects: [
                        FadeEffect(
                          delay: 100.milliseconds
                        )
                      ]
                    ),
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                Expanded(
                  child: Column(
                    children: [
                      Expanded(
                        child: Swiper(
                          controller: swipCtrl,
                          onTap: (tp) {
                            if (PThemes.themeMap.isNotEmpty) {
                              if (AppData.DataFile["AUTOPLAY"] ?? true) {
                                AppData.DataFile["AUTOPLAY"] = false;
                                AppData().writeDataFile();
                              }
                              setState(() {
                                swipCtrl.next();
                              });
                            }
                          },
                          itemBuilder: (BuildContext context, int index) {
                            return WidsManager().getContainer(
                              child: (index == 0)
                                  ? Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            WidsManager().getText("Album",fontWeight: ThemeDt.boldText),
                                            const SizedBox(
                                              width: 8,
                                            ),
                                            GestureDetector(
                                                onTap: () async {
                                                  await chooseAlbum();
                                                },
                                                child: Icon(
                                                  Icons.edit,
                                                  color:
                                                      ThemeDt.themeColors["fg"],
                                                  size: 13,
                                                )),
                                            const SizedBox(width: 10,),
                                            GestureDetector(
                                                onTap: () async {
                                                  setState(() {
                                                    largeAlbum=!largeAlbum;
                                                  });
                                                },
                                                child: Icon(
                                                  Icons.photo_size_select_large,
                                                  color:
                                                      ThemeDt.themeColors["fg"],
                                                  size: 13,
                                                )),
                                          ],
                                        ),
                                        const SizedBox(
                                          height: 10,
                                        ),
                                        wallList.isEmpty
                                            ? Center(
                                                child: GetButtons(
                                                  onTap: () async {
                                                    await chooseAlbum();
                                                  },
                                                  light: true,
                                                  child: WidsManager().getText(
                                                    "Choose an Album",
                                                    size: 15,
                                                  ),
                                                ),
                                              )
                                            : Expanded(
                                                child: GridView.builder(
                                                gridDelegate:
                                                     SliverGridDelegateWithFixedCrossAxisCount(
                                                        childAspectRatio: TabManager.isLargeScreen?1.3:2,
                                                        crossAxisCount: TabManager.isSuperLarge?(MediaQuery.sizeOf(context).width/250).floor():TabManager.isLargeScreen?3:1,
                                                        crossAxisSpacing: 8,
                                                        mainAxisSpacing: 8),
                                                itemCount: wallList.length,
                                                shrinkWrap: true,
                                                itemBuilder: (
                                                  BuildContext context,
                                                  int index,
                                                ) {
                                                  return GetButtons(
                                                      onTap: () async {
                                                        await ThemeDt()
                                                            .setWallpaper(
                                                                wallList[index]
                                                                    .path);
                                                        wall = await WidsManager()
                                                            .getWallpaperSample();
                                                        setState(() {

                                                        });
                                                        await setAdaptiveTheme();
                                                        widget.state();
                                                      },
                                                      light: true,
                                                      child: ClipRRect(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(5),
                                                        child: Image.file(
                                                          wallList[index],
                                                          width:
                                                              double.infinity,
                                                          height:
                                                              double.infinity,
                                                          fit: BoxFit.cover,
                                                        ),
                                                      )).animate(
                                                    effects: [
                                                      FadeEffect(
                                                          delay: 100.milliseconds

                                                      ),
                                                    ]
                                                  );
                                                },
                                              ))
                                      ],
                                    )
                                  : Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Row(
                                          children: [
                                            WidsManager()
                                                .getText('Set an AT+ theme',fontWeight: ThemeDt.boldText),
                                            const SizedBox(width: 10,),
                                            GestureDetector(
                                                onTap: () async {
                                                  setState(() {
                                                    largeAlbum=!largeAlbum;
                                                  });
                                                },
                                                child: Icon(
                                                  Icons.photo_size_select_large,
                                                  color:
                                                  ThemeDt.themeColors["fg"],
                                                  size: 13,
                                                )),

                                          ],
                                        ),
                                        Expanded(
                                          child: Container(
                                            margin: const EdgeInsets.only(top: 10),
                                            height: 100,
                                            child: GridView.builder(
                                              gridDelegate:
                                                  SliverGridDelegateWithFixedCrossAxisCount(
                                                      crossAxisCount:
                                                          (MediaQuery.sizeOf(
                                                                          context)
                                                                      .width /
                                                                  200)
                                                              .floor(),
                                                      crossAxisSpacing: 8,
                                                      childAspectRatio: largeAlbum?1:2,
                                                      mainAxisSpacing: 8),
                                              shrinkWrap: true,
                                              itemCount:
                                                  PThemes.themeMap.length,
                                              itemBuilder:
                                                  (BuildContext context,
                                                      int index) {
                                             //   index = index + 1;
                                                return WidsManager().getTooltip(
widget: Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    WidsManager().getText("${PThemes.themeMap.values.elementAt(index)["NAME"]} ${PThemes.themeMap.values.elementAt(index)["VERS"]!="N/A"?PThemes.themeMap.values.elementAt(index)["VERS"]:""}\n"
        "\n${PThemes.themeMap.values.elementAt(index)["DESC"]}\n\n"
        "${PThemes.themeMap.values.elementAt(index)["THEME"]}\n"
        "${PThemes.themeMap.values.elementAt(index)["ICON"]}"),
    Padding(
      padding: const EdgeInsets.only(top: 18.0),
      child: Row(
        children: <Widget>[
          Container(
            height: 30,
            width: 30,
            color: Color(PThemes.themeMap.values.elementAt(index)["COLOR1"]),
          ),
          Container(
            height: 30,
            width: 30,
            color: Color(PThemes.themeMap.values.elementAt(index)["COLOR2"]),
          ),
          Container(
            height: 30,
            width: 30,
            color: Color(PThemes.themeMap.values.elementAt(index)["COLOR3"]),
          ),
        ],),
    ),
                                                    ],
),
                                                  child: GetButtons(
                                                    light: true,
                                                    onTap: () async {
                                                      //run AT+ Theme Apply
                                                      if (index <= 4) {
                                                        ThemeDt.ThemeNamePath =
                                                            "${SystemInfo.home}/.themes/${PThemes.themeMap.values.elementAt(index)["THEME"]}";
                                                        globalAppliedTheme =
                                                            ThemeDt.ThemeNamePath
                                                                    .split("/")
                                                                .last;
                                                        globalAppliedThemePath =
                                                            ThemeDt.ThemeNamePath;
                                                        await ThemeDt().setTheme(
                                                            respectSystem: false,
                                                            dark: isDark);
                                                        widget.state();
                                                        if (PThemes.themeMap.keys.elementAt(index) != 1) {
                                                          await ThemeDt()
                                                              .setWallpaper(
                                                                  "${SystemInfo.home}/AT/UID${PThemes.themeMap.keys.elementAt(index)}/w1.png");
                                                        } else {
                                                          await ThemeDt()
                                                              .setWallpaper(
                                                                  "${SystemInfo.home}/AT/UID${PThemes.themeMap.keys.elementAt(index)}/w1.jpg");
                                                        }
                                                        ThemeDt().setIcon(
                                                            packName: PThemes
                                                                    .themeMap.values.elementAt(index)["ICON"]);
                                                        await ThemeDt().setGTK3(
                                                            PThemes.themeMap.values.elementAt(index)["THEME"],
                                                            context);
                                                        await ThemeDt().setGTK4(
                                                            '${SystemInfo.home}/.themes/${PThemes.themeMap.values.elementAt(index)["THEME"]}',
                                                            context);
                                                        await ThemeDt().setShell(
                                                            PThemes.themeMap.values.elementAt(index)["THEME"],
                                                            context);
                                                        ThemeDt()
                                                            .getIconThemeName();
                                                        wall = await WidsManager()
                                                            .getWallpaperSample();
                                                        await getWallList();
                                                        setState(() {});
                                                      }
                                                      AppData.DataFile[
                                                          "ATPLUSTHEME"] = index;
                                                      AppData().writeDataFile();
                                                    },
                                                    ghost: AppData.DataFile[
                                                            "ATPLUSTHEME"] ==
                                                        index,
                                                    child: Container(
                                                      height: 100,
                                                      decoration:
                                                    largeAlbum?  BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(10),
                                                          gradient:
                                                              RadialGradient(
                                                            radius:
                                                                MediaQuery.sizeOf(
                                                                            context)
                                                                        .width /
                                                                   ( 300),
                                                            colors: [
                                                              Colors.white,
                                                              Color(
                                                                  PThemes.themeMap.values.elementAt(index)
                                                                      ["COLOR1"]),
                                                              Color(
                                                                  PThemes.themeMap.values.elementAt(index)
                                                                      ["COLOR2"]),
                                                              Color(PThemes
                                                                      .themeMap.values.elementAt(index)["COLOR3"])
                                                            ],
                                                            center: Alignment
                                                                .topRight,
                                                          )):null,
                                                      child: (largeAlbum)? Center(
                                                            child: Padding(
                                                              padding: const EdgeInsets.all(8.0),
                                                              child:
                                                         WidsManager().getContainer(
                                                             child: WidsManager().getText(PThemes.themeMap.values.elementAt(index)["NAME"])),),
                                                          ) : Row(
                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                        children: <Widget>[
                                                          Container(
                                                            height: 20,
                                                            width: 20,
                                                            color: Color(PThemes.themeMap.values.elementAt(index)["COLOR1"]),
                                                          ), Container(
                                                            height: 20,
                                                            width: 20,
                                                            color: Color(PThemes.themeMap.values.elementAt(index)["COLOR2"]),
                                                          ),Container(
                                                            height: 20,
                                                            width: 20,
                                                            color: Color(PThemes.themeMap.values.elementAt(index)["COLOR3"]),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              },
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                            );
                          },
                          itemCount: PThemes.themeMap.isEmpty ? 1 : 2,
                          autoplay: PThemes.themeMap.isNotEmpty? AppData.DataFile["AUTOPLAY"] ?? true : false,
                        ),
                      ),
                      if((!globalAppliedThemePath.startsWith("/usr/"))&&ThemeManager.GTKThemeList.contains(globalAppliedThemePath))    const SizedBox(
                        height: 10,
                      ),
                   if((!globalAppliedThemePath.startsWith("/usr/"))&&ThemeManager.GTKThemeList.contains(globalAppliedThemePath))   WidsManager().getTooltip(
                        text:
                            "Use Background image colours in applied GTK Theme.",

                        child: GestureDetector(
                          onTap: () async {
                            String fle="";
                            //change path to adaptive before entering
                            if(!ThemeDt.GTK3.endsWith("-Adaptive")){
                              fle="${SystemInfo.home}/.themes/${ThemeDt.GTK3}-Adaptive/gtk-3.0/${(isDark) ? "gtk-dark.css" : "gtk.css"}";
                            Directory adapTheme = Directory("${SystemInfo.home}/.themes/${ThemeDt.GTK3}-Adaptive");
                            if (await adapTheme.exists()==false){
                              await adapTheme.create();
                              await Shell().run("cp -T -r ${SystemInfo.home}/.themes/${ThemeDt.GTK3} ${SystemInfo.home}/.themes/${ThemeDt.GTK3}-Adaptive" );
                            }
                            }
                            else {
                              fle="${SystemInfo.home}/.themes/${ThemeDt.GTK3}/gtk-3.0/${(isDark) ? "gtk-dark.css" : "gtk.css"}";
                            }
                            File fl = File(fle);
                            if (!(await fl.exists())) {
                              WidsManager().showMessage(
                                  title: "Error",
                                  message:
                                  "Only locally installed themes can be edited. Please download and install a theme if you don't have any local user themes.",
                                  context: context);
                              return;
                            }
                            Navigator.push(context, MaterialPageRoute(builder: (context)=>ChangeColors(filePath: fle, state: widget.state, editAccents: true,))).then((value) async {
                              globalAppliedThemePath = await ThemeDt().getGTKThemePath();
                              ThemeDt.isThemeFolderMade = await ThemeManager().populateThemeList();
                              globalAppliedTheme = globalAppliedThemePath.split("/").last;
                              widget.state();
                            });
                          },
                          onSecondaryTap: (){
                           showMenu(context: context, color: Colors.transparent, elevation:0,items: [
                            PopupMenuItem(
                                child: WidsManager().getContainer(blur:true,  child: WidsManager().getText("Toggle adaptive mode")),
                              onTap: () async {

                                        try {
                                          if (AppData
                                                  .DataFile["AUTOTHEMECOLOR"] ==
                                              null) {
                                            AppData.DataFile["AUTOTHEMECOLOR"] =
                                                3;
                                            await setAdaptiveTheme();
                                          } else {
                                            AppData.DataFile.remove(
                                                "AUTOTHEMECOLOR");
                                            String normalThemeName =
                                                globalAppliedThemePath
                                                    .split("/")
                                                    .last;
                                            normalThemeName =
                                                normalThemeName.substring(
                                                    0,
                                                    normalThemeName
                                                        .lastIndexOf("-"));
                                            await ThemeDt().setGTK3(
                                                normalThemeName, context);
                                            await ThemeDt().setShell(
                                                normalThemeName, context);
                                            String themePath =
                                                globalAppliedThemePath;
                                            themePath = themePath.substring(
                                                0, themePath.lastIndexOf("/"));
                                            themePath =
                                                "$themePath/$normalThemeName";
                                            await ThemeDt()
                                                .setGTK4(themePath, context);
                                            globalAppliedThemePath =
                                                await ThemeDt().getGTKThemePath();
                                            ThemeDt.isThemeFolderMade =
                                                await ThemeManager()
                                                    .populateThemeList();
                                            globalAppliedTheme =
                                                globalAppliedThemePath
                                                    .split("/")
                                                    .last;
                                            await ThemeDt()
                                                .setTheme(respectSystem: true);
                                            widget.state();
                                          }
                                          AppData().writeDataFile();

                                                                                widget.state();
                                        } catch (e) {
                                          Navigator.pop(context);
                                          setState(() {
                                            settingColour=false;
                                            AppData.DataFile["AUTOTHEMECOLOR"]=null;
                                          });
                                          WidsManager().showMessage(title: "Error", message: e.toString(), context: context);
                                        }
                              },
                            )
                           ],
                               position: RelativeRect.fromLTRB(MediaQuery.sizeOf(context).width,
                                   MediaQuery.sizeOf(context).height/4, 0, 0));
                          },
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: AnimatedMeshGradient(
                              colors: settingColour?[
                                Colors.white,
                                Colors.blue[100]!,
                                Colors.blue[400]!,
                                Colors.indigo[900]!
                              ]: AppData.DataFile["AUTOTHEMECOLOR"]==null?[
                              ThemeDt.themeColors["altbg"]!,
                                ThemeDt.themeColors["altbg"]!,
                                ThemeDt.themeColors["altbg"]!,
                                ThemeDt.themeColors["altbg"]!,
                              ]:[
                                ThemeDt.themeColors["fg"]!,
                                ThemeDt.themeColors["bg"]!,
                               ThemeDt.themeColors["sltbg"]!,
                               ThemeDt.themeColors["bg"]!,
                              ],
                              options: AnimatedMeshGradientOptions(
                              ),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      WidsManager().getText(
                                       settingColour?"Setting adaptive colour...":"Adaptive Colours",
                                      ),
                                      Icon(
                                        Icons.auto_awesome,
                                        color: ThemeDt.themeColors["fg"],
                                      )
                                    ],
                                  ),
                                )),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 40,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  WidsManager().getText("Global Theme", fontWeight: ThemeDt.boldText),
                  IconButton(
                      onPressed: () {

                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return Center(
                              child: SizedBox(
                                height: 300,
                                width: 500,
                                child: Column(
                                  children: [
                                    Expanded(
                                      child: WidsManager().getContainer(
                                          pad: 20,
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              WidsManager()
                                                  .getText("Applied Theme"),
                                              WidsManager().getText(
                                                  globalAppliedTheme,
                                                  size: 28),
                                              const SizedBox(
                                                height: 10,
                                              ),
                                              Row(
                                                children: [
                                                  if (ThemeManager.themeSupport[
                                                              globalAppliedThemePath]
                                                          ?["gtk4"] ??
                                                      false)
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              right: 10.0),
                                                      child: WidsManager()
                                                          .getText("GTK-4.0",
                                                              size: 12,
                                                              stylize: true),
                                                    ),
                                                  if (ThemeManager.themeSupport[
                                                              globalAppliedThemePath]
                                                          ?["shell"] ??
                                                      false)
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              right: 10.0),
                                                      child:
                                                          WidsManager().getText(
                                                        "gnome-shell",
                                                        size: 12,
                                                      ),
                                                    ),
                                                  if (ThemeManager.themeSupport[
                                                              globalAppliedThemePath]
                                                          ?["xfce"] ??
                                                      false)
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              right: 10.0),
                                                      child: WidsManager()
                                                          .getText("xfce",
                                                              size: 12,
                                                              stylize: true),
                                                    ),
                                                  if (ThemeManager.themeSupport[
                                                              globalAppliedThemePath]
                                                          ?["cin"] ??
                                                      false)
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              right: 10.0),
                                                      child: WidsManager()
                                                          .getText("cinnamon",
                                                              size: 12,
                                                              stylize: true),
                                                    ),
                                                ],
                                              ),
                                            ],
                                          )),
                                    ),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    Expanded(
                                      child: WidsManager().getContainer(
                                          pad: 20,
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              WidsManager()
                                                  .getText("App Theme"),
                                              WidsManager().getText(
                                                  ThemeDt.ThemeNamePath.split(
                                                          "/")
                                                      .last,
                                                  size: 28),
                                              const SizedBox(
                                                height: 10,
                                              ),
                                              Row(
                                                children: [
                                                  if (ThemeManager.themeSupport[
                                                              ThemeDt
                                                                  .ThemeNamePath]
                                                          ?["gtk4"] ??
                                                      false)
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              right: 10.0),
                                                      child: WidsManager()
                                                          .getText("GTK-4.0",
                                                              size: 12,
                                                              stylize: true),
                                                    ),
                                                  if (ThemeManager.themeSupport[
                                                              ThemeDt
                                                                  .ThemeNamePath]
                                                          ?["shell"] ??
                                                      false)
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              right: 10.0),
                                                      child:
                                                          WidsManager().getText(
                                                        "gnome-shell",
                                                        size: 12,
                                                      ),
                                                    ),
                                                  if (ThemeManager.themeSupport[
                                                              ThemeDt
                                                                  .ThemeNamePath]
                                                          ?["xfce"] ??
                                                      false)
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              right: 10.0),
                                                      child: WidsManager()
                                                          .getText("xfce",
                                                              size: 12,
                                                              stylize: true),
                                                    ),
                                                  if (ThemeManager.themeSupport[
                                                              ThemeDt
                                                                  .ThemeNamePath]
                                                          ?["cin"] ??
                                                      false)
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              right: 10.0),
                                                      child: WidsManager()
                                                          .getText("cinnamon",
                                                              size: 12,
                                                              stylize: true),
                                                    ),
                                                ],
                                              ),
                                            ],
                                          )),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      },
                      icon: Icon(
                        Icons.info,
                        color: ThemeDt.themeColors["fg"],
                      ))
                ],
              ),
              Row(
                children: [
                  PopupMenuButton(
                    tooltip: "",
                    splashRadius: 20,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                    color: Colors.transparent,
                    elevation: 0,
                    itemBuilder: (BuildContext context) {
                      return [
                        PopupMenuItem(enabled: false,child:  WidsManager().getContainer(blur: true,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                          for (int i = 0;
                              i < ThemeManager.GTKThemeList.length;
                              i++)
                            if (checkGlobal(ThemeManager.GTKThemeList[i]))
                           Padding(
                             padding: const EdgeInsets.all( 4.0),
                             child: GestureDetector( onTap: () async {
                             Navigator.pop(context);
                             ThemeDt.ThemeNamePath =
                                 ThemeManager.GTKThemeList[i];
                             await ThemeDt().setTheme(
                                 respectSystem: false, dark: isDark);
                             AppData.DataFile.remove("AUTOTHEMECOLOR");
                             widget.state();},
                                                          child: WidsManager().getText(
                               ThemeManager.GTKThemeList[i]
                                   .split("/")
                                   .last,
                               color: "fg"),
                                                        ),
                           ),
                           Padding(
                             padding: const EdgeInsets.all( 4.0),
                             child: GestureDetector(
                             onTap: () async {
                             Navigator.pop(context);
                             ThemeDt.ThemeNamePath="default";
                             await ThemeDt().setTheme(respectSystem: false, dark: isDark);
                             AppData.DataFile.remove("AUTOTHEMECOLOR");
                             widget.state();
                                                          },
                                                          child: WidsManager().getText(
                              "Adwaita",
                               color: "fg"),
                                                        ),
                           ),

                            ]
                          ),
                        ),
                        )];
                    },
                    child: WidsManager().getContainer(
                        width: (ThemeDt.ThemeNamePath != globalAppliedThemePath
                            ? MediaQuery.sizeOf(context).width / 3 - 53
                            : MediaQuery.sizeOf(context).width / 3)+(TabManager.isLargeScreen?0:60),
                        child: WidsManager().getText(
                            ThemeDt.ThemeNamePath.split("/").last,
                            maxLines: 1)),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  GetButtons(
                    onTap: () {
                      if (ThemeDt.ThemeNamePath.contains("usr/share")) {
                        WidsManager().showMessage(
                            title: "Error",
                            message:
                                "Only locally installed themes can be modded. Please download and install a theme if you don't have any local user themes.",
                            context: context);
                        return;
                      }
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => NewTheme(
                                    name: ThemeDt.ThemeNamePath,
                                  ))).then((value) async {
                        setVals();
                      });
                    },
                    light: true,
                    child: Icon(
                      Icons.add_rounded,
                      color: ThemeDt.themeColors["fg"],
                      size: 21,
                    ),
                  ),
                  if (ThemeDt.ThemeNamePath != globalAppliedThemePath)
                    const SizedBox(
                      width: 10,
                    ),
                  if (ThemeDt.ThemeNamePath != globalAppliedThemePath)
                    GetButtons(
                      onTap: () async {
                      if(ThemeDt.ThemeNamePath=="default") {
                        globalAppliedTheme="default";
                      }else{
                          globalAppliedTheme =
                              ThemeDt.ThemeNamePath.split("/").last;
                        }
                        globalAppliedThemePath = ThemeDt.ThemeNamePath;
                      if(AppData.DataFile["FLATPAK"]==true){
                        await ThemeDt().setFlatpakTheme(globalAppliedThemePath, context);
                      }
                        await ThemeDt().setGTK3(globalAppliedTheme, context);
                        await ThemeDt().setGTK4(globalAppliedThemePath, context);
                        await ThemeDt().setShell(globalAppliedTheme, context);
                        widget.state();
                      },
                      light: true,
                      child: Icon(
                        Icons.check_rounded,
                        color: ThemeDt.themeColors["fg"],
                        size: 21,
                      ),
                    ),
                ],
              )
            ],
          ),
          const SizedBox(
            height: 10,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              WidsManager().getText("GTK 3.0 Theme",fontWeight: ThemeDt.boldText),
              Row(
                children: [
                  PopupMenuButton(
                    tooltip: "",
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                    color: Colors.transparent,
                    elevation: 0,
                    itemBuilder: (BuildContext context) {
                      return [
                        PopupMenuItem(enabled: false,child:
                        WidsManager().getContainer(blur: true,
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                for (int i = 0;
                                i < ThemeManager.GTKThemeList.length;
                                i++)
                                  if (ThemeManager.themeSupport[
                                  ThemeManager.GTKThemeList[i]]?["gtk3"] ??
                                      false)
                                    Padding(
                                      padding: const EdgeInsets.all( 4.0),
                                      child: GestureDetector(
                                        onTap: () async {
                                          Navigator.pop(context);
                                          await ThemeDt().setGTK3(
                                              ThemeManager.GTKThemeList[i]
                                                  .split("/")
                                                  .last,
                                              context);
                                          AppData.DataFile.remove("AUTOTHEMECOLOR");

                                          widget.state();
                                        },
                                        child: WidsManager().getText(
                                            ThemeManager.GTKThemeList[i]
                                                .split("/")
                                                .last,
                                            color: "fg"),
                                      ),
                                    ),]
                          ),
                        ),
                        )];
                    },
                    child: WidsManager().getContainer(
                        width: (MediaQuery.sizeOf(context).width / 3)+(TabManager.isLargeScreen?0:60),
                        child:
                        WidsManager().getText(ThemeDt.GTK3, maxLines: 1)),
                  ),
                  const SizedBox(
                    width: 8,
                  ),
                  GetButtons(
                    onTap: () async {
                      String fle =
                          "${SystemInfo.home}/.themes/${ThemeDt.GTK3}/gtk-3.0/${(isDark) ? "gtk-dark.css" : "gtk.css"}";
                      File fl = File(fle);
                      if (!(await fl.exists())) {
                        WidsManager().showMessage(
                            title: "Error",
                            message:
                                "Only locally installed themes can be edited. Please download and install a theme if you don't have any local user themes.",
                            context: context);
                        return;
                      }
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ChangeColors(
                                    filePath: fle,
                                    state: widget.state,
                                  ))).then((value) async {
                        widget.state();
                      });
                    },
                    light: true,
                    child: Icon(
                      Icons.edit_rounded,
                      color: ThemeDt.themeColors["fg"],
                      size: 21,
                    ),
                  ),
                ],
              )
            ],
          ),
          const SizedBox(
            height: 10,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              WidsManager().getText("GTK 4.0 Theme",fontWeight: ThemeDt.boldText),
              Row(
                children: [
                  PopupMenuButton(
                    tooltip: "",
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                    color: Colors.transparent,
                    elevation: 0,
                    itemBuilder: (BuildContext context) {
                      return [
                        PopupMenuItem(enabled: false,child:
                        WidsManager().getContainer(blur: true,
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                for (int i = 0;
                                i < ThemeManager.GTKThemeList.length;
                                i++)
                                  if (ThemeManager.themeSupport[
                                  ThemeManager.GTKThemeList[i]]?["gtk4"] ??
                                      false)
                                    Padding(
                                      padding: const EdgeInsets.all( 4.0),
                                      child: GestureDetector(
                                        onTap: () async {
                                          Navigator.pop(context);
                                          await ThemeDt().setGTK4(
                                              ThemeManager.GTKThemeList[i], context);
                                          AppData.DataFile.remove("AUTOTHEMECOLOR");
                                          setState(() {});
                                        },
                                        child: WidsManager().getText(ThemeManager
                                            .GTKThemeList[i]
                                            .split("/")
                                            .last),
                                      ),
                                    ),]
                          ),
                        ),
                        )];
                    },
                    child: WidsManager().getContainer(
                        width:( MediaQuery.sizeOf(context).width / 3)+(TabManager.isLargeScreen?0:60),
                        child: WidsManager().getText(
                            ThemeDt.GTK4 ?? "Not Applied",
                            maxLines: 1))),

                  const SizedBox(
                    width: 10,
                  ),
                  GetButtons(
                    onTap: () async {
                      String fle =
                          "${SystemInfo.home}/.themes/${ThemeDt.GTK4}/gtk-4.0/${(isDark) ? "gtk-dark.css" : "gtk.css"}";
                      File fl = File(fle);
                      if (!(await fl.exists())) {
                        WidsManager().showMessage(
                            title: "Error",
                            message:
                                "Only locally installed themes can be edited. Please download and install a theme if you don't have any local user themes.",
                            context: context);
                        return;
                      }
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ChangeColors(
                                    filePath: fle,
                                    state: widget.state,
                                  )));
                    },
                    light: true,
                    child: Icon(
                      Icons.edit_rounded,
                      color: ThemeDt.themeColors["fg"],
                      size: 21,
                    ),
                  ),
                ],
              )
            ],
          ),
          const SizedBox(
            height: 10,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              WidsManager().getText("Gnome Shell",fontWeight: ThemeDt.boldText),
              Row(
                children: [
                  PopupMenuButton(
                      tooltip: "",
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                      color: Colors.transparent,
                      elevation: 0,
                      itemBuilder: (BuildContext context) {
                        return [
                          PopupMenuItem(enabled: false,child:
                          WidsManager().getContainer(blur: true,
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  for (int i = 0;
                                  i < ThemeManager.GTKThemeList.length;
                                  i++)
                                    if (ThemeManager.themeSupport[
                                    ThemeManager.GTKThemeList[i]]?["shell"] ??
                                        false)
                                      Padding(
                                        padding: const EdgeInsets.all( 4.0),
                                        child:GestureDetector(
                                          onTap: () async {
                                            Navigator.pop(context);
                                            await ThemeDt().setShell(
                                                ThemeManager.GTKThemeList[i]
                                                    .split("/")
                                                    .last,
                                                context);
                                            AppData.DataFile.remove("AUTOTHEMECOLOR");
                                            setState(() {});
                                          },
                                          child: WidsManager().getText(ThemeManager
                                              .GTKThemeList[i]
                                              .split("/")
                                              .last),
                                        ),
                                      ),]
                            ),
                          ),
                          )];
                      },
                      child:  WidsManager().getContainer(
                          width: (MediaQuery.sizeOf(context).width / 3)+(TabManager.isLargeScreen?0:60),
                          child: WidsManager()
                              .getText(ThemeDt.ShellName, maxLines: 1)),
                  ),

                  const SizedBox(
                    width: 10,
                  ),
                  GetButtons(
                    onTap: () async {
                      String fle =
                          "${SystemInfo.home}/.themes/${ThemeDt.ShellName}/gnome-shell/gnome-shell.css";
                      File fl = File(fle);
                      if (!(await fl.exists())) {
                        WidsManager().showMessage(
                            title: "Error",
                            message:
                                "Only locally installed themes can be edited. Please download and install a theme if you don't have any local user themes.",
                            context: context);
                        return;
                      }
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ChangeColors(
                                  filePath: fle,
                                  state: widget.state,
                                  update: false)));
                    },
                    light: true,
                    child: Icon(
                      Icons.edit_rounded,
                      color: ThemeDt.themeColors["fg"],
                      size: 21,
                    ),
                  ),
                ],
              )
            ],
          ),
          const SizedBox(
            height: 10,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              WidsManager().getText("Toggle Dark Mode",fontWeight: ThemeDt.boldText),
              WidsManager().getTooltip(

                text:
                    "This does not relate to system-wide dark or light mode. This simply means which css file the app would use to theme its colour - gtk.css or gtk-dark.css",
                child: GetToggleButton(value: isDark,
                  onTap: () async {
                    isDark = !isDark;
                    await ThemeDt()
                        .setTheme(respectSystem: false, dark: isDark);
                    widget.state();
                  },
                ),
              ),
            ],
          ),
          SizedBox(height: 10,),
          Align(
              alignment: Alignment.bottomRight,
              child: GetButtons(
                onTap: () async {
                  FilePickerResult? result =
                      await FilePicker.platform.pickFiles();

                  if (result != null) {
                    Navigator.push(context, MaterialPageRoute(builder: (context)=>ChangeColors(filePath: result.files.single.path!, state: widget.state, isDefinedFile:true, update: false,)));
                  }
                  },

                text: "Open CSS file", light: true,pillShaped: true,))
        ],
      ),
    );
  }

  Future<void> setAdaptiveTheme() async {

     if(AppData.DataFile["AUTOTHEMECOLOR"]!=null){
       showDialog(context: context,barrierColor: Colors.transparent, builder: (BuildContext context) {
         return AnimatedBlurryContainer(
           blur: 15,
           child: Center(
             child: WidsManager().getText("Applying Background Colour...", size: 20),
           ),);
       }, );
       setState(() {
       settingColour=true;
     });

      // await Future.delayed(Duration(seconds: 1));

      await AdaptiveTheming().genColours( context);

       globalAppliedThemePath = await ThemeDt().getGTKThemePath();
       ThemeDt.isThemeFolderMade = await ThemeManager().populateThemeList();
       globalAppliedTheme = globalAppliedThemePath.split("/").last;
      try{
        if (AdaptiveTheming
                .paletteColours
                .values
                .length <=
            AppData.DataFile[
                "AUTOTHEMECOLOR"]) {
          AppData.DataFile[
                  "AUTOTHEMECOLOR"] =
              "max";
          AppData()
              .writeDataFile();
        }
      }catch(e){
        print(e);
        //skip
      }
      await AdaptiveTheming().makeThemeAdaptive(filePath: globalAppliedThemePath, active: 0);
       //await Future.delayed(Duration(seconds: 1));
       AppData.DataFile["AUTOTHEMECOLOR"]=0;
       await AppData().writeDataFile();
       settingColour=false;
       Navigator.pop(context);
       widget.state();
      // await Future.delayed(const Duration(milliseconds: 600));
      // ThemeDt.d=const Duration(milliseconds: 300);
    }
  }


  Future<void> chooseAlbum() async {
    String? selectedDirectory = await FilePicker.platform.getDirectoryPath();

    if (selectedDirectory != null) {
      await getWallList(path: selectedDirectory);
      await ThemeDt().setWallpaper(wallList.first.path);
      wall = await WidsManager().getWallpaperSample();
      await setAdaptiveTheme();
      widget.state();
    }
  }
}
