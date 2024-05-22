import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gtkthememanager/back_end/app_data.dart';
import 'package:gtkthememanager/back_end/gtk_theme_manager.dart';
import 'package:gtkthememanager/theme_manager/gtk_widgets.dart';
import 'package:gtkthememanager/theme_manager/tab_manage.dart';
import 'package:process_run/process_run.dart';

import '../../theme_manager/gtk_to_theme.dart';

class ExtensionUi extends StatefulWidget {
  final Function state;

  const ExtensionUi({super.key, required this.state});

  @override
  State<ExtensionUi> createState() => _ExtensionUiState();
}

class _ExtensionUiState extends State<ExtensionUi> {
  bool cliTool = false;
  Map exts = {};
  @override
  void initState() {
    // TODO: implement initState
    populate();
    super.initState();
  }

  populate() async {

    await Future.delayed(1.microseconds);
    TabManager.freeze = true;
    widget.state();
    String s = (await Shell().run("gnome-extensions list")).outText;
    List l = s.split('\n');
    for (int i = 0; i < l.length; i++) {
      String info =
          (await Shell().run("gnome-extensions info ${l[i]}")).outText;
      exts.addAll({l[i]: getMap(info)});
    }
    AppData.DataFile["maxExts"] = exts.length;
    AppData().writeDataFile();
    TabManager.freeze = false;
    widget.state();
  }

  getMap(String info) {
    info = '$info\n';
    Map m = {};
    try {
      if (!info.contains("Name:")) {
        throw 42;
      }
      m["name"] = info
          .substring(info.indexOf("Name:") + "Name:".length,
              info.indexOf("\n", info.indexOf("Name:") + "Name:".length))
          .trim();
    } catch (e) {
      m["name"] = "N/A";
    }
    try {
      if (!info.contains("URL:")) {
        throw 42;
      }
      m["url"] = info
          .substring(info.indexOf("URL:") + "URL:".length,
              info.indexOf("\n", info.indexOf("URL:") + "URL:".length))
          .trim();
    } catch (e) {
      m["url"] = "N/A";
    }
    try {
      if (!info.contains("Description:")) {
        throw 42;
      }
      m["desc"] = info
          .substring(
              info.indexOf("Description:") + "Description:".length,
              info.indexOf(
                  "\n", info.indexOf("Description:") + "Description:".length))
          .trim();
    } catch (e) {
      m["desc"] = "N/A";
    }
    try {
      if (!info.contains("Enabled:")) {
        throw 42;
      }
      m["enable"] = info
                  .substring(
                      info.indexOf("Enabled:") + "Enabled:".length,
                      info.indexOf(
                          "\n", info.indexOf("Enabled:") + "Enabled:".length))
                  .trim() ==
              "Yes"
          ? true
          : false;
    } catch (e) {
      m["enable"] = false;
    }
    try {
      if (!info.contains("State:")) {
        throw 42;
      }
      m["state"] = info
                  .substring(
                      info.indexOf("State:") + "State:".length,
                      info.indexOf(
                          "\n", info.indexOf("State:") + "State:".length))
                  .trim() ==
              "ACTIVE"
          ? true
          : false;
    } catch (e) {
      m["state"] = false;
    }
    try {
      if (!info.contains("Version:")) {
        throw 42;
      }
      m["vers"] = info
          .substring(info.indexOf("Version:") + "Version:".length,
              info.indexOf("\n", info.indexOf("Version:") + "Version:".length))
          .trim();
    } catch (e) {
      m["vers"] = "N/A";
    }
    return m;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        WidsManager().gtkColumn(
            width: TabManager.isSuperLarge?900.0:MediaQuery.sizeOf(context).width-((TabManager.isLargeScreen)?170:0),

            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                WidsManager()
                    .getText("GNOME Extensions", fontWeight: ThemeDt.boldText),
                WidsManager().getText(
                  "Right click more options.",
                  color: "altfg",
                ),
                const SizedBox(
                  height: 13,
                )
              ],
            ),
            children: [
                for (int i = 0; i < (exts.isNotEmpty?exts.length:(AppData.DataFile["maxExts"] ?? 10)); i++)
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ExtensionInfoPage(
                                    m: exts.values.elementAt(i),
                                    uuid: exts.keys.elementAt(i),
                                  ))).then((val){
                                    setState(() {
                                      exts={};
                                    });
                                    populate();
                      });
                    },
                    child: Container(
                      color: ThemeDt.themeColors["altbg"],
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  FutureWid(
                                    val: exts.isEmpty ? null:"",
                                    width: 100,
                                    height: 15,
                                    child: WidsManager().getText(
                                        exts.isNotEmpty?  exts.values.elementAt(i)["name"] :"",
                                        size: 15),
                                  ),
                                  const SizedBox(
                                    width: 6,
                                  ),
                                  FutureWid(
                                    val: exts.isEmpty ? null:"",
                                    width: 20,
                                    height: 10,
                                    child: Container(
                                      decoration: BoxDecoration(
                                            color: ThemeDt.themeColors["fg"]
                                                ?.withOpacity(0.1),
                                            borderRadius:
                                                BorderRadius.circular(7)),
                                      padding: const EdgeInsets.all(3),
                                      child: WidsManager().getText(
                                            exts.isNotEmpty? exts.values.elementAt(i)["vers"]:"N/A",
                                            size: 10),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 3,
                              ),
                              Opacity(
                                opacity: 0.7,
                                child: Container(
                                    width: (TabManager.isSuperLarge?900.0:MediaQuery.sizeOf(context).width-((TabManager.isLargeScreen)?170:0)) / 2,
                                    child: FutureWid(
                                      val: exts.isEmpty ? null:"",
                                      width: 150,
                                      height: 10,
                                      child: WidsManager().getText(
                                         exts.isNotEmpty? exts.values.elementAt(i)["desc"]:"",
                                          size: 10,
                                          maxLines: 2),
                                    )),
                              ),
                            ],
                          ),
                          FutureWid(
                            val: exts.isEmpty ? null:"",
                            width: 40,
                            height: 20,
                            child: GetToggleButton(
                                value: exts.isNotEmpty ?  exts.values.elementAt(i)["enable"] :false,
                                onTap: () async {
                                  setState(() {
                                    exts[exts.keys.elementAt(i)]["enable"] =
                                        !exts[exts.keys.elementAt(i)]["enable"];
                                  });
                                  Shell().run(
                                      "gnome-extensions ${exts[exts.keys.elementAt(i)]["enable"] ? "enable" : "disable"} ${exts.keys.elementAt(i)}");
                                }),
                          )
                        ],
                      ).animate(effects: [const FadeEffect()]),
                    ),
                  ),
            ])
      ],
    );
  }
}

class ExtensionInfoPage extends StatefulWidget {
  final Map? m;
  final Map? jsonInfo;
  final String uuid;
  const ExtensionInfoPage({super.key, this.m, required this.uuid, this.jsonInfo});

  @override
  State<ExtensionInfoPage> createState() => _ExtensionInfoPageState();
}

class _ExtensionInfoPageState extends State<ExtensionInfoPage> {
   Map m={};
  @override
  void initState() {
    // TODO: implement initState
    fetchMapFromList();

    super.initState();
  }
bool incompatible=false;
  fetchMapFromList() async { 
    try {
      Map jsonInfo;
      String h = (await Shell().run("gnome-shell --version"))
          .outText
          .replaceAll("GNOME Shell ", "");
      h = h.substring(0, h.lastIndexOf(".")).trim();
        if(widget.jsonInfo==null){
        Directory("extensions").existsSync()
            ? Directory("extensions").delete(recursive: true)
            : Directory("extensions").create(recursive: true);
      
        await Shell().run(
            "wget -O info.json https://extensions.gnome.org/extension-info/?uuid=${widget.uuid}&shell_version=$h");
        File info = File("./info.json");
        jsonInfo = jsonDecode(info.readAsStringSync());
      }else{
      jsonInfo=widget.jsonInfo!;
        }
      creator = jsonInfo["creator"];
      icoLink=jsonInfo["icon"]==null ? "icon_3088_N9zsvc8.png":"https://extensions.gnome.org${jsonInfo["icon"]}";
      
      screenShot=jsonInfo["screenshot"]==null ? null:"https://extensions.gnome.org${jsonInfo["screenshot"]}";
      name=jsonInfo["name"];
      
      if(jsonInfo["shell_version_map"][h]==null) {
        incompatible = true;
      } else {
        inst=jsonInfo["shell_version_map"][h]["version"].toString();
      }
      String pre =(await Shell().run("gnome-extensions list")).outText;
      if(pre.contains(widget.uuid)){
       installable="installed";
      }else{
        installable="notinstalled";
      }
      desc=jsonInfo["description"];
      if (widget.m == null) {
      
      } else {
        m = widget.m!;
        name = m["name"];
        inst = m["vers"];
      
        if(m["enable"]!=null)installable="installed";
      }
      
      setState(() {});
    }  catch (e) {
      setState(() {
        err=true;
        errCode=e.toString();
      });
      // TODO
    }
  }
  bool err=false;
  String errCode="";
String? icoLink;
  fetchVal(h, val) {
    return h
        .substring(h.indexOf("$val:") + "$val:".length,
            h.indexOf("\n", h.indexOf("$val:") + "$val:".length))
        .trim();
  }
String? installable;
  String? desc;
  String? screenShot;
  String? creator;
  String? name;
  String? inst;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: err?Center(
        child: Container(
            width: 500,
            child: WidsManager().getText("There was an error while loading this page.\n\n$errCode")),
      ):Column(
        children: [
         if(MediaQuery.sizeOf(context).width>600) const SizedBox(
            height: 30,
          ),
          AnimatedPadding(
            padding:  EdgeInsets.all((MediaQuery.sizeOf(context).width<500)?20:60),
            duration: ThemeDt.d,
            curve: ThemeDt.c,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Flex(
                 // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  direction: (MediaQuery.sizeOf(context).width<600)?Axis.vertical:Axis.horizontal,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            FutureWid(
                              val: icoLink,
                              width: 30,
                              height: 30,
                              child:(icoLink??"icon_3088_N9zsvc8.pngplugin").contains("icon_3088_N9zsvc8.png")||(icoLink??"icon_3088_N9zsvc8.pngplugin").contains("plugin")? Icon(
                                Icons.extension,
                                color: ThemeDt.themeColors["altfg"],
                              ):Image.network(
                                  height: 30,
                                  icoLink ?? ""),
                            ),
                            const SizedBox(width: 6,),

                            FutureWid(val: name,
                            width: 150,
                            height: 30,
                            child: Container(
                                width: MediaQuery.sizeOf(context).width<(name ?? "N/A").length*30?200:null,
                                child: WidsManager().getText(name ?? "N/A", size: MediaQuery.sizeOf(context).width<600?18:24))),
                            const SizedBox(width: 6,),
                            FutureWid(
                              val: inst,
                              width: 20,
                              height: 30,
                              child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(7),
                                    color:
                                        ThemeDt.themeColors["fg"]?.withOpacity(0.1),
                                  ),
                                  child: WidsManager().getText(inst ?? "N/A", size: 12)),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        FutureWid(
                          val: creator,
                          width: 100,
                          height: 10,
                          child: WidsManager().getText(creator??"N/A", size: 13), 
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        FutureWid(
                          val:  desc,
                          width: 100,
                          height: 10,
                          child: GestureDetector(
                            onTap: (){
                              WidsManager().showMessage(
                                isDismisible: true,
                                  height: MediaQuery.sizeOf(context).height/1.2,
                                  title: "Info", message: (desc ?? "N/A"), context: context);
                            },
                            child: Container(
                              color: ThemeDt.themeColors["bg"],
                                width: MediaQuery.sizeOf(context).width / 2,
                                child: WidsManager().getText(
                                    maxLines: 2,
                                    (desc ?? "N/A").replaceAll("\n", " "), size: 11)),
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 18.0),
                      child: Row(
                        children: [
                          FutureWid(
                            val: installable,
                            width: 100,
                            height: 30,
                            child: incompatible? Container(
                              decoration: BoxDecoration(
                                color: Colors.red.withOpacity(0.7),
                                borderRadius: BorderRadius.circular(100)
                              ),
                              padding: const EdgeInsets.all(10),
                              child: Row(
                                children: [
                                  Icon(Icons.error, color: ThemeDt.themeColors["fg"],),
                                  WidsManager().getText(" Incompatible"),
                                ],
                              ),
                            ):
                            (installable ?? "") == "installed"? Row(
                              children: [
                                ElevatedButton.icon(
                                    onPressed: () async {
                                      setState(() {
                                        installable=null;
                                      });
                                      try {
                                        await Shell().run("gnome-extensions uninstall ${widget.uuid}");
                                        setState(() {
                                          installable = "notinstalled";
                                        });
                                      }catch(e){
                                        setState(() {
                                          installable = "installed";
                                        });
                                      }
                                    },
                                    icon: Icon(

                                      Icons.delete,
                                      color: ThemeDt.themeColors["altfg"],
                                    ),
                                    label: WidsManager().getText("Uninstall")),
                                const SizedBox(
                                  width: 10,
                                ),
                                IconButton(
                                  onPressed: () async {

                                    try {
                                    }  catch (e) {WidsManager().showMessage(title: "info", message: e.toString(), context: context);
                                    }


                                  },
                                  icon: Icon(
                                    Icons.settings,
                                    color: ThemeDt.themeColors["altfg"],
                                  ),
                                )
                              ],
                            ):ElevatedButton.icon(
                                onPressed: () async {
                                  setState(() {
                                    installable=null;
                                  });
                                  try {
                                    String? s =await ThemeManager().extensionInstaller(uuid: widget.uuid);
                                    if((s ?? "cancelled").contains("cancelled")){
                                      setState(() {
                                        installable = "notinstalled";
                                      });
                                    }
                                   else {
                                      setState(() {
                                        installable = "installed";
                                      });
                                    }
                                  }catch(e){
                                    setState(() {
                                      installable = "notinstalled";
                                    });
                                  }
                                },
                                icon: Icon(

                                  Icons.install_desktop,
                                  color: ThemeDt.themeColors["altfg"],
                                ),
                                label: WidsManager().getText("Install")),
                          ),

                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 3,
                ),

                const SizedBox(height: 20,),
               if(screenShot!=null) ClipRRect(
                 borderRadius: BorderRadius.circular(8),
                 child: Image.network(
                     loadingBuilder: (BuildContext context, Widget child,
                         ImageChunkEvent? loadingProgress) {
                       if (loadingProgress == null) return child;
                       return Center(
                         child: Padding(
                           padding: const EdgeInsets.only(top: 200.0),
                           child: LinearProgressIndicator(
                             value: (loadingProgress.cumulativeBytesLoaded/(loadingProgress.expectedTotalBytes ?? 1)),
                             color: Colors.white,
                           ),
                         ),
                       );
                     },
                     height: MediaQuery.sizeOf(context).height/2,
                     fit: BoxFit.fitWidth,
                     screenShot!),
               )
              ],
            ),
          )
        ],
      ),
    );
  }
}
