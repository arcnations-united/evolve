import 'dart:io';
import 'dart:ui';
import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/material.dart';
import 'package:gtkthememanager/back_end/app_data.dart';
import 'package:gtkthememanager/back_end/colour_info.dart';
import 'package:gtkthememanager/back_end/gtk_theme_manager.dart';
import 'package:gtkthememanager/theme_manager/gtk_to_theme.dart';
import 'package:gtkthememanager/theme_manager/gtk_widgets.dart';

import '../back_end/adaptive_theming.dart';
//manages wallpaper adaptive theming along with gtk colour edit
//thought implementing here would help since we are already changing colours of gtk themes inside this page
//but I don't think it was useful enough. Should have opted for separate dart file but yeah its fine...
class ChangeColors extends StatefulWidget {
  String filePath;
  final bool? editAccents;
  final Function() state;
  final bool? update;
  ChangeColors(
      {super.key,
      required this.filePath,
      required this.state,
      this.update,
      this.editAccents});

  @override
  State<ChangeColors> createState() => _ChangeColorsState();
}

class _ChangeColorsState extends State<ChangeColors> {
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
            widget.state();
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
                      WidsManager().getText(
                          "Choose a colour palette.\n(BETA. Choose a dark variant.)",
                          size: 15),
                      const SizedBox(
                        height: 25,
                      ),
                      Container(
                        height: MediaQuery.sizeOf(context).height / 2,
                        child: Row(
                          children: <Widget>[
                            if (isLoading == false)
                              Stack(
                                children: [
                                  Center(
                                    child: Container(
                                        width:
                                            MediaQuery.sizeOf(context).width /
                                                1.5,
                                        child: wall),
                                  ),
                                  Center(
                                    child: Container(
                                      padding: const EdgeInsets.all(10),
                                      margin: EdgeInsets.only(
                                          left:
                                              MediaQuery.sizeOf(context).width /
                                                  1.5 /
                                                  8),
                                      height:
                                          MediaQuery.sizeOf(context).height / 3,
                                      width: MediaQuery.sizeOf(context).width /
                                          1.5 /
                                          1.4,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        boxShadow: [
                                          BoxShadow(
                                              color: Colors.black.withOpacity(
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
                                                MainAxisAlignment.spaceBetween,
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
                                                            .getText("Not Okay",
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
                                                await AdaptiveTheming().makeThemeAdaptive(filePath: widget.filePath, active: active);
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
                                    duration: const Duration(milliseconds: 500),
                                    child: AnimatedScale(
                                      scale: editAvailable ? 1 : 0,
                                      curve: Curves.easeOutCubic,
                                      duration: const Duration(milliseconds: 500),
                                      child: Center(
                                        child: Container(
                                          padding: const EdgeInsets.all(10),
                                          margin: EdgeInsets.only(
                                              left: MediaQuery.sizeOf(context)
                                                      .width /
                                                  1.5 /
                                                  8),
                                          height: MediaQuery.sizeOf(context)
                                                  .height /
                                              3,
                                          width:
                                              MediaQuery.sizeOf(context).width /
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
                                                      "Edit Parameters",
                                                      size: 11),
                                                  GestureDetector(
                                                      onTap: () {
                                                        editAvailable = false;
                                                        setState(() {});
                                                      },
                                                      child: Icon(Icons.circle,
                                                          color:
                                                              Colors.red[300],
                                                          size: 12))
                                                ],
                                              ),
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  WidsManager()
                                                      .getText("Saturation"),
                                                  Slider(
                                                      min: 0,
                                                      max: 1,
                                                      value: satVal,
                                                      activeColor: ThemeDt
                                                          .themeColors["altfg"],
                                                      onChanged: (val) {
                                                        satVal = val;
                                                        editPallete();
                                                        setState(() {});
                                                      }),
                                                  WidsManager()
                                                      .getText("Brightness"),
                                                  Slider(
                                                      min: 0,
                                                      max: 1,
                                                      value: ltness,
                                                      activeColor: ThemeDt
                                                          .themeColors["altfg"],
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
                                                        editAvailable = false;
                                                      });
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
                                    ),
                                  )
                                ],
                              ),
                            const SizedBox(
                              width: 25,
                            ),
                            if (isLoading)
                              WidsManager().getText("Generating Palette...")
                            else
                              Expanded(
                                child: ListView(
                                  children: [
                                    for (int i = 0;
                                        i <
                                            AdaptiveTheming
                                                .paletteColours.keys.length;
                                        i++)
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 12.0),
                                        child: GetButtons(
                                            light: true,
                                            ltVal: 1.2,
                                            ghost: active == i,
                                            onTap: () {
                                              active = i;
                                              Map themeCopy =  ThemeDt.themeColors;
                                              ThemeDt.themeColors.forEach((key, value) {
                                                themeCopy[key]= ColourManipulate().setHue(value, fromColor:  AdaptiveTheming.paletteColours.values.elementAt(i).values.elementAt(0));
                                              });
                                              satVal = HSLColor.fromColor(
                                                      ThemeDt
                                                          .themeColors["bg"]!)
                                                  .saturation;
                                              ltness = HSLColor.fromColor(
                                                      ThemeDt
                                                          .themeColors["bg"]!)
                                                  .lightness;
                                              widget.state();
                                            },
                                            child: Container(
                                                height: 50,
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    WidsManager().getText(
                                                        AdaptiveTheming
                                                            .paletteColours.keys
                                                            .elementAt(i)),
                                                    Container(
                                                        height: 30,
                                                        child: getPalette(
                                                            AdaptiveTheming
                                                                .paletteColours
                                                                .keys
                                                                .elementAt(i))),
                                                  ],
                                                ))),
                                      )
                                  ],
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
          backgroundColor: ThemeDt.themeColors["bg"],
          foregroundColor: ThemeDt.themeColors["fg"],
        ),
        backgroundColor: ThemeDt.themeColors["bg"],
        body: (badGTK)
            ? Container()
            : Row(
                children: [
                  Expanded(
                      child: GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount:
                            (MediaQuery.sizeOf(context).width / 150).floor()),
                    itemCount: col.length,
                    itemBuilder: (BuildContext context, int index) {
                      return GetButtons(
                          ghost: index == active,
                          moreResponsive:
                              !(col[index] == ThemeDt.themeColors["bg"] ||
                                  col[index] == ThemeDt.themeColors["fg"]),
                          light: (col[index] == ThemeDt.themeColors["bg"] ||
                              col[index] == ThemeDt.themeColors["fg"]),
                          onTap: () {
                            setState(() {
                              active = index;
                            });
                          },
                          child: Container(
                            decoration: BoxDecoration(
                                color: col[index],
                                borderRadius: BorderRadius.circular(5)),
                          ));
                    },
                  )),
                  Padding(
                    padding:
                        const EdgeInsets.only(right: 8.0, bottom: 8, left: 8),
                    child: WidsManager().getContainer(
                      width: 500,
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
                                    color: ThemeDt.themeColors["fg"]
                                        ?.withOpacity(0.5),
                                  )),
                              const SizedBox(
                                width: 20,
                              ),
                              GetButtons(
                                onTap: () async {
                                  Navigator.pop(context);
                                  var path = "${widget.filePath}-new";
                                  File fl = File(path);
                                  if (await fl.exists()) {
                                    await fl.delete();
                                  }
                                  ThemeDt.themeColors = await ThemeDt()
                                      .extractColors(filePath: widget.filePath);
                                  ThemeDt().generateTheme();
                                  widget.state();
                                },
                                text: "Reset",
                                ghost: true,
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              GetButtons(
                                onTap: () async {
                                  var path = "${widget.filePath}-new";
                                  File fl = File(path);
                                  File flOrg = File(widget.filePath);
                                  if (await fl.exists()) {
                                    Navigator.pop(context);
                                    flOrg.delete();
                                    fl.rename(widget.filePath);
                                  }
                                },
                                text: "Apply (System)",
                                ghost: true,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
      );
    } catch (e) {
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

  Future<void> changeColor(Color clr, BuildContext context) async {
    try {
      col[active] = clr;
      editedIndex.add(active);
      editedIndex = editedIndex.toSet().toList();
      await ThemeManager().updateColors(
          test: true,
          path: widget.filePath,
          col: col,
          editedIndex: editedIndex,
          oldCol: oldCol,
          update: widget.update);
      oldCol = List.of(col);
      widget.state();
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
