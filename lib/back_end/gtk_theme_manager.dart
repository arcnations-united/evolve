import 'dart:io';
import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/material.dart';
import 'package:gtkthememanager/theme_manager/gtk_to_theme.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:path_provider/path_provider.dart';
import 'package:process_run/process_run.dart';

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
      if (await cssFile.exists()) {
        await cssFile.delete();
      }
      await cssFile.writeAsString(cssContents);
    }
    if (update) {
      ThemeDt.themeColors =
          await ThemeDt().extractColors(filePath: cssFile.path);
      ThemeDt().generateTheme();
    }
  }
}

class AdaptiveTheming {
  static PaletteGenerator? paletteGenerator;
  static Map<String, Map<String, Color>> paletteColours = {};
  genColours(context) async {
    bool adaptiveThemePresent = false;
    String themePath = ThemeDt.ThemeNamePath;
    if (!ThemeDt.ThemeNamePath.endsWith("Adaptive")) {
      String themePathNew = "$themePath-Adaptive";
      Directory thms = Directory(themePathNew);
      if (await thms.exists() != true) {
        await thms.create();
        await Shell().run("cp -r -T $themePath $themePathNew");

      }
      await ThemeDt().setGTK3("$themePath-Adaptive".split("/").last, context);
      await ThemeDt().setGTK4("$themePath-Adaptive", context);
      await ThemeDt().setShell("$themePath-Adaptive".split("/").last, context);
      await ThemeDt().setTheme(respectSystem: true);
    } else {
      adaptiveThemePresent = true;
    }
    double factor = 1.1;

    String wallpaper = (await Shell().run("""
    gsettings get org.gnome.desktop.background picture-uri
    """)).outText.replaceAll("file://", "").replaceAll("'", "");
if(wallpaper==ThemeDt.oldWallpaper&&adaptiveThemePresent&&paletteColours.isNotEmpty){
  return;
}
ThemeDt.oldWallpaper=wallpaper;
    paletteGenerator =
        await PaletteGenerator.fromImageProvider(FileImage(File(wallpaper)));
    paletteColours.clear();

    if (paletteGenerator?.darkMutedColor != null) {
      paletteColours["darkMutedColor"] = {
        "bg": ThemeDt()
            .changeLight(
                color:
                    HSLColor.fromColor(paletteGenerator!.darkMutedColor!.color),
                factor: factor + 0.2)
            .toColor(),
        "fg": ThemeDt()
            .changeLight(
                color:
                    HSLColor.fromColor(paletteGenerator!.darkMutedColor!.color),
                factor: factor + 8)
            .toColor(),
        "sltbg": ThemeDt()
            .changeLight(
                color:
                    HSLColor.fromColor(paletteGenerator!.darkMutedColor!.color),
                factor: factor + 2)
            .toColor(),
        "rowSltBG": ThemeDt()
            .changeLight(
                color:
                    HSLColor.fromColor(paletteGenerator!.darkMutedColor!.color),
                factor: factor + 0.7)
            .toColor(),
        "rowSltLabel": ThemeDt()
            .changeLight(
                color:
                    HSLColor.fromColor(paletteGenerator!.darkMutedColor!.color),
                factor: factor + 4.5)
            .toColor(),
      };
    }
    if (paletteGenerator?.vibrantColor != null) {
      bool isLight = false;
      if (HSLColor.fromColor(paletteGenerator!.dominantColor!.color).lightness >
          0.5) {
        isLight = true;
      }
      paletteColours["vibrantColor"] = {
        "bg": paletteGenerator!.vibrantColor!.color,
        "fg": ThemeDt()
            .changeLight(
                light: isLight,
                color:
                    HSLColor.fromColor(paletteGenerator!.vibrantColor!.color),
                factor: factor + 2)
            .toColor(),
        "sltbg": ThemeDt()
            .changeLight(
                light: !isLight,
                color:
                    HSLColor.fromColor(paletteGenerator!.vibrantColor!.color),
                factor: factor)
            .toColor(),
        "rowSltBG": ThemeDt()
            .changeLight(
                light: !isLight,
                color:
                    HSLColor.fromColor(paletteGenerator!.vibrantColor!.color),
                factor: factor + 2.2)
            .toColor(),
        "rowSltLabel": ThemeDt()
            .changeLight(
                light: isLight,
                color:
                    HSLColor.fromColor(paletteGenerator!.vibrantColor!.color),
                factor: factor + 4.5)
            .toColor(),
      };
    }
    if (paletteGenerator?.darkVibrantColor != null) {
      paletteColours["darkVibrantColor"] ={
        "bg": ThemeDt()
            .changeLight(
                color: HSLColor.fromColor(
                    paletteGenerator!.darkVibrantColor!.color),
                factor: factor + 0.2)
            .toColor(),
        "fg": ThemeDt()
            .changeLight(
                color: HSLColor.fromColor(
                    paletteGenerator!.darkVibrantColor!.color),
                factor: factor + 4)
            .toColor(),
        "sltbg": ThemeDt()
            .changeLight(
                color: HSLColor.fromColor(
                    paletteGenerator!.darkVibrantColor!.color),
                factor: factor)
            .toColor(),
        "rowSltBG": ThemeDt()
            .changeLight(
                color: HSLColor.fromColor(
                    paletteGenerator!.darkVibrantColor!.color),
                factor: factor + 0.5)
            .toColor(),
        "rowSltLabel": ThemeDt()
            .changeLight(
                color: HSLColor.fromColor(
                    paletteGenerator!.darkVibrantColor!.color),
                factor: factor + 7.5)
            .toColor(),
      };
    }
    if (paletteGenerator?.lightMutedColor != null) {
      paletteColours["lightMutedColor"] = {
        "bg": paletteGenerator!.lightMutedColor!.color,
        "fg": ThemeDt()
            .changeLight(
                color: HSLColor.fromColor(
                    paletteGenerator!.lightMutedColor!.color),
                factor: factor + 2,
                light: false)
            .toColor(),
        "sltbg": ThemeDt()
            .changeLight(
                light: false,
                color: HSLColor.fromColor(
                    paletteGenerator!.lightMutedColor!.color),
                factor: factor)
            .toColor(),
        "rowSltBG": ThemeDt()
            .changeLight(
                light: false,
                color: HSLColor.fromColor(
                    paletteGenerator!.lightMutedColor!.color),
                factor: factor + 0.2)
            .toColor(),
        "rowSltLabel": ThemeDt()
            .changeLight(
                color: HSLColor.fromColor(
                    paletteGenerator!.lightMutedColor!.color),
                factor: factor + 4.5)
            .toColor(),
      };
    }
    if (paletteGenerator?.lightVibrantColor != null) {
      paletteColours["lightVibrantColor"] ={
        "bg": paletteGenerator!.lightVibrantColor!.color,
        "fg": ThemeDt()
            .changeLight(
                color: HSLColor.fromColor(
                    paletteGenerator!.lightVibrantColor!.color),
                factor: factor + 2,
                light: false)
            .toColor(),
        "sltbg": ThemeDt()
            .changeLight(
                light: false,
                color: HSLColor.fromColor(
                    paletteGenerator!.lightVibrantColor!.color),
                factor: factor)
            .toColor(),
        "rowSltBG": ThemeDt()
            .changeLight(
                light: false,
                color: HSLColor.fromColor(
                    paletteGenerator!.lightVibrantColor!.color),
                factor: factor + 0.2)
            .toColor(),
        "rowSltLabel": ThemeDt()
            .changeLight(
                light: false,
                color: HSLColor.fromColor(
                    paletteGenerator!.lightVibrantColor!.color),
                factor: factor + 4.5)
            .toColor(),
      };
    }
    if (paletteGenerator?.mutedColor != null) {
      paletteColours["mutedColor"] ={
        "bg": ThemeDt()
            .changeLight(
              color: HSLColor.fromColor(paletteGenerator!.mutedColor!.color),
              factor: factor + 1,
              light: false,
            )
            .toColor(),
        "fg": ThemeDt()
            .changeLight(
                color: HSLColor.fromColor(paletteGenerator!.mutedColor!.color),
                factor: factor + 2)
            .toColor(),
        "sltbg": ThemeDt()
            .changeLight(
                color: HSLColor.fromColor(paletteGenerator!.mutedColor!.color),
                factor: factor)
            .toColor(),
        "rowSltBG": ThemeDt()
            .changeLight(
                light: false,
                color: HSLColor.fromColor(paletteGenerator!.mutedColor!.color),
                factor: factor + 0.2)
            .toColor(),
        "rowSltLabel": ThemeDt()
            .changeLight(
                color: HSLColor.fromColor(paletteGenerator!.mutedColor!.color),
                factor: factor + 4.5)
            .toColor(),
      };
    }
    if (paletteGenerator?.dominantColor != null) {
      bool isLight = false;
      double factor1 = factor;
      if (HSLColor.fromColor(paletteGenerator!.dominantColor!.color).lightness >
          0.5) {
        isLight = true;
      }
      paletteColours["dominantColor"] = {
        "bg": paletteGenerator!.dominantColor!.color,
        "fg": ThemeDt()
            .changeLight(
                light: !isLight,
                color:
                    HSLColor.fromColor(paletteGenerator!.dominantColor!.color),
                factor: factor1 + 9)
            .toColor(),
        "sltbg": ThemeDt()
            .changeLight(
                color:
                    HSLColor.fromColor(paletteGenerator!.dominantColor!.color),
                factor: factor1)
            .toColor(),
        "rowSltBG": ThemeDt()
            .changeLight(
                color:
                    HSLColor.fromColor(paletteGenerator!.dominantColor!.color),
                factor: factor1 + 1.5)
            .toColor(),
        "rowSltLabel": ThemeDt()
            .changeLight(
                color:
                    HSLColor.fromColor(paletteGenerator!.dominantColor!.color),
                factor: factor + 4.5)
            .toColor(),
      };
    }
    await contrastSafety();
    Map pals=Map.from(paletteColours);
    pals.forEach((key, value) {
      paletteColours[key]=ThemeDt().generateTheme(shouldReturn: true, themeColors: value);
    });
  }

  contrastSafety({file}) async {
    String themePath = ThemeDt.ThemeNamePath;
    Directory theme = Directory(themePath).parent;
    themePath = themePath.split("/").last;
    themePath = themePath.substring(0, themePath.lastIndexOf("-"));
    Map origColours = await ThemeDt()
        .extractColors(filePath: "${theme.path}/$themePath/gtk-3.0/gtk.css");

    //makes sure colour generation is contrast-safe
    bool ltTheme = HSLColor.fromColor(origColours["bg"]).lightness > 0.5;
    Map paletteColoursCopy = Map.from(paletteColours);
    paletteColours.forEach((key, value) {
      HSLColor bg = HSLColor.fromColor(value["bg"]!);
      HSLColor fg = HSLColor.fromColor(value["fg"]!);
      HSLColor sltbg = HSLColor.fromColor(value["sltbg"]!);
      HSLColor sidebarRowBG = HSLColor.fromColor(value["rowSltBG"]!);
      HSLColor sideRowLabel = HSLColor.fromColor(value["rowSltLabel"]!);
      if (!ltTheme) {
        if(bg.lightness>0.5) {
          paletteColoursCopy.remove(key);
        } else{
          paletteColoursCopy[key]?["bg"] =
              adjustColour(bar: 0.2, colour: bg, satbar:0.4,darken: true, );
          paletteColoursCopy[key]?["fg"] =
              adjustColour(bar: 0.7, colour: fg,darken: false);
          paletteColoursCopy[key]?["sltbg"] =
              adjustColour(bar: 0.2, colour: sltbg,darken: false);
          paletteColoursCopy[key]?["rowSltLabel"] =
              adjustColour(bar: 0.2, colour: sideRowLabel, darken: false);
          paletteColoursCopy[key]?["rowSltBG"] =
              adjustColour(bar: 0.2, colour: sidebarRowBG, darken: true);
        }
      } else {
        if(bg.lightness<0.5) {
          paletteColoursCopy.remove(key);
        } else{
          paletteColoursCopy[key]?["bg"] =
              adjustColour(bar: 0.2, colour: bg, satbar:0.4,darken: false, );
          paletteColoursCopy[key]?["fg"] =
              adjustColour(bar: 0.7, colour: fg,darken: true);
          paletteColoursCopy[key]?["sltbg"] =
              adjustColour(bar: 0.2, colour: sltbg,darken: true);
          paletteColoursCopy[key]?["rowSltLabel"] =
              adjustColour(bar: 0.2, colour: sideRowLabel, darken: true);
          paletteColoursCopy[key]?["rowSltBG"] =
              adjustColour(bar: 0.2, colour: sidebarRowBG, darken: false);
        }
      }
    });
    paletteColours = Map.from(paletteColoursCopy);
  }

  adjustColour({required double bar, double? satbar, required HSLColor colour, bool? darken}) {
    if (darken ?? true) {
      for (;;) {
        if (colour.lightness >= bar) {
          colour = colour.withLightness(colour.lightness / 2);
        } else {
          break;
        }
      }
    } else {
      for (;;) {
        if (colour.lightness <= bar) {
          colour = colour.withLightness(
              colour.lightness * 2 >= 0.8 ? 0.8 : colour.lightness * 2);
        } else {
          break;
        }
      }
    }
   if(satbar!=null) {
      if (darken ?? true) {
        for (;;) {
          if (colour.saturation >= satbar) {
            colour = colour.withSaturation(colour.saturation / 2);
          } else {
            break;
          }
        }
      } else {
        for (;;) {
          if (colour.saturation <= satbar) {
            colour = colour.withSaturation(
                colour.saturation * 2 >= 0.8 ? 0.8 : colour.saturation * 2);
          } else {
            break;
          }
        }
      }
    }
    return colour.toColor();
  }
}
