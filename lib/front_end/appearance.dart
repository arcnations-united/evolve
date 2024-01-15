import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gtkthememanager/back_end/gtk_theme_manager.dart';
import 'package:gtkthememanager/front_end/edit_colours.dart';
import 'package:gtkthememanager/front_end/new_theme.dart';
import 'package:gtkthememanager/theme_manager/gtk_to_theme.dart';
import 'package:gtkthememanager/theme_manager/gtk_widgets.dart';

class Appearances extends StatefulWidget {
  final Function() state;
  const Appearances({super.key, required this.state});

  @override
  State<Appearances> createState() => _AppearancesState();
}

class _AppearancesState extends State<Appearances> {
  bool checkGlobal(name){
    if (!(ThemeManager.themeSupport[name]
    ?["gtk3"] ??
        false)) return false;
    if (!(ThemeManager.themeSupport[name]
    ?["gtk4"] ??
        false)) return false;
    if (!(ThemeManager.themeSupport[name]
    ?["shell"] ??
        false)) return false;
   return true;
  }
  @override
  void initState() {
    setVals();
    super.initState();
  }

  String? globalAppliedTheme;
  setVals() async {
    globalAppliedTheme = await ThemeDt().getGTKThemeName();
     ThemeDt.isThemeFolderMade= await ThemeManager().populateThemeList();

      ThemeDt.GTK3 = globalAppliedTheme ?? "Not Set";
      ThemeDt.ShellName = await ThemeDt().getShellThemeName();
      if(ThemeDt.ShellName=="")ThemeDt.ShellName="Default";
      await ThemeDt().getGTK4ThemeName();
      ThemeDt.ThemeName=globalAppliedTheme!;
      setState(() {
        opacity=1.0;
      });
  }
  double opacity =0.0;
  //ensure smooth transition with controlled opacity
  bool isDark = true;
  @override
  Widget build(BuildContext context) {
    if(!ThemeDt.isThemeFolderMade){
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
                Icon(Icons.warning_rounded, color: ThemeDt.themeColors["fg"],size: 100,),
                WidsManager().getText("Theme folder not found! Create theme folder and unpack themes into\n${SystemInfo.home}/.themes", size: 10, center: true),
                const SizedBox(height: 10,),
                GetButtons(onTap: ()async{
                  Directory theme = Directory("${SystemInfo.home}/.themes");
                  if(!(await theme.exists())){
                    await theme.create();
                  }
                  ThemeDt.IconName="";
                  setVals();
                }, text: "Create theme folder", light: true,)
              ],
            ),
          ),
        ),
      );
    }
    if(ThemeManager.GTKThemeList.isEmpty){
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
                Icon(Icons.warning_rounded, color: ThemeDt.themeColors["fg"],size: 100,),
                WidsManager().getText("No theme(s) installed yet! Unpack themes into\n${SystemInfo.home}/.themes", size: 10, center: true),
                GetButtons(onTap: ()async{
                  setVals();
                }, text: "Refresh", light: true,)

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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  WidsManager().getText("Global Theme"),
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
                                                  globalAppliedTheme ??
                                                      "Fetching...",
                                                  size: 28),
                                              const SizedBox(
                                                height: 10,
                                              ),
                                              Row(
                                                children: [
                                                  if (ThemeManager.themeSupport[
                                                              globalAppliedTheme ??
                                                                  ThemeDt
                                                                      .ThemeName]
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
                                                              globalAppliedTheme ??
                                                                  ThemeDt
                                                                      .ThemeName]
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
                                                              globalAppliedTheme ??
                                                                  ThemeDt
                                                                      .ThemeName]
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
                                                              globalAppliedTheme ??
                                                                  ThemeDt
                                                                      .ThemeName]
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
                                              WidsManager().getText("App Theme"),
                                              WidsManager().getText(
                                                  ThemeDt.ThemeName,
                                                  size: 28),
                                              const SizedBox(
                                                height: 10,
                                              ),
                                              Row(
                                                children: [
                                                  if (ThemeManager.themeSupport[
                                                              ThemeDt.ThemeName]
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
                                                              ThemeDt.ThemeName]
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
                                                              ThemeDt.ThemeName]
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
                                                              ThemeDt.ThemeName]
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
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                    color: ThemeDt.themeColors["sltbg"],
                    elevation: 0,
                    itemBuilder: (BuildContext context) {
                      return [
                        for (int i = 0; i < ThemeManager.GTKThemeList.length; i++)
                          if(checkGlobal(ThemeManager.GTKThemeList[i]))
                          PopupMenuItem(
                              child: Row(
                            children: [
                              Expanded(
                                  child: GetButtons(
                                light: true,
                                ltVal: 1.75,
                                text: ThemeManager.GTKThemeList[i],
                                onTap: () async {
                                  Navigator.pop(context);
                                  ThemeDt.ThemeName = ThemeManager.GTKThemeList[i];
                                  await ThemeDt()
                                      .setTheme(respectSystem: false, dark: isDark);

                                  widget.state();

                                },
                              )),
                            ],
                          ))
                      ];
                    },
                    child: WidsManager().getContainer(
                        child: WidsManager().getText(ThemeDt.ThemeName)),
                  ),
                  const SizedBox(width: 10,),
                  GetButtons(onTap: (){
                    Navigator.push(context, MaterialPageRoute(builder: (context)=>NewTheme(name: ThemeDt.ThemeName,))).then((value) async {
                       setVals();

                    } );
                  },light: true, child: Icon(Icons.add_rounded, color: ThemeDt.themeColors["fg"], size: 21,),),
                  if(ThemeDt.ThemeName!=globalAppliedTheme)  const SizedBox(width: 10,),
                  if(ThemeDt.ThemeName!=globalAppliedTheme)GetButtons(onTap: () async {
                    globalAppliedTheme=ThemeDt.ThemeName;
                    //Passed the context to handle exception messages. Should have done the try-catch here
                    //TODO use try-catch instead of passing context
                    await ThemeDt().setGTK3(globalAppliedTheme, context);
                    await ThemeDt().setGTK4(globalAppliedTheme!, context);
                    await  ThemeDt().setShell(globalAppliedTheme!, context);
                    widget.state();
                  }, light: true, child: Icon(Icons.check_rounded, color: ThemeDt.themeColors["fg"], size: 21,),),
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
              WidsManager().getText("GTK 3.0"),
              Row(
                children: [
                  PopupMenuButton(
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                    color: ThemeDt.themeColors["sltbg"],
                    elevation: 0,
                    itemBuilder: (BuildContext context) {
                      return [
                        for (int i = 0; i < ThemeManager.GTKThemeList.length; i++)
                          if (ThemeManager.themeSupport[ThemeManager.GTKThemeList[i]]
                          ?["gtk3"] ??
                              false)
                            PopupMenuItem(
                                child: Row(
                              children: [
                                Expanded(
                                    child: GetButtons(
                                  light: true,
                                  ltVal: 1.75,
                                  text: ThemeManager.GTKThemeList[i],
                                  onTap: () async { Navigator.pop(context);
                                     await ThemeDt()
                                          .setGTK3(ThemeManager.GTKThemeList[i], context);
                                      widget.state();

                                  },
                                )),
                              ],
                            ))
                      ];
                    },
                    child: WidsManager().getContainer(
                        child: WidsManager().getText(ThemeDt.GTK3)),
                  ),
                  const SizedBox(width: 8,),
                  GetButtons(
                    onTap: (){
                      String fle = "${SystemInfo.home}/.themes/${ThemeDt.GTK3}/gtk-3.0/${(isDark)?"gtk-dark.css":"gtk.css"}";
                      Navigator.push(context, MaterialPageRoute(builder: (context)=>ChangeColors(
                        filePath: fle, state: widget.state,
                      ))).then((value) async {
                        widget.state();
                      });
                    }, light: true,
                    child: Icon(Icons.edit_rounded, color: ThemeDt.themeColors["fg"], size: 21,),),
                ],
              )
            ],
          ),const SizedBox(
            height: 10,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              WidsManager().getText("GTK 4.0"),
              Row(
                children: [
                  PopupMenuButton(
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                    color: ThemeDt.themeColors["sltbg"],
                    elevation: 0,
                    itemBuilder: (BuildContext context) {
                      return [
                        for (int i = 0; i < ThemeManager.GTKThemeList.length; i++)
                          if (ThemeManager.themeSupport[ThemeManager.GTKThemeList[i]]
                                  ?["gtk4"] ??
                              false)
                            PopupMenuItem(
                                child: Row(
                              children: [
                                Expanded(
                                    child: GetButtons(
                                  light: true,
                                  ltVal: 1.75,
                                  text: ThemeManager.GTKThemeList[i],
                                  onTap: () async { Navigator.pop(context);
                                     await ThemeDt()
                                          .setGTK4(ThemeManager.GTKThemeList[i], context);
                                      setState(() {

                                      });

                                  },
                                )
                                ),
                              ],
                            ))
                      ];
                    },
                    child: WidsManager().getContainer(
                        child: WidsManager().getText(ThemeDt.GTK4 ?? "Not Applied")),
                  ),
                  const SizedBox(width: 10,),
                  GetButtons(
                    onTap: (){
                      String fle = "${SystemInfo.home}/.themes/${ThemeDt.GTK4}/gtk-4.0/${(isDark)?"gtk-dark.css":"gtk.css"}";
                      Navigator.push(context, MaterialPageRoute(builder: (context)=>ChangeColors(
                        filePath: fle, state: widget.state,
                      )));
                    }, light: true,
                    child: Icon(Icons.edit_rounded, color: ThemeDt.themeColors["fg"], size: 21,),),

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
              WidsManager().getText("Gnome Shell"),
              Row(
                children: [


                  PopupMenuButton(
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                    color: ThemeDt.themeColors["sltbg"],
                    elevation: 0,
                    itemBuilder: (BuildContext context) {
                      return [
                        for (int i = 0; i < ThemeManager.GTKThemeList.length; i++)
                          if (ThemeManager.themeSupport[ThemeManager.GTKThemeList[i]]
                          ?["shell"] ??
                              false)
                            PopupMenuItem(
                                child: Row(
                                  children: [
                                    Expanded(
                                        child: GetButtons(
                                          light: true,
                                          ltVal: 1.75,
                                          text: ThemeManager.GTKThemeList[i],
                                          onTap: () async { Navigator.pop(context);
                                          await ThemeDt()
                                              .setShell(ThemeManager.GTKThemeList[i], context);
                                          setState(() {

                                          });

                                          },
                                        )),
                                  ],
                                ))
                      ];
                    },
                    child: WidsManager().getContainer(
                        child: WidsManager().getText(ThemeDt.ShellName)),
                  ),
                  const SizedBox(width: 10,),
                  GetButtons(
                    onTap: (){
                      String fle = "${SystemInfo.home}/.themes/${ThemeDt.ShellName}/gnome-shell/gnome-shell.css";
                      Navigator.push(context, MaterialPageRoute(builder: (context)=>ChangeColors(
                        filePath: fle, state: widget.state,   update : false
                      )));
                    }, light: true,
                    child: Icon(Icons.edit_rounded, color: ThemeDt.themeColors["fg"], size: 21,),),
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
              Row(
                children: [
                  WidsManager().getText("Toggle Dark Mode"),
                  IconButton(onPressed: (){
                    WidsManager().showMessage(title: "Info", message: "This does not relate to system-wide dark or light mode. This simply means which css file the app would use to theme its colour - gtk.css or gtk-dark.css",
                        context: context);
                  }, icon: Icon(Icons.info_rounded, color: ThemeDt.themeColors["fg"],)),
                ],
              ),
              GestureDetector(
                onTap: () {
                  isDark = !isDark;
                  ThemeDt().setTheme(respectSystem: false, dark: isDark);
                  widget.state();
                },
                child: Row(
                  children: <Widget>[
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(10),
                            bottomLeft: Radius.circular(10),
                          ),
                          color:
                              ThemeDt.themeColors[(!isDark) ? "altbg" : "sltbg"]),
                      child: WidsManager().getText("Dark"),
                    ),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                          borderRadius: const BorderRadius.only(
                            topRight: Radius.circular(10),
                            bottomRight: Radius.circular(10),
                          ),
                          color:
                              ThemeDt.themeColors[(isDark) ? "altbg" : "sltbg"]),
                      child: WidsManager().getText("Light"),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
