import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';
import 'package:card_swiper/card_swiper.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../back_end/app_data.dart';
import '../back_end/gtk_theme_manager.dart';
import '../front_end/at_plus_preview.dart';
import '../front_end/edit_colours.dart';
import '../theme_manager/atplus_themes.dart';
import '../theme_manager/gtk_to_theme.dart';
import '../theme_manager/gtk_widgets.dart';
import '../theme_manager/tab_manage.dart';
import 'package:process_run/process_run.dart';

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

  bool settingColour = false;

  String globalAppliedThemePath = "";
  String globalAppliedTheme = "";
  List wallList = [];
  List<Color> oldCol = [];
  List<Color> col = [];
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
      print(
          "Directory listing fails when you have never installed any premium theme pack from AT, Patreon. You may ignore this.");
    }
    ThemeDt.ThemeNamePath = globalAppliedThemePath;
    setState(() {
      opacity = 1.0;
    });
  }
  final Map<String, Uint8List> _thumbnailCache = {};

  Future<Uint8List> _getResizedImage(String path) async {
    if (_thumbnailCache.containsKey(path)) {
      return _thumbnailCache[path]!;
    }
    final resizedImage = await getResizedImage(path); // Your resizing logic
    _thumbnailCache[path] = resizedImage;
    return resizedImage;
  }

  Future<Uint8List> getResizedImage(String path) async {
    final file = File(path);
    final bytes = await file.readAsBytes();
    final codec = await instantiateImageCodec(bytes, targetHeight: 180); // Resize dimensions
    final frame = await codec.getNextFrame();
    final resizedImage = await frame.image.toByteData(format: ImageByteFormat.png);
    return resizedImage!.buffer.asUint8List();
  }
  bool activeAT = false;
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

  bool largeAlbum = false;
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
            height: (largeAlbum)
                ? MediaQuery.sizeOf(context).height / 2
                : MediaQuery.sizeOf(context).height / 3.8,
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
                        widget.state();
                      }
                    },
                    child: AnimatedContainer(
                            duration: ThemeDt.d,
                            curve: ThemeDt.c,
                            width: (largeAlbum)
                                ? 100
                                : MediaQuery.sizeOf(context).width / 3,
                            child: wall)
                        .animate(
                            effects: [FadeEffect(delay: 100.milliseconds)]),
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
                              colour: index == 0 ? "altbg" : "fg",
                              opacity: index == 0 ? 1.0 : 0.1,
                              child: (index == 0)
                                  ? Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            WidsManager().getText("Album",
                                                fontWeight: ThemeDt.boldText),
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
                                            const SizedBox(
                                              width: 10,
                                            ),
                                            GestureDetector(
                                                onTap: () async {
                                                  setState(() {
                                                    largeAlbum = !largeAlbum;
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
                                                        childAspectRatio:
                                                            TabManager
                                                                    .isLargeScreen
                                                                ? 1.3
                                                                : 2,
                                                        crossAxisCount: TabManager
                                                                .isSuperLarge
                                                            ? (MediaQuery.sizeOf(
                                                                            context)
                                                                        .width /
                                                                    250)
                                                                .floor()
                                                            : TabManager
                                                                    .isLargeScreen
                                                                ? 3
                                                                : 1,
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
                                                        widget.state();
                                                      },
                                                      light: true,
                                                      child:  RepaintBoundary(
                                                  child: FutureBuilder<Uint8List>(
                                                  future: _getResizedImage(
                                                    wallList[index].path,
                                                  ),
                                                  builder: (context, snapshot) {
                                                  if (snapshot.connectionState == ConnectionState.done) {
                                                  return ClipRRect(
                                                  borderRadius:
                                                  BorderRadius
                                                      .circular(10),child: Image.memory(snapshot.data!, fit: BoxFit.cover,)).animate(
                                                  effects: [
                                                  FadeEffect(
                                                  duration: 1.seconds
                                                  ),
                                                  SaturateEffect(
                                                    begin: 3,
                                                    end: 1,
                                                    duration: 700.milliseconds,

                                                  ),
                                                  BlurEffect(
                                                  begin: Offset(10, 10),
                                                  delay: 200.milliseconds,
                                                  duration: 3.seconds,
                                                  curve: Curves.easeOutExpo
                                                  ),
                                                  ]
                                                  );
                                                  } else {
                                                  return Container();
                                                  }
                                                  },)));}))])
                                  : MouseRegion(
                                      onEnter: (dt) {
                                        activeAT = true;

                                        setState(() {});
                                      },
                                      onExit: (dt) {
                                        activeAT = false;
                                        setState(() {});
                                      },
                                      child: Wrap(
                                        runSpacing: 5,
                                        spacing: 5,
                                        children: <Widget>[
                                          for (int i = 0;
                                              i < PThemes.themeMap.length;
                                              i++)
                                            GestureDetector(
                                              onTap: () async {
                                                await Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            AtPlusPreview(
                                                              m: PThemes
                                                                  .themeMap
                                                                  .values
                                                                  .elementAt(i),
                                                              i: i,
                                                            )));
                                                await ThemeDt().setTheme();
                                                await ThemeDt().setAppTheme();
                                                setVals();
                                              },
                                              onSecondaryTapDown: (dt) {
                                                showMenu(
                                                    context: context,
                                                    position:
                                                        RelativeRect.fromLTRB(
                                                            dt.globalPosition
                                                                .dx,
                                                            dt.globalPosition
                                                                .dy,
                                                            dt.globalPosition
                                                                .dx,
                                                            dt.globalPosition
                                                                .dy),
                                                    color: Colors.transparent,
                                                    elevation: 0,
                                                    items: [
                                                      PopupMenuItem(
                                                        child: WidsManager()
                                                            .getContainer(
                                                                blur: true,
                                                                child: WidsManager()
                                                                    .getText(
                                                                        "Apply Theme-Pack")),
                                                        onTap: () async {
                                                          WidsManager().notify(
                                                              context,
                                                              message:
                                                                  "Applying Theme-Pack. DO NOT CLOSE THE APPLICATION!");
                                                          File conkyfile = File(
                                                              "${SystemInfo.home}/AT/UID${PThemes.themeMap.keys.elementAt(i)}/conky/weather.sh");

                                                          if (await conkyfile
                                                                  .exists() ==
                                                              false) {
                                                            conkyfile = File(
                                                                "${SystemInfo.home}/AT/UID${PThemes.themeMap.keys.elementAt(i)}/weather.sh");
                                                          }
                                                          if (await conkyfile
                                                              .exists()) {
                                                            String s =
                                                                await conkyfile
                                                                    .readAsString();
                                                            if (s
                                                                    .substring(
                                                                        s.indexOf("wget") +
                                                                            4,
                                                                        s.indexOf(
                                                                            "-O"))
                                                                    .contains(
                                                                        "-q") ==
                                                                false) {
                                                              List m = s.split(
                                                                  "wget");
                                                              s = "${m[0]}wget -q${m[1]}";
                                                              conkyfile
                                                                  .writeAsString(
                                                                      s);
                                                            }
                                                          }
                                                          Shell(
                                                                  throwOnError:
                                                                      false)
                                                              .run(
                                                                  """bash -c 'cd ${SystemInfo.home}/AT/UID${PThemes.themeMap.keys.elementAt(i)} && ${PThemes.themeMap.values.elementAt(i)["apply"]}'""");
                                                          if (PThemes
                                                                  .themeMap.keys
                                                                  .elementAt(
                                                                      i) ==
                                                              6) {
                                                            ThemeDt().setWallpaper(
                                                                "${SystemInfo.home}/AT/UID6/w1.jpg");
                                                            await Future
                                                                .delayed(
                                                                    3.seconds);
                                                            Shell().run(
                                                                "bash -c 'cp -r ~/.themes/Evergreen-GTK-AT/gtk-4.0 ~/.config'");
                                                            wall = await WidsManager()
                                                                .getWallpaperSample();
                                                            setState(() {});
                                                          } else if (PThemes
                                                                  .themeMap.keys
                                                                  .elementAt(
                                                                      i) ==
                                                              7) {
                                                            ThemeDt().setWallpaper(
                                                                "${SystemInfo.home}/AT/UID7/wallpaper/w1.png");
                                                            await Future
                                                                .delayed(
                                                                    3.seconds);
                                                            Shell().run(
                                                                "bash -c 'cp -r ~/.themes/Gruvbox-Dark/gtk-4.0 ~/.config'");
                                                            wall = await WidsManager()
                                                                .getWallpaperSample();
                                                            setState(() {});
                                                          } else if (PThemes
                                                                  .themeMap.keys
                                                                  .elementAt(
                                                                      i) ==
                                                              8) {
                                                            ThemeDt().setWallpaper(
                                                                "${SystemInfo.home}/AT/UID8/wallpaper/w1.png");
                                                            await Future
                                                                .delayed(
                                                                    3.seconds);
                                                            Shell().run(
                                                                "bash -c 'cp -r ~/.themes/Evergreen-Mac/gtk-4.0 ~/.config'");
                                                            wall = await WidsManager()
                                                                .getWallpaperSample();
                                                            setState(() {});
                                                          }
                                                          await Future.delayed(
                                                              3.seconds);
                                                          await ThemeDt()
                                                              .setTheme();
                                                          await ThemeDt()
                                                              .setAppTheme();
                                                          setVals();
                                                          widget.state();
                                                          WidsManager().notify(
                                                              context,
                                                              message:
                                                                  "Operation Complete.");
                                                        },
                                                      )
                                                    ]);
                                              },
                                              child: Column(
                                                children: [
                                                  Container(
                                                    width: 120,
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          const BorderRadius.only(
                                                              topLeft: Radius
                                                                  .circular(10),
                                                              topRight: Radius
                                                                  .circular(
                                                                      10)),
                                                      border: Border(
                                                        top: BorderSide(
                                                          color: ThemeDt
                                                              .themeColors[
                                                                  "fg"]!
                                                              .withOpacity(
                                                                  0.26),
                                                        ),
                                                        right: BorderSide(
                                                            color: ThemeDt
                                                                .themeColors[
                                                                    "fg"]!
                                                                .withOpacity(
                                                                    0.26)),
                                                        left: BorderSide(
                                                            color: ThemeDt
                                                                .themeColors[
                                                                    "fg"]!
                                                                .withOpacity(
                                                                    0.26)),
                                                      ),
                                                      gradient: LinearGradient(
                                                        begin:
                                                            Alignment.topLeft,
                                                        end: Alignment
                                                            .bottomRight,
                                                        colors: [
                                                          Color(int.parse(
                                                              "0xff${PThemes.themeMap.values.elementAt(i)['color'][1]}")),
                                                          Color(int.parse(
                                                              "0xff${PThemes.themeMap.values.elementAt(i)['color'][0]}"))
                                                        ],
                                                      ),
                                                    ),
                                                    padding: const EdgeInsets.all(10),
                                                    child:
                                                        WidsManager().getText(
                                                      PThemes.themeMap.values
                                                          .elementAt(
                                                              i)['theme_name']
                                                          .toString(),
                                                    ),
                                                  ),
                                                  Container(
                                                    width: 120,
                                                    decoration: BoxDecoration(
                                                        border: Border(
                                                          bottom: BorderSide(
                                                            color: ThemeDt
                                                                .themeColors[
                                                                    "fg"]!
                                                                .withOpacity(
                                                                    0.26),
                                                          ),
                                                          right: BorderSide(
                                                              color: ThemeDt
                                                                  .themeColors[
                                                                      "fg"]!
                                                                  .withOpacity(
                                                                      0.26)),
                                                          left: BorderSide(
                                                              color: ThemeDt
                                                                  .themeColors[
                                                                      "fg"]!
                                                                  .withOpacity(
                                                                      0.26)),
                                                        ),
                                                        borderRadius:
                                                            const BorderRadius.only(
                                                                bottomRight:
                                                                    Radius
                                                                        .circular(
                                                                            10),
                                                                bottomLeft: Radius
                                                                    .circular(
                                                                        10)),
                                                        color: ThemeDt
                                                            .themeColors["bg"]),
                                                    padding:
                                                        const EdgeInsets.all(
                                                            10),
                                                    child: WidsManager().getText(
                                                        PThemes.themeMap.values
                                                            .elementAt(i)[
                                                                'description']
                                                            .toString(),
                                                        size: 9,
                                                        maxLines: activeAT
                                                            ? null
                                                            : 2),
                                                  ),
                                                ],
                                              ),
                                            )
                                        ],
                                      ),
                                    ),
                            );
                          },
                          itemCount: PThemes.themeMap.isEmpty ? 1 : 2,
                          autoplay: PThemes.themeMap.isNotEmpty
                              ? AppData.DataFile["AUTOPLAY"] ?? true
                              : false,
                        ),
                      ),
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
                  WidsManager()
                      .getText("Global Theme", fontWeight: ThemeDt.boldText),
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
                        PopupMenuItem(
                          enabled: false,
                          child: WidsManager().getContainer(
                            blur: true,
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  for (int i = 0;
                                      i < ThemeManager.GTKThemeList.length;
                                      i++)
                                    if (checkGlobal(
                                        ThemeManager.GTKThemeList[i]))
                                      Padding(
                                        padding: const EdgeInsets.all(4.0),
                                        child: GestureDetector(
                                          onTap: () async {
                                            Navigator.pop(context);
                                            ThemeDt.ThemeNamePath =
                                                ThemeManager.GTKThemeList[i];
                                            await ThemeDt().setTheme(
                                                respectSystem: false,
                                                dark: isDark);
                                            AppData.DataFile.remove(
                                                "AUTOTHEMECOLOR");
                                            widget.state();
                                          },
                                          child: WidsManager().getText(
                                              ThemeManager.GTKThemeList[i]
                                                  .split("/")
                                                  .last,
                                              color: "fg"),
                                        ),
                                      ),
                                  Padding(
                                    padding: const EdgeInsets.all(4.0),
                                    child: GestureDetector(
                                      onTap: () async {
                                        Navigator.pop(context);
                                        ThemeDt.ThemeNamePath = "default";
                                        await ThemeDt().setTheme(
                                            respectSystem: false, dark: isDark);
                                        AppData.DataFile.remove(
                                            "AUTOTHEMECOLOR");
                                        widget.state();
                                      },
                                      child: WidsManager()
                                          .getText("Adwaita", color: "fg"),
                                    ),
                                  ),
                                ]),
                          ),
                        )
                      ];
                    },
                    child: WidsManager().getContainer(
                        width: (ThemeDt.ThemeNamePath != globalAppliedThemePath
                                ? MediaQuery.sizeOf(context).width / 3
                                : MediaQuery.sizeOf(context).width / 3 + 50) +
                            (TabManager.isLargeScreen ? 0 : 60),
                        child: WidsManager().getText(
                            ThemeDt.ThemeNamePath.split("/").last,
                            maxLines: 1)),
                  ),
                  if (ThemeDt.ThemeNamePath != globalAppliedThemePath)
                    const SizedBox(
                      width: 10,
                    ),
                  if (ThemeDt.ThemeNamePath != globalAppliedThemePath)
                    GetButtons(
                      onTap: () async {
                        if (ThemeDt.ThemeNamePath == "default") {
                          globalAppliedTheme = "default";
                        } else {
                          globalAppliedTheme =
                              ThemeDt.ThemeNamePath.split("/").last;
                        }
                        globalAppliedThemePath = ThemeDt.ThemeNamePath;
                        if (AppData.DataFile["FLATPAK"] == true) {
                          await ThemeDt()
                              .setFlatpakTheme(globalAppliedThemePath, context);
                        }
                        await ThemeDt.setGTK3(
                          globalAppliedTheme,
                        );
                        await ThemeDt.setGTK4(
                          globalAppliedThemePath,
                        );
                        await ThemeDt.setShell(
                          globalAppliedTheme,
                        );
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
              WidsManager()
                  .getText("GTK 3.0 Theme", fontWeight: ThemeDt.boldText),
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
                        PopupMenuItem(
                          enabled: false,
                          child: WidsManager().getContainer(
                            blur: true,
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  for (int i = 0;
                                      i < ThemeManager.GTKThemeList.length;
                                      i++)
                                    if (ThemeManager.themeSupport[ThemeManager
                                            .GTKThemeList[i]]?["gtk3"] ??
                                        false)
                                      Padding(
                                        padding: const EdgeInsets.all(4.0),
                                        child: GestureDetector(
                                          onTap: () async {
                                            Navigator.pop(context);
                                            await ThemeDt.setGTK3(
                                              ThemeManager.GTKThemeList[i]
                                                  .split("/")
                                                  .last,
                                            );
                                            AppData.DataFile.remove(
                                                "AUTOTHEMECOLOR");

                                            widget.state();
                                          },
                                          child: WidsManager().getText(
                                              ThemeManager.GTKThemeList[i]
                                                  .split("/")
                                                  .last,
                                              color: "fg"),
                                        ),
                                      ),
                                ]),
                          ),
                        )
                      ];
                    },
                    child: WidsManager().getContainer(
                        width: (MediaQuery.sizeOf(context).width / 3) +
                            (TabManager.isLargeScreen ? 0 : 60),
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
              WidsManager()
                  .getText("GTK 4.0 Theme", fontWeight: ThemeDt.boldText),
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
                          PopupMenuItem(
                            enabled: false,
                            child: WidsManager().getContainer(
                              blur: true,
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    for (int i = 0;
                                        i < ThemeManager.GTKThemeList.length;
                                        i++)
                                      if (ThemeManager.themeSupport[ThemeManager
                                              .GTKThemeList[i]]?["gtk4"] ??
                                          false)
                                        Padding(
                                          padding: const EdgeInsets.all(4.0),
                                          child: GestureDetector(
                                            onTap: () async {
                                              Navigator.pop(context);
                                              await ThemeDt.setGTK4(
                                                ThemeManager.GTKThemeList[i],
                                              );
                                              AppData.DataFile.remove(
                                                  "AUTOTHEMECOLOR");
                                              setState(() {});
                                            },
                                            child: WidsManager().getText(
                                                ThemeManager.GTKThemeList[i]
                                                    .split("/")
                                                    .last),
                                          ),
                                        ),
                                  ]),
                            ),
                          )
                        ];
                      },
                      child: WidsManager().getContainer(
                          width: (MediaQuery.sizeOf(context).width / 3) +
                              (TabManager.isLargeScreen ? 0 : 60),
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
              WidsManager()
                  .getText("Gnome Shell", fontWeight: ThemeDt.boldText),
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
                        PopupMenuItem(
                          enabled: false,
                          child: WidsManager().getContainer(
                            blur: true,
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  for (int i = 0;
                                      i < ThemeManager.GTKThemeList.length;
                                      i++)
                                    if (ThemeManager.themeSupport[ThemeManager
                                            .GTKThemeList[i]]?["shell"] ??
                                        false)
                                      Padding(
                                        padding: const EdgeInsets.all(4.0),
                                        child: GestureDetector(
                                          onTap: () async {
                                            Navigator.pop(context);
                                            await ThemeDt.setShell(
                                              ThemeManager.GTKThemeList[i]
                                                  .split("/")
                                                  .last,
                                            );
                                            AppData.DataFile.remove(
                                                "AUTOTHEMECOLOR");
                                            setState(() {});
                                          },
                                          child: WidsManager().getText(
                                              ThemeManager.GTKThemeList[i]
                                                  .split("/")
                                                  .last),
                                        ),
                                      ),
                                ]),
                          ),
                        )
                      ];
                    },
                    child: WidsManager().getContainer(
                        width: (MediaQuery.sizeOf(context).width / 3) +
                            (TabManager.isLargeScreen ? 0 : 60),
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
              WidsManager()
                  .getText("Toggle Dark Mode", fontWeight: ThemeDt.boldText),
              WidsManager().getTooltip(
                text:
                    "This does not relate to system-wide dark or light mode. This simply means which css file the app would use to theme its colour - gtk.css or gtk-dark.css",
                child: GetToggleButton(
                  value: isDark,
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
          const SizedBox(
            height: 10,
          ),
          Align(
              alignment: Alignment.bottomRight,
              child: GetButtons(
                onTap: () async {
                  FilePickerResult? result =
                      await FilePicker.platform.pickFiles();

                  if (result != null) {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ChangeColors(
                                  filePath: result.files.single.path!,
                                  state: widget.state,
                                  isDefinedFile: true,
                                  update: false,
                                )));
                  }
                },
                text: "Open CSS file",
                light: true,
                pillShaped: true,
              ))
        ],
      ),
    );
  }

  Future<void> chooseAlbum() async {
    String? selectedDirectory = await FilePicker.platform.getDirectoryPath();

    if (selectedDirectory != null) {
      setState(() {
        wall = const CircularProgressIndicator();
      });
      await getWallList(path: selectedDirectory);
      await ThemeDt().setWallpaper(wallList.first.path);
      wall = await WidsManager().getWallpaperSample();

      widget.state();
    }
  }
}
