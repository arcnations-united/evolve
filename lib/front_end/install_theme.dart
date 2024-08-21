import 'dart:io';
import 'package:flutter/material.dart';
import 'package:gtkthememanager/theme_manager/gtk_to_theme.dart';
import 'package:gtkthememanager/theme_manager/gtk_widgets.dart';
import 'package:process_run/process_run.dart';

import '../back_end/gtk_theme_manager.dart';

class Installer extends StatefulWidget {
  final Function() state;
  const Installer({super.key, required this.state});

  @override
  State<Installer> createState() => _InstallerState();
}

class _InstallerState extends State<Installer> {
  List<Directory> dirList = [];
  List<String> nameList = [];
  List<int> isTheme = [];
  final gridControl = ScrollController();
  late Directory currentDir;
  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }
  @override
  void initState() {
    // TODO: implement initState

    currentDir = Directory(SystemInfo.home);
    listDirs();
    super.initState();
  }
  filterList(){
    List<Directory> filteredDirList = [];
    List<String> filteredNameList = [];
    List<int> filteredIsThemeList = [];
    for (int i=0;i<nameList.length;i++){
      try {
        if(isTheme[i]>0){
          filteredNameList.add(nameList[i]);
          filteredDirList.add(dirList[i]);
          filteredIsThemeList.add(isTheme[i]);
        }
      } catch (e) {
        continue;
      }
    }
    isTheme=filteredIsThemeList;
    dirList=filteredDirList;
    nameList=filteredNameList;
  }
  listDirs() async {
    dirList = [];
    nameList = [];
    isTheme = [];
    List s = currentDir.listSync();
    for (var lst in s) {
      try {
        Directory d = lst;
        dirList.add(Directory(d.path));
        nameList.add(d.path.split("/").last);
        isTheme.add(await SystemInfo().isTheme(d.path));
      } catch (e) {
        continue;
      }
    }
    if(filter){
      filterList();
    }
    setState(() {});
  }
  bool filter=false;
  double topBarHt = 70;
  double dockWd = 20;
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(12), bottomRight: Radius.circular(12)),
      child: Scaffold(
        backgroundColor: ThemeDt.themeColors["bg"],
        body: Column(
          children: [

            Padding(
              padding: const EdgeInsets.all(8.0),
              child: WidsManager().getContainer(
                blur: true,

                height: topBarHt,
                pad: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Row(
                      children: [
                        AnimatedPadding(
                          duration: ThemeDt.d,
                          curve: ThemeDt.c,
                          padding:  const EdgeInsets.only(left: 8, right: 10),
                          child: GetButtons(onTap: (){
                            currentDir=currentDir.parent;
                            listDirs();
                          },light: true,
                            ltVal: 1.23, child: Icon(Icons.arrow_back_ios_new_rounded, size: 10, color: ThemeDt.themeColors["fg"],),),
                        ),
                        WidsManager().getContainer(
                          pad: 5,
                          blur: true,
                          width: MediaQuery.sizeOf(context).width/2,
                          child: WidsManager().getText(
                              currentDir.path
                          ),
                        ),
                      ],
                    ), GetButtons(
                      onTap: () {
                        if (currentDir.path != SystemInfo.home) {
                          currentDir = Directory(SystemInfo.home);
                          listDirs();
                        }
                      },
                      light: true,
                      ltVal: 1.25,
                      ghost: currentDir.path == SystemInfo.home,
                      child: Row(
                        children: <Widget>[
                          Icon(
                            Icons.home_rounded,
                            color: ThemeDt.themeColors["fg"],
                          )
                        ],
                      ),
                    ),
                    GetButtons(
                      onTap: () {
                        if (currentDir.path !=
                            "${SystemInfo.home}/Documents") {
                          currentDir =
                              Directory("${SystemInfo.home}/Documents");
                          listDirs();
                        }
                      },
                      light: true,
                      ltVal: 1.25,
                      ghost:
                      currentDir.path == "${SystemInfo.home}/Documents",
                      child: Row(
                        children: <Widget>[
                          Icon(
                            Icons.file_present_rounded,
                            color: ThemeDt.themeColors["fg"],
                          )
                        ],
                      ),
                    ),
                    GetButtons(
                      onTap: () {
                        if (currentDir.path !=
                            "${SystemInfo.home}/Downloads") {
                          currentDir =
                              Directory("${SystemInfo.home}/Downloads");
                          listDirs();
                        }
                      },
                      light: true,
                      ltVal: 1.25,
                      ghost:
                      currentDir.path == "${SystemInfo.home}/Downloads",
                      child: Row(
                        children: <Widget>[
                          Icon(
                            Icons.download_rounded,
                            color: ThemeDt.themeColors["fg"],
                          )
                        ],
                      ),
                    ),
                    GetButtons(
                      onTap: () {
                        if (currentDir.path != "/") {
                          currentDir = Directory("/");
                          listDirs();
                        }
                      },
                      light: true,
                      ltVal: 1.25,
                      ghost: currentDir.path == "/",
                      child: Row(
                        children: <Widget>[
                          Icon(
                            Icons.lock,
                            color: ThemeDt.themeColors["fg"],
                          )
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        GetButtons(onTap: (){
                          filter=!filter;
                          listDirs();
                          setState(() {

                          });
                        }, ghost: filter,light: true,
                          ltVal: 1.23, child: Icon((filter)?Icons.filter_alt_rounded:Icons.filter_alt_off_rounded, size: 10, color: ThemeDt.themeColors["fg"],),),
                        AnimatedPadding(
                          duration: ThemeDt.d,
                          curve: ThemeDt.c,
                          padding:  EdgeInsets.only(right: (topBarHt==40)?4.0:8, left: 4),
                          child: GetButtons(onTap: () async {
                            Navigator.pop(context);
                            await ThemeManager().populateThemeList();
                            widget.state();
                          },light: true,
                            ltVal: 1.23, child: Icon(Icons.close_rounded, size: 10, color: ThemeDt.themeColors["fg"],),),
                        ),
                      ],
                    ),

                  ],
                ),
              ),
            ),
            Expanded(
              child: Row(
                children: [

                  (dirList.isEmpty)?
                  Padding(
                    padding:  EdgeInsets.only(left: MediaQuery.sizeOf(context).width/3.5),
                    child:WidsManager().getText("Nothing to see here!", size: MediaQuery.sizeOf(context).width/30),
                  )
                      :  Expanded(
                    child: GridView.builder(
                      controller: gridControl,
                      itemCount: nameList.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount:
                        (MediaQuery.sizeOf(context).width / 120).floor(),

                      ),
                      itemBuilder: (BuildContext context, int index,) {

                        try {
                          Directory dir = dirList[index];

                          return GetButtons(
                            moreResponsive: true,
                            onTap: () {
                              if(isTheme[index]==0)  {
                                setState(() {
                                  currentDir = dir;
                                  listDirs();
                                });
                              }else {
                                WidsManager().showMessage(title: "Info", message: "Are you sure you want to install this theme/icon-pack?", context: context,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children:<Widget>[
                                      GetButtons(onTap: (){
                                        Navigator.pop(context);
                                      }, text: "Close",),
                                      const SizedBox(width: 8,),
                                      GetButtons(ghost : true,onTap: (){
                                        Navigator.pop(context);
                                        install(index);
                                      }, text: "Install",),
                                    ],
                                  ),
                                );
                              }
                            },
                            child: Column(
                              children: <Widget>[
                                Icon(
                                  (isTheme[index]==0)
                                      ? Icons.folder_rounded
                                      : (isTheme[index]==1)?Icons.format_paint_rounded:Icons.app_registration_rounded,
                                  size: 50,
                                  color: ThemeDt.themeColors["fg"],
                                ),
                                WidsManager().getText(nameList[index], maxLines: 2,
                                    size: 10, center: true)
                              ],
                            ),
                          );
                        } catch (e) {
                          return GetButtons(
                              onTap: () {
                                WidsManager().showMessage(
                                    title: "Info",
                                    message:
                                    "I know about this issue. Will fix this. :)",
                                    context: context);
                              },
                              moreResponsive: true,
                              child: WidsManager()
                                  .getText("Error. Click to know more."));
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  void install(index)async{
    try {
      Directory ico = Directory("${SystemInfo.home}/.icons");
      Directory thms = Directory("${SystemInfo.home}/.themes");
      if(isTheme[index]==1){
        if(!(await thms.exists())){
          await thms.create(recursive: true);
        }
        await Shell().run("""cp -r '${dirList[index].path}' '${thms.path}'""");
      }
      else if(isTheme[index]==2){
        if(!(await ico.exists())){
          await ico.create(recursive: true);
        }
        await Shell().run("""cp -r '${dirList[index].path}' '${ico.path}'""");
      }

        WidsManager().showMessage(title: "Success!", message: "Installed Successfully. Please restart the app for everything to function normally. Remember, icon themes often depend on other icon-packs, install all of them under one pack to avoid corruption.", context: context);
    } catch (e) {

        WidsManager().showMessage(title: "Error", message: "Installation was unsuccessful", context: context);
    }
  }
}
