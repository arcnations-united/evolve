//clearly needed a different file for implementation
//so here we are!
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:process_run/process_run.dart';
import '../theme_manager/gtk_to_theme.dart';
import 'app_data.dart';
import 'colour_info.dart';
import 'gtk_theme_manager.dart';

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
   // await contrastSafety();
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
    Map origColours = await ThemeDt
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
  makeThemeAdaptive({required String filePath, required int active} )async{
    Directory themeFolder;
    if(filePath.endsWith(".css")||filePath.endsWith(".css-new")){
      themeFolder = Directory(filePath).parent.parent;
    }else{
      themeFolder = Directory(filePath);
    }

    //ADAPT GTK3 COLOURS
    File gtk3 = File("${themeFolder.path}/gtk-3.0/gtk.css");
    File gtk3_dark = File("${themeFolder.path}/gtk-3.0/gtk-dark.css");
    await updateColours(path: gtk3.path, active: active);
    await updateColours(path: gtk3_dark.path, active: active);
    await ThemeDt().setGTK3("Adwaita",);
    await ThemeDt().setGTK3(themeFolder.path.split("/").last,);
    AppData.DataFile[
    "AUTOTHEMECOLOR"] =
        active;
    await AppData()
        .writeDataFile();
    
    //ADAPT GTK4 COLOURS
    try{
      File gtk4 = File("${themeFolder.path}/gtk-4.0/gtk.css");
      File gtk4_dark = File("${themeFolder.path}/gtk-4.0/gtk-dark.css");
     await updateColours(path: gtk4.path, active: active);
     await updateColours(path: gtk4_dark.path, active: active);
     await ThemeDt().setGTK4(themeFolder.path,);
    }catch(e){
      //GTK4 may not be present in such a case catch
      print("GTK4 not supported.");
      print(e);
    } //ADAPT SHELL COLOURS
    try{
      File shell = File("${themeFolder.path}/gnome-shell/gnome-shell.css");
      File shell_new = File("${themeFolder.path}/gnome-shell/gnome-shell.css-new");
      if(await shell_new.exists()){
        await shell_new.delete();
      }
     await updateColours(path: shell.path, active: active);
     await ThemeDt().setShell("Adwaita",);
      await ThemeDt().setShell(themeFolder.path.split("/").last,);
    }catch(e){
      //SHELL Theme may not be present in such a case catch
      print("Shell Theme not supported.");
      print(e);
    }
  }
  updateColours({required String path, required int active}) async {
    List <Color> col = await ThemeManager().convertFile(path, demo: true);
    List <Color> oldCol = List.of(col);
    for (int i=0;i<col.length;i++) {
      col[i]=ColourManipulate().setHue(col[i], fromColor: paletteColours.values.elementAt(active).values.elementAt(0));
    }
    await ThemeManager()
        .updateColors(
        path: path,
        col: col,
        oldCol: oldCol,
        updateAll: true,
        update: false);
  }
}