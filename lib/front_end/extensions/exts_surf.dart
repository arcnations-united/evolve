import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gtkthememanager/theme_manager/gtk_to_theme.dart';
import 'package:gtkthememanager/theme_manager/gtk_widgets.dart';
import 'package:process_run/process_run.dart';

import 'extension_ui.dart';

class ExtsSurf extends StatefulWidget {
  const ExtsSurf({super.key});

  @override
  State<ExtsSurf> createState() => _ExtsSurfState();
}

class _ExtsSurfState extends State<ExtsSurf> {

  bool load=false;
  String vers="";


  static Map results={};
  static Future<Map>search(txt)async{
    String vrs=txt.split("{}").last;
    txt=txt.split("{}").first;
File src=File("search.json");
if(src.existsSync())src.deleteSync();
   (await Shell().run("bash -c 'wget -O search.json https://extensions.gnome.org/extension-query/?search=\"$txt\"'"));
   List s = jsonDecode(src.readAsStringSync())["extensions"];
   for(int i=0;i<s.length;i++){
     if(s[i]["shell_version_map"][vrs]!=null) {
       results[s[i]["uuid"]]=s[i];
     }
   }
return results;
  }
bool err=false;
  Timer? t;static String txt1="";
  bool fetching=false;
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar: WidsManager().gtkAppBar(context),
      body: load?Center(
        child: CircularProgressIndicator(
          color: ThemeDt.themeColors["fg"],strokeWidth: 8,
          strokeCap: StrokeCap.round,
        ),
      ) :

          Padding(
            padding: const EdgeInsets.all(18.0),
            child: Column(
              children: [

                AnimatedScale(
                  scale: txt1!=""?1:1.6,
                  duration: ThemeDt.d,
                  curve: ThemeDt.c,
                  child: WidsManager().getContainer(pad: 0,mar: 0,
                    colour: "bg",
                    height: txt1==""?300:130,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        WidsManager().getText("Extensions", size: 30),

                        WidsManager().getText(" Install online extensions", size: 13  ),      const SizedBox(height: 16,),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.extension_rounded, size: 13,color: ThemeDt.themeColors["altfg"],),
                            const SizedBox(width: 7,),
                            Icon(Icons.settings, size: 13,color: ThemeDt.themeColors["altfg"],),  const SizedBox(width: 7,),
                            Icon(Icons.account_circle_rounded, size: 13,color: ThemeDt.themeColors["altfg"],), const SizedBox(width: 7,),
                            Icon(Icons.auto_awesome, size: 13,color: ThemeDt.themeColors["altfg"],),const SizedBox(width: 7,),
                            Icon(Icons.map, size: 13,color: ThemeDt.themeColors["altfg"],),const SizedBox(width: 7,),
                            Icon(Icons.access_time_filled_rounded, size: 13,color: ThemeDt.themeColors["altfg"],),const SizedBox(width: 7,),
                            Icon(Icons.archive, size: 13,color: ThemeDt.themeColors["altfg"],),
                          ],
                        ),

                      ],
                    )
                  ),
                ),
                Center(
                  child: Container(
                    width: 650,
                    child: TextField(cursorColor: ThemeDt.themeColors["altfg"],
                      style: WidsManager().getText("s", size: 18).style,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(100)
                        ),

                      ),
                      onChanged: (txt){
                      setState(() {
                        txt1=txt;
                      });

                     if(txt1!="") {
                                  t?.cancel();
                                  t = Timer(500.milliseconds, () async {
                                    setState(() {
                                      fetching=true;
                                      results = {};
                                    });

                                    try {
                                      results = await compute(search, "$txt1{}${SystemInfo.shellVers}");
                                    }  catch (e) {
                                     setState(() {
                                      txt1="";
                                     });
                                    }

                                    setState(() {
                                      fetching=false;
                                      if(results.isEmpty){
                                        txt1="";
                                      }

                                    });
                                  });
                                }
                              },
                    ),
                  ),
                ),
                const SizedBox(height: 20,),
                Center(
                  child:
                  WidsManager().getContainer(
                        height: txt1==""?0:MediaQuery.sizeOf(context).height-300,
                        width: 650,
                        colour: (txt1!="")?"altbg":"bg",
                        child: (txt1=="")?WidsManager().getText("Search for extensions and results will appear here..."):
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: SingleChildScrollView(
                            child: WidsManager().gtkColumn(
                             // crossAxisAlignment: CrossAxisAlignment.start,
                              width: 650.0,
                              children: [
                                for(int i =0;i<(results.isEmpty ? 10 : results.length);i++)
                                GestureDetector(
                                  onTap: (){
                                    Navigator.push(context, MaterialPageRoute(builder: (context)=>ExtensionInfoPage(
                                      uuid: results.keys.elementAt(i),
                                      jsonInfo: results.values.elementAt(i) ,)));
                                  },
                                  child: Container(
                                    color: ThemeDt.themeColors["altbg"],
                                    child: Row(
                                      children: [
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            FutureWid(
                                              val: results.isEmpty ? null : "",
                                              width: 200,
                                              height: 15,
                                              child: WidsManager().getText(results.isEmpty ? "" : results.values.elementAt(i)["name"],color: "altfg",size: 15),
                                            ),
                                            const SizedBox(height: 2,),
                                            Opacity(
                                              opacity: 0.5,
                                              child: FutureWid(
                                                val: results.isEmpty ? null : "",
                                                width: 100,
                                                height: 11,
                                                child: WidsManager().getText(results.isEmpty ? "" : results.values.elementAt(i)["creator"], size: 11),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                )
              ],
            ),
          )
    );
  }
}
