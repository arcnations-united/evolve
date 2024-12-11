import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme_manager/gtk_to_theme.dart';
import 'package:process_run/process_run.dart';

import '../theme_manager/atplus_themes.dart';
import '../theme_manager/gtk_widgets.dart';

class AtPlusPreview extends StatefulWidget {
  final Map m;
  final int i;
  const AtPlusPreview({super.key, required this.m, required this.i});

  @override
  State<AtPlusPreview> createState() => _AtPlusPreviewState();
}

class _AtPlusPreviewState extends State<AtPlusPreview> {
  bool applying=false;
  @override
  Widget build(BuildContext context) {
    int i=widget.i;
    return  applying?
    Scaffold(
      body: Center(
        child: WidsManager().getText("Applying Theme-Pack. Please wait...").animate(
            effects:[
              ShimmerEffect(
                  color: ThemeDt.themeColors["bg"]?.withOpacity(0.9),
                  duration: 6 .seconds
              ),ShimmerEffect(
                  color: Colors.white,
                  delay: 6.seconds,
                  duration: 6.seconds
              ), ShimmerEffect(
                  color: ThemeDt.themeColors["bg"]?.withOpacity(0.9),
                  delay: 12.seconds,
                  duration: 6 .seconds
              ),ShimmerEffect(
                  color: Colors.white,
                  delay: 18.seconds,
                  duration: 7.seconds
              ),
            ]
        ),
      ),
    ):
    Scaffold(
      appBar: WidsManager().gtkAppBar(context,),
      body: Center(
        child: SizedBox(
          height: 900,
          width: 900,
          child: Padding(
            padding:  const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,

                      children: [
                        Row(
                          children: [
                            WidsManager().getText(widget.m["theme_name"],size: 20, fontWeight: FontWeight.w400),
                            const SizedBox(width: 7,),
                            WidsManager().getContainer(
                                child: WidsManager().getText(widget.m["version"].toString(), ),
                                pad: 5,
                                borderRadius: 7
                            )
                          ],
                        ),
                        const SizedBox(height: 5,),

                        WidsManager().getText(widget.m["description"],size: 11, fontWeight: FontWeight.w200),
                        const SizedBox(height: 5,),
                        Wrap(
                          spacing: 8,
                          children: [
                            for(String m in widget.m["tags"])
                              Chip(label: Text(m, style: const TextStyle(fontSize: 11),),padding: const EdgeInsets.all(1),)
                          ],
                        ),
                      ],
                    ),
                    ElevatedButton.icon(onPressed: () async {
                      setState(() {
                        applying=true;
                      });
                      try {
                        File conkyfile = File("${SystemInfo.home}/AT/UID${PThemes.themeMap.keys.elementAt(i)}/conky/weather.sh");

                        if(await conkyfile.exists()==false){
                          conkyfile = File("${SystemInfo.home}/AT/UID${PThemes.themeMap.keys.elementAt(i)}/weather.sh");
                        }
                        if(await conkyfile.exists()){
                          String s =await  conkyfile.readAsString();
                          if(s.substring(s.indexOf("wget")+4,s.indexOf("-O")).contains("-q")==false){
                            List m = s.split("wget");
                            s= "${m[0]}wget -q${m[1]}";
                            conkyfile.writeAsString(s);
                          }
                        }
                        Shell(throwOnError: false).run("""bash -c 'cd ${SystemInfo.home}/AT/UID${PThemes.themeMap.keys.elementAt(i)} && ${PThemes.themeMap.values.elementAt(i)["apply"]}'""");
                        if(PThemes.themeMap.keys.elementAt(i)==6){
                          ThemeDt().setWallpaper("${SystemInfo.home}/AT/UID6/w1.jpg");
                          await Future.delayed(3.seconds);
                          Shell().run("bash -c 'cp -r ~/.themes/Evergreen-GTK-AT/gtk-4.0 ~/.config'");

                        }else if(PThemes.themeMap.keys.elementAt(i)==7){
                          ThemeDt().setWallpaper("${SystemInfo.home}/AT/UID7/wallpaper/w1.png");
                          await Future.delayed(3.seconds);
                          Shell().run("bash -c 'cp -r ~/.themes/Gruvbox-Dark/gtk-4.0 ~/.config'");

                        }else if(PThemes.themeMap.keys.elementAt(i)==8){
                          ThemeDt().setWallpaper("${SystemInfo.home}/AT/UID8/wallpaper/w1.png");
                          await Future.delayed(3.seconds);
                          Shell().run("bash -c 'cp -r ~/.themes/Evergreen-Mac/gtk-4.0 ~/.config'");

                        }
                      }  catch (e) {

                      }
                      setState(() {
                        applying=false;
                      });
                    }, label: WidsManager().getText("Apply Theme-Pack"))
                  ],
                ),
                const SizedBox(height: 15,),
                if(widget.m["preview"]!="N/A")ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.file(File(widget.m["preview"].replaceAll("~",SystemInfo.home))))
                else
                  Column(
                    children: [
                      WidsManager().getText(widget.m["theme_name"],size: 120, fontWeight: FontWeight.w600, letterSpacing: -5),
                      Row(
                        children: [
                          for(String c in widget.m["color"])
                            Expanded(child: Container(
                              color: HSLColor.fromColor(Color(int.parse("0xff$c"))).lightness<0.5?Colors.white.withOpacity(0.6):Colors.black.withOpacity(0.2),
                              padding: const EdgeInsets.all(5),
                              child: Container(
                                height: 20,
                                color: Color(int.parse("0xff$c")),
                              ),
                            ))
                        ],
                      )
                    ],
                  ),



              ],
            ),
          ),
        ),
      ),
    );
  }
}
