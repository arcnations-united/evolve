import 'dart:io';
import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/material.dart';
import 'package:gtkthememanager/theme_manager/gtk_to_theme.dart';
import 'package:path_provider/path_provider.dart';

class ThemeManager {
  //Class to manage theme and icon list inside the system
  static List GTKThemeList = []; //List of all the GTK Themes installed
  static List iconList = []; //List of all the icons installed
  static List iconPathList = []; //List of paths of icons installed
  static Map<String, Map<String, bool>> themeSupport =
      {}; //Map to contain support info of theme
  static String themeFolder = ""; //The .themes folder path

  Future<bool> populateThemeList() async {
    //fetches list of GTK Themes installed
    GTKThemeList = [];
    themeSupport.clear();
    String home = ((await getApplicationDocumentsDirectory()).parent.path)
        .replaceAll("'", "");
    themeFolder = "$home/.themes";
    String themeFolder1 = "/usr/share/themes";
    Directory themes = Directory(themeFolder);
    Directory themes1 = Directory(themeFolder1);
    List files, files1;
    bool tst = false;
    if (await themes.exists()) {
      files = themes.listSync();
      for (var dir in files) {
        try {
          //makes sure the list is of directory
          Directory d = dir;
          String file = dir.path.replaceAll("'", "");
          bool isGTK4 = false,
              isGTK3 = false,
              isShell = false,
              isXFCE = false,
              isCinnamon = false;
          Directory gtk4 = Directory("$file/gtk-4.0");
          Directory gtk3 = Directory("$file/gtk-3.0");
          Directory shell = Directory("$file/gnome-shell");
          Directory xfce = Directory("$file/xfwm4");
          Directory cinnamon = Directory("$file/cinnamon");
          if (await gtk4.exists()) {
            isGTK4 = true;
          }
          if (await gtk3.exists()) {
            isGTK3 = true;
          }
          if (await shell.exists()) {
            isShell = true;
          }
          if (await xfce.exists()) {
            isXFCE = true;
          }
          if (await cinnamon.exists()) {
            isCinnamon = true;
          }
          themeSupport.addAll({
            d.path: {
              "gtk3": isGTK3,
              "gtk4": isGTK4,
              "shell": isShell,
              "xfce": isXFCE,
              "cin": isCinnamon
            }
          });
          GTKThemeList.add(d.path);
        } catch (e) {
          //continue if it throws exception when it is not a directory
          continue;
        }
      }
      tst = true;
    }
    if (await themes1.exists()) {
      files1 = themes1.listSync();
      for (var dir in files1) {
        try {
          //makes sure the list is of directory
          Directory d = dir;
          String file = dir.path.replaceAll("'", "");
          bool isGTK4 = false,
              isGTK3 = false,
              isShell = false,
              isXFCE = false,
              isCinnamon = false;
          Directory gtk4 = Directory("$file/gtk-4.0");
          Directory gtk3 = Directory("$file/gtk-3.0");
          Directory shell = Directory("$file/gnome-shell");
          Directory xfce = Directory("$file/xfwm4");
          Directory cinnamon = Directory("$file/cinnamon");
          if (await gtk4.exists()) {
            isGTK4 = true;
          }
          if (await gtk3.exists()) {
            isGTK3 = true;
          }
          if (await shell.exists()) {
            isShell = true;
          }
          if (await xfce.exists()) {
            isXFCE = true;
          }
          if (await cinnamon.exists()) {
            isCinnamon = true;
          }
          themeSupport.addAll({
            d.path: {
              "gtk3": isGTK3,
              "gtk4": isGTK4,
              "shell": isShell,
              "xfce": isXFCE,
              "cin": isCinnamon
            }
          });
          GTKThemeList.add(d.path);
        } catch (e) {
          //continue if it throws exception when it is not a directory
          continue;
        }
      }
      tst = true;
    }
    return tst;
  }

  Future<bool> populateIconList() async {
    //fetches list of icon packs installed
    iconList = [];
    iconPathList = [];
    String home = ((await getApplicationDocumentsDirectory()).parent.path)
        .replaceAll("'", "");
    String icoFolder = "$home/.icons";
    Directory icons = Directory(icoFolder);
    List files = [];
    bool icoExists = false;
    if (await icons.exists()) {
      files = icons.listSync();
      for (var dir in files) {
        try {
          Directory d = dir; //Makes sure only directories are populated
          String file = dir.path.replaceAll("'", "");
          String themeName = file.split("/").last;
          iconList.add(themeName);
          iconPathList.add(file);
        } catch (e) {
          //continue if it throws exception when it is not a directory
          continue;
        }
      }
      icoExists = true;
    }
    icoFolder = "$home/.local/share/icons";
    icons = Directory(icoFolder);
    if (await icons.exists()) {
      files = icons.listSync();
      for (var dir in files) {
        try {
          Directory d = dir; //Makes sure only directories are populated
          String file = dir.path.replaceAll("'", "");
          String themeName = file.split("/").last;
          iconList.add(themeName);
          iconPathList.add(file);
        } catch (e) {
          //continue if it throws exception when it is not a directory
          continue;
        }
      }
      icoExists = true;
    }
    return icoExists;
  }

  List<Color> extractColorsFromFile(String filePath, {bool? demo}) {
    //Creates a list of color from entered file path and returns it
    //Under demo mode it creates a new instance of the file.
    //I don't think demo mode is required anymore. Will look into this later.
    String oldFilePath = filePath;
    if (demo ?? false) {
      filePath = "$filePath-new";
      File newFl = File(filePath);
      File oldFl = File(oldFilePath);
      String contents = oldFl.readAsStringSync();
      if (newFl.existsSync() == false) {
        newFl.createSync();
        newFl.writeAsStringSync(contents);
      }
    }
    final content = File(filePath).readAsStringSync();
    final colorRegExp =
        RegExp(r'#([0-9a-fA-F]{6}|[0-9a-fA-F]{3})|rgba?\([^)]*\)');
    //RedExp to extract color in format of # (hexcode) or rgba
    final matches = colorRegExp.allMatches(content);
    final colors = matches.map((match) {
      final colorString = match.group(0)!;
      return parseColor(colorString);
    }).toList();
    return colors;
  }

  Color parseColor(String colorString) {
    //Accepts colour as a string. In form of hexcode or rgba
    //Returns the possible colour after conversion
    if (colorString.startsWith('#')) {
      return Color(int.parse(colorString.substring(1), radix: 16) + 0xFF000000);
    } else {
      // RGBA color
      final components = colorString
          .replaceAll('rgba(', '')
          .replaceAll('rgb(', '')
          .replaceAll(')', '')
          .split(',')
          .map((c) => c.trim())
          .toList();

      if (components.length == 4) {
        // With alpha channel
        return Color.fromRGBO(
          int.parse(components[0]),
          int.parse(components[1]),
          int.parse(components[2]),
          double.parse(components[3]),
        );
      } else if (components.length == 3) {
        // Without alpha channel
        return Color.fromARGB(
          255,
          int.parse(components[0]),
          int.parse(components[1]),
          int.parse(components[2]),
        );
      } else {
        throw FormatException('Invalid color format: $colorString');
      }
    }
  }

  List<Color> removeColorsWithDifferentOpacity(List<Color> colors) {
    final Set<Color> uniqueColors = {};

    for (var color in colors) {
      uniqueColors.add(color);
    }

    return uniqueColors.toList();
  }

  convertFile(filePath, {bool? demo}) {
    //Accept file path, convert contents into colour list without repetition of colours
    List<Color> col = extractColorsFromFile(filePath, demo: demo);
    col = removeColorsWithDifferentOpacity(col);
    return col;
  }

  Future<void> updateColors(
      {bool? test,
      required String path,
      required List<Color> col,
      required List<Color> oldCol,
      bool? updateAll,
      List<int>? editedIndex,
      bool? update}) async {
    //Update colours inside a CSS code
    update ??= true;
    String cssContents =
        await File((test ?? false) ? "$path-new" : path).readAsString();
    String oldRGBA = "", oldHex = "", oldRGB = "";
    String newRGBA = "", newHex = "", newRGB = "";
    if (updateAll ?? false) {
      for (int i = 0; i < oldCol.length; i++) {
        Color oldColor = oldCol[i];
        Color newColor = col[i];
        oldRGBA = "rgba(${oldColor.red}, ${oldColor.green}, ${oldColor.blue}";
        oldRGB = "rgb(${oldColor.red}, ${oldColor.green}, ${oldColor.blue}";
        oldHex = oldColor.hex;
        newRGBA = "rgba(${newColor.red}, ${newColor.green}, ${newColor.blue}";
        newRGB = "rgb(${newColor.red}, ${newColor.green}, ${newColor.blue}";
        newHex = newColor.hex;
        cssContents = cssContents.replaceAll(oldRGBA, newRGBA);
        cssContents = cssContents.replaceAll(oldRGB, newRGB);
        cssContents =
            cssContents.replaceAll(oldHex.toLowerCase(), newHex.toLowerCase());
        cssContents =
            cssContents.replaceAll(oldHex.toUpperCase(), newHex.toUpperCase());
      }
    } else {
      for (var element in editedIndex!) {
        Color oldColor = oldCol[element];
        Color newColor = col[element];
        oldRGBA = "rgba(${oldColor.red}, ${oldColor.green}, ${oldColor.blue}";
        oldRGB = "rgb(${oldColor.red}, ${oldColor.green}, ${oldColor.blue}";
        oldHex = oldColor.hex;
        newRGBA = "rgba(${newColor.red}, ${newColor.green}, ${newColor.blue}";
        newRGB = "rgb(${newColor.red}, ${newColor.green}, ${newColor.blue}";
        newHex = newColor.hex;
        cssContents = cssContents.replaceAll(oldRGBA, newRGBA);
        cssContents = cssContents.replaceAll(oldRGB, newRGB);
        cssContents =
            cssContents.replaceAll(oldHex.toLowerCase(), newHex.toLowerCase());
        cssContents =
            cssContents.replaceAll(oldHex.toUpperCase(), newHex.toUpperCase());
      }
    }

    File cssFile = File((test ?? false) ? "$path-new" : path);
    if (await cssFile.exists()) {
      await cssFile.create();
      await cssFile.writeAsString(cssContents);
    } else {
      await cssFile.writeAsString(cssContents);
    }
    if (test ?? false == false) {
      cssFile = File("$path-new");
    }
      if (await cssFile.exists()) {
        await cssFile.delete();
      }
      await cssFile.writeAsString(cssContents);
      print(cssFile.path);
    if (update) {
      ThemeDt.themeColors =
          await ThemeDt().extractColors(filePath: cssFile.path);
      ThemeDt().generateTheme();
    }
    cssContents="";
  }
}


