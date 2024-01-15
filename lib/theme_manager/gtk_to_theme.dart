import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:gtkthememanager/back_end/gtk_theme_manager.dart';
import 'package:path_provider/path_provider.dart';
import 'package:process_run/process_run.dart';
import 'gtk_widgets.dart';


class ThemeDt {
  static Duration d = const Duration(milliseconds: 300);
  static Curve c = Curves.easeOutCubic;
  static String ThemeName = "";
  static String? GTK4;
  static String GTK3 = "";
  static String ShellName = "";
  static String IconName = "";
  static Map<String, Color> themeColors = {};
  static bool isIcoFolderMade = false;
  static bool isThemeFolderMade = false;

  //Getters - Get and populate Lists or set values accordingly
  Future<String> getGTKThemeName() async {
    //returns the GTK theme name currently in use
    var sh = Shell();
    String s = """
    gsettings get org.gnome.desktop.interface gtk-theme
""";
    String ThemeName = (await sh.run(s)).outText;
    ThemeName = ThemeName.replaceAll("'", "");
    return ThemeName;
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
    }
  }
  Future<bool> searchTheme({bool? dark, }) async {
    dark ??= true;
    String ThemePath =
        "${(await getApplicationDocumentsDirectory()).parent.path.replaceAll("'", "")}/.themes/$ThemeName";
    Directory themeDirectory = Directory(ThemePath);
    if (await themeDirectory.exists()) {
      String gtkfile="gtk.css-new";
      if (dark) {
        gtkfile = "gtk-dark.css-new";
      }
      var path = "$ThemePath/gtk-3.0/$gtkfile";
      File gtk = File(path);
      if (await gtk.exists()) {
        themeColors = extractColors(filePath: path);
        return true;
      } else{
        gtkfile="gtk.css";
        if (dark) {
          gtkfile = "gtk-dark.css";
        }
        path = "$ThemePath/gtk-3.0/$gtkfile";
        gtk = File(path);
        if (await gtk.exists()) {
          themeColors = extractColors(filePath: path);
          return true;
        }
      }
    }
    return false;
  }

  //Setters - Set mostly system level GTK Theme or Icons
  setGTK3(name, BuildContext context) async{
    try {
      await Shell().run("""
gsettings set org.gnome.desktop.interface gtk-theme $name
  """);
      ThemeDt.GTK3=name;
      ThemeDt.ThemeName=name;
      await ThemeDt().setTheme(respectSystem: false);
    }catch (e) {
      if(context.mounted) {
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
    }
  }
  setGTK4(String name, context)async{
    try {
      Directory dir = Directory("${SystemInfo.home}/.config/gtk-4.0");
      if(await dir.exists()){
        await dir.delete(recursive: true);
      }
      await Shell().run("""
      cp -r ${SystemInfo.home}/.themes/$name/gtk-4.0 ${SystemInfo.home}/.config
      """);
      File fl = File("${SystemInfo.home}/.config/gtk-4.0/theme-info.json");
      Map m ={"THEME_NAME":name};
      if(await fl.exists() == false){
        await fl.create();
      }else{
        fl.delete();
      }
      GTK4 = name;
      await fl.writeAsString(jsonEncode(m));
    }  catch (e) {
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
  setShell(String name, context)async{
    String Name=name;
    name="""
"'$name'"
""";
    try {
      await Shell().run("""dconf write /org/gnome/shell/extensions/user-theme/name $name""");
      ShellName=Name;
    }catch (e) {
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
    }
  }
  setTheme({bool? respectSystem, bool? dark}) async {
    respectSystem ??= true;
    try {
      if (respectSystem) ThemeName = await getGTKThemeName();
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
  Map<String, Color> extractColors({String? filePath, String? css}) {
    final colorMap = <String, Color>{};
    File? file;
    if(filePath!=null)file= File(filePath);

    try {
      final lines = (filePath==null)?css?.split("\n"):file?.readAsLinesSync();

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
         colorMap.addAll({"theme_fg_color":clr});
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
          colorMap.addAll({"theme_bg_color":clr});
        }
      }
    } catch (e) {
      print(e);
    }

    return colorMap;
  }
  generateTheme() {
    HSLColor bg = HSLColor.fromColor(themeColors["theme_bg_color"]!);
    HSLColor fg = HSLColor.fromColor(themeColors["theme_fg_color"]!);
    HSLColor sltBG;
    HSLColor sltFG;
    HSLColor altBG;
    HSLColor altFG;
    bool isLight = bg.lightness > 0.5;
    if (isLight) {
      sltBG = changeLight(color: bg, factor: 1.3, light: false);
      altBG = changeLight(color: bg, factor: 1.6, light: false);
      sltFG = changeLight(
        color: fg,
        factor: 1.3,
      );
      altFG = changeLight(
        color: fg,
        factor: 1.6,
      );
    } else {
      sltBG = changeLight(
        color: bg,
        factor: 1.75,
      );
      altBG = changeLight(
        color: bg,
        factor: 1.4,
      );
      sltFG = changeLight(color: fg, factor: 1.3, light: false);
      altFG = changeLight(color: fg, factor: 1.6, light: false);
    }
    themeColors = {
      "bg": bg.toColor(),
      "fg": fg.toColor(),
      "altfg": altFG.toColor(),
      "altbg": altBG.toColor(),
      "sltbg": sltBG.toColor(),
      "sltfg": sltFG.toColor(),
    };
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
    themeColors = {
      "theme_bg_color": const Color(0xff353535),
      "theme_fg_color": const Color(0xffffffff),
    };
    generateTheme();
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
    List<String>checkList=["gtk-2.0","gtk-3.0","gtk-4.0","gnome-shell", "index.theme"];
    List<String>checkListIco=["apps","categories","16x16","22x22", "24x24","64x64","128x128","index.theme", "animation", "panel"];
    Directory dir = Directory(path);
    List l = dir.listSync();
    for(var lst in l){
    if(checkList.contains(lst.toString().split("/").last.replaceAll("'", ""))){
      i++;
    }else if(checkListIco.contains(lst.toString().split("/").last.replaceAll("'", ""))){
      j++;
    }
    }
   if(i==checkList.length) return 1;
   if(j>=3&&j<=checkListIco.length) {
      return 2;
    }
    return 0;
 }
}
