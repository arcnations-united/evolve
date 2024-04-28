import 'dart:io';
import 'dart:ui';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/material.dart';
import 'package:gtkthememanager/back_end/app_data.dart';
import 'package:gtkthememanager/back_end/colour_info.dart';
import 'package:gtkthememanager/back_end/gtk_theme_manager.dart';
import 'package:gtkthememanager/theme_manager/gtk_to_theme.dart';
import 'package:gtkthememanager/theme_manager/gtk_widgets.dart';
import 'package:gtkthememanager/theme_manager/tab_manage.dart';

import '../back_end/adaptive_theming.dart';

//manages wallpaper adaptive theming along with gtk colour edit
//thought implementing here would help since we are already changing colours of gtk themes inside this page
//but I don't think it was useful enough. Should have opted for separate dart file but yeah its fine...
class ChangeColors extends StatefulWidget {
  String filePath;
  final bool? editAccents;
  final Function() state;
  final bool? update;
  final bool? isDefinedFile;
  ChangeColors(
      {super.key,
        this.isDefinedFile,
      required this.filePath,
      required this.state,
      this.update,
      this.editAccents});

  @override
  State<ChangeColors> createState() => _ChangeColorsState();
}

class _ChangeColorsState extends State<ChangeColors> {
  refreshPage(){
    setState(() {

    });
  }
  bool isLoading = true;
  bool editAvailable = false;
  int active = 0;
  Widget wall = Container();
  List<Color> col = [];
  List<Color> oldCol = [];
  @override
  void initState() {
    // TODO: implement initState
    try {
      if (widget.editAccents ?? false) {
        setAccentEditPage();
        // oldCol=[ThemeDt.themeColors["bg"]!,ThemeDt.themeColors["fg"]!,ThemeDt.themeColors["sltbg"]!,ThemeDt.themeColors["altbg"]!,ThemeDt.themeColors["altfg"]!];
      } else {
        col = ThemeManager().convertFile(widget.filePath, demo: true);
        oldCol = List.of(col);
        active = 0;
      }
    } catch (e) {
      badGTK = true;
      WidsManager().showMessage(
          title: "Error",
          message: "The GTK Theme is invalid",
          icon: Icons.error_rounded,
          child: GetButtons(
              text: "Close",
              onTap: () {
                Navigator.pop(context);
                Navigator.pop(context);
              }),
          context: context);
    }

    super.initState();
  }

  bool badGTK = false;
  List<int> editedIndex = [];
  double satVal = 0, ltness = 0;
  setAccentEditPage() async {
    await Future.delayed(const Duration(milliseconds: 100));
    satVal = HSLColor.fromColor(ThemeDt.themeColors["bg"]!).saturation;
    ltness = HSLColor.fromColor(ThemeDt.themeColors["bg"]!).lightness;
    await AdaptiveTheming().genColours(context);
    wall = await WidsManager().getWallpaperSample();
    if (AppData.DataFile["AUTOTHEMECOLOR"] == "max") {
      AppData.DataFile["AUTOTHEMECOLOR"] =
          AdaptiveTheming.paletteColours.length - 1;
    } else {
      active = AppData.DataFile["AUTOTHEMECOLOR"] ?? 0;
    }
    isLoading = false;

    setState(() {});
  }
  bool isUpdatingState=false;
  bool filterUse = false;
  double? hue, sat, val;
  bool showColorHex = false;
  @override
  Widget build(BuildContext context) {
    try {
      if (widget.editAccents ?? false == true) {
        return PopScope(
          canPop: true,
          onPopInvoked: (didPop) async {
            //await Future.delayed(const Duration(milliseconds: 200));
            await ThemeDt().setTheme(respectSystem: true);
            AppData().writeDataFile();
            refreshPage();
          },
          child: Scaffold(
            appBar: AppBar(
              backgroundColor: ThemeDt.themeColors["bg"],
              foregroundColor: ThemeDt.themeColors["fg"],
            ),
            backgroundColor: ThemeDt.themeColors["bg"],
            body: Padding(
              padding: const EdgeInsets.all(18.0),
              child: Stack(
                children: [
                  AnimatedOpacity(
                    duration: const Duration(seconds: 1),
                    opacity: isLoading ? 0 : 0.3,
                    child: ImageFiltered(
                      imageFilter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
                      child: Image.file(
                        File(WidsManager.wallPath),
                        height: double.infinity,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      WidsManager()
                          .getText("Choose a colour palette.", size: 15),
                      const SizedBox(
                        height: 25,
                      ),
                      Container(
                        height: MediaQuery.sizeOf(context).height - 138,
                        child: Stack(
                          children: <Widget>[
                            if (isLoading == false)
                              AnimatedPositioned(
                                duration: ThemeDt.d,
                                curve: ThemeDt.c,
                                left: 0,
                                child: Container(
                                  height: 300,
                                  child: Stack(
                                    children: [
                                      Center(
                                        child: Container(
                                            width: MediaQuery.sizeOf(context)
                                                    .width /
                                                (TabManager.isLargeScreen
                                                    ? 1.5
                                                    : 1),
                                            child: wall),
                                      ),
                                      Center(
                                        child: Container(
                                          padding: const EdgeInsets.all(10),
                                          margin: EdgeInsets.only(
                                              left: !TabManager.isLargeScreen
                                                  ? 10
                                                  : MediaQuery.sizeOf(context)
                                                          .width /
                                                      1.5 /
                                                      8),
                                          height: MediaQuery.sizeOf(context)
                                                  .height /
                                              3,
                                          width: !TabManager.isLargeScreen
                                              ? 300
                                              : MediaQuery.sizeOf(context)
                                                      .width /
                                                  1.5 /
                                                  1.4,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            boxShadow: [
                                              BoxShadow(
                                                  color:
                                                      Colors.black.withOpacity(
                                                    0.2,
                                                  ),
                                                  blurRadius: 10,
                                                  offset: const Offset(3, 8)),
                                            ],
                                            color: ThemeDt.themeColors["bg"],
                                          ),
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: <Widget>[
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: <Widget>[
                                                  WidsManager().getText(
                                                      "Preview Window",
                                                      size: 11),
                                                  Icon(Icons.circle,
                                                      color: Colors.red[300],
                                                      size: 12)
                                                ],
                                              ),
                                              Container(
                                                  width: 260,
                                                  child: WidsManager().getText(
                                                      "This is a sample generated window to help you understand how the colour might look. This does not represent the final result.\n\nYou may press Okay to apply the theme system-wide.",
                                                      size: 11)),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.end,
                                                children: [
                                                  GestureDetector(
                                                    onTap: () {
                                                      editAvailable = true;
                                                      setState(() {});
                                                    },
                                                    child: WidsManager()
                                                        .getContainer(
                                                            child: WidsManager()
                                                                .getText(
                                                                    "Not Okay",
                                                                    size: 11)),
                                                  ),
                                                  const SizedBox(
                                                    width: 10,
                                                  ),
                                                  GestureDetector(
                                                    onTap: () async {
                                                      // List <Color> col=[ThemeDt.themeColors["bg"]!,ThemeDt.themeColors["fg"]!,ThemeDt.themeColors["sltbg"]!,ThemeDt.themeColors["altbg"]!,ThemeDt.themeColors["altfg"]!];
                                                      WidsManager().showMessage(
                                                          title: 'Info',
                                                          message:
                                                              "Applying theme system-wide",
                                                          context: context);
                                                      await AdaptiveTheming()
                                                          .makeThemeAdaptive(
                                                              filePath: widget
                                                                  .filePath,
                                                              active: active);
                                                      Navigator.pop(context);
                                                      Navigator.pop(context);
                                                    },
                                                    child: WidsManager()
                                                        .getContainer(
                                                            border: true,
                                                            child: WidsManager()
                                                                .getText("Okay",
                                                                    size: 11)),
                                                  ),
                                                ],
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                      AnimatedSlide(
                                        offset: editAvailable
                                            ? const Offset(0.05, 0.05)
                                            : const Offset(0, 0),
                                        curve: Curves.easeOutCubic,
                                        duration:
                                            const Duration(milliseconds: 500),
                                        child: AnimatedScale(
                                          scale: editAvailable ? 1 : 0,
                                          curve: Curves.easeOutCubic,
                                          duration:
                                              const Duration(milliseconds: 500),
                                          child: Center(
                                            child: Container(
                                              padding: const EdgeInsets.all(10),
                                              margin: EdgeInsets.only(
                                                  left: TabManager.isLargeScreen
                                                      ? MediaQuery.sizeOf(
                                                                  context)
                                                              .width /
                                                          1.5 /
                                                          8
                                                      : 10),
                                              height: MediaQuery.sizeOf(context)
                                                      .height /
                                                  3,
                                              width: TabManager.isLargeScreen
                                                  ? MediaQuery.sizeOf(context)
                                                          .width /
                                                      1.5 /
                                                      1.4
                                                  : 320,
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                boxShadow: [
                                                  BoxShadow(
                                                      color: Colors.black
                                                          .withOpacity(
                                                        0.2,
                                                      ),
                                                      blurRadius: 10,
                                                      offset:
                                                          const Offset(3, 8)),
                                                ],
                                                color:
                                                    ThemeDt.themeColors["bg"],
                                              ),
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: <Widget>[
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: <Widget>[
                                                      WidsManager().getText(
                                                          "Edit Parameters",
                                                          size: 11),
                                                      GestureDetector(
                                                          onTap: () {
                                                            editAvailable =
                                                                false;
                                                            setState(() {});
                                                          },
                                                          child: Icon(
                                                              Icons.circle,
                                                              color: Colors
                                                                  .red[300],
                                                              size: 12))
                                                    ],
                                                  ),
                                                  Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      WidsManager().getText(
                                                          "Saturation"),
                                                      Slider(
                                                          min: 0,
                                                          max: 1,
                                                          value: satVal,
                                                          activeColor: ThemeDt
                                                                  .themeColors[
                                                              "altfg"],
                                                          onChanged: (val) {
                                                            satVal = val;
                                                            editPallete();
                                                            setState(() {});
                                                          }),
                                                      WidsManager().getText(
                                                          "Brightness"),
                                                      Slider(
                                                          min: 0,
                                                          max: 1,
                                                          value: ltness,
                                                          activeColor: ThemeDt
                                                                  .themeColors[
                                                              "altfg"],
                                                          onChanged: (val) {
                                                            ltness = val;
                                                            editPallete();
                                                            setState(() {});
                                                          }),
                                                    ],
                                                  ),
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.end,
                                                    children: [
                                                      GestureDetector(
                                                        onTap: () async {
                                                          setState(() {
                                                            editAvailable =
                                                                false;
                                                          });
                                                        },
                                                        child: WidsManager()
                                                            .getContainer(
                                                                border: true,
                                                                child: WidsManager()
                                                                    .getText(
                                                                        "Okay",
                                                                        size:
                                                                            11)),
                                                      ),
                                                    ],
                                                  )
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            if (isLoading)
                              WidsManager().getText("Generating Palette...")
                            else
                              AnimatedPositioned(
                                duration: ThemeDt.d,
                                curve: ThemeDt.c,
                                top: TabManager.isLargeScreen ? 0 : 320,
                                right: 0,
                                child: AnimatedContainer(
                                  duration: ThemeDt.d,
                                  curve: ThemeDt.c,
                                  height:
                                      MediaQuery.sizeOf(context).height / 2 -
                                          (TabManager.isLargeScreen ? 50 : 130),
                                  width: MediaQuery.sizeOf(context).width -
                                      (TabManager.isLargeScreen
                                          ? (MediaQuery.sizeOf(context).width /
                                                  (1.5)) +
                                              50
                                          : 40),
                                  child: ListView(
                                    children: [
                                      for (int i = 0;
                                          i <
                                              AdaptiveTheming
                                                  .paletteColours.keys.length;
                                          i++)
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              bottom: 12.0),
                                          child: GetButtons(
                                              light: true,
                                              ltVal: 1.2,
                                              ghost: active == i,
                                              onTap: () {
                                                active = i;
                                                Map themeCopy =
                                                    ThemeDt.themeColors;
                                                ThemeDt.themeColors
                                                    .forEach((key, value) {
                                                  themeCopy[key] =
                                                      ColourManipulate().setHue(
                                                          value,
                                                          fromColor:
                                                              AdaptiveTheming
                                                                  .paletteColours
                                                                  .values
                                                                  .elementAt(i)
                                                                  .values
                                                                  .elementAt(
                                                                      0));
                                                });
                                                satVal = HSLColor.fromColor(
                                                        ThemeDt
                                                            .themeColors["bg"]!)
                                                    .saturation;
                                                ltness = HSLColor.fromColor(
                                                        ThemeDt
                                                            .themeColors["bg"]!)
                                                    .lightness;
                                                refreshPage();
                                              },
                                              child: Container(
                                                  height: 50,
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      WidsManager().getText(
                                                          AdaptiveTheming
                                                              .paletteColours
                                                              .keys
                                                              .elementAt(i)),
                                                      Container(
                                                          height: 30,
                                                          child: getPalette(
                                                              AdaptiveTheming
                                                                  .paletteColours
                                                                  .keys
                                                                  .elementAt(
                                                                      i))),
                                                    ],
                                                  ))),
                                        )
                                    ],
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      }
      return Scaffold(
        appBar: AppBar(
          title: GestureDetector(
            onPanUpdate: (dt) {
              appWindow.startDragging();
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                GetPopMenuButton(
                  widgetOnTap:
                  StatefulBuilder(builder: (BuildContext context,
                      void Function(void Function()) setState) {
                    return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          WidsManager().getText("Filter", size: 24),
                          WidsManager().getText(
                            "Edit group of colours according to set threshold.",
                          ),
                          if (filterUse)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(
                                  height: 12,
                                ),
                                WidsManager().getText("Hue $hue", size: 10),
                                Slider(
                                    min: 0.0,
                                    max: 360,
                                    value: hue ?? 0.0,
                                    activeColor:
                                        HSLColor.fromAHSL(1, hue ?? 0, 0.5, 0.5)
                                            .toColor(),
                                    onChanged: (dt) {
                                      setState(() {
                                        hue = dt;
                                      });
                                      filterEditedIndex();
                                      refreshPage();
                                    }),
                                const SizedBox(
                                  height: 20,
                                ),
                                WidsManager()
                                    .getText("Saturation $sat", size: 10),
                                Slider(
                                    value: sat ?? 0.0,
                                    activeColor: ThemeDt.themeColors["altfg"],
                                    onChanged: (dt) {
                                      setState(() {
                                        sat = dt;
                                      });
                                      filterEditedIndex();

                                      refreshPage();
                                    }),
                                const SizedBox(
                                  height: 20,
                                ),
                                WidsManager().getText("Value $val", size: 10),
                                Slider(
                                    value: val ?? 0.0,
                                    activeColor: ThemeDt.themeColors["altfg"],
                                    onChanged: (dt) {
                                      setState(() {
                                        val = dt;
                                      });
                                      filterEditedIndex();

                                      refreshPage();
                                    }),
                                const SizedBox(height: 10,),

                                GetTextBox(
                                  hintText: "Search hexcode",
                                  onDone: (tx){
                                    String srcHex=tx;
                                    srcHex= srcHex.replaceAll("#", "");
                                    editedIndex.clear();
                                    for(int i =0;i<col.length;i++){
                                      if(col[i].hex.toLowerCase()==srcHex){
                                        editedIndex.add(i);
                                      }
                                    }
                                    refreshPage();
                                    Navigator.pop(context);
                                  },
                                  height: 60,
                                ),
                                const SizedBox(height: 20,),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    WidsManager().getText("Invert"),
                                    GetToggleButton(
                                        value: invertFilter,
                                        onTap: () {
                                          setState(() {
                                            invertFilter = !invertFilter;
                                          });
                                          filterEditedIndex();
                                          refreshPage();
                                        })
                                  ],
                                ),
                              ],
                            ),
                          const SizedBox(
                            height: 13,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              WidsManager().getText("Use filter"),
                              GetToggleButton(
                                  value: filterUse,
                                  onTap: () {
                                    setState(() {
                                      hue = null;
                                      sat = null;
                                      val = null;
                                      filterUse = !filterUse;
                                    });
                                    if (filterUse) {
                                      filterEditedIndex();
                                    }
                                    refreshPage();
                                  })
                            ],
                          ),
                        ]);
                  }),
                  child: Icon(
                    Icons.filter_alt_rounded,
                    color: ThemeDt.themeColors["fg"],
                  ),
                ),
                    const SizedBox(width: 10,),
                    GetPopMenuButton(
                      tooltip: "HSV Adjustments",
                      widgetOnTap: AnimatedCrossFade(
                        duration: ThemeDt.d,
                        crossFadeState: isUpdatingState?CrossFadeState.showSecond:CrossFadeState.showFirst,
                        secondChild: Container(),
                        firstChild: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            GetTextBox(
                              hintText: "Hue Factor",
                              height: 50,
                              onDone: (dt) async {
                            Navigator.pop(context);
                                if (double.tryParse(dt) == null ||
                                    double.tryParse(dt)! >= 2.0 ||
                                    double.tryParse(dt)! <= 0.0) {
                                  WidsManager().showMessage(
                                      title: "Error",
                                      message:
                                          "The value must be a floating number and between 0.0 - 1.0",
                                      context: context);
                                } else {
                                  if(!filterUse) {
                                    editedIndex.clear();
                                  }

                                  for (int i = 0; i < col.length; i++) {
                                   if(!filterUse) {
                                  editedIndex.add(i);
                                  Color c = col[i];
                                  var hslColor = HSLColor.fromColor(c);
                                  double hueVal = hslColor.hue;
                                  if (hueVal == 0) hueVal = 2;
                                  hueVal = hueVal * double.parse(dt);
                                  if (hueVal >= 360.0) hueVal = 2;
                                  c = hslColor.withHue(hueVal).toColor();
                                  col[i] = c;
                                } else{
                                     if(editedIndex.contains(i)){
                                       Color c = col[i];
                                       var hslColor = HSLColor.fromColor(c);
                                       double hueVal = hslColor.hue;
                                       if (hueVal == 0) hueVal = 2;
                                       hueVal = hueVal * double.parse(dt);
                                       if (hueVal >= 360.0) hueVal = 2;
                                       c = hslColor.withHue(hueVal).toColor();
                                       col[i] = c;
                                     }
                                   }
                              }

                                }

                                await ThemeManager().updateColors(
                                    test: true,
                                    path: widget.filePath,
                                    col: col,
                                    editedIndex: editedIndex,
                                    oldCol: oldCol,
                                    update: widget.update);
                                oldCol = List.of(col);
                                refreshPage();
                                setState(() {});
                                //hue=dt;
                              },
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            GetTextBox(
                              hintText: "Saturation Factor",
                              height: 50,
                              onDone: (dt) async {
                                Navigator.pop(context);

                                if (double.tryParse(dt) == null ||
                                    double.tryParse(dt)! >= 2.0 ||
                                    double.tryParse(dt)! <= 0.0) {
                                  WidsManager().showMessage(
                                      title: "Error",
                                      message:
                                          "The value must be a floating number and between 0.0 - 1.0",
                                      context: context);
                                } else {
                               if(!filterUse) {
                                editedIndex.clear();
                              }

                              for (int i = 0; i < col.length; i++) {
                                   if(filterUse){


                                     if(editedIndex.contains(i)){
                                       Color c = col[i];
                                       var hslColor = HSLColor.fromColor(c);
                                       double saturationVal = hslColor.saturation;
                                       if (saturationVal == 0) saturationVal = 0.01;
                                       saturationVal =
                                           saturationVal * double.parse(dt);
                                       if (saturationVal >= 1.0) {
                                         saturationVal =
                                         (hslColor.saturation > 0.5) ? 0.95 : 0.5;
                                       }
                                       c = hslColor
                                           .withSaturation(saturationVal)
                                           .toColor();
                                       col[i] = c;
                                     }
                                   } else{
                                  editedIndex.add(i);
                                  Color c = col[i];
                                  var hslColor = HSLColor.fromColor(c);
                                  double saturationVal = hslColor.saturation;
                                  if (saturationVal == 0) saturationVal = 0.01;
                                  saturationVal =
                                      saturationVal * double.parse(dt);
                                  if (saturationVal >= 1.0) {
                                    saturationVal =
                                        (hslColor.saturation > 0.5) ? 0.95 : 0.5;
                                  }
                                  c = hslColor
                                      .withSaturation(saturationVal)
                                      .toColor();
                                  col[i] = c;
                                }
                              }

                                } await ThemeManager().updateColors(
                                    test: true,
                                    path: widget.filePath,
                                    col: col,
                                    editedIndex: editedIndex,
                                    oldCol: oldCol,
                                    update: widget.update);
                                oldCol = List.of(col);
                                refreshPage();
                                setState(() {});
                              },
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            GetTextBox(
                              hintText: "Value Factor",
                              height: 50,
                              onDone: (dt) async {
                                Navigator.pop(context);
                                if(!filterUse)   editedIndex.clear();
                                for (int i = 0; i < col.length; i++) {
                                  if(filterUse){
                                    if(editedIndex.contains(i)){
                                      Color c = col[i];
                                      var hslColor = HSLColor.fromColor(c);
                                      double lightnessVal = hslColor.lightness;
                                      if (lightnessVal == 0) lightnessVal = 0.01;
                                      lightnessVal =
                                          lightnessVal * double.parse(dt);
                                      if (lightnessVal >= 1.0) {
                                        lightnessVal =
                                        (hslColor.lightness > 0.5) ? 0.95 : 0.5;
                                      }
                                      c = hslColor
                                          .withLightness(lightnessVal)
                                          .toColor();
                                      col[i] = c;
                                    }
                                  } else{
                                    editedIndex.add(i);
                                    Color c = col[i];
                                    var hslColor = HSLColor.fromColor(c);
                                    double lightnessVal = hslColor.lightness;
                                    if (lightnessVal == 0) lightnessVal = 0.01;
                                    lightnessVal =
                                        lightnessVal * double.parse(dt);
                                    if (lightnessVal >= 1.0) {
                                      lightnessVal =
                                      (hslColor.lightness > 0.5) ? 0.95 : 0.5;
                                    }
                                    c = hslColor
                                        .withLightness(lightnessVal)
                                        .toColor();
                                    col[i] = c;
                                  }
                                }
                                await ThemeManager().updateColors(
                                    test: true,
                                    path: widget.filePath,
                                    col: col,
                                    editedIndex: editedIndex,
                                    oldCol: oldCol,
                                    update: widget.update);
                                oldCol = List.of(col);
                                refreshPage();
                                setState(() {});
                              },
                            ),
                          ],
                        ),
                      ),
                      child: const Icon(Icons.auto_graph_rounded),
                    ),
                const SizedBox(width: 5,),
                WidsManager().getTooltip(
                  text: "Toggle colour codes",
                  child: IconButton(
                      onPressed: () {
                        setState(() {
                          showColorHex = !showColorHex;
                        });
                      },
                      icon: const Icon(Icons.info_outline_rounded)),
                ),
                if (!TabManager.isSuperLarge)
                  WidsManager().getTooltip(
                    text: "Reset changes",
                    child: IconButton(
                      icon: const Icon(Icons.undo_rounded),
                      onPressed: () async {
                        await resetColors();
                      },
                    ),
                  ),
              ],
            ),
          ),
          backgroundColor: ThemeDt.themeColors["bg"],
          foregroundColor: ThemeDt.themeColors["fg"],
        ),
        backgroundColor: ThemeDt.themeColors["bg"],
        body: (badGTK)
            ? Container()
            : Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (!TabManager.isSuperLarge)
                            WidsManager().getText("Pick a colour to edit"),
                          if (!TabManager.isSuperLarge)
                            const SizedBox(
                              height: 10,
                            ),
                          Expanded(
                              child: GridView.builder(
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                                    childAspectRatio: showColorHex ? 2 : 1,
                                    crossAxisCount:
                                        (MediaQuery.sizeOf(context).width /
                                                (showColorHex
                                                    ? (!TabManager.isSuperLarge
                                                        ? 200
                                                        : 300)
                                                    : (!TabManager.isSuperLarge
                                                        ? 80
                                                        : 150)))
                                            .floor()),
                            itemCount: col.length,
                            itemBuilder: (BuildContext context, int index) {
                              return GetButtons(
                                  //small: filterUse?isShowable(index):false,

                                  ghost: filterUse
                                      ? editedIndex.contains(index)
                                      : index == active,
                                  moreResponsive: !(col[index] ==
                                          ThemeDt.themeColors["bg"] ||
                                      col[index] == ThemeDt.themeColors["fg"]),
                                  light: filterUse
                                      ? editedIndex.contains(index)
                                      : false,
                                  onTap: () {
                                    setState(() {
                                      active = index;
                                      if (filterUse) {
                                        editedIndex.contains(index)
                                            ? editedIndex.remove(index)
                                            : editedIndex.add(index);
                                      }
                                    });
                                    if (!filterUse) {
                                      if (!TabManager.isSuperLarge) {
                                        showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return Container(
                                                child: Center(
                                                    child: Container(
                                                        height: 600,
                                                        width: 380,
                                                        child: colourPick())));
                                          },
                                        );
                                      }
                                    }
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                        color: col[index],
                                        borderRadius: BorderRadius.circular(5)),
                                    child: showColorHex
                                        ? Center(
                                            child: WidsManager().getContainer(
                                              child: WidsManager().getText(
                                                  "#${col[index].hex}"),
                                            ),
                                          )
                                        : null,
                                  ));
                            },
                          )),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.only(right: 8.0, bottom: 8, left: 8),
                    child: colourPick(),
                  )
                ],
              ),
      );
    } catch (e) {
      File fl=File("${widget.filePath}-new");
      if(fl.existsSync())fl.deleteSync();
      print(e);
      return Scaffold(
          backgroundColor: ThemeDt.themeColors["bg"],
          body: Center(
              child: WidsManager().getContainer(
                  width: 400,
                  height: 160,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      WidsManager().getText(
                          "Some issues in the css file reading is causing this problem. Please switch to a different mode. Some themes import url instead of directly writing the css file. Such themes are not supported yet."
                          " (light/dark) and try again."),
                      GetButtons(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        text: "Close",
                      )
                    ],
                  ))));
      // TODO
    }
  }

  bool invertFilter = false;
  filterEditedIndex() {
    editedIndex.clear();
    for (int i = 0; i < col.length; i++) {
      if (isShowable(i)) {
        editedIndex.add(i);
      }
    }
  }

  bool isShowable(index) {
    HSLColor c = HSLColor.fromColor(col[index]);
    if (c.lightness == 0 && c.hue == 0) c = c.withSaturation(0.1);
    return (((c.saturation <= (sat ?? 1.0)) &&
            (c.hue <= (hue ?? 360)) &&
            (c.lightness <= (val ?? 1.0))) ==
        !invertFilter);
  }

  Widget colourPick() {
    return WidsManager().getContainer(
        width: TabManager.isSuperLarge ? 500 : 0,
        child: Column(
          children: [
            ColorPicker(
                title: WidsManager().getText(
                  'Pick a colour',
                ),
                color: col[active],
                pickersEnabled: const {
                  ColorPickerType.wheel: true,
                  ColorPickerType.primary: false,
                  ColorPickerType.accent: false,
                  ColorPickerType.both: false
                },
                wheelDiameter: 300,
                enableTonalPalette: true,
                enableShadesSelection: true,
                onColorChangeEnd: (clr) async {
                  await changeColor(clr, context);
                },
                onColorChanged: (clr) {}),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                if (!TabManager.isSuperLarge)
                  IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: Icon(
                        Icons.close,
                        color: ThemeDt.themeColors["fg"]?.withOpacity(0.5),
                      )),
                IconButton(
                    onPressed: () {
                      WidsManager().showMessage(
                          title: "Info",
                          message:
                              "Possible foreground and background colours are specially highlighted. Named colours cannot be edited as of now.",
                          context: context);
                    },
                    icon: Icon(
                      Icons.info_rounded,
                      color: ThemeDt.themeColors["fg"]?.withOpacity(0.5),
                    )),
                const SizedBox(
                  width: 20,
                ),
                GetButtons(
                  onTap: () async {
                    await resetColors();
                  },
                  text: "Reset",
                  ghost: true,
                ),
                const SizedBox(
                  width: 10,
                ),
                GetButtons(
                  onTap: () async {

                    if (editedIndex.length == col.length) {
                      Navigator.pop(context);
                      ThemeManager().updateColors(
                          path: widget.filePath,
                          col: col,
                          oldCol: oldCol,
                          editedIndex: editedIndex,
                          update: false,
                          test: false);

                    } else {
                      var path = "${widget.filePath}-new";
                      File fl = File(path);
                      File flOrg = File(widget.filePath);
                      if (await fl.exists()) {
                        Navigator.pop(context);
                        flOrg.delete();
                        fl.rename(widget.filePath);
                      }
                    }
                   if(!(widget.isDefinedFile ?? false)) {
                      if (widget.filePath.contains("/gtk-4.0/")) {
                        File fl = File(widget.filePath);
                        ThemeDt().setGTK4(fl.parent.parent.path);
                      } else if (widget.filePath.contains("/gtk-3.0/")) {
                        File fl = File(widget.filePath);
                        await ThemeDt().setGTK3("default");
                        ThemeDt()
                            .setGTK3(fl.parent.parent.path.split("/").last);
                      } else if (widget.filePath.contains("/gnome-shell/")) {
                        File fl = File(widget.filePath);
                        ThemeDt().setShell(fl.parent.parent.path.split("/").last);
                      }
                    }
                  },
                  text: "Apply (System)",
                  ghost: true,
                ),
              ],
            ),
          ],
        ));
  }

  Future<void> resetColors() async {
    Navigator.pop(context);
    var path = "${widget.filePath}-new";
    File fl = File(path);
    if (await fl.exists()) {
      await fl.delete();
    }
    ThemeDt.themeColors =
        await ThemeDt().extractColors(filePath: widget.filePath);
    ThemeDt().generateTheme();
    refreshPage();
  }

  Future<void> changeColor(Color clr, BuildContext context) async {
    try {
      if (filterUse) {
        HSLColor c = HSLColor.fromColor(clr);
        for (int i = 0; i < col.length; i++) {
          if (editedIndex.contains(i)) {
            col[i] = HSLColor.fromColor(col[i]).withHue(c.hue).toColor();
          }
        }
      } else {
        col[active] = clr;
        editedIndex.add(active);
        editedIndex = editedIndex.toSet().toList();
      }
      await ThemeManager().updateColors(
          test: true,
          path: widget.filePath,
          col: col,
          editedIndex: editedIndex,
          oldCol: oldCol,
          update: widget.update);
      oldCol = List.of(col);
      refreshPage();
    } on Exception catch (e) {
      WidsManager().showMessage(
          title: "Error",
          message: "Theme could not be updated.\n\n$e",
          context: context);
      // TODO
    }
  }

  Row getPalette(key) {
    return Row(
      children: <Widget>[
        Expanded(
          child: Container(
            color: AdaptiveTheming.paletteColours[key]?["bg"],
          ),
        ),
        Expanded(
          child: Container(
            color: AdaptiveTheming.paletteColours[key]?["altbg"],
          ),
        ),
        Expanded(
          child: Container(
            color: AdaptiveTheming.paletteColours[key]?["rowSltBG"],
          ),
        ),
        Expanded(
          child: Container(
            color: AdaptiveTheming.paletteColours[key]?["sltbg"],
          ),
        ),
        Expanded(
          child: Container(
            color: AdaptiveTheming.paletteColours[key]?["altfg"],
          ),
        ),
        Expanded(
          child: Container(
            color: AdaptiveTheming.paletteColours[key]?["rowSltLabel"],
          ),
        ),
        Expanded(
          child: Container(
            color: AdaptiveTheming.paletteColours[key]?["fg"],
          ),
        ),
      ],
    );
  }

  void editPallete() {
    if (satVal == 0) satVal = 0.01;
    if (satVal == 1) satVal = 0.99;
    if (ltness == 0) ltness = 0.01;
    if (ltness == 1) ltness = 0.99;
    Map clrs = Map.from(ThemeDt.themeColors);
    clrs.forEach((key, value) {
      ThemeDt.themeColors[key] =
          HSLColor.fromColor(value).withSaturation(satVal).toColor();
      if (key == "bg") {
        ThemeDt.themeColors[key] = HSLColor.fromColor(ThemeDt.themeColors[key]!)
            .withLightness(ltness)
            .toColor();
      }
    });
  }
}
