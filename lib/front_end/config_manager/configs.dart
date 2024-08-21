import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gtkthememanager/back_end/app_data.dart';
import 'package:gtkthememanager/front_end/config_manager/apply_config.dart';
import 'package:gtkthememanager/theme_manager/gtk_to_theme.dart';
import 'package:gtkthememanager/theme_manager/gtk_widgets.dart';
import 'package:process_run/process_run.dart';

import '../../theme_manager/tab_manage.dart';

class ConfigPage extends StatefulWidget {
  final Function state;
  const ConfigPage({super.key, required this.state});

  @override
  State<ConfigPage> createState() => _ConfigPageState();
}

class _ConfigPageState extends State<ConfigPage> {
  GlobalKey key = GlobalKey();
  Map dt = {};
  @override
  void initState() {
   checkifActive();
    // TODO: implement initState
    dt = AppData.DataFile["confData"] ??
        {"theme": true, "icon": true, "exts": true, "at+": true, "wal": true};
    if (dt.isEmpty) {
      dt = {
        "theme": true,
        "icon": true,
        "exts": true,
        "at+": true,
        "wal": true
      };
    }
    super.initState();
  }
bool filePresent=true;
  checkifActive() async {
    try {

      Directory dir=Directory(AppData.DataFile["backUPLoc"]);
      if(dir.existsSync()==false){
        await dir.create(recursive: true);
      } setState(() {
        filePresent=true;
      });
    }  catch (e) {

      setState(() {
        filePresent=false;
      });
    }
  }
  @override
  void dispose() {
    // TODO: implement dispose
    AppData.DataFile["confData"] = dt;
    AppData().writeDataFile();
    super.dispose();
  }

  bool backup = false;
  bool applyload = false;
  GlobalKey k1 = GlobalKey();
  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.sizeOf(context).height-70,
      child: Column(
        //crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: TabManager.isSuperLarge?900.0:MediaQuery.sizeOf(context).width-((TabManager.isLargeScreen)?170:0),

            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(40),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: ThemeDt.themeColors["fg"]?.withOpacity(0.04),
                  ),
                  child: Icon(
                   filePresent? Icons.file_present_rounded:Icons.highlight_off_rounded,
                    size: 100,
                    color: filePresent?ThemeDt.themeColors["fg"]?.withOpacity(0.8):Colors.red.withOpacity(0.8),
                  ),
                ),
                const SizedBox(
                  width: 30,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    WidsManager().getText("config.zip", size: 25),
                    Container(
                      width: MediaQuery.sizeOf(context).width / 3,
                      key: k1,
                      child: AdaptiveList(
                        parentKey: k1,
                        space: 0,
                        children: [
                          WidsManager().getText("last updated : ", size: 11),
                          WidsManager().getText(
                              "${AppData.DataFile["lastBackUp"] ?? "never"}",
                              size: 11),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    Container(
                      width: MediaQuery.sizeOf(context).width / 3,
                      key: key,
                      child: AnimatedCrossFade(
                        duration: ThemeDt.d,
                        crossFadeState: (applyload || backup)
                            ? CrossFadeState.showFirst
                            : CrossFadeState.showSecond,
                        firstChild: BackingUP(),
                        secondChild: AdaptiveList(parentKey: key, children: [
                          WidsManager().getTooltip(
                            text:
                                filePresent?
                                "Backup current theme, wallpaper, icon packs, extensions and more to seamlessly apply them on freshly installed systems.":
                            "Check again if config directory is reachable."
                            ,
                            child: ElevatedButton(
                                onPressed: () async {
                             if(filePresent) {

                                    if(AppData.DataFile["bgUpdateBackup"] ?? false){
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: WidsManager().getText('Updating in background. DO NOT CLOSE THE APP!', color: "bg", fontWeight: FontWeight.bold),
                                        ),
                                      );
                                      Isolate.run(BackUpRunner.run());
                                    }
                                    else {
                                      backup = true;
                                      TabManager.freeze=true;
                                      widget.state();
                                      await runBackUp();
                                    }

                                      backup = false;
                                    TabManager.freeze=false;
                                    widget.state();

                                  }else{
                               checkifActive();
                             }
                                },
                                child: WidsManager().getText(filePresent?"Run Backup":"Refresh Loc.")),
                          ),
                          WidsManager().getTooltip(
                            text:
                                "Apply config.zip to the system. Launches the file picker to select the file.",
                            child: ElevatedButton(
                                onPressed: () async {
                                  FilePickerResult? result =
                                      await FilePicker.platform.pickFiles();
                                  if (result != null) {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => ApplyConfig(
                                                  path: result.files.single.path ??
                                                      "",
                                                  state: widget.state,
                                                )));
                                  }
                                },
                                child: WidsManager().getText("Apply Config")),
                          ),
                        ]),
                      ),
                    )
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 30,
          ),
          Container(
            height: (MediaQuery.sizeOf(context).height/1.7),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    IgnorePointer(
                      ignoring: !filePresent,
                      child: AnimatedOpacity(
                        duration: ThemeDt.d,
                        opacity: filePresent?1:0.4,
                        child: WidsManager().gtkColumn(
                            width: TabManager.isSuperLarge?900.0:MediaQuery.sizeOf(context).width-((TabManager.isLargeScreen)?170:0),
              
              
                            title: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                WidsManager()
                                    .getText("Backup Data", fontWeight: ThemeDt.boldText),
                                WidsManager().getText(
                                  "Select which of the following you want to backup",
                                  color: "altfg",
                                ),
                                const SizedBox(
                                  height: 13,
                                )
                              ],
                            ),
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  WidsManager().getText("Installed Themes"),
                                  GetToggleButton(
                                    value: dt["theme"],
                                    onTap: () {
                                      setState(() {
                                        dt["theme"] = !dt["theme"];
                                      });
                                    },
                                  )
                                ],
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  WidsManager().getText("Installed Icons"),
                                  GetToggleButton(
                                    value: dt["icon"],
                                    onTap: () {
                                      setState(() {
                                        dt["icon"] = !dt["icon"];
                                      });
                                    },
                                  )
                                ],
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  WidsManager().getText("Installed Extensions"),
                                  GetToggleButton(
                                    value: dt["exts"],
                                    onTap: () {
                                      setState(() {
                                        dt["exts"] = !dt["exts"];
                                      });
                                    },
                                  )
                                ],
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  WidsManager().getText("AT+ Themes"),
                                  GetToggleButton(
                                    value: dt["at+"],
                                    onTap: () {
                                      setState(() {
                                        dt["at+"] = !dt["at+"];
                                      });
                                    },
                                  )
                                ],
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  WidsManager().getText("Wallpaper Album"),
                                  GetToggleButton(
                                    value: dt["wal"],
                                    onTap: () {
                                      setState(() {
                                        dt["wal"] = !dt["wal"];
                                      });
                                    },
                                  )
                                ],
                              ),
                            ]),
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    WidsManager().gtkColumn(
                        width: TabManager.isSuperLarge?900.0:MediaQuery.sizeOf(context).width-((TabManager.isLargeScreen)?170:0),
              
                        title: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            WidsManager()
                                .getText("More options", fontWeight: ThemeDt.boldText),
                            WidsManager().getText(
                              "Some more available options",
                              color: "altfg",
                            ),
                            const SizedBox(
                              height: 13,
                            )
                          ],
                        ),
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              WidsManager().getText("Update Location : ${AppData.DataFile["backUPLoc"]}"),
                              IconButton(
                                  onPressed: () async {
                                    String? selectedDirectory =
                                    await FilePicker.platform.getDirectoryPath(initialDirectory:(filePresent)? AppData.DataFile["backUPLoc"]:SystemInfo.home);
                                    if (selectedDirectory != null) {
              
                                      setState(() {
                                        AppData.DataFile["backUPLoc"] = selectedDirectory;
                                      });
                                      await AppData().writeDataFile();
                                      checkifActive();
                                    }
                                  },
                                  icon: const Icon(Icons.chevron_right))
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              WidsManager().getText("Auto-Run Backup"),
                              GetToggleButton(
                                value: AppData.DataFile["autoUpdateBackup"] ?? false,
                                onTap: () {
                                  setState(() {
                                    AppData.DataFile["autoUpdateBackup"] ??= false;
                                    AppData.DataFile["autoUpdateBackup"] = !AppData.DataFile["autoUpdateBackup"];
                                  });
                                },
                              )
                            ],
                          ),WidsManager().getTooltip(
                            text: "Update the config in the background while keeping the app usable. DON'T CLOSE THE APP WHILE UPDATING!",
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                WidsManager().getText("Background update"),
                                GetToggleButton(
                                  value: AppData.DataFile["bgUpdateBackup"] ?? false,
                                  onTap: () {
                                    setState(() {
                                      AppData.DataFile["bgUpdateBackup"] ??= false;
                                      AppData.DataFile["bgUpdateBackup"] = !AppData.DataFile["bgUpdateBackup"];
                                    });
                                  },
                                )
                              ],
                            ),
                          ),
                        ]),
                    SizedBox(height: 15,),
                    GestureDetector(
                      onTap: (){
                        WidsManager().showMessage(title: "Info", message: "With the v1.5+ releases, configurations are created more securely and efficiently.\n\nHowever, making the algorithm public would compromise its effectiveness. To access the latest release and export configurations for daily use, visit our Patreon page.", context: context);
                      },
                      child: Container(
                        color: Colors.white.withOpacity(0.001),
                        child: Row(
                          children: [
                            Icon(Icons.info_outline, color: ThemeDt.themeColors["altfg"], size: 16,),
                            WidsManager().getText("   This page is no more maintained")
                          ],
                        ),
                      ),
                    )

                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget BackingUP() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LinearProgressIndicator(
          color: Colors.white,
          value: vl,
        ),
        const SizedBox(
          height: 2,
        ),
        WidsManager().getText(txt)
      ],
    );
  }

  String txt = "";
  double vl = 0.0;
  String backUPLoc = "${SystemInfo.home}/.NexData/Evolve";
  String backUPFile = "${SystemInfo.home}/.NexData/Evolve/config.zip";
  runBackUp() async {
    try {
      Directory dir=Directory("${AppData.DataFile["backUPLoc"]}");
      if(await dir.exists()==false){
        await dir.create(recursive: true);
      }
    }  catch (e) {
      setState(() {
        filePresent=false;
      });
      return;
    }

    DateTime time = DateTime.now();
    AppData.DataFile["lastBackUp"] =
        "${time.day}-${time.month}-${time.year} at ${(time.hour).toString().length < 2 ? "0${time.hour}" : time.hour}:${(time.minute).toString().length < 2 ? "0${time.minute}" : time.minute}";
    AppData().writeDataFile();
    setState(() {
      txt = "backing up - ${(vl * 100).round()}%";
    });
    conf["avail"] = dt;
    Directory dir1 = Directory("$backUPLoc/bckup");
    if (!(await dir1.exists())) {
      await dir1.create(recursive: true);
    } else {
      await dir1.delete(recursive: true);
      await dir1.create(recursive: true);
    }

    for (int i = 0; i < dt.length; i++) {
      setState(() {
        vl = (i) / dt.length;
        txt = "backing up - ${(vl * 100).round()}%";
      });
      if (dt.values.elementAt(i) == true) {
        String key = dt.keys.elementAt(i);
        if (key == "theme") {
          await BackUpRunner.backupTheme(backUPLoc);
        }
        if (key == "icon") {
          await BackUpRunner.backupIco(backUPLoc);
        }
        if (key == "at+") {
          await BackUpRunner.backupAt(backUPLoc);
        }

        if (key == "exts") {
          await BackUpRunner.extBackup();
        }
      }if (dt.keys.elementAt(i) == "wal") {
        await BackUpRunner.backupWal(backUPLoc,dt.values.elementAt(i)  );
      }
    }

    await BackUpRunner.miscBackUP(backUPLoc,backUPFile,);
    setState(() {
      vl = 1;
      txt = "Done! File saved successfully.";
    });

    await Future.delayed(1.seconds);
    vl = 0;
  }


}
Map conf={};
class BackUpRunner{
  static run() async{
    try {
      Directory dir=Directory("${AppData.DataFile["backUPLoc"]}");
      if(await dir.exists()==false){
        await dir.create(recursive: true);
      }
    }  catch (e) {
      return;
    }
    Map dt={};
    dt = AppData.DataFile["confData"] ??
        {"theme": true, "icon": true, "exts": true, "at+": true, "wal": true};
    if (dt.isEmpty) {
      dt = {
        "theme": true,
        "icon": true,
        "exts": true,
        "at+": true,
        "wal": true
      };
    }

    String backUPLoc="${SystemInfo.home}/.NexData/Evolve";
    String backUPFile="${SystemInfo.home}/.NexData/Evolve/config.zip";
    Directory dir1 = Directory("$backUPLoc/bckup");
    if (await dir1.exists()) {
      await dir1.delete(recursive: true);
    }
      await dir1.create(recursive: true);
    for (int i = 0; i < dt.length; i++) {


      if (dt.values.elementAt(i) == true) {


        String key = dt.keys.elementAt(i);

        if (key == "theme") {
          await backupTheme(backUPLoc);
        }
        if (key == "icon") {
          await backupIco(backUPLoc);
        }
        if (key == "at+") {
          await backupAt(backUPLoc);
        }
        if (key == "exts") {
          await extBackup();
        }
      }
      if (dt.keys.elementAt(i) == "wal") {
        await BackUpRunner.backupWal(backUPLoc,dt.values.elementAt(i)  );
      }
    }
    miscBackUP(backUPLoc, backUPFile);
      DateTime time = DateTime.now();
      AppData.DataFile["lastBackUp"] =
      "${time.day}-${time.month}-${time.year} at ${(time.hour).toString().length < 2 ? "0${time.hour}" : time.hour}:${(time.minute).toString().length < 2 ? "0${time.minute}" : time.minute}";
      AppData().writeDataFile();
  }
 static Future<void> extBackup() async {
    String s = (await Shell()
        .run("dconf read /org/gnome/shell/enabled-extensions"))
        .outText;
    s = s
        .substring(1, s.length - 1)
        .replaceAll("[", "")
        .replaceAll("]", "");
    List extensions = s.split(',');
    conf["exts"] = extensions.toString();
  }

  static Future<void> miscBackUP(backUPLoc,backUPFile,) async {
    Directory gtk4 = Directory("${SystemInfo.home}/.config/gtk-4.0");
    if (gtk4.existsSync()) {
      await Shell().run("bash -c 'cp -r ${gtk4.path} $backUPLoc/bckup'");
    }
    conf["appdata"] = jsonDecode(
        await File("${SystemInfo.home}/.NexData/Evolve/data.json")
            .readAsString());
    conf["appliedGTK3"] = (await Shell()
        .run("gsettings get org.gnome.desktop.interface gtk-theme"))
        .outText
        .replaceAll("'", "");

    conf["appliedIcon"] = (await Shell()
        .run("gsettings get org.gnome.desktop.interface icon-theme"))
        .outText
        .replaceAll("'", "");
    conf["appliedSHELL"] = (await Shell()
        .run("dconf read /org/gnome/shell/extensions/user-theme/name"))
        .outText
        .replaceAll("'", "");
    File fl = File("${SystemInfo.home}/.NexData/Evolve/bckup/config.evolve");
    await fl.writeAsString(jsonEncode(conf));
    if(File("$backUPLoc/config.zip").existsSync())await File("$backUPLoc/config.zip").delete();
    await Shell().run("bash -c 'cd $backUPLoc && zip -r config.zip bckup' ");
    await Directory("$backUPLoc/bckup").delete(recursive: true);

    File fle=File("${AppData.DataFile["backUPLoc"]}/config.zip");
    if(await fle.exists()){
      await fle.delete();
    }

    File flFinal=File(backUPFile);
    File flNew=File("${AppData.DataFile["backUPLoc"]}/config.zip");
    await flNew.writeAsBytes((await flFinal.readAsBytes()));
  }
  static backupTheme(backUPLoc) async {
    //TODO add more backup locations
    List locations = [
      "${SystemInfo.home}/.themes",
    ];

    for (int i = 0; i < locations.length; i++) {
      Directory dir = Directory(locations[i]);
      if (await dir.exists()) {
        //await Shell().run("bash -c 'cp -r ${locations[i]} ${backUPLoc}/bckup'");

        await Shell().run("bash -c 'rsync -avh --progress ${locations[i]} $backUPLoc/bckup'");
      }
    }
  }
  static backupIco(backUPLoc) async {
    //TODO add more backup locations
    List locations = [
      "${SystemInfo.home}/.icons",
    ];

    for (int i = 0; i < locations.length; i++) {
      Directory dir = Directory(locations[i]);
      if (await dir.exists()) {
        await Shell().run("bash -c 'cp -r ${locations[i]} $backUPLoc/bckup'");
      }
    }
  }
  static backupAt(backUPLoc) async {
    //TODO add more backup locations
    List locations = [
      "${SystemInfo.home}/AT",
    ];

    for (int i = 0; i < locations.length; i++) {
      Directory dir = Directory(locations[i]);
      if (await dir.exists()) {
        await Shell().run("bash -c 'cp -r ${locations[i]} $backUPLoc/bckup'");
      }
    }
  }
  static backupWal(backUPLoc,wl) async {
    //TODO add more backup locations
    String picLight = (await Shell()
        .run("gsettings get org.gnome.desktop.background picture-uri"))
        .outText
        .replaceAll("'", "")
        .replaceAll("file://", "");
    String picDark = (await Shell()
        .run("gsettings get org.gnome.desktop.background picture-uri"))
        .outText
        .replaceAll("'", "")
        .replaceAll("file://", "");
    File imgLight = File(picLight);
    File imgDark = File(picDark);

    List locations = [imgLight.parent.path, imgDark.parent.path];
    Directory dWal = Directory("$backUPLoc/bckup/wal0");
    await dWal.create(recursive: true);
    if (locations[0] != locations[1]) {
      dWal = Directory("$backUPLoc/bckup/wal1");
      await dWal.create(recursive: true);
    }
    if(wl){
      for (int i = 0; i < locations.length; i++) {
        Directory dir = Directory(locations[i]);
        if (await dir.exists()) {
          List<FileSystemEntity> l = dir.listSync();
          for (int j = 0; j < l.length; j++) {
            if (l[j].path.endsWith(".jpg") ||
                l[j].path.endsWith(".jpeg") ||
                l[j].path.endsWith(".png") ||
                l[j].path.endsWith(".svg")) {
              await Shell()
                  .run("bash -c 'cp ${l[j].path} $backUPLoc/bckup/wal$i'");
            }
          }
        }
        if (imgLight.parent.path == imgDark.parent.path) {
          break;
        }
      }
    }else{
      await Shell().run("cp ${imgLight.path} $backUPLoc/bckup/wal0");
      await Shell().run("cp ${imgDark.path} $backUPLoc/bckup/wal1");
    }
    picLight = picLight.replaceAll(SystemInfo.home, "~");
    picDark = picDark.replaceAll(SystemInfo.home, "~");
    conf["walLight"] = picLight;
    conf["walDark"] = picDark;
  }
}