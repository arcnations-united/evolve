import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '../back_end/app_data.dart';
import 'package:process_run/process_run.dart';
import 'package:url_launcher/url_launcher.dart';
import 'gtk_to_theme.dart';

//Returns required widgets in style of the applied GTK Theme
class WidsManager {
  static int activeTab = 0;
  static List<String> tabs = [
    "Theme",
    "Icons",
    "Configs",
    "Extensions",
    "Settings",
    "About"
  ];

  gtkAppBar(context,
      {Widget? title, Color? backgroundColor, Color? foregroundColor}) {
    return AppBar(
      backgroundColor: backgroundColor ?? ThemeDt.themeColors["bg"],
      foregroundColor: foregroundColor,
    );
  }

  notify(context, {String head = "Info", required String message}) async {
    try {
      await Shell().run(
          "notify-send --app-name=Evolve-Core --icon=${SystemInfo.home}/nex/apps/evolvecore/iconfile.png \"$head\" \"$message\"");
    } catch (E) {
      if (context != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: WidsManager()
                .getText(message, color: "bg", fontWeight: FontWeight.bold),
          ),
        );
      }
    }
  }

  Widget getContainer(
      {double borderOpacity = 1.0,
      double opacity = 1.0,
      double? mar,
      Duration? duration,
      Curve? curve,
      double? borderRadius,
      String? colour,
      bool? border,
      final child,
      double? pad,
      double? width,
      double? height,
      bool? blur}) {
    borderRadius ??= 10;
    blur ??= false;
    if (AppData.DataFile["GNOMEUI"] == true) {
      blur = false;
    }
    colour ??= blur ? "fg" : "altbg";

    border ??= false;
    pad ??= 10;
    if (blur) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: AnimatedBlurryContainer(
          // filter: ImageFilter.blur(sigmaY: 30,sigmaX: 30),
          //delay: 1.seconds,
          blur: 50,
          duration: 600.milliseconds,
          child: Container(
              height: height,
              width: width,
              padding: EdgeInsets.all(pad),
              decoration: BoxDecoration(
                  gradient: (AppData.DataFile["GNOMEUI"] ?? false)
                      ? null
                      : LinearGradient(
                          colors: [
                            ThemeDt.themeColors["bg"]!.withOpacity(0),
                            ThemeDt.themeColors["bg"]!.withOpacity(0),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                  borderRadius: BorderRadius.all(Radius.circular(borderRadius)),
                  border: Border.all(
                      width: 1.2,
                      color: ThemeDt.themeColors["fg"]!.withOpacity(0.2))),
              child: child),
        ),
      );
    }
    return AnimatedContainer(
      width: width,
      height: height,
      margin: EdgeInsets.all(mar ?? 0),
      padding: EdgeInsets.all(pad),
      duration: duration ?? ThemeDt.d,
      curve: curve ?? ThemeDt.c,
      decoration: BoxDecoration(
          border: border
              ? Border.all(
                  width: 1.5,
                  color: (ThemeDt.themeColors["fg"] ?? Colors.transparent)
                      .withOpacity(borderOpacity),
                )
              : null,
          color: ThemeDt.themeColors[colour]!.withOpacity(opacity),
          borderRadius: BorderRadius.circular(borderRadius)),
      child: child,
    );
  }

  Text getText(String s,
      {double? size,
      double? letterSpacing,
      double? height,
      bool? center,
      bool right = false,
      bool? stylize,
      int? maxLines,
      String? color,
      double opacity = 1.0,
      FontWeight? fontWeight}) {
    stylize ??= false;
    center ??= false;
    size ??= AppData.DataFile["MAXSIZE"] == true ? 15 : 13;
    return Text(
      s,
      textAlign: (center)
          ? TextAlign.center
          : right
              ? TextAlign.right
              : null,
      maxLines: maxLines,
      overflow: TextOverflow.fade,
      style: AppData.DataFile["GNOMEUI"] == true
          ? TextStyle(
              letterSpacing: letterSpacing,
              fontFamily: sysFont,
              fontWeight: fontWeight ?? FontWeight.normal,
              fontSize: size,
              height: height,
              color: ThemeDt.themeColors[color ?? "fg"]?.withOpacity(opacity),
            )
          : stylize == true
              ? GoogleFonts.audiowide(
                  letterSpacing: letterSpacing,
                  height: height,
                  color:
                      ThemeDt.themeColors[color ?? "fg"]?.withOpacity(opacity),
                  fontSize: size,
                )
              : GoogleFonts.lexendDeca(
                  letterSpacing: letterSpacing,
                  height: height,
                  color:
                      ThemeDt.themeColors[color ?? "fg"]?.withOpacity(opacity),
                  fontSize: size,
                  fontWeight: fontWeight ??
                      (size > 15 ? FontWeight.w200 : FontWeight.w300),
                ),
    );
  }

  void showMessage(
      {required String title,
      double height = 350,
      required String message,
      IconData? icon,
      double? icoSize,
      Widget? child,
      bool? isDismisible,
      required context}) {
    icon ??= (title.toLowerCase() == "error")
        ? Icons.error_rounded
        : (title.toLowerCase() == "warning")
            ? Icons.warning_rounded
            : Icons.info_rounded;
    child ??= GetButtons(
      onTap: () {
        Navigator.pop(context);
      },
      text: "Close",
    );
    showDialog(
      barrierColor: Colors.transparent,
      context: context,
      barrierDismissible: isDismisible ?? false,
      builder: (BuildContext context) {
        var wdth = MediaQuery.sizeOf(context).width;
        return Scaffold(
          backgroundColor: Colors.transparent,
          body: Center(
            child: WidsManager()
                .getContainer(
              blur: true,
              border: true,
              pad: 20,
              height: height,
              width: wdth > 1200 ? wdth / 2.5 : 1200 / 2.5,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      WidsManager().getText(title, size: 27),
                      if (isDismisible ?? false)
                        GestureDetector(
                            onTap: () {
                              Navigator.pop(context);
                            },
                            child: Icon(
                              Icons.cancel,
                              color: ThemeDt.themeColors["fg"],
                              size: 20,
                            ))
                    ],
                  ),
                  Row(
                    children: [
                      Icon(
                        icon,
                        color: ThemeDt.themeColors["fg"],
                        size: icoSize ?? 70,
                      ),
                      const SizedBox(
                        width: 20,
                      ),
                      Expanded(
                        child: ListView(
                          shrinkWrap: true,
                          children: [
                            SizedBox(
                                width: wdth > 1200 ? wdth / 3.8 : 1200 / 3.8,
                                child: WidsManager().getText(message)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  child!
                ],
              ),
            )
                .animate(effects: [
              ScaleEffect(
                  begin: const Offset(0.8, 0.1),
                  end: const Offset(1, 1),
                  duration: (ThemeDt.d.inMilliseconds + 400).milliseconds,
                  curve: Curves.easeOutExpo),
              FadeEffect(
                  delay: (ThemeDt.d.inMilliseconds - 200).milliseconds,
                  duration: ThemeDt.d),
            ]),
          ),
        );
      },
    );
  }

  Tooltip getTooltip({child, String? text, Widget? widget}) {
    return Tooltip(
      richMessage: WidgetSpan(
          alignment: PlaceholderAlignment.baseline,
          baseline: TextBaseline.alphabetic,
          child: Container(
            decoration: AppData.DataFile["GNOMEUI"] ?? false
                ? BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: ThemeDt.themeColors["altbg"],
                    boxShadow: [
                        BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            offset: const Offset(0, 6),
                            blurRadius: 5)
                      ])
                : null,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: AnimatedBlurryContainer(
                delay: Duration.zero,
                duration: Duration.zero,
                blur: AppData.DataFile["GNOMEUI"] ? 0 : null,
                //  filter: AppData.DataFile["GNOMEUI"]?ImageFilter.blur():ImageFilter.blur(sigmaX: 30,sigmaY: 30),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  constraints: const BoxConstraints(maxWidth: 250),
                  decoration: AppData.DataFile["GNOMEUI"]
                      ? null
                      : BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                              color:
                                  ThemeDt.themeColors["fg"]!.withOpacity(0.5),
                              width: 1.4)),
                  child: widget ?? WidsManager().getText(text ?? "Tap here"),
                ),
              ),
            ).animate(
                effects: AppData.DataFile["GNOMEUI"]
                    ? []
                    : [
                        SlideEffect(
                            begin: const Offset(0, -0.05),
                            end: const Offset(0, 0),
                            duration: ThemeDt.d,
                            curve: ThemeDt.c)
                      ]),
          )),
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(5)),
      ),
      // margin: EdgeInsets.only(left: MediaQuery.sizeOf(context).width/(largeAlbum?2:1.5)),
      child: child,
    );
  }

  static String sysFont = "";
  static double? sysFontSize;
  Future<void> loadFontAndApply() async {
    sysFont = (await Shell()
            .run("gsettings get org.gnome.desktop.interface font-name"))
        .outText;
    await Future.delayed(1.seconds);
    sysFont = sysFont.replaceAll(",", "");
    sysFontSize = double.tryParse(
        sysFont.substring(sysFont.lastIndexOf(" ") + 1, sysFont.length - 1));
    sysFont = sysFont.substring(1, sysFont.lastIndexOf(" "));
  }

  Future<void> _launchUrl(url) async {
    if (!await launchUrl(url)) {
      print('Could not launch $url');
    }
  }

  void showAboutPage(context, AnimationController controller) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Scaffold(
          backgroundColor: Colors.transparent,
          body: Container(
            child: Center(
              child: getContainer(
                borderRadius: 20,
                colour: "bg",
                height: 530,
                width: 350,
                child: Stack(
                  // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Align(
                      alignment: Alignment.topRight,
                      child: GestureDetector(
                        onTap: () async {
                          await controller
                              .reverse()
                              .then((value) => Navigator.pop(context));
                        },
                        child: Container(
                          margin: const EdgeInsets.all(13),
                          height: 15,
                          width: 15,
                          decoration: BoxDecoration(
                              color: Colors.red[300], shape: BoxShape.circle),
                        ),
                      ),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Image.asset(
                          "assets/iconfile.png",
                          height: 130,
                          width: 130,
                        ),
                        getText("Evolve Core",
                            size: 27, fontWeight: FontWeight.w600),
                        getText("NEX Opensource"),
                        const SizedBox(
                          height: 10,
                        ),
                        getContainer(
                            border: true,
                            borderOpacity: 0.2,
                            child:
                                getText("${AppData.vers}-${AppData.release}")),
                        const SizedBox(
                          height: 30,
                        ),
                        gtkColumn(
                          children: [
                            GestureDetector(
                              onTap: () async {
                                await _launchUrl(Uri.parse(
                                    "https://www.patreon.com/arcnations"));
                              },
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  getText("Patreon"),
                                  Icon(
                                    Icons.open_in_new_rounded,
                                    color: ThemeDt.themeColors["fg"],
                                    size: 17,
                                  )
                                ],
                              ),
                            ),
                            GestureDetector(
                              onTap: () async {
                                await _launchUrl(Uri.parse(
                                    "https://arcnations.wixsite.com/nex-apps"));
                              },
                              child: Container(
                                color:
                                    ThemeDt.themeColors["bg"]?.withOpacity(0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    getText("Website"),
                                    Icon(
                                      Icons.open_in_new_rounded,
                                      color: ThemeDt.themeColors["fg"],
                                      size: 17,
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ).animate(controller: controller, effects: [
            ScaleEffect(
                begin: const Offset(1, 0),
                end: const Offset(1, 1),
                curve: Curves.easeOut,
                duration: 100.milliseconds)
          ]),
        );
      },
    );
  }

  static String wallPath = "";
  Widget gtkColumn(
      {required List<Widget> children, width, Column? title, String? color}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null) title,
        WidsManager().getContainer(
            colour: color ?? "altbg",
            borderOpacity: 0.2,
            border: false,
            pad: 0,
            width: width,
            child: Column(
              children: [
                for (Widget wid in children)
                  Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: wid,
                      ),
                      if (children.length > 1)
                        Container(
                          height: 1,
                          color: ThemeDt.themeColors["bg"]?.withOpacity(0.9),
                        ),
                    ],
                  )
              ],
            )),
      ],
    );
  }

  Future<Widget> getWallpaperSample({String? wallPath}) async {
    if (File("${SystemInfo.home}/.NexData/compressed/img.jpg").existsSync() ==
        false) {
      wallPath = (await Shell().run("""
    gsettings get org.gnome.desktop.background picture-uri
    """)).outText.replaceAll("file://", "").replaceAll("'", "");
    } else {
      wallPath = "${SystemInfo.home}/.NexData/compressed/img.jpg";
    }
    WidsManager.wallPath = wallPath;
    File wp = File(wallPath);
    if (await wp.exists() == false) {
      return Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            gradient: LinearGradient(colors: [
              Colors.lightBlueAccent,
              Colors.lightBlue,
              Colors.blue[800]!,
            ])),
      );
    }
    return ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Stack(
          children: [
            Image.file(
              wp,
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,
            ),
            Stack(
              children: [
                Container(
                  color: Colors.black,
                  height: 25,
                ),
                Container(
                  margin: const EdgeInsets.only(top: 10, left: 10),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(100)),
                  width: 25,
                  height: 8,
                ),
                Container(
                  margin: const EdgeInsets.only(top: 10, left: 40),
                  decoration: const BoxDecoration(
                    color: Colors.grey,
                    shape: BoxShape.circle,
                  ),
                  width: 8,
                  height: 8,
                ),
              ],
            )
          ],
        ));
  }
}

class GetAddRem extends StatefulWidget {
  final IconData icoD1;
  final IconData icoD2;
  final Color icoColor;
  final double value;
  final double step;
  final double max;
  final double min;
  final Function onTapIco;
  const GetAddRem({
    super.key,
    this.icoD1 = Icons.add,
    this.icoD2 = Icons.remove,
    this.icoColor = Colors.white,
    required this.value,
    this.step = 0.1,
    this.max = 1,
    this.min = 0,
    required this.onTapIco,
  });

  @override
  State<GetAddRem> createState() => _GetAddRemState();
}

class _GetAddRemState extends State<GetAddRem> {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        WidsManager().getText(
            ""
            "${widget.value.toString().substring(0, widget.value.toString().lastIndexOf(".") + 1)}"
            "${widget.value.toString().substring(widget.value.toString().lastIndexOf(".") + 1).length > 3 ? widget.value.toString().substring(widget.value.toString().lastIndexOf(".") + 1, 5) : widget.value.toString().substring(widget.value.toString().lastIndexOf(".") + 1)}"
            "",
            size: 30),
        Row(
          children: [
            GetButtons(
              onTap: () {
                widget.onTapIco(widget.value + widget.step);
              },
              child: Icon(
                widget.icoD1,
                color: widget.icoColor,
              ),
            ),
            const SizedBox(
              width: 5,
            ),
            GetButtons(
              onTap: () {
                widget.onTapIco(widget.value - widget.step);
              },
              child: Icon(widget.icoD2, color: widget.icoColor),
            ),
          ],
        )
      ],
    );
  }
}

class AdaptiveList extends StatefulWidget {
  final List<Widget> children;
  final GlobalKey parentKey;

  final double space;

  const AdaptiveList(
      {super.key,
      required this.children,
      this.space = 5,
      required this.parentKey});

  @override
  State<AdaptiveList> createState() => _AdaptiveListState();
}

class _AdaptiveListState extends State<AdaptiveList> {
  List<double> spacingWidth = [];
  List<double> spacingColm = [];
  List<GlobalKey> keys = [];
  @override
  void dispose() {
    // TODO: implement dispose
    t?.cancel();
    super.dispose();
  }

  bool row = true;
  GlobalKey thisKey = GlobalKey();
  @override
  void initState() {
    row = true;
    // TODO: implement initState
    for (int i = 0; i < widget.children.length; i++) {
      spacingWidth.add(widget.space * i);
      keys.add(GlobalKey());
    }
    generate();
    super.initState();
  }

  generate() async {
    await Future.delayed(10.milliseconds);
    spacingWidth = [];
    for (int i = 0; i < widget.children.length; i++) {
      double d = 0;
      double d1 = 0;
      for (int j = 0; j < i; j++) {
        d = ((j == 0) ? 0 : widget.space) +
            d +
            keys[j].currentContext!.size!.width;
        d1 = widget.space + d1 + keys[j].currentContext!.size!.height;
        if (lrgHt < keys[j].currentContext!.size!.height) {
          lrgHt = keys[j].currentContext!.size!.height;
        }
      }
      // print(widget.space);
      //print(d);
      spacingWidth.add(d);
      spacingColm.add(d1);
    }
    mod();
  }

  double ht = 0.0;
  double lrgHt = 0.0;
  mod() async {
    await Future.delayed(10.milliseconds);

    if ((spacingWidth.last + keys.last.currentContext!.size!.width) <
        widget.parentKey.currentContext!.size!.width) {
      setState(() {
        row = true;
        ht = lrgHt;
      });
    } else {
      setState(() {
        row = false;
        ht = spacingColm.last +
            keys.last.currentContext!.size!.height +
            widget.space;
      });
    }
  }

  Timer? t;
  bool load = false;
  @override
  void didUpdateWidget(covariant AdaptiveList oldWidget) {
    // TODO: implement didUpdateWidget
    mod();
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    // generate();
    return AnimatedOpacity(
      key: thisKey,
      opacity: load ? 0 : 1,
      duration: 100.milliseconds,
      child: AnimatedContainer(
        duration: ThemeDt.d,
        curve: ThemeDt.c,
        height: ht + 10,
        child: Stack(
          children: [
            for (int i = 0; i < widget.children.length; i++)
              AnimatedPositioned(
                  left: i == 0
                      ? 0
                      : row
                          ? widget.space + spacingWidth[i]
                          : 0,
                  top: !(row) ? widget.space + spacingColm[i] : 0,
                  duration: ThemeDt.d,
                  curve: ThemeDt.c,
                  child: Container(key: keys[i], child: widget.children[i]))
          ],
        ),
      ),
    );
  }
}

class AnimatedBlurryContainer extends StatefulWidget {
  final Widget child;
  final Duration? delay;
  final double? blur;
  final Duration? duration;
  final bool plus;
  const AnimatedBlurryContainer(
      {super.key,
      required this.child,
      this.delay,
      this.duration,
      this.blur,
      this.plus = false});

  @override
  State<AnimatedBlurryContainer> createState() =>
      _AnimatedBlurryContainerState();
}

class _AnimatedBlurryContainerState extends State<AnimatedBlurryContainer> {
  @override
  Widget build(BuildContext context) {
    if (widget.blur == 0) return widget.child;
    return BackdropFilter(
        filter: ImageFilter.blur(
          tileMode: TileMode.decal,
          sigmaY: (widget.blur ?? 5),
          sigmaX: (widget.blur ?? 5),
        ),
        child: BackdropFilter(
          filter: ColorFilter.mode(ThemeDt.themeColors["bg"]!.withOpacity(0.95),
              widget.plus ? BlendMode.plus : BlendMode.luminosity),
          child: widget.child,
        ));
  }
}

class FutureWid extends StatefulWidget {
  final val;
  final Widget child;
  final Widget? loadChild;
  final double width;
  final double height;
  final Duration duration;
  const FutureWid(
      {super.key,
      required this.val,
      required this.child,
      this.loadChild,
      this.duration = const Duration(seconds: 3),
      required this.width,
      required this.height});

  @override
  State<FutureWid> createState() => _FutureWidState();
}

class _FutureWidState extends State<FutureWid> with TickerProviderStateMixin {
  late AnimationController ant;
  @override
  void initState() {
    // TODO: implement initState
    ant = AnimationController(vsync: this);
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    ant.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedCrossFade(
      duration: 700.milliseconds,
      sizeCurve: Curves.easeOutExpo,
      firstCurve: Curves.easeOutExpo,
      secondCurve: Curves.easeOutExpo,
      firstChild: widget.loadChild ??
          WidsManager()
              .getContainer(
                  colour: "fg", width: widget.width, height: widget.height)
              .animate(
                  controller: ant,
                  onComplete: (dt) {
                    ant.repeat();
                  },
                  effects: [
                ShimmerEffect(
                  duration: widget.duration,
                  color: ThemeDt.themeColors["fg"]!,
                  size: 6,
                  angle: 45,
                  colors: [
                    ThemeDt.themeColors["altbg"]!,
                    ThemeDt.themeColors["fg"]!,
                    ThemeDt.themeColors["altbg"]!,
                  ],
                )
              ]),
      secondChild: widget.val == null ? Container() : widget.child,
      crossFadeState: widget.val == null
          ? CrossFadeState.showFirst
          : CrossFadeState.showSecond,
    );
  }
}

class TabButton extends StatefulWidget {
  final String text;
  final int Tab;
  final Function() state;
  const TabButton({
    required this.text,
    super.key,
    required this.Tab,
    required this.state,
  });

  @override
  State<TabButton> createState() => _TabButtonState();
}

class _TabButtonState extends State<TabButton> {
  bool hover = false;

  @override
  void initState() {
    // TODO: implement initState
    // initiateTheme();
    super.initState();
  }

  initiateTheme() async {
    await ThemeDt().setTheme();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    double width = 150;
    return MouseRegion(
      onEnter: (dt) {
        setState(() {
          hover = true;
        });
      },
      onExit: (dt) {
        setState(() {
          hover = false;
        });
      },
      child: GestureDetector(
        onTap: () {
          setState(() {
            WidsManager.activeTab = widget.Tab;
          });
          widget.state();
        },
        child: AnimatedContainer(
          width: width,
          decoration: BoxDecoration(
            color: ThemeDt.themeColors[widget.Tab == WidsManager.activeTab
                ? "rowSltBG"
                : (hover)
                    ? "altbg"
                    : "bg"],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
                width: 2,
                color: (((AppData.DataFile["HCONTRAST"] ?? false)
                        ? (widget.Tab == WidsManager.activeTab)
                            ? ThemeDt.themeColors["fg"]
                            : null
                        : ThemeDt.themeColors["rowSltBG"] ==
                                ThemeDt.themeColors["bg"]
                            ? ((widget.Tab == WidsManager.activeTab)
                                ? ThemeDt.themeColors["fg"]
                                : null)
                            : null) ??
                    Colors.transparent)),
          ),
          duration: ThemeDt.d,
          curve: ThemeDt.c,
          padding: const EdgeInsets.all(10),
          child: WidsManager().getText(widget.text,
              color:
                  (widget.Tab == WidsManager.activeTab ? "rowSltLabel" : "fg"),
              fontWeight: widget.Tab == WidsManager.activeTab
                  ? ThemeDt.boldText
                  : FontWeight.w300),
        ),
      ),
    );
  }
}

class GetButtons extends StatefulWidget {
  final Function() onTap;
  final child;
  final String? text;
  final String? textCol;
  final bool? light;
  final bool? small;
  final bool? pillShaped;
  final bool? ghost;
  final bool? moreResponsive;
  final double? opacity;
  final double? ltVal;
  const GetButtons(
      {this.ltVal,
      this.child,
      this.text,
      this.small,
      this.ghost,
      super.key,
      required this.onTap,
      this.light,
      this.moreResponsive,
      this.pillShaped,
      this.opacity,
      this.textCol});

  @override
  _GetButtonsState createState() => _GetButtonsState();
}

class _GetButtonsState extends State<GetButtons> {
  bool hover = false;
  bool tap = false;
  Timer? t;
  Timer? t1;
  @override
  void initState() {
    // TODO: implement initState

    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    t?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Color? buttonCol = ThemeDt.themeColors[tap
        ? "sltbg"
        : (hover)
            ? "altbg"
            : "bg"];
    return MouseRegion(
      onEnter: (dt) {
        setState(() {
          hover = true;
        });
      },
      onExit: (dt) {
        t?.cancel();
        t = Timer(const Duration(milliseconds: 40), () {
          if (context.mounted) {
            setState(() {
              hover = false;
            });
          }
        });
      },
      child: GestureDetector(
        onTapDown: (dt) {
          setState(() {
            tap = true;
          });
        },
        onTapUp: (dt) {
          widget.onTap();
          t1?.cancel();
          t1 = Timer(const Duration(milliseconds: 200), () {
            if (context.mounted) {
              setState(() {
                tap = false;
              });
            }
          });
        },
        child: AnimatedScale(
          duration: Duration.zero,
          scale: widget.small ?? false ? 0.7 : 1,
          child: ClipRRect(
            borderRadius:
                BorderRadius.circular(widget.pillShaped ?? false ? 100 : 10),
            child: AnimatedBlurryContainer(
              plus: true,
              blur: widget.opacity != null ? 15 : 0,
              child: AnimatedContainer(
                // width: width,
                decoration: BoxDecoration(
                    color: ((widget.light ?? false)
                            ? HSLColor.fromColor(buttonCol!)
                                .withLightness(HSLColor.fromColor(buttonCol)
                                                .lightness *
                                            (widget.ltVal ?? 2) >
                                        1
                                    ? 1
                                    : HSLColor.fromColor(buttonCol).lightness *
                                        (widget.ltVal ?? 2))
                                .toColor()
                            : buttonCol)!
                        .withOpacity(widget.opacity ?? 1),
                    borderRadius: BorderRadius.circular(
                        widget.pillShaped ?? false ? 100 : 10),
                    border: Border.all(
                      width: 2,
                      color: (widget.ghost ?? false)
                          ? ThemeDt.themeColors["fg"]!
                          : ((tap) ? ThemeDt.themeColors["fg"] : null) ??
                              Colors.transparent,
                    )),
                duration: ThemeDt.d,
                curve: ThemeDt.c,
                padding: ((widget.moreResponsive ?? false)
                    ? EdgeInsets.all((hover) ? 10 : 15)
                    : widget.pillShaped ?? false
                        ? const EdgeInsets.only(
                            left: 20, right: 20, top: 10, bottom: 10)
                        : const EdgeInsets.all(8)),
                margin: (widget.moreResponsive ?? false)
                    ? EdgeInsets.all((hover) ? 5 : 0)
                    : EdgeInsets.zero,
                child: (widget.child == null)
                    ? WidsManager().getText(widget.text ?? "",
                        color: widget.textCol ?? "fg")
                    : widget.child,
              ),
            ),
          ),
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
  List svgPaths = ["", "", "", "", "", ""];
  @override
  void initState() {
    // TODO: implement initState
    initateLocations();
    super.initState();
  }

  initateLocations() async {
    Directory Ico = Directory(widget.icoPackPath);
    svgPaths[0] = await checkFile("org.gnome.files.svg");
    if (svgPaths[0] == "NotFound") {
      svgPaths[0] = await checkFile("org.gnome.Nautilus.svg");
      if (svgPaths[0] == "NotFound") {
        svgPaths[0] = await checkFile("org.gnome.Files.svg");
      }
    }
    svgPaths[1] = await checkFile("gnome-settings.svg");
    svgPaths[2] = await checkFile("org.gnome.weather.svg");
    if (svgPaths[2] == "NotFound") {
      svgPaths[2] = await checkFile("org.gnome.Weather.svg");
    }
    svgPaths[3] = await checkFile("org.gnome.gedit.svg");
    if (svgPaths[3] == "NotFound") {
      svgPaths[3] = await checkFile("org.gnome.Gedit.svg");
    }
    svgPaths[4] = await checkFile("org.gnome.totem.svg");
    if (svgPaths[4] == "NotFound") {
      svgPaths[4] = await checkFile("org.gnome.Totem.svg");
    }
    svgPaths[5] = await checkFile("org.gnome.music.svg");
    if (svgPaths[5] == "NotFound") {
      svgPaths[5] = await checkFile("org.gnome.Music.svg");
    }
    int nots = 0;
    for (var element in svgPaths) {
      if (element == "NotFound") nots++;
    }
    if (nots >= 3) corruptTheme = true;
    setState(() {});
  }

  checkFile(String svgFile) async {
    String fle = "${widget.icoPackPath}/apps/24/$svgFile";
    String fle1 = "${widget.icoPackPath}/apps/scalable/$svgFile";
    String fle2 = "${widget.icoPackPath}/24x24/apps/$svgFile";
    String fle3 = "${widget.icoPackPath}/128x128/apps/$svgFile";
    String fle4 = "${widget.icoPackPath}/64x64/apps/$svgFile";
    File f = File(fle);
    File f1 = File(fle1);
    File f2 = File(fle2);
    File f3 = File(fle3);
    File f4 = File(fle4);
    if (await f.exists()) {
      return fle;
    } else if (await f1.exists()) {
      return fle1;
    } else if (await f2.exists()) {
      return fle2;
    } else if (await f3.exists()) {
      return fle3;
    } else if (await f4.exists()) {
      return fle4;
    } else {
      return "NotFound";
    }
  }

  double wd = 50;
  double ht = 50;

  @override
  Widget build(BuildContext context) {
    wd =
        (MediaQuery.sizeOf(context).width + MediaQuery.sizeOf(context).height) /
            50;
    ht = wd;

    return GetButtons(
      moreResponsive: true,
      ghost: ThemeDt.IconName == widget.icoPackPath.split("/").last,
      light: true,
      ltVal: 2,
      onTap: () {
        if (corruptTheme) {
          WidsManager().showMessage(
              context: context,
              title: "Warning",
              message:
                  "The icon pack you are trying to apply may be corrupted. Some system icons may not show after applying.",
              icon: Icons.warning_rounded,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  GetButtons(
                    light: true,
                    onTap: () {
                      Navigator.pop(context);
                    },
                    text: "Cancel",
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  GetButtons(
                    light: true,
                    onTap: () {
                      applyIcon();
                      Navigator.pop(context);
                    },
                    text: "Apply",
                  ),
                ],
              ));
        } else {
          applyIcon();
        }
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (corruptTheme)
            WidsManager().getText("Icon-pack may be corrupt.", size: 15),
          if (!corruptTheme)
            Expanded(
                child: GridView.builder(
              itemCount: 6,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3, crossAxisSpacing: 5, mainAxisSpacing: 5),
              itemBuilder: (BuildContext context, int index) {
                if (svgPaths[index] == "NotFound") {
                  return Icon(
                    Icons.error,
                    size: wd,
                    color: ThemeDt.themeColors["fg"],
                  );
                } else {
                  return AnimatedOpacity(
                      duration: ThemeDt.d,
                      opacity: svgPaths[index] == "" ? 0.0 : 1.0,
                      child: svgPaths[index] == ""
                          ? Container()
                          : SvgPicture.file(
                              File(svgPaths[index]),
                              width: MediaQuery.sizeOf(context).width / 10,
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
    ThemeDt.IconName = widget.icoPackPath.split("/").last;
  }
}

class GetTextBox extends StatefulWidget {
  final onDone;
  final double? width;
  final double? height;
  final String? hintText;
  final String? tag;
  final String? initText;
  final bool? isSensitive;
  final bool? padding;
  final TextEditingController? cnt;
  const GetTextBox(
      {super.key,
      this.isSensitive,
      this.onDone,
      this.height,
      this.width,
      this.padding,
      this.cnt,
      this.hintText,
      this.initText,
      this.tag});

  @override
  State<GetTextBox> createState() => _GetTextBoxState();
}

class _GetTextBoxState extends State<GetTextBox> {
  late TextEditingController tx;
  @override
  void initState() {
    // TODO: implement initState
    if (widget.cnt != null) {
      tx = widget.cnt!;
    } else {
      tx = TextEditingController();
    }
    tx.text = widget.initText ?? "";
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    tx.dispose();
    super.dispose();
  }

  bool tapped = true;
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: widget.tag == "src"
          ? BorderRadius.circular(100)
          : BorderRadius.circular(0),
      child: WidsManager().getContainer(
          blur: true,
          colour: "transparent",
          pad: widget.padding == true
              ? (widget.height != null
                  ? widget.height! < 70
                      ? 0
                      : null
                  : null)
              : 0,
          border: tapped,
          width: widget.width,
          height: widget.height,
          borderRadius: widget.tag == "src" ? 100 : 10,
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  onSubmitted: (tx) {
                    widget.onDone(tx);
                  },
                  obscureText: widget.isSensitive ?? false,
                  onChanged: (tx) {
                    setState(() {});
                  },
                  cursorColor: ThemeDt.themeColors["fg"],
                  controller: tx,
                  style: WidsManager().getText("s").style?.copyWith(
                      fontSize: (((widget.height ?? 80) / 5) < 12.0)
                          ? 12.0
                          : (widget.height ?? 80) / 5),
                  decoration: InputDecoration(
                      contentPadding: const EdgeInsets.only(left: 15),
                      hintText: widget.hintText,
                      hintStyle: WidsManager().getText("s").style?.copyWith(
                          fontSize: (widget.height ?? 80) / 3.7,
                          color: ThemeDt.themeColors["fg"]!.withOpacity(0.6)),
                      border: OutlineInputBorder(
                          borderSide: BorderSide.none,
                          gapPadding: 4,
                          borderRadius: widget.tag == "src"
                              ? BorderRadius.circular(100)
                              : BorderRadius.circular(10))),
                ),
              ),
              if (tx.text != "")
                IconButton(
                  iconSize: ((widget.height ?? 80) < 70) ? 20 : null,

                  // small: ((widget.height ?? 80) < 70),
                  //light: true,
                  onPressed: () {
                    setState(() {
                      tx.text = "";
                    });
                  },
                  icon: Icon(
                    Icons.close_rounded,
                    color: ThemeDt.themeColors["fg"],
                  ),
                ),
              if (tx.text != "")
                IconButton(
                  iconSize: ((widget.height ?? 80) < 70) ? 20 : null,
                  // small: ((widget.height ?? 80) < 70),
                  //light: true,
                  onPressed: () {
                    widget.onDone(tx.text);
                  },
                  icon: Icon(
                    widget.tag == "src" ? Icons.search : Icons.check_rounded,
                    color: ThemeDt.themeColors["fg"],
                  ),
                ),
              const SizedBox(
                width: 8,
              ),
            ],
          )),
    );
  }
}

class GetToggleButton extends StatefulWidget {
  bool value;
  final Function onTap;
  GetToggleButton({required this.value, required this.onTap, super.key});

  @override
  State<GetToggleButton> createState() => _GetToggleButtonState();
}

class _GetToggleButtonState extends State<GetToggleButton> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        widget.onTap();
      },
      child: Stack(
        children: [
          WidsManager().getContainer(
              // curve: Curves.ease,
              duration: 600.milliseconds,
              width: 43,
              height: 23,
              borderRadius: 100,
              border: true,
              colour: widget.value ? "fg" : "bg"),
          AnimatedContainer(
            duration: ThemeDt.d,
            curve: ThemeDt.c,
            width: 16,
            height: 16,
            margin: EdgeInsets.only(left: widget.value ? 23 : 4, top: 3.4),
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: ThemeDt.themeColors[!widget.value ? "fg" : "bg"]),
          )
        ],
      ),
    );
  }
}

class GetPopMenuButton extends StatefulWidget {
  final Widget widgetOnTap;
  final Widget child;
  final String? tooltip;

  const GetPopMenuButton(
      {super.key,
      required this.widgetOnTap,
      this.tooltip,
      required this.child});

  @override
  State<GetPopMenuButton> createState() => _GetPopMenuButtonState();
}

class _GetPopMenuButtonState extends State<GetPopMenuButton> {
  @override
  Widget build(BuildContext context) {
    return WidsManager().getTooltip(
        text: widget.tooltip ?? "Show Menu",
        child: PopupMenuButton(
          tooltip: "",
          popUpAnimationStyle: AnimationStyle(duration: Duration.zero),
          color: Colors.transparent,
          elevation: 0,
          enableFeedback: false,
          itemBuilder: (
            BuildContext context,
          ) {
            return [
              PopupMenuItem(
                  enabled: false,
                  child: StatefulBuilder(builder: (BuildContext context,
                      void Function(void Function()) setState) {
                    return WidsManager()
                        .getContainer(
                      mar: 5,
                      // height: 400 ,

                      blur: true,
                      width: 800,
                      child: widget.widgetOnTap,
                    )
                        .animate(effects: [
                      ScaleEffect(
                          alignment: Alignment.topRight,
                          duration: ThemeDt.d,
                          curve: ThemeDt.c)
                    ]);
                  }))
            ];
          },
          child: widget.child,
        ));
  }
}
