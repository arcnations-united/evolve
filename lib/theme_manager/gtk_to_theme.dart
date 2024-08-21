import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gtkthememanager/back_end/gtk_theme_manager.dart';
import 'package:path_provider/path_provider.dart';
import 'package:process_run/process_run.dart';
import 'gtk_widgets.dart';
import 'image_resizer.dart';

//edited how colours are fetched from gtk.css
class ThemeDt {
  static ThemeData themeData=ThemeData();
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
    "rowSltBG": const Color(0xff727272),
    "rowSltLabel": const Color(0xffe3eeff),
  };
  static bool isIcoFolderMade = false;
  static bool isThemeFolderMade = false;
  setAppTheme(){
    double headSize=30;

    var textTheme = TextTheme(
          headlineLarge:TextStyle(fontSize:headSize,  fontWeight: FontWeight.w700,  color: themeColors["fg"]!),
          headlineMedium :TextStyle(fontSize:headSize/1.3, fontWeight: FontWeight.w600,  color: themeColors["fg"]!),
          headlineSmall :TextStyle(fontSize:headSize/1.3/1.3, fontWeight: FontWeight.w600, color: themeColors["fg"]!),
          bodyLarge:TextStyle(fontSize:headSize/1.6, fontWeight: FontWeight.w400,color: themeColors["fg"]!),
          bodyMedium :TextStyle(fontSize:headSize/1.6/1.3, fontWeight: FontWeight.w300, color: themeColors["fg"]! ),
          bodySmall :TextStyle(fontSize:headSize/1.6/1.3/1.3,fontWeight: FontWeight.w300, height: 0.96 ,color: themeColors["fg"]!),
          displaySmall: TextStyle(fontSize:headSize/1.6/1.6/1.3, fontWeight: FontWeight.w300, color: themeColors["fg"]!),
          labelMedium: TextStyle(fontSize:headSize/1.6/1.6/1.3, fontWeight: FontWeight.w300,color: themeColors["fg"]! ),
          labelLarge: TextStyle(fontSize:headSize/1.6/1.6, fontWeight: FontWeight.w300,color: themeColors["rowSltLabel"]! ),
        );
    themeData=ThemeData(

      textSelectionTheme: TextSelectionThemeData(
        selectionColor: ThemeDt.themeColors["altfg"]!.withOpacity(0.2)
      ),
        useMaterial3: true,
        colorScheme: ColorScheme(
            brightness: Brightness.light,
            primary: themeColors["altbg"]!,
            onPrimary: themeColors["altfg"]!,
            secondary: themeColors["rowSltBG"]!,
            onSecondary: themeColors["rowSltLabel"]!,
            error: Colors.red.shade800, onError: Colors.red.shade100, surface: themeColors["altbg"]!, onSurface: themeColors["altfg"]!
        ),
        buttonTheme: ButtonThemeData(
        colorScheme: ColorScheme(
            brightness: Brightness.light,
            primary: themeColors["altbg"]!,
            onPrimary: themeColors["altfg"]!,
            secondary: themeColors["rowSltBG"]!,
            onSecondary: themeColors["rowSltLabel"]!,
            error: Colors.red.shade800, onError: Colors.red.shade100, surface: themeColors["altbg"]!, onSurface: themeColors["altfg"]!
        ),
        ),
        scaffoldBackgroundColor: themeColors["bg"],
        textTheme: textTheme
    );
  }
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
 static Future<bool> searchTheme(dark) async {
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
  static setGTK3(String name) async{
    if(name =="default")name="Adwaita";
    try {
      await Shell().run("""
gsettings set org.gnome.desktop.interface gtk-theme $name
  """);
      ThemeDt.GTK3=name;
      await ThemeDt().setTheme(respectSystem: false);
    }catch (e) {
         print(e);
    }
  }
  static setGTK4(String pathToTheme)async{
    try {
      Directory dir = Directory("${SystemInfo.home}/.config/gtk-4.0");
      if(await dir.exists()){
        await dir.delete(recursive: true);
      }
      if(pathToTheme=="default")return;

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
   print(e);
    }
  }
  static setGTK4Isolate(String colonedTheme)async{
    String home=colonedTheme.split(":").last;
    String pathToTheme=colonedTheme.split(":").first;
    try {
      Directory dir = Directory("${home}/.config/gtk-4.0");
      if(await dir.exists()){
        await dir.delete(recursive: true);
      }
      if(pathToTheme=="default")return;

      await Shell().run("""
      cp -r $pathToTheme/gtk-4.0 ${home}/.config
      """);
      File fl = File("${home}/.config/gtk-4.0/theme-info.json");
      Map m ={"THEME_NAME":pathToTheme.split("/").last.replaceAll("/", "")};
      if(await fl.exists() == false){
        await fl.create();
      }else{
        fl.delete();
      }
      GTK4 = pathToTheme.split("/").last.replaceAll("/", "");
      await fl.writeAsString(jsonEncode(m));
    }  catch (e) {
   print(e);
    }
  }
  static setShell(String name)async{
    if(name=="default"){
      name="Adwaita";
    }
    String Name=name;
    name="""
"'$name'"
""";
    try {
      await Shell().run("""dconf write /org/gnome/shell/extensions/user-theme/name $name""");
      ShellName=Name;
    }catch (e) {
        print(e);

    }
  }
  setTheme({bool? respectSystem, bool? dark}) async {
    respectSystem ??= true;
    try {
      if (respectSystem) ThemeNamePath = await getGTKThemePath();
      if (await searchTheme(dark)) {

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
 static Future<Map<String, Color>> extractColors({String? filePath, String? css}) async {
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
   if(colorMap["rowSltBG"]==null) {
      HSLColor b = HSLColor.fromColor(colorMap["bg"]!);
      if (b.lightness > 0.4) {
        colorMap["rowSltBG"] = b.withLightness(b.lightness / 2).toColor();
      } else {
        double lt = b.lightness * 2;
        if (lt > 1) {
          lt = 0.86;
        }
        colorMap["rowSltBG"] = b.withLightness(lt).toColor();
      }
    }
    return colorMap;
  }
  static bool lightTheme=false;
  generateTheme({bool? shouldReturn, Map? themeColors}) {
    themeColors ??= ThemeDt.themeColors;
    HSLColor bg = HSLColor.fromColor(themeColors["bg"]!);
    HSLColor fg = HSLColor.fromColor(themeColors["fg"]!);
    HSLColor sltBG = HSLColor.fromColor(themeColors["sltbg"]!);
    HSLColor rowSltBG = HSLColor.fromColor(themeColors["rowSltBG"] ?? const Color(0xff727272));
    HSLColor rowSltLabel = HSLColor.fromColor(themeColors["rowSltLabel"] ?? const Color(0xffe3eeff));
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
        color: rowSltLabel,
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
      sltFG = changeLight(color: rowSltLabel, factor: 1.3, light: false);
      altFG = changeLight(color: rowSltLabel, factor: 1.2, light: true);
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
      setAppTheme();
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
listResFile(String resFilePath) async {
    String res = (await Shell().run("""gresource list $resFilePath""")).outText;
    List str = res.split('\n');
    return str;
}
   static extractResToFile({required String resLoc, required String resFileLoc}) async{
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
    if(await File("${SystemInfo.home}/.NexData/compressed/img.jpg").exists()){
     await File("${SystemInfo.home}/.NexData/compressed/img.jpg").delete();
    }
    compute(ImageResizer.reduceImageSizeAndQuality,"$s:${SystemInfo.home}");
   await Shell().run("""gsettings set org.gnome.desktop.background picture-uri 'file://$s'""");
   await Shell(throwOnError: false).run("""gsettings set org.gnome.desktop.background picture-uri-dark 'file://$s'""");
  }

   Future<void> setFlatpakTheme(String globalAppliedTheme, BuildContext context) async {
    WidsManager().showMessage(title: "Authenticator", message: "Enter admin password to apply Flatpak Theme", context: context,
        child: GetTextBox(
isSensitive: true,
          onDone: (txt) async {
            Navigator.pop(context);
            try{
              Directory dir = Directory(globalAppliedTheme);
              String run ="""
bash -c "echo \"$txt\" | sudo -S flatpak override --filesystem=$globalAppliedTheme"
bash -c "echo \"$txt\" | sudo -S flatpak override --env=GTK_THEME=${dir.path.split("/").last}"
              """;
             await Shell().run(run);
              run ="""
              """;
             await Shell().run(run);
            }catch(e){
WidsManager().showMessage(title: "Error", message: e.toString(), context: context);
            }
          },
        ));
  }
}
class SystemInfo{
  //kinda late when I realised I needed this
  //stores system level info like home directory path and all
  static String home="";
  static String shellVers = "";
  static String exactShellVers = "";
  Future<void> getHome() async {
    home = ((await getApplicationDocumentsDirectory()).parent.path)
        .replaceAll("'", "");
  }
  Future<void> getShellVersion() async{
   try {
     shellVers = (await Shell().run("gnome-shell --version")).outText;
   }catch (e) {
     WidsManager().notify(null,head: "ERROR!", message: "Can't determine Shell Version. Some features won't work properly.");
   }
     shellVers=shellVers.toLowerCase();
     shellVers=shellVers.replaceAll("gnome shell ", "");
     exactShellVers=shellVers;
     if(shellVers.contains(".")){
       shellVers=shellVers.substring(0,shellVers.indexOf("."));
     }
  }
  Future<int> isTheme(String path)async{

    int i =0;
    int j =0;
    //TODO gtk 3.x/4.x support
    List<String>checkListIco=["apps","actions","categories","16x16","22x22", "24x24","64x64","128x128","index.theme", "animation", "panel", "symbolic"];
    List<String>forbid=["0","1","2","3","4", "5","6","7","8", "9",];
    Directory dir = Directory(path);
    List l = dir.listSync();
    if(l.length==1){
      if(l[0]=="gnome-shell")return 1;
    }
    if(checkListIco.contains(path.split("/").last))return 0;
    if(forbid.contains(path.split("/").last[0]))return 0;
if(path.contains(".themes")||path.contains(".icons")||path.contains(".config")) return 0;
bool containsIndexTheme=false;
    for(var lst in l){
if(lst is Directory) {
  //print("object");
  var folderName = lst
      .toString()
      .split("/")
      .last
      .replaceAll("'", "");
  if (folderName == "index.theme") {
    containsIndexTheme = true;
  }
  if (folderName.startsWith("gtk-3")) {
    if (File("${lst.path}/gtk-dark.css").existsSync()
    && File("${lst.path}/gtk.css").existsSync()) {
      return 1;
    }
  } else if (checkListIco.contains(folderName)) {
    j++;
  }
}
    }
    if(j>0){
      if(containsIndexTheme)return 2;
    }
    if(j>=3&&j<=checkListIco.length) {
      return 2;
    }
    return 0;
  }
}
