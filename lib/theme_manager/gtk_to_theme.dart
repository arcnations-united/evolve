import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:gtkthememanager/back_end/gtk_theme_manager.dart';
import 'package:path_provider/path_provider.dart';
import 'package:process_run/process_run.dart';
import 'gtk_widgets.dart';

//edited how colours are fetched from gtk.css
class ThemeDt {
  static Duration d = const Duration(milliseconds: 300);
  static Curve c = Curves.easeOutCubic;
  static String ThemeNamePath = "";
  static String? GTK4;
  static String GTK3 = "";
  static String ShellName = "";
  static String IconName = "";
  static FontWeight boldText=FontWeight.w400;
  static Map<String, Color> themeColors = {
    "bg": const Color(0xff353535),
    "altbg": const Color(0xff595757),
    "fg": const Color(0xffffffff),
    "altfg": const Color(0xffdcdcdc),
    "sltbg": const Color(0xff565656),
    "rowSltBG": const Color(0xff2b2f37),
    "rowSltLabel": const Color(0xffe3eeff),
  };
  static bool isIcoFolderMade = false;
  static bool isThemeFolderMade = false;

  //Getters - Get and populate Lists or set values accordingly
  Future<String> getGTKThemePath() async {
    //returns the GTK theme name currently in use
    var sh = Shell();
    String s = """
    gsettings get org.gnome.desktop.interface gtk-theme
""";
    String ThemeName = (await sh.run(s)).outText;
    ThemeName = ThemeName.replaceAll("'", "");
    Directory d = Directory("/usr/share/themes/$ThemeName");
    if(await d.exists()==false){
      d = Directory("${SystemInfo.home}/.themes/$ThemeName");
    }
    if(await d.exists()==false){
      return ThemeName;
    }
    return d.path;
  }
  Future<String> getShellThemeName() async {
    //returns the GTK theme name currently in use
    var sh = Shell();
    String s = """
 dconf read /org/gnome/shell/extensions/user-theme/name
""";
    String ThemeName = (await sh.run(s)).outText;
    ThemeName = ThemeName.replaceAll("'", "");
    return ThemeName;
  }
  Future<String> getIconThemeName() async {
    //returns the GTK theme name currently in use
    var sh = Shell();
    String s = """
gsettings get org.gnome.desktop.interface icon-theme
""";
    String IconName = (await sh.run(s)).outText;
    IconName = IconName.replaceAll("'", "");
    return IconName;
  }
  Future<void> getGTK4ThemeName() async {
    try {
      Map m={};
      Directory gtk = Directory("${SystemInfo.home}/.config/gtk-4.0");
      if(!(await gtk.exists())){
        await gtk.create(recursive: true);
      }
      //No idea why I used json but... yeah okay I guess?
      File gtkName = File("${SystemInfo.home}/.config/gtk-4.0/theme-info.json");
      if(await gtkName.exists()){
        String s = await gtkName.readAsString();
        m=jsonDecode(s);
        GTK4=m["THEME_NAME"];
      }
    } catch (e) {
      GTK4="Not Set";
      // TODO
    }
  }
  Future<bool> searchTheme({bool? dark,}) async {
    dark ??= true;
    Directory themeDirectory = Directory(ThemeNamePath);
      String gtkfile="gtk.css-new";
      if (dark) {
        gtkfile = "gtk-dark.css-new";
      }
      var path = "$ThemeNamePath/gtk-3.0/$gtkfile";
      File gtk = File(path);
      if (await gtk.exists()) {
        themeColors = await extractColors(filePath: path);
        return true;
      } else {
        gtkfile = "gtk.css";
        if (dark) {
          gtkfile = "gtk-dark.css";
        }
        path = "$ThemeNamePath/gtk-3.0/$gtkfile";
        gtk = File(path);
        if (await gtk.exists()) {
          themeColors = await extractColors(filePath: path);
          return true;
        }
      }


    return false;
  }

  //Setters - Set mostly system level GTK Theme or Icons
  setGTK3(name,  [context]) async{
    try {
      await Shell().run("""
gsettings set org.gnome.desktop.interface gtk-theme $name
  """);
      ThemeDt.GTK3=name;
      await ThemeDt().setTheme(respectSystem: false);
    }catch (e) {
       if(context!=null) {
         WidsManager().showMessage(
            title: "Error",
            message:
            "GTK 3.0 theme could not be applied. Make sure you have user-themes extension installed.",
            icon: Icons.error_rounded,
            child: GetButtons(
                text: "Close",
                onTap: () {
                  Navigator.pop(context);
                }),
            context: context);
       }
       else{
         print(e);
       }
    }
  }
  setGTK4(String pathToTheme, [context])async{
    try {
      Directory dir = Directory("${SystemInfo.home}/.config/gtk-4.0");
      if(await dir.exists()){
        await dir.delete(recursive: true);
      }
      await Shell().run("""
      cp -r $pathToTheme/gtk-4.0 ${SystemInfo.home}/.config
      """);
      File fl = File("${SystemInfo.home}/.config/gtk-4.0/theme-info.json");
      Map m ={"THEME_NAME":pathToTheme.split("/").last.replaceAll("/", "")};
      if(await fl.exists() == false){
        await fl.create();
      }else{
        fl.delete();
      }
      GTK4 = pathToTheme.split("/").last.replaceAll("/", "");
      await fl.writeAsString(jsonEncode(m));
    }  catch (e) {
    if(context!=null) {
      WidsManager().showMessage(
          title: "Error",
          message: "The theme could not be applied!",
          icon: Icons.error,
          child: GetButtons(onTap: (){
            Navigator.pop(context);
          },text:"Close",),
          context: context);
    }
    }
  }
  setShell(String name, [context])async{
    String Name=name;
    name="""
"'$name'"
""";
    try {
      await Shell().run("""dconf write /org/gnome/shell/extensions/user-theme/name $name""");
      ShellName=Name;
    }catch (e) {
      if(context!=null){
        WidsManager().showMessage(
            title: "Warning",
            message:
                "Shell theme could not be applied. Make sure you have user-themes extension installed.",
            icon: Icons.warning_rounded,
            child: GetButtons(
                text: "Close",
                onTap: () {
                  Navigator.pop(context);
                }),
            context: context);
      }else{
        print(e);
      }
    }
  }
  setTheme({bool? respectSystem, bool? dark}) async {
    respectSystem ??= true;
    try {
      if (respectSystem) ThemeNamePath = await getGTKThemePath();
      if (await searchTheme(dark: dark)) {
        generateTheme();

      } else {
        initiateFallbackTheme();
      }
    } catch (e) {
      initiateFallbackTheme();
    }
  }
  setIcon({required String packName}) {
    String s = """
gsettings set org.gnome.desktop.interface icon-theme "$packName"
""";
    Shell().run(s);
  }

  //Get colours from applied GTK Theme to set app theme.
  Future<Map<String, Color>> extractColors({String? filePath, String? css}) async {
    final colorMap = <String, Color>{};
    File? file;
    if(filePath!=null)file= File(filePath);
    try {
      var lines = (filePath==null)?css?.split("\n"):file?.readAsLinesSync();
      if(lines!.length<=10){
        for (String line in lines) {
          if(line.startsWith("@import url(")){
            line=line.trim();
            String val = line.substring(line.indexOf("(")+1,line.indexOf(")")).replaceAll('"', '');

            if(val.startsWith("resource:")){
              String resLoc = val.substring("resource://".length);
              Directory theme = Directory(file!.parent.path);
              List dirFiles = theme.listSync();
              String resFileLoc = "";
              for(var fl in dirFiles){
                if(fl.path.endsWith(".gresource")){
                  resFileLoc=fl.path;
                  break;
                }
              }
              String res="";
               try {
                  res = await extractResToFile(resLoc : resLoc, resFileLoc: resFileLoc,);
               }catch (e) {
                 print(e);
                 print("Please run the failed command and restart the app to apply the GTK Theme to the application.");
               }
              file = File("${file.parent.path}/theme.css");
             if(res!=""){
               file.writeAsString(res);
               lines=res.split("\n");
             }else {
               lines = file.readAsLinesSync();
             }
            }
          }
        }
      }
      bool slt=false;
      bool rowSltLabel=false;
      for (String line in lines!) {

        line=line.trim();
        if(line.startsWith("@define-color theme_fg_color")){
          int indEnd = "@define-color theme_fg_color".length;
          String val = line.substring(indEnd, line.length-1).trim();
          Color? clr;
          if(val=="white") {
            clr=Colors.white;
          } else{
            clr = ThemeManager().parseColor(val);
          }
          colorMap.addAll({"fg":clr});
        }
        if(line.startsWith("@define-color theme_bg_color")){
          int indEnd = "@define-color theme_bg_color".length;
          String val = line.substring(indEnd, line.length-1).trim();
          Color? clr;
          if(val=="white") {
            clr=Colors.white;
          } else{
            clr = ThemeManager().parseColor(val);
          }
          colorMap.addAll({"bg":clr});
        }

        if(line.startsWith("@define-color theme_selected_bg_color")){
          int indEnd = "@define-color theme_selected_bg_color".length;
          String val = line.substring(indEnd, line.length-1).trim();
          Color? clr;
          if(val=="white") {
            clr=Colors.white;
          } else{
            clr = ThemeManager().parseColor(val);
          }
          colorMap.addAll({"sltbg":clr});
        } if(slt==false&&line.startsWith("list.navigation-sidebar > row:selected {") || line.startsWith(".navigation-sidebar > row:selected:hover {")){

          slt=true;
          continue;
        } if(rowSltLabel==false&&line.startsWith("list.navigation-sidebar > row:selected label {")||line.startsWith(".navigation-sidebar > row:selected label")){

          rowSltLabel=true;
          continue;
        }
        if(slt){
          try{
            int indEnd = "background-color:".length;
            String val = line.substring(indEnd, line.length - 1).trim();

            Color? clr;
            if (val == "white") {
              clr = Colors.white;
            } else {
              clr = ThemeManager().parseColor(val);
            }
            colorMap.addAll({"rowSltBG": clr});
            slt = false;
          }catch(e){
            continue;
          }
        }if(rowSltLabel){
          try{
            int indEnd = "color:".length;
            String val = line.substring(indEnd, line.length - 1).trim();

            Color? clr;
            if (val == "white") {
              clr = Colors.white;
            } else {
              clr = ThemeManager().parseColor(val);
            }
            colorMap.addAll({"rowSltLabel": clr});
            rowSltLabel = false;
          }catch(e){
            continue;
          }
        }
      }
    } catch (e) {
      print(e);
    }

    return colorMap;
  }
  static bool lightTheme=false;
  generateTheme({bool? shouldReturn, Map? themeColors}) {
    themeColors ??= ThemeDt.themeColors;
    HSLColor bg = HSLColor.fromColor(themeColors["bg"]!);
    HSLColor fg = HSLColor.fromColor(themeColors["fg"]!);
    HSLColor sltBG = HSLColor.fromColor(themeColors["sltbg"]!);
    HSLColor rowSltBG = HSLColor.fromColor(themeColors["rowSltBG"] ?? Color(0xff2b2f37));
    HSLColor rowSltLabel = HSLColor.fromColor(themeColors["rowSltLabel"] ?? Color(0xffe3eeff));
    HSLColor sltFG;
    HSLColor altBG;
    HSLColor altFG;
    bool isLight = bg.lightness > 0.5;
    lightTheme=isLight;
    if (isLight) {
      //sltBG = changeLight(color: bg, factor: 1.3, light: false);
      altBG = changeLight(color: bg, factor: 1.1,);
      sltFG = changeLight(
        color: fg,
        factor: 1.1,
      );
      altFG = changeLight(
        color: fg,
        factor: 1.2,
      );
    } else {
     // sltBG = changeLight(
      //  color: bg,
      //  factor: 1.75,
      //);
      altBG = changeLight(
        color: bg,
        factor: 1.4,
      );
      sltFG = changeLight(color: fg, factor: 1.3, light: false);
      altFG = changeLight(color: fg, factor: 1.6, light: false);
    }
    if(shouldReturn ?? false){
      return  {
        "bg": bg.toColor(),
        "fg": fg.toColor(),
        "altfg": altFG.toColor(),
        "altbg": altBG.toColor(),
        "sltbg": sltBG.toColor(),
        "sltfg": sltFG.toColor(),
        "rowSltBG": rowSltBG.toColor(),
        "rowSltLabel": rowSltLabel.toColor(),
      };
    }else {
      ThemeDt.themeColors = {
      "bg": bg.toColor(),
      "fg": fg.toColor(),
      "altfg": altFG.toColor(),
      "altbg": altBG.toColor(),
      "sltbg": sltBG.toColor(),
      "sltfg": sltFG.toColor(),
        "rowSltBG": rowSltBG.toColor(),
        "rowSltLabel": rowSltLabel.toColor(),
    };
    }
  }
  HSLColor changeLight({required HSLColor color, required double factor, bool? light}) {
    light ??= true;
    if (light) {
      return color.withLightness(
          color.lightness * factor > 1.0 ? 0.8 : color.lightness * factor);
    } else {
      return color.withLightness(color.lightness / factor);
    }
  }
  initiateFallbackTheme() {
    print("Fallback theme initiated - Adwaita colours");
    themeColors = {
      "bg": const Color(0xff353535),
      "fg": const Color(0xffffffff),
      "sltbg": const Color(0xff565656),
      "rowSltBG": const Color(0xff757474),
      "rowSltLabel": const Color(0xffe3eeff),
    };
    generateTheme();
  }

   extractResToFile({required String resLoc, required String resFileLoc}) async{
    String finalPath = resFileLoc.substring(0,resFileLoc.lastIndexOf("/"),);
String cmd = "gresource extract /home/arcnations/.themes/Yaru/gtk-3.0/gtk.gresource /com/ubuntu/themes/Yaru/3.0/gtk-dark.css >/home/arcnations/.themes/Yaru/gtk-3.0/theme.css";

//await Shell().run(cmd);
     final result = await Process.run(
       'gresource',
       ['extract', resFileLoc, resLoc,],
     );
     return result.stdout;
  }
static String oldWallpaper="";
  Future<void> setWallpaper(String s) async{
    oldWallpaper=WidsManager.wallPath;
   await Shell().run("""gsettings set org.gnome.desktop.background picture-uri 'file://$s'""");
   await Shell().run("""gsettings set org.gnome.desktop.background picture-uri-dark 'file://$s'""");
  }
}
class SystemInfo{
  //kinda late when I realised I needed this
  //stores system level info like home directory path and all
  static String home="";
  Future<void> getHome() async {
    home = ((await getApplicationDocumentsDirectory()).parent.path)
        .replaceAll("'", "");
  }

  Future<int> isTheme(String path)async{

    int i =0;
    int j =0;
    List<String>checkList=["gtk-2.0","gtk-3.0","gnome-shell",];
    List<String>checkListIco=["apps","actions","categories","16x16","22x22", "24x24","64x64","128x128","index.theme", "animation", "panel"];
    Directory dir = Directory(path);
    List l = dir.listSync();

    for(var lst in l){
      if(checkList.contains(lst.toString().split("/").last.replaceAll("'", ""))){
        i++;
      }else if(checkListIco.contains(lst.toString().split("/").last.replaceAll("'", ""))){
        j++;
      }
    }
    if(i==checkList.length) {
      if(l.length>10)return 0;
      return 1;
    }
    if(j>=3&&j<=checkListIco.length) {
      return 2;
    }
    return 0;
  }
}
