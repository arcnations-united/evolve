import 'dart:async';
import 'dart:io';
import 'package:blurrycontainer/blurrycontainer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'gtk_to_theme.dart';

//Returns required widgets in style of the applied GTK Theme
class WidsManager{
  static int activeTab=0;
  Widget getContainer({bool? border,child,double? pad,double? width,double? height, bool? blur}){
    blur ??=false;
    border ??= false;
    pad ??= 10;
    if(blur) {
     return BlurryContainer(
       borderRadius: BorderRadius.circular(10),

       padding: EdgeInsets.zero,
      blur: 15,
      child: AnimatedContainer(
      
        width: width,
        height: height,
        padding: EdgeInsets.all(pad),
        duration: ThemeDt.d,
        curve: ThemeDt.c,
        decoration: BoxDecoration(
            border: border?Border.all(
              width: 1.5,
              color: ThemeDt.themeColors["fg"] ?? Colors.transparent,
            ):null,
            color: ThemeDt.themeColors["sltbg"]?.withOpacity(0.2),
            borderRadius: BorderRadius.circular(10)
        ),
        child: child,
      ),
    );
    }
    return AnimatedContainer(

      width: width,
      height: height,
      padding: EdgeInsets.all(pad),
        duration: ThemeDt.d,
      curve: ThemeDt.c,
      decoration: BoxDecoration(
        border: border?Border.all(
          width: 1.5,
          color: ThemeDt.themeColors["fg"] ?? Colors.transparent,
        ):null,
        color: ThemeDt.themeColors["altbg"],
        borderRadius: BorderRadius.circular(10)
      ),
      child: child,
    );
  }
  Text getText(String s, {double? size,bool? center, bool? stylize, int? maxLines}){
    stylize ??= false;
    center ??= false;
    size ??= 13;
    return Text(s, textAlign:(center)? TextAlign.center:null,maxLines: maxLines, overflow: TextOverflow.fade, style:stylize==true?
    GoogleFonts.audiowide(
      color: ThemeDt.themeColors["fg"], fontSize: size,

    ):
    GoogleFonts.montserrat(

      color: ThemeDt.themeColors["fg"], fontSize: size,
      fontWeight: size>15? FontWeight.w200 : FontWeight.w400,

    ),);
  }

  void showMessage({required String title, required String message,  IconData? icon, Widget? child, required context}) {
    icon ??= (title.toLowerCase()=="error")?Icons.error_rounded:(title.toLowerCase()=="warning")?Icons.warning_rounded:Icons.info_rounded;
    child ??= GetButtons(onTap: (){
      Navigator.pop(context);
    }, text: "Close",);
    showDialog(barrierColor: Colors.transparent,context: context, builder: (BuildContext context) {
      var wdth = MediaQuery.sizeOf(context).width;
      return  Center(
        child: WidsManager().getContainer(
          blur: true,
          border: true,
          pad: 20,
          height: 300,
          width: wdth>1200?wdth/2.5 : 1200/2.5,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Align(
                  alignment: Alignment.center,
                  child: WidsManager().getText(title, size: 27)),
              Row(
                children: [
                  Icon(icon, color: ThemeDt.themeColors["fg"],size: 70,),
                  const SizedBox(width: 20,),
                  Expanded(
                    child: ListView(
                      shrinkWrap: true,
                      children: [
                        SizedBox(
                            width: wdth>1200?wdth/3.8:1200/3.8,
                            child: WidsManager().getText(message)),
                      ],
                    ),
                  ),
                ],
              ),
              child!
            ],
          ),
        ),
      );

    },);
  }
}

class TabButton extends StatefulWidget {
  final String text;
  final int Tab;
  final Function() state;
   const TabButton({required this.text, super.key, required this.Tab, required this.state,});

  @override
  State<TabButton> createState() => _TabButtonState();
}
class _TabButtonState extends State<TabButton> {
  bool hover=false;

  @override
  void initState() {
    initiateTheme();
    super.initState();
  }
  initiateTheme()async{
    ThemeDt().initiateFallbackTheme();
    await ThemeDt().setTheme();
    setState(() {

    });
  }
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.sizeOf(context).width/5;
          return  MouseRegion(
            onEnter: (dt){
              setState(() {
                hover = true;
              });
            },
            onExit: (dt){

              setState(() {
                hover = false;
              });
            },
            child: GestureDetector(
              onTap: (){
                  WidsManager.activeTab=widget.Tab;
                  widget.state();
              },
              child:  AnimatedContainer(
                width: width,
                decoration: BoxDecoration(
                    color: ThemeDt.themeColors[widget.Tab==WidsManager.activeTab?"sltbg":(hover)?"altbg":"bg"],
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      width: 2,
                      color: ((widget.Tab==WidsManager.activeTab)?ThemeDt.themeColors["fg"] :null) ?? Colors.transparent,
                    )
                ),
                duration: ThemeDt.d,
                curve: ThemeDt.c,
                padding: const EdgeInsets.all(10),
                child: WidsManager().getText(widget.text,),
              ),
            ),
          );
  }
}

class GetButtons extends StatefulWidget {
final Function() onTap;
final  child;
  final String? text;
  final bool? light;
 final bool? ghost;
 final bool? moreResponsive;
 final double? ltVal;
  const GetButtons({this.ltVal, this.child, this.text, this.ghost,  super.key, required this.onTap, this.light, this.moreResponsive});

  @override
  _GetButtonsState createState() => _GetButtonsState();
}
class _GetButtonsState extends State<GetButtons> {

  bool hover=false;
  bool tap=false;
  Timer? t;
  Timer? t1;
  @override
  void dispose() {
    t?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Color? buttonCol = ThemeDt.themeColors[tap?"sltbg":(hover)?"altbg":"bg"];
    return  MouseRegion(
      onEnter: (dt){
        setState(() {
          hover = true;
        });
      },
      onExit: (dt){
t?.cancel();
t=Timer(const Duration(milliseconds: 200), () {
 if(context.mounted) {
   setState(() {
    hover = false;
  });
 }
});

      },
      child: GestureDetector(
        onTapDown: (dt){
          setState(() {
            tap=true;
          });

        },onTapUp: (dt){
          widget.onTap();
          t1?.cancel();
          t1=Timer(const Duration(milliseconds: 200), () {
           if(context.mounted) {
             setState(() {
              tap=false;
            });
           }
          });



        },
        child:  AnimatedContainer(
         // width: width,
          decoration: BoxDecoration(
              color: (widget.light ?? false)?
              HSLColor.fromColor(buttonCol!).withLightness(
                  HSLColor.fromColor(buttonCol).lightness*(widget.ltVal ?? 2)>1 ?1:HSLColor.fromColor(buttonCol).lightness*(widget.ltVal ?? 2)
              ).toColor():
              buttonCol,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                width: 2,
                color: (widget.ghost ?? false)?ThemeDt.themeColors["fg"]!:
                ((tap)?ThemeDt.themeColors["fg"] :null) ?? Colors.transparent,
              )
          ),
          duration: ThemeDt.d,
          curve: ThemeDt.c,
          padding:(widget.moreResponsive ?? false)? EdgeInsets.all((hover)?10:15):const EdgeInsets.all(8),
          margin:(widget.moreResponsive ?? false)? EdgeInsets.all((hover)?5:0) : EdgeInsets.zero,
          child: (widget.child==null)?WidsManager().getText(widget.text ?? "",):widget.child,
        ),
      ),
    );
  }
}

class GetIcons extends StatefulWidget {
  final String icoPackPath;
  final Function() state;
  const GetIcons({super.key, required this.icoPackPath, required this.state});

  @override
  State<GetIcons> createState() => _GetIconsState();
}
class _GetIconsState extends State<GetIcons> {
bool corruptTheme = false;
  List svgPaths=["","","","","",""];
  @override
  void initState() {
    initateLocations();
    super.initState();
  }
  initateLocations()async{
    Directory Ico = Directory(widget.icoPackPath);
    svgPaths[0]=await checkFile("org.gnome.files.svg");
    if(svgPaths[0]=="NotFound") {
      svgPaths[0]=await checkFile("org.gnome.Nautilus.svg");
      if(svgPaths[0]=="NotFound") {
        svgPaths[0]=await checkFile("org.gnome.Files.svg");
      }
    }
    svgPaths[1]=await checkFile("gnome-settings.svg");
    svgPaths[2]=await checkFile("org.gnome.weather.svg");
    if(svgPaths[2]=="NotFound") {
      svgPaths[2]=await checkFile("org.gnome.Weather.svg");
    }
    svgPaths[3]=await checkFile("org.gnome.gedit.svg");
    if(svgPaths[3]=="NotFound") {
      svgPaths[3]=await checkFile("org.gnome.Gedit.svg");
    }
    svgPaths[4]=await checkFile("org.gnome.totem.svg");
    if(svgPaths[4]=="NotFound") {
      svgPaths[4]=await checkFile("org.gnome.Totem.svg");
    }
    svgPaths[5]=await checkFile("org.gnome.music.svg");
    if(svgPaths[5]=="NotFound") {
      svgPaths[5]=await checkFile("org.gnome.Music.svg");
    }
    int nots=0;
for (var element in svgPaths) {
  if(element=="NotFound")nots++;
}
if(nots>=3) corruptTheme=true;
    setState(() {

    });
  }
  checkFile(String svgFile)async{
    String fle="${widget.icoPackPath}/apps/24/$svgFile";
    String fle1="${widget.icoPackPath}/apps/scalable/$svgFile";
    String fle2="${widget.icoPackPath}/24x24/apps/$svgFile";
    String fle3="${widget.icoPackPath}/128x128/apps/$svgFile";
    String fle4="${widget.icoPackPath}/64x64/apps/$svgFile";
    File f = File(fle);
    File f1 = File(fle1);
    File f2 = File(fle2);
    File f3 = File(fle3);
    File f4 = File(fle4);
    if(await f.exists()){
    return fle;
    }
    else if(await f1.exists()){
      return fle1;
    }
    else if(await f2.exists()){
      return fle2;
    }else if(await f3.exists()){
      return fle3;
    }else if(await f4.exists()){
      return fle4;
    }
    else {
      return "NotFound";
    }
  }
  double wd=50;
  double ht=50;

  @override
  Widget build(BuildContext context) {
    wd =(MediaQuery.sizeOf(context).width+MediaQuery.sizeOf(context).height)/50;
    ht=wd;
    
    return GetButtons(
      moreResponsive: true,
      ghost: ThemeDt.IconName==widget.icoPackPath.split("/").last,
      light: true,ltVal: 2,
      onTap: () {
        if(corruptTheme){
          WidsManager().showMessage(
            context: context,
            title : "Warning",
            message : "The icon pack you are trying to apply may be corrupted. Some system icons may not show after applying.",
            icon : Icons.warning_rounded,
            child : Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                GetButtons(light:true,onTap: (){
                  Navigator.pop(context);
                }, text: "Cancel",),
                const SizedBox(width: 10,),
                GetButtons(light:true,onTap: (){
                  applyIcon();
                  Navigator.pop(context);
                }, text: "Apply",),
              ],
            )
          );
        }
        else{
          applyIcon();
        }
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if(corruptTheme) WidsManager().getText("Icon-pack may be corrupt.", size: 15),
        if(!corruptTheme)  Expanded(child: GridView.builder(
            itemCount: 6,
            gridDelegate:
            const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
              crossAxisSpacing: 5,
              mainAxisSpacing: 5
            ),
            itemBuilder: (BuildContext context, int index) {
              if(svgPaths[index]=="NotFound"){
                return Icon(Icons.error, size: wd, color: ThemeDt.themeColors["fg"],);
              } else{
                return AnimatedOpacity(
                  duration: ThemeDt.d,
                  opacity: svgPaths[index]==""?0.0:1.0,
                    child: svgPaths[index]==""?Container():SvgPicture.file(
                File(svgPaths[index]),width: MediaQuery.sizeOf(context).width/10,
              ));
            }

            },
          )),
          WidsManager().getText(widget.icoPackPath.split("/").last, size: 10),


        ],
      ),
    );
  }

  void applyIcon() {
    widget.state();
    ThemeDt().setIcon(packName: widget.icoPackPath.split("/").last);
    ThemeDt.IconName=widget.icoPackPath.split("/").last;

  }
}

class GetTextBox extends StatefulWidget {
  final onDone;
  final double? width;
  final double? height;
  final String? hintText;
  final String? initText;
  const GetTextBox({super.key, this.onDone, this.height, this.width, this.hintText, this.initText});

  @override
  State<GetTextBox> createState() => _GetTextBoxState();
}
class _GetTextBoxState extends State<GetTextBox> {
  late TextEditingController tx;
  @override
  void initState() {
    tx=TextEditingController();
    tx.text=widget.initText ?? "";
    super.initState();
  }
  @override
  void dispose() {
    tx.dispose();
    super.dispose();
  }
  bool tapped=true;
  @override
  Widget build(BuildContext context) {
    return WidsManager().getContainer(
      border: tapped,
      width: widget.width,
      height: widget.height,
      child: Row(
        children: [
          Expanded(
            child: TextField(
              onChanged: (tx){
                setState(() {
                });
              },
              cursorColor: ThemeDt.themeColors["fg"],
              controller: tx,
              style: WidsManager().getText("s").style,
              decoration: InputDecoration(
                hintText: widget.hintText,
                hintStyle: WidsManager().getText("s").style,
                border: const OutlineInputBorder(
                  borderSide: BorderSide.none,
                  gapPadding: 0
                )
              ),
            ),
          ),
          if(tx.text!="")GetButtons(light: true,onTap: (){
setState(() {
  tx.text="";
});
          }, child: Icon(Icons.close_rounded, color: ThemeDt.themeColors["fg"],),),
          const SizedBox(width: 10,),
          if(tx.text!="")GetButtons(light: true,onTap: (){
            widget.onDone(tx.text);
          }, child: Icon(Icons.check_rounded, color: ThemeDt.themeColors["fg"],),)
        ],
      )
    );
  }
}
