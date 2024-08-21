import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gtkthememanager/back_end/app_data.dart';
import 'package:gtkthememanager/back_end/gtk_theme_manager.dart';
import 'package:gtkthememanager/theme_manager/gtk_to_theme.dart';
import 'package:gtkthememanager/theme_manager/gtk_widgets.dart';
import 'package:process_run/process_run.dart';

import '../../theme_manager/tab_manage.dart';

class ApplyConfig extends StatefulWidget {
  final String path;
  final Function state;
  const ApplyConfig({super.key, required this.path, required this.state});

  @override
  State<ApplyConfig> createState() => _ApplyConfigState();
}

class _ApplyConfigState extends State<ApplyConfig> {
  @override
  void initState() {
    // TODO: implement initState
    ready();
    super.initState();
  }

  ready() async {
    File fl = File(widget.path);
    if (fl.path.endsWith(".zip")) {
      if (fl.existsSync()) {
        File f = File("${SystemInfo.home}/.NexData/Evolve/${widget.path
            .split('/')
            .last}");
        Directory d = Directory("${SystemInfo.home}/.NexData/Evolve/bckup");
        if (d.existsSync()) {
          d.deleteSync(recursive: true);
        }
        if (f.existsSync()) {
          f.deleteSync();
        }
        await Shell().run("bash -c 'cp ${widget.path} ~/.NexData/Evolve'");
        await Shell().run(
            "bash -c 'cd ~/.NexData/Evolve && unzip ./${widget.path
                .split('/')
                .last}'");
        await checkConfigValid();
      } else {
        Navigator.pop(context);
      }
    } else {
      await Future.delayed(1.seconds);
      Navigator.pop(context);
    }
    setState(() {
      loading = false;
    });
  }

  List dirs = [];
  Map conf = {};
  Map opts = {};
  Map optsSelect = {};

  checkConfigValid() async {
    try {
      Directory d = Directory("${SystemInfo.home}/.NexData/Evolve/bckup");
      dirs = d.listSync();
      File config = File(
          "${SystemInfo.home}/.NexData/Evolve/bckup/config.evolve");
      conf = jsonDecode(config.readAsStringSync());
      opts = conf["avail"];
      optsSelect = Map.from(opts);
      optsSelect["appData"]=false;
      walLight = conf["walLight"];
      walDark = conf["walDark"];
      appdata = conf["appdata"];
      appliedGTK3 = conf["appliedGTK3"];
      appliedSHELL = conf["appliedSHELL"];
      appliedIcon = conf["appliedIcon"];
      for (int i = 0; i < opts.length; i++) {
        var k = opts.keys.elementAt(i);
        var v = opts.values.elementAt(i);
        if (v) {
          if (k == "theme") {
            List locations = [
              "${SystemInfo.home}/.NexData/Evolve/bckup/.themes",
            ];

            for (int i = 0; i < locations.length; i++) {
              Directory dir = Directory(locations[i]);
              if (!(await dir.exists())) {
                throw 42;
              }
            }
          }
          if (k == "icon") {
            List locations = [
              "${SystemInfo.home}/.NexData/Evolve/bckup/.icons",
            ];

            for (int i = 0; i < locations.length; i++) {
              Directory dir = Directory(locations[i]);
              if (!(await dir.exists())) {
                throw 42;
              }
            }
          }
          if (k == "at+") {
            List locations = [
              "${SystemInfo.home}/.NexData/Evolve/bckup/AT",
            ];

            for (int i = 0; i < locations.length; i++) {
              Directory dir = Directory(locations[i]);
              if (!(await dir.exists())) {
                throw 42;
              }
            }
          }
          if (k == "exts") {
            String s = conf["exts"];
            s = s.substring(1, s.length - 1).replaceAll("[", "").replaceAll(
                "]", "");
            instExts = s.split(',');
          }
        }
      }
    } catch (e) {
      WidsManager().showMessage(title: "Error",
          message: "The config file is corrupt. Please use a different file.",
          context: context,
          child: ElevatedButton(onPressed: () {
            Navigator.pop(context);
            Navigator.pop(context);
          }, child: WidsManager().getText("Exit")));
    }
  }

  GlobalKey pKey = GlobalKey();
  late String walLight;
   List instExts=[];
  late String walDark;
  late Map appdata;
  late String appliedGTK3;
  late String appliedSHELL;
  late String appliedIcon;
  bool loading = true;

  @override
  Widget build(BuildContext context) {
    try {
      return Scaffold(
        appBar: AppBar(),
        body: loading ? const Center(
          child: CircularProgressIndicator(
            color: Colors.white,
            strokeWidth: 10,
            strokeCap: StrokeCap.round,
          ),
        ) : Padding(
          padding: const EdgeInsets.all(18.0),
          child: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                WidsManager().gtkColumn(
                    width: TabManager.isSuperLarge?900.0:MediaQuery.sizeOf(context).width-((TabManager.isLargeScreen)?170:0),

                    title: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        WidsManager().getText(
                            "Config Data", fontWeight: ThemeDt.boldText),
                        WidsManager().getText(
                          "The following data are available and will be used.",
                          color: "altfg",),
                        const SizedBox(height: 13,)
                      ],
                    ),
                    children: [
                      if(opts["theme"]) Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          WidsManager().getText("Installed Themes"),
                          GetToggleButton(
                            value: optsSelect["theme"],
                            onTap: () {
                              setState(() {
                                optsSelect["theme"] = !optsSelect["theme"];
                              });
                            },)
                        ],
                      ),
                      if(opts["icon"]) Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          WidsManager().getText("Installed Icons"),
                          GetToggleButton(
                            value: optsSelect["icon"],
                            onTap: () {
                              setState(() {
                                optsSelect["icon"] = !optsSelect["icon"];
                              });
                            },)
                        ],
                      ),
                      if(opts["exts"]) Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          WidsManager().getText("Installed Extensions"),
                          GetToggleButton(
                            value: optsSelect["exts"],
                            onTap: () {
                              setState(() {
                                optsSelect["exts"] = !optsSelect["exts"];
                              });
                            },)
                        ],
                      ),
                      if(opts["at+"]) Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          WidsManager().getText("AT+ Themes"),
                          GetToggleButton(
                            value: optsSelect["at+"],
                            onTap: () {
                              setState(() {
                                optsSelect["at+"] = !optsSelect["at+"];
                              });
                            },)
                        ],
                      ),
                      if(opts["wal"]) Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          WidsManager().getText("Wallpaper Album"),
                          GetToggleButton(
                            value: optsSelect["wal"],
                            onTap: () {
                              setState(() {
                                optsSelect["wal"] = !optsSelect["wal"];
                              });
                            },)
                        ],
                      ),Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          WidsManager().getText("Evolve App Data"),
                          GetToggleButton(
                            value: optsSelect["appData"],
                            onTap: () {
                              setState(() {
                                optsSelect["appData"] = !optsSelect["appData"];
                              });
                            },)
                        ],
                      ),

                    ]),
                const SizedBox(height: 10,),
                Align(
                 // alignment: Alignment.bottomRight,
                  child: AnimatedCrossFade(
                    duration: ThemeDt.d,
                    crossFadeState: load?CrossFadeState.showFirst:CrossFadeState.showSecond,
                    firstChild: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        LinearProgressIndicator(
                          value: vl/(opts.length+instExts.length+1),
                          color: ThemeDt.themeColors["fg"],
                        ),
                        const SizedBox(height: 2,),
                        WidsManager().getText("Applying...")
                      ],
                    ),
                    secondChild: AnimatedContainer(
                      duration: ThemeDt.d,
                      curve: ThemeDt.c,
                      key: pKey,
                      width: MediaQuery
                          .sizeOf(context)
                          .width / 4 > 200 ? 200 : 100,
                      child: AdaptiveList(
                        parentKey: pKey,
                        children: [
                          WidsManager().getTooltip(
                            text: "Replaces existing files with the config. Currently installed files are DELETED!",
                            child: ElevatedButton(
                                onPressed: () async {
                                  setState(() {
                                    load=true;
                                  });
                                  await apply();

                                  setState(() {
                                    load=false;
                                  });
                                  WidsManager().showMessage(title: "Done", message: "The config has been applied", context: context,child: ElevatedButton(onPressed: (){
                                    Navigator.pop(context);
                                  //  Navigator.pop(context);
                                  }, child: WidsManager().getText("Exit")));
                                },
                                child: WidsManager().getText("Replace")
                            ),
                          ), WidsManager().getTooltip(
                            text: "Appends config files with existing files.",
                            child: ElevatedButton(
                                onPressed: () async {
                                  setState(() {
                                    load=true;
                                  });
                                  await apply(replace: false);

                                  setState(() {
                                    load=false;
                                  });
                                  WidsManager().showMessage(title: "Done", message: "The config has been applied", context: context,child: ElevatedButton(onPressed: (){
                                    Navigator.pop(context);
                                    Navigator.pop(context);
                                  }, child: WidsManager().getText("Exit")));
                                },
                                child: WidsManager().getText("Append")
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      );
    }  catch (e) {
    return Scaffold(
      body: Center(child: WidsManager().getText("The config file is corrupt.")),
    );
    }
  }
double vl=0.0;
  bool load=false;
  Future<void> apply({bool replace = true}) async {

    setState(() {
      vl=0.0;
    });
    for (int i = 0; i < optsSelect.length; i++) {
      var k = optsSelect.keys.elementAt(i);
      var v = optsSelect.values.elementAt(i);
      setState(() {
      vl++;
     });
      if (v) {
        if (k == "theme") {
          List locations = [
            "${SystemInfo.home}/.NexData/Evolve/bckup/.themes",
          ];

          for (int i = 0; i < locations.length; i++) {
            Directory dir = Directory(locations[i]);
            if (await dir.exists()) {
             if(replace) {
                if (dir.path.endsWith(".themes")) {
                  if (Directory("${SystemInfo.home}/.themes").existsSync()) {
                    await Shell()
                        .run("bash -c 'rm -r ${SystemInfo.home}/.themes'");
                  }
                  await Shell().run(
                      "bash -c 'cp -r ${SystemInfo.home}/.NexData/Evolve/bckup/.themes ${SystemInfo.home}'");
                }
              }else{
               if (Directory("${SystemInfo.home}/.themes").existsSync()) {
                 if(Directory("${SystemInfo.home}/.themes").listSync().isNotEmpty) {
                   await Shell().run("bash -c 'cp -r ${SystemInfo.home}/.NexData/Evolve/bckup/.themes/* ${SystemInfo.home}/.themes'");
                 }
               }
             }
            }
          }
        }
        if (k == "icon") {
          List locations = [
            "${SystemInfo.home}/.NexData/Evolve/bckup/.icons",
          ];

          for (int i = 0; i < locations.length; i++) {
            Directory dir = Directory(locations[i]);
            if (await dir.exists()) {
              if(replace) {
                if (dir.path.endsWith(".icons")) {
                  if (Directory("${SystemInfo.home}/.icons").existsSync()) {
                    await Shell()
                        .run("bash -c 'rm -r ${SystemInfo.home}/.icons'");
                  }
                  await Shell().run(
                      "bash -c 'cp -r ${SystemInfo.home}/.NexData/Evolve/bckup/.icons ${SystemInfo.home}'");
                }
              }else{
                if (Directory("${SystemInfo.home}/.icons").existsSync()) {
                  if(Directory("${SystemInfo.home}/.icons").listSync().isNotEmpty) {
                    await Shell().run("bash -c 'cp -r ${SystemInfo.home}/.NexData/Evolve/bckup/.icons/* ${SystemInfo.home}/.icons'");
                  }
                }
              }
            }
          }
        }
        if (k == "at+") {
          List locations = [
            "${SystemInfo.home}/.NexData/Evolve/bckup/AT",
          ];

          for (int i = 0; i < locations.length; i++) {
            Directory dir = Directory(locations[i]);
            if (await dir.exists()) {
              if(replace) {
                  if (Directory("${SystemInfo.home}/AT").existsSync()) {
                    await Shell()
                        .run("bash -c 'rm -r ${SystemInfo.home}/AT'");
                  }
                  await Shell().run(
                      "bash -c 'cp -r ${SystemInfo.home}/.NexData/Evolve/bckup/AT ${SystemInfo.home}'");
              }else{
                if (Directory("${SystemInfo.home}/AT").existsSync()) {
                  if(Directory("${SystemInfo.home}/AT").listSync().isNotEmpty) {
                    await Shell().run("bash -c 'cp -r ${SystemInfo.home}/.NexData/Evolve/bckup/AT/* ${SystemInfo.home}/AT'");
                  }
                }
              }
            }
          }
        }

        if (k == "exts") {
        for(int i=0;i<instExts.length;i++){
          setState(() {
            vl++;
          });
          await ThemeManager().extensionInstaller(uuid: instExts[i]);
        }
        }
      }
  }
    await ThemeDt.setGTK3(appliedGTK3);
    setState(() {
      vl++;
    });
    if(Directory("${SystemInfo.home}/.config/gtk-4.0").existsSync()){
      Directory("${SystemInfo.home}/.config/gtk-4.0").deleteSync(recursive: true);
    }
    setState(() {
      vl++;
    });
    await Shell().run("bash -c 'cp -r ~/.NexData/Evolve/bckup/gtk-4.0 ${SystemInfo.home}/.config'");
    setState(() {
      vl++;
    });
    await ThemeDt.setShell(appliedSHELL);
    setState(() {
      vl++;
    });
    await ThemeDt().setIcon( packName: appliedIcon);
    await ThemeDt().setAppTheme();
    walLight=walLight.replaceAll("~", SystemInfo.home);
    walDark=walDark.replaceAll("~", SystemInfo.home);
    if(optsSelect["wal"]){
      File wL = File(walLight);
      File wD = File(walDark);
      Directory d=wL.parent;
      if(d.existsSync()==false){
        await d.create(recursive: true);
      }
      await Shell().run("bash -c 'cp ~/.NexData/Evolve/bckup/wal0/* ${wL.parent.path}'");
      if(wD.path!=wL.path) {
        d=wD.parent;
        if(d.existsSync()==false){
          await d.create(recursive: true);
        }
        await Shell().run("bash -c 'cp ~/.NexData/Evolve/bckup/wal1/* ${wD.parent.path}'");
      }
      await Shell().run("""gsettings set org.gnome.desktop.background picture-uri 'file://${wL.path}'""");
      await Shell().run("""gsettings set org.gnome.desktop.background picture-uri-dark 'file://${wD.path}'""");
    }
    if(optsSelect["appData"]) {
      AppData.DataFile=conf["appdata"];
      await AppData().writeDataFile();
    }
    widget.state();
  }
}