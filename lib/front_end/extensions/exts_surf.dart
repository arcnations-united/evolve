import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../theme_manager/gtk_to_theme.dart';
import '../../theme_manager/gtk_widgets.dart';
import 'package:process_run/process_run.dart';

import 'extension_ui.dart';

class ExtsSurf extends StatefulWidget {
  const ExtsSurf({super.key});

  @override
  State<ExtsSurf> createState() => _ExtsSurfState();
}

class _ExtsSurfState extends State<ExtsSurf> {
  bool load = false;
  String vers = "";

  static Map results = {};
  static Future<Map> search(txt) async {
    results.clear();
    String vrs = txt.split("{}").last;
    txt = txt.split("{}").first;
    txt = txt.replaceAll(" ", "+");
    String src = (await Shell().run(
            "bash -c 'curl \"https://extensions.gnome.org/extension-query/?search=$txt&shell_version=$vrs\"'"))
        .outText;
    List s = jsonDecode(src)["extensions"];
    for (int i = 0; i < s.length; i++) {
      results[s[i]["uuid"]] = s[i];
    }
    return results;
  }

  bool err = false;
  Timer? t;
  static String txt1 = "";
  int currentPos = 0;
  bool fetching = false;
  List suggestedSearches = [
    "ArcMenu",
    "Apps Menu",
    "Burn My Windows",
    "Rounded Corners",
    "Frippery Clock",
  ];
  List history = [];
  late TextEditingController tx;
  @override
  void initState() {
    // TODO: implement initState
    tx = TextEditingController();
    loadHome();
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement initState
    super.dispose();
  }

  Map home = {};
  loadHome() async {
    load = true;
    File hm =
        File("${SystemInfo.home}/.NexData/cache/search/exts/homePage.json");
    if (await hm.exists()) {
      home = jsonDecode(hm.readAsStringSync());
    } else {
      await hm.create(recursive: true);
      await Shell().run(
          "bash -c 'wget -O ${hm.path} \"https://extensions.gnome.org/extension-query/?page=1&shell_version=${SystemInfo.shellVers}\"'");
      home = jsonDecode(hm.readAsStringSync());
    }
    List l = home["extensions"];
    List l2 = home["extensions"];
    for (int i = 0; i < l.length; i++) {
      if (l[i]["uuid"] ==
          "user-theme@gnome-shell-extensions.gcampax.github.com") {
        if (i != 0) l2.insert(0, l[i]);
        l2.removeAt(i + 1);
      }
    }
    l = List.of(l2);

    homeList = l2;
    setState(() {
      load = false;
    });
  }

  static bool homePageShow = true;
  List homeList = [];
  @override
  Widget build(BuildContext context) {
    double msize = MediaQuery.sizeOf(context).width / 2.5;
    double mhsize = msize / 1.2;
    double ssize = (MediaQuery.sizeOf(context).width - msize) - 54;
    if (msize < 220) {
      ssize = MediaQuery.sizeOf(context).width;
      msize = ssize;
      mhsize = 200;
    }
    String link =
        "https://i.ibb.co/KFbKf0h/Screenshot-from-2024-06-12-11-30-49.webp";
    return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: ThemeDt.themeColors["bg"],
          actions: [
            Expanded(
              child: Row(
                children: [
                  const Padding(
                    padding: EdgeInsets.only(left: 4.0, right: 4),
                    child: BackButton(),
                  ),
                  GetTextBox(
                    cnt: tx,
                    onDone: (txt) {
                      src(txt);

                      history.add(txt);
                      history = history.toSet().toList();
                      currentPos = history.length - 1;
                    },
                    tag: "src",
                    height: 40,
                    width: MediaQuery.sizeOf(context).width / 3.5,
                  ),
                  if (txt1 == "" && homePageShow)
                    for (int i = 0; i < suggestedSearches.length; i++)
                      Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: GestureDetector(
                            onTap: () {
                              history.add(suggestedSearches[i]);
                              history = history.toSet().toList();
                              currentPos = history.length - 1;
                              tx.text = suggestedSearches[i];
                              src(suggestedSearches[i]);
                            },
                            child: WidsManager().getContainer(
                                border: true,
                                height: 40,
                                borderRadius: 100,
                                borderOpacity: 0.2,
                                child: Center(
                                    child: WidsManager().getText(
                                        "  ${suggestedSearches[i]}  ",
                                        size: 11))),
                          ).animate(effects: [
                            SlideEffect(
                                begin: const Offset(0, 0.5),
                                end: Offset.zero,
                                duration: 1.seconds,
                                delay: 100.milliseconds * i,
                                curve: Curves.easeOutExpo),
                            FadeEffect(
                                delay: 100.milliseconds * i,
                                duration: 600.milliseconds,
                                curve: ThemeDt.c),
                          ])),
                  if (txt1 != "" || !homePageShow) ...[
                    const SizedBox(
                      width: 8,
                    ),
                    GestureDetector(
                      onTap: () {
                        if (history.isEmpty) return;
                        currentPos = currentPos - 1;
                        if (currentPos == 0) {
                          currentPos = history.length - 1;
                        }
                        if (currentPos < 0 || currentPos >= history.length) {
                          currentPos = history.length - 1;
                        }

                        tx.text = history[currentPos];
                        src(history[currentPos]);
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: WidsManager().getContainer(
                          border: true,
                          borderOpacity: 0.1,
                          borderRadius: 100,
                          height: 40,
                          width: 50,
                          child: Icon(
                            Icons.chevron_left,
                            color: ThemeDt.themeColors["fg"],
                            size: 17,
                          ),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        if (history.isEmpty) return;
                        currentPos = currentPos + 1;
                        if (currentPos == 0) {
                          currentPos = history.length - 1;
                        }
                        if (currentPos < 0 || currentPos >= history.length) {
                          currentPos = history.length - 1;
                        }

                        tx.text = history[currentPos];
                        src(history[currentPos]);
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: WidsManager().getContainer(
                          border: true,
                          borderOpacity: 0.1,
                          borderRadius: 100,
                          height: 40,
                          width: 50,
                          child: Icon(
                            Icons.chevron_right,
                            color: ThemeDt.themeColors["fg"],
                            size: 17,
                          ),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () async {
                        setState(() {
                          results.clear();
                        });
                        await search(
                          "$txt1{}${SystemInfo.shellVers}",
                        );
                        setState(() {});
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: WidsManager().getContainer(
                          border: true,
                          borderOpacity: 0.1,
                          borderRadius: 100,
                          height: 40,
                          width: 50,
                          child: Icon(
                            Icons.refresh,
                            color: ThemeDt.themeColors["fg"],
                            size: 17,
                          ),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        tx.text = "";

                        setState(() {
                          homePageShow = true;
                          txt1 = "";
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: WidsManager().getContainer(
                          border: true,
                          borderOpacity: 0.1,
                          borderRadius: 100,
                          height: 40,
                          width: 50,
                          child: Icon(
                            Icons.home,
                            color: ThemeDt.themeColors["fg"],
                            size: 17,
                          ),
                        ),
                      ),
                    ),
                  ]
                ],
              ),
            )
          ],
        ),
        body: load
            ? Center(
                child: CircularProgressIndicator(
                  color: ThemeDt.themeColors["fg"],
                  strokeWidth: 8,
                  strokeCap: StrokeCap.round,
                ),
              )
            : Padding(
                padding: const EdgeInsets.all(18.0),
                child: SizedBox(
                  height: MediaQuery.sizeOf(context).height,
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (txt1 == "" && homePageShow)
                          Wrap(
                            spacing: 18,
                            runSpacing: 10,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(15),
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                ExtensionInfoPage(
                                                  uuid: homeList.first["uuid"],
                                                  jsonInfo: homeList.first,
                                                )));
                                  },
                                  child: Stack(
                                    children: [
                                      if ((homeList.first["screenshot"] ??
                                                  homeList.first["icon"])
                                              .contains("plugin") ==
                                          false)
                                        ClipRRect(
                                          child: ImageFiltered(
                                              imageFilter: ImageFilter.blur(
                                                sigmaX: 20,
                                                sigmaY: 20,
                                              ),
                                              child: Image.network(
                                                  loadingBuilder: (context,
                                                      child, loadingProgress) {
                                                if (loadingProgress
                                                        ?.cumulativeBytesLoaded ==
                                                    loadingProgress
                                                        ?.expectedTotalBytes) {
                                                  return child
                                                      .animate(effects: [
                                                    FadeEffect(
                                                        duration: 1.seconds),
                                                    BlurEffect(
                                                        begin: const Offset(10, 10),
                                                        delay: 200.milliseconds,
                                                        duration: 3.seconds,
                                                        curve:
                                                            Curves.easeOutExpo),
                                                  ]);
                                                } else {
                                                  return const SizedBox(
                                                    width: 10,
                                                    height: 10,
                                                  );
                                                }
                                              },
                                                  fit: BoxFit.fill,
                                                  width: ssize,
                                                  height: mhsize,
                                                  "https://extensions.gnome.org${(homeList.first["screenshot"] ?? homeList.first["icon"])}")),
                                        )
                                      else if (homeList.first["uuid"] ==
                                          "user-theme@gnome-shell-extensions.gcampax.github.com")
                                        ClipRRect(
                                          child: ImageFiltered(
                                            imageFilter: ImageFilter.blur(
                                              sigmaX: 20,
                                              sigmaY: 20,
                                            ),
                                            child: Image.network(
                                                width: ssize,
                                                height: mhsize,
                                                fit: BoxFit.fill,
                                                loadingBuilder: (context, child,
                                                    loadingProgress) {
                                              if (loadingProgress
                                                      ?.cumulativeBytesLoaded ==
                                                  loadingProgress
                                                      ?.expectedTotalBytes) {
                                                return child.animate(effects: [
                                                  FadeEffect(
                                                      duration: 1.seconds),
                                                ]);
                                              } else {
                                                return const SizedBox(
                                                  width: 10,
                                                  height: 10,
                                                );
                                              }
                                            }, errorBuilder: (context, error,
                                                    stackTrace) {
                                              return Image.asset(
                                                  width: ssize,
                                                  height: mhsize,
                                                  "assets/userthemes.png");
                                            }, link),
                                          ),
                                        ),
                                      if ((homeList.first["screenshot"] ??
                                                  homeList.first["icon"])
                                              .contains("plugin") ==
                                          false)
                                        ShaderMask(
                                            shaderCallback: (Rect bounds) {
                                              return const LinearGradient(
                                                begin: Alignment.bottomCenter,
                                                end: Alignment.topCenter,
                                                colors: [
                                                  Colors.transparent,
                                                  Colors.black,
                                                ],
                                                stops: [0.35, 0.7],
                                              ).createShader(bounds);
                                            },
                                            blendMode: BlendMode.dstIn,
                                            child: Image.network(
                                                width: ssize,
                                                height: mhsize,
                                                fit: BoxFit.cover,
                                                loadingBuilder: (context, child,
                                                    loadingProgress) {
                                              if (loadingProgress
                                                      ?.cumulativeBytesLoaded ==
                                                  loadingProgress
                                                      ?.expectedTotalBytes) {
                                                return child.animate(effects: [
                                                  FadeEffect(
                                                      duration: 1.seconds),
                                                  BlurEffect(
                                                      begin: const Offset(10, 10),
                                                      delay: 200.milliseconds,
                                                      duration: 3.seconds,
                                                      curve:
                                                          Curves.easeOutExpo),
                                                ]);
                                              } else {
                                                return const SizedBox(
                                                  width: 10,
                                                  height: 10,
                                                );
                                              }
                                            }, "https://extensions.gnome.org${(homeList.first["screenshot"] ?? homeList.first["icon"])}"))
                                      else if (homeList.first["uuid"] ==
                                          "user-theme@gnome-shell-extensions.gcampax.github.com")
                                        ShaderMask(
                                          shaderCallback: (Rect bounds) {
                                            return const LinearGradient(
                                              begin: Alignment.bottomCenter,
                                              end: Alignment.topCenter,
                                              colors: [
                                                Colors.transparent,
                                                Colors.black,
                                              ],
                                              stops: [0.35, 0.7],
                                            ).createShader(bounds);
                                          },
                                          blendMode: BlendMode.dstIn,
                                          child: Image.network(
                                              fit: BoxFit.cover,
                                              loadingBuilder: (context, child,
                                                  loadingProgress) {
                                                if (loadingProgress
                                                        ?.cumulativeBytesLoaded ==
                                                    loadingProgress
                                                        ?.expectedTotalBytes) {
                                                  return child
                                                      .animate(effects: [
                                                    FadeEffect(
                                                        duration: 1.seconds),
                                                    BlurEffect(
                                                        begin: const Offset(10, 10),
                                                        delay: 200.milliseconds,
                                                        duration: 3.seconds,
                                                        curve:
                                                            Curves.easeOutExpo),
                                                  ]);
                                                } else {
                                                  return const SizedBox(
                                                    width: 10,
                                                    height: 10,
                                                  );
                                                }
                                              },
                                              width: ssize,
                                              height: mhsize,
                                              errorBuilder:
                                                  (context, error, stackTrace) {
                                                return Image.asset(
                                                    width: ssize,
                                                    height: mhsize,
                                                    "assets/userthemes.png");
                                              },
                                              link),
                                        ),
                                      Container(
                                          width: ssize,
                                          height: mhsize,
                                          decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(15),
                                              border: Border.all(
                                                  color: ThemeDt
                                                      .themeColors["fg"]!
                                                      .withOpacity(0.2)),
                                              gradient: LinearGradient(
                                                  begin: Alignment.bottomCenter,
                                                  end: Alignment.topCenter,
                                                  colors: [
                                                    ThemeDt.themeColors["bg"]!
                                                        .withOpacity(0.95),
                                                    ThemeDt.themeColors["bg"]!
                                                        .withOpacity(0.6),
                                                    ThemeDt.themeColors["bg"]!
                                                        .withOpacity(0.0)
                                                  ],
                                                  stops: const [
                                                    0.0,
                                                    0.4,
                                                    1
                                                  ]))),
                                      Positioned(
                                        bottom: 0,
                                        child: Padding(
                                          padding: const EdgeInsets.all(18.0),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              WidsManager().getText(
                                                  homeList.first["creator"]
                                                      .toUpperCase(),
                                                  letterSpacing: 0,
                                                  size: 10,
                                                  fontWeight: FontWeight.w400,
                                                  opacity: 0.7),
                                              const SizedBox(
                                                height: 3,
                                              ),
                                              SizedBox(
                                                width: ssize / 1.6,
                                                child: WidsManager().getText(
                                                  (homeList.first["description"]
                                                              .toString()
                                                              .length >=
                                                          50)
                                                      ? homeList.first["name"]
                                                      : homeList.first[
                                                              "description"] ??
                                                          homeList
                                                              .first["name"],
                                                  height: 1.15,
                                                  letterSpacing: 0,
                                                  size: 20,
                                                  maxLines: 2,
                                                  fontWeight: FontWeight.w400,
                                                ),
                                              ),
                                              const SizedBox(
                                                height: 8,
                                              ),
                                              WidsManager().getText(
                                                homeList.first["uuid"] ==
                                                        "user-theme@gnome-shell-extensions.gcampax.github.com"
                                                    ? "Modify the GNOME Shell (the top bar) with custom themes."
                                                    :
                                                    //  "Click to download the extension",
                                                    homeList.first["description"]
                                                                .toString()
                                                                .toLowerCase()
                                                                .replaceAll(
                                                                    ".", "")
                                                                .replaceAll(
                                                                    "the", "")
                                                                .replaceAll(
                                                                    " ", "") ==
                                                            homeList
                                                                .first["name"]
                                                                .toString()
                                                                .toLowerCase()
                                                                .replaceAll(
                                                                    ".", "")
                                                                .replaceAll(
                                                                    "the", "")
                                                                .replaceAll(
                                                                    " ", "")
                                                        ? "Click to download the extension"
                                                        : "${homeList.first["name"]}",
                                                letterSpacing: 0,
                                                size: 10,
                                                opacity: 0.7,
                                                fontWeight: FontWeight.w400,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      if (homeList.first["uuid"] ==
                                          "user-theme@gnome-shell-extensions.gcampax.github.com")
                                        Padding(
                                          padding: const EdgeInsets.all(18.0),
                                          child: WidsManager().getContainer(
                                              colour: "altbg",
                                              borderRadius: 4,
                                              pad: 5,
                                              child: WidsManager().getText(
                                                  " RECOMMENDED! ",
                                                  size: 10)),
                                        )
                                    ],
                                  ),
                                ),
                              ).animate(effects: [
                                SlideEffect(
                                    begin: const Offset(0, 0.1),
                                    end: Offset.zero,
                                    duration: 1.seconds,
                                    curve: Curves.easeOutExpo),
                                FadeEffect(
                                    duration: 600.milliseconds,
                                    curve: ThemeDt.c),
                              ]),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(15),
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                ExtensionInfoPage(
                                                  uuid: homeList[1]["uuid"],
                                                  jsonInfo: homeList[1],
                                                )));
                                  },
                                  child: Stack(
                                    children: [
                                      if ((homeList[1]["screenshot"] ??
                                                  homeList[1]["icon"])
                                              .contains("plugin") ==
                                          false)
                                        ClipRRect(
                                          child: ImageFiltered(
                                              imageFilter: ImageFilter.blur(
                                                sigmaX: 20,
                                                sigmaY: 20,
                                              ),
                                              child: Image.network(
                                                  loadingBuilder: (context,
                                                      child, loadingProgress) {
                                                if (loadingProgress
                                                        ?.cumulativeBytesLoaded ==
                                                    loadingProgress
                                                        ?.expectedTotalBytes) {
                                                  return child
                                                      .animate(effects: [
                                                    FadeEffect(
                                                        duration: 1.seconds),
                                                    BlurEffect(
                                                        begin: const Offset(10, 10),
                                                        delay: 200.milliseconds,
                                                        duration: 3.seconds,
                                                        curve:
                                                            Curves.easeOutExpo),
                                                  ]);
                                                } else {
                                                  return const SizedBox(
                                                    width: 10,
                                                    height: 10,
                                                  );
                                                }
                                              },
                                                  fit: BoxFit.fill,
                                                  width: msize,
                                                  height: mhsize,
                                                  "https://extensions.gnome.org${(homeList[1]["screenshot"] ?? homeList[1]["icon"])}")),
                                        )
                                      else if (homeList[1]["uuid"] ==
                                          "user-theme@gnome-shell-extensions.gcampax.github.com")
                                        ClipRRect(
                                          child: ImageFiltered(
                                            imageFilter: ImageFilter.blur(
                                              sigmaX: 20,
                                              sigmaY: 20,
                                            ),
                                            child: Image.network(
                                                width: msize,
                                                height: mhsize,
                                                fit: BoxFit.fill, errorBuilder:
                                                    (context, error,
                                                        stackTrace) {
                                              return Image.asset(
                                                      width: msize,
                                                      height: mhsize,
                                                      "assets/userthemes.png")
                                                  .animate(effects: [
                                                FadeEffect(duration: 3.seconds),
                                                BlurEffect(
                                                    begin: const Offset(10, 10),
                                                    duration: 2.seconds),
                                              ]);
                                            }, loadingBuilder: (context, child,
                                                    loadingProgress) {
                                              if (loadingProgress
                                                      ?.cumulativeBytesLoaded ==
                                                  loadingProgress
                                                      ?.expectedTotalBytes) {
                                                return child.animate(effects: [
                                                  FadeEffect(
                                                      duration: 1.seconds),
                                                  BlurEffect(
                                                      begin: const Offset(10, 10),
                                                      delay: 200.milliseconds,
                                                      duration: 3.seconds,
                                                      curve:
                                                          Curves.easeOutExpo),
                                                ]);
                                              } else {
                                                return const SizedBox(
                                                  width: 10,
                                                  height: 10,
                                                );
                                              }
                                            }, link),
                                          ),
                                        ),
                                      if ((homeList[1]["screenshot"] ??
                                                  homeList[1]["icon"])
                                              .contains("plugin") ==
                                          false)
                                        ShaderMask(
                                            shaderCallback: (Rect bounds) {
                                              return const LinearGradient(
                                                begin: Alignment.bottomCenter,
                                                end: Alignment.topCenter,
                                                colors: [
                                                  Colors.transparent,
                                                  Colors.black,
                                                ],
                                                stops: [0.35, 0.7],
                                              ).createShader(bounds);
                                            },
                                            blendMode: BlendMode.dstIn,
                                            child: Image.network(
                                                width: msize,
                                                height: mhsize,
                                                fit: BoxFit.cover,
                                                loadingBuilder: (context, child,
                                                    loadingProgress) {
                                              if (loadingProgress
                                                      ?.cumulativeBytesLoaded ==
                                                  loadingProgress
                                                      ?.expectedTotalBytes) {
                                                return child.animate(effects: [
                                                  FadeEffect(
                                                      duration: 1.seconds),
                                                  BlurEffect(
                                                      begin: const Offset(10, 10),
                                                      delay: 200.milliseconds,
                                                      duration: 3.seconds,
                                                      curve:
                                                          Curves.easeOutExpo),
                                                ]);
                                              } else {
                                                return const SizedBox(
                                                  width: 10,
                                                  height: 10,
                                                );
                                              }
                                            }, "https://extensions.gnome.org${(homeList[1]["screenshot"] ?? homeList[1]["icon"])}"))
                                      else if (homeList[1]["uuid"] ==
                                          "user-theme@gnome-shell-extensions.gcampax.github.com")
                                        ShaderMask(
                                          shaderCallback: (Rect bounds) {
                                            return const LinearGradient(
                                              begin: Alignment.bottomCenter,
                                              end: Alignment.topCenter,
                                              colors: [
                                                Colors.transparent,
                                                Colors.black,
                                              ],
                                              stops: [0.3, 0.7],
                                            ).createShader(bounds);
                                          },
                                          blendMode: BlendMode.dstIn,
                                          child: Image.network(
                                              fit: BoxFit.cover,
                                              width: msize,
                                              height: mhsize, errorBuilder:
                                                  (context, error, stackTrace) {
                                            return Image.asset(
                                                width: msize,
                                                height: mhsize,
                                                "assets/userthemes.png");
                                          }, loadingBuilder: (context, child,
                                                  loadingProgress) {
                                            if (loadingProgress
                                                    ?.cumulativeBytesLoaded ==
                                                loadingProgress
                                                    ?.expectedTotalBytes) {
                                              return child.animate(effects: [
                                                FadeEffect(duration: 1.seconds),
                                                BlurEffect(
                                                    begin: const Offset(10, 10),
                                                    delay: 200.milliseconds,
                                                    duration: 3.seconds,
                                                    curve: Curves.easeOutExpo),
                                              ]);
                                            } else {
                                              return const SizedBox(
                                                width: 10,
                                                height: 10,
                                              );
                                            }
                                          }, link),
                                        ),
                                      Container(
                                          width: msize,
                                          height: mhsize,
                                          decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(15),
                                              border: Border.all(
                                                  color: ThemeDt
                                                      .themeColors["fg"]!
                                                      .withOpacity(0.2)),
                                              gradient: LinearGradient(
                                                  begin: Alignment.bottomCenter,
                                                  end: Alignment.topCenter,
                                                  colors: [
                                                    ThemeDt.themeColors["bg"]!
                                                        .withOpacity(0.95),
                                                    ThemeDt.themeColors["bg"]!
                                                        .withOpacity(0.6),
                                                    ThemeDt.themeColors["bg"]!
                                                        .withOpacity(0.0)
                                                  ],
                                                  stops: const [
                                                    0.0,
                                                    0.4,
                                                    1
                                                  ]))),
                                      Positioned(
                                        bottom: 0,
                                        child: Padding(
                                          padding: const EdgeInsets.all(18.0),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              WidsManager().getText(
                                                  homeList[1]["creator"]
                                                      .toUpperCase(),
                                                  letterSpacing: 0,
                                                  size: 10,
                                                  fontWeight: FontWeight.w400,
                                                  opacity: 0.7),
                                              const SizedBox(
                                                height: 3,
                                              ),
                                              SizedBox(
                                                width: ssize / 1.6,
                                                child: WidsManager().getText(
                                                  (homeList[1]["description"]
                                                              .toString()
                                                              .length >=
                                                          50)
                                                      ? homeList[1]["name"]
                                                      : homeList[1]
                                                              ["description"] ??
                                                          homeList[1]["name"],
                                                  height: 1.15,
                                                  letterSpacing: 0,
                                                  size: 20,
                                                  maxLines: 2,
                                                  fontWeight: FontWeight.w400,
                                                ),
                                              ),
                                              const SizedBox(
                                                height: 8,
                                              ),
                                              WidsManager().getText(
                                                homeList[1]["uuid"] ==
                                                        "user-theme@gnome-shell-extensions.gcampax.github.com"
                                                    ? "Modify the GNOME Shell (the top bar) with custom themes."
                                                    :
                                                    //  "Click to download the extension",
                                                    homeList[1]["description"]
                                                                .toString()
                                                                .toLowerCase()
                                                                .replaceAll(
                                                                    ".", "")
                                                                .replaceAll(
                                                                    "the", "")
                                                                .replaceAll(
                                                                    " ", "") ==
                                                            homeList[1]["name"]
                                                                .toString()
                                                                .toLowerCase()
                                                                .replaceAll(
                                                                    ".", "")
                                                                .replaceAll(
                                                                    "the", "")
                                                                .replaceAll(
                                                                    " ", "")
                                                        ? "Click to download the extension"
                                                        : "${homeList[1]["name"]}",
                                                letterSpacing: 0,
                                                size: 10,
                                                opacity: 0.7,
                                                fontWeight: FontWeight.w400,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ).animate(effects: [
                                SlideEffect(
                                    begin: const Offset(0, 0.1),
                                    end: Offset.zero,
                                    duration: 1.seconds,
                                    delay: 60.milliseconds,
                                    curve: Curves.easeOutExpo),
                                FadeEffect(
                                    delay: 60.milliseconds,
                                    duration: 600.milliseconds,
                                    curve: ThemeDt.c),
                              ]),
                            ],
                          ),
                        if (txt1 == "" && homePageShow)
                          const SizedBox(
                            height: 20,
                          ),
                        if (txt1 == "" && homePageShow)
                          SizedBox(
                            height: MediaQuery.sizeOf(context).height / 2,
                            child: GridView(
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount:
                                    (MediaQuery.sizeOf(context).width / 300)
                                        .ceil(),
                                childAspectRatio: 3,
                                mainAxisSpacing: 8,
                                crossAxisSpacing: 8,
                              ),
                              children: [
                                for (int i = 2; i < homeList.length; i++)
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(15),
                                    child: GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    ExtensionInfoPage(
                                                      uuid: homeList[i]["uuid"],
                                                      jsonInfo: homeList[i],
                                                    )));
                                      },
                                      child: Stack(
                                        children: [
                                          if ((homeList[i]["screenshot"] ??
                                                      homeList[i]["icon"])
                                                  .contains("plugin") ==
                                              false)
                                            ClipRRect(
                                              child: Image.network(
                                                  opacity:
                                                      const AlwaysStoppedAnimation(
                                                          0.2),
                                                  fit: BoxFit.fill,
                                                  width: double.infinity,
                                                  loadingBuilder: (context,
                                                      child, loadingProgress) {
                                                if (loadingProgress
                                                        ?.cumulativeBytesLoaded ==
                                                    loadingProgress
                                                        ?.expectedTotalBytes) {
                                                  return child
                                                      .animate(effects: [
                                                    FadeEffect(
                                                        duration: 1.seconds),
                                                    BlurEffect(
                                                        end: const Offset(40, 40),
                                                        delay: 200.milliseconds,
                                                        duration: 3.seconds,
                                                        curve:
                                                            Curves.easeOutExpo),
                                                  ]);
                                                } else {
                                                  return const SizedBox(
                                                    width: 10,
                                                    height: 10,
                                                  );
                                                }
                                              },
                                                  //  height: 100,
                                                  "https://extensions.gnome.org${(homeList[i]["screenshot"] ?? homeList[i]["icon"])}"),
                                            )
                                          else if (homeList[i]["uuid"] ==
                                              "user-theme@gnome-shell-extensions.gcampax.github.com")
                                            ClipRRect(
                                              child: ImageFiltered(
                                                imageFilter: ImageFilter.blur(
                                                  sigmaX: 40,
                                                  sigmaY: 40,
                                                ),
                                                child: Image.network(
                                                    width: double.infinity,
                                                    //  height: 100,
                                                    fit: BoxFit.fill,
                                                    errorBuilder: (context,
                                                        error, stackTrace) {
                                                  return Image.asset(
                                                      width: double.infinity,
                                                      //     height: 100,
                                                      "assets/userthemes.png");
                                                }, loadingBuilder: (context,
                                                        child,
                                                        loadingProgress) {
                                                  if (loadingProgress
                                                          ?.cumulativeBytesLoaded ==
                                                      loadingProgress
                                                          ?.expectedTotalBytes) {
                                                    return child
                                                        .animate(effects: [
                                                      FadeEffect(
                                                          duration: 1.seconds),
                                                      BlurEffect(
                                                          begin: const Offset(10, 10),
                                                          delay:
                                                              200.milliseconds,
                                                          duration: 3.seconds,
                                                          curve: Curves
                                                              .easeOutExpo),
                                                    ]);
                                                  } else {
                                                    return const SizedBox(
                                                      width: 10,
                                                      height: 10,
                                                    );
                                                  }
                                                }, link),
                                              ),
                                            )
                                          /*  else
                                                WidsManager().getContainer(
                                                  width: double.infinity,
                                                  height: double.infinity,
                                                  child: Center(child: WidsManager().getText("  ${homeList[i]["name"]}  ",fontWeight: FontWeight.w500))
                                                )*/
                                          ,
                                          Container(
                                              width: double.infinity,
                                              //    height: 100,
                                              decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(15),
                                                  border: Border.all(
                                                      color: ThemeDt
                                                          .themeColors["fg"]!
                                                          .withOpacity(0.2)),
                                                  gradient: LinearGradient(
                                                      begin: Alignment
                                                          .bottomCenter,
                                                      end: Alignment.topCenter,
                                                      colors: [
                                                        ThemeDt
                                                            .themeColors["bg"]!
                                                            .withOpacity(0.95),
                                                        ThemeDt
                                                            .themeColors["bg"]!
                                                            .withOpacity(0.6),
                                                        ThemeDt
                                                            .themeColors["bg"]!
                                                            .withOpacity(0.0)
                                                      ],
                                                      stops: const [
                                                        0.0,
                                                        0.4,
                                                        1
                                                      ]))),
                                          Padding(
                                            padding: const EdgeInsets.all(14.0),
                                            child: WidsManager().getText(
                                                homeList[i]["creator"]
                                                    .toUpperCase(),
                                                letterSpacing: 0,
                                                size: 10,
                                                fontWeight: FontWeight.w400,
                                                opacity: 0.7),
                                          ),
                                          Positioned(
                                            bottom: 0,
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(14.0),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  /*  WidsManager().getText(homeList[i]["creator"].toUpperCase(),
                                letterSpacing: 0,
                                size: 6,
                                fontWeight: FontWeight.w400,
                                opacity: 0.7),*/

                                                  SizedBox(
                                                    width: 160,
                                                    child:
                                                        WidsManager().getText(
                                                      (homeList[i]["description"]
                                                                  .toString()
                                                                  .length >=
                                                              50)
                                                          ? homeList[i]["name"]
                                                          : homeList[i][
                                                                  "description"] ??
                                                              homeList[i]
                                                                  ["name"],
                                                      height: 1,
                                                      letterSpacing: 0,
                                                      size: 16,
                                                      maxLines: 1,
                                                      opacity: 0.9,
                                                      fontWeight:
                                                          FontWeight.w400,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ).animate(effects: [
                                    SlideEffect(
                                        begin: const Offset(0, 0.1),
                                        end: Offset.zero,
                                        duration: 1.seconds,
                                        delay: 60.milliseconds * i,
                                        curve: Curves.easeOutExpo),
                                    FadeEffect(
                                        delay: 60.milliseconds * i,
                                        duration: 600.milliseconds,
                                        curve: ThemeDt.c),
                                  ]),
                              ],
                            ),
                          ),
                        if (!homePageShow &&
                            tx.text != "" &&
                            !loadSrc &&
                            results.isEmpty)
                          WidsManager().getText(
                              "No results found. Try searching something else."),
                        Center(
                            child: WidsManager().getContainer(
                          height: txt1 == ""
                              ? 0
                              : MediaQuery.sizeOf(context).height - 152,
                          width: MediaQuery.sizeOf(context).width,
                          colour: (txt1 != "") ? "altbg" : "bg",
                          child: (txt1 == "")
                              ? WidsManager().getText(
                                  "Search for extensions and results will appear here...")
                              : ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: SingleChildScrollView(
                                    child: WidsManager().gtkColumn(
                                      // crossAxisAlignment: CrossAxisAlignment.start,
                                      width: MediaQuery.sizeOf(context).width,
                                      children: [
                                        for (int i = 0;
                                            i <
                                                (results.isEmpty
                                                    ? 10
                                                    : results.length);
                                            i++)
                                          GestureDetector(
                                            onTap: () {
                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          ExtensionInfoPage(
                                                            uuid: results.keys
                                                                .elementAt(i),
                                                            jsonInfo: results
                                                                .values
                                                                .elementAt(i),
                                                          )));
                                            },
                                            child: Container(
                                              color:
                                                  ThemeDt.themeColors["altbg"],
                                              child: Row(
                                                children: [
                                                  Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      FutureWid(
                                                        val: results.isEmpty
                                                            ? null
                                                            : "",
                                                        width: 200,
                                                        height: 15,
                                                        child: WidsManager().getText(
                                                            results.isEmpty
                                                                ? ""
                                                                : results.values
                                                                    .elementAt(
                                                                        i)["name"],
                                                            color: "altfg",
                                                            size: 15),
                                                      ),
                                                      const SizedBox(
                                                        height: 2,
                                                      ),
                                                      Opacity(
                                                        opacity: 0.5,
                                                        child: FutureWid(
                                                          val: results.isEmpty
                                                              ? null
                                                              : "",
                                                          width: 100,
                                                          height: 11,
                                                          child: WidsManager().getText(
                                                              results.isEmpty
                                                                  ? ""
                                                                  : results
                                                                          .values
                                                                          .elementAt(
                                                                              i)[
                                                                      "creator"],
                                                              size: 11),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                        ))
                      ],
                    ),
                  ),
                ),
              ));
  }

  bool loadSrc = false;
  void src(txt) {
    homePageShow = false;

    setState(() {
      loadSrc = true;
      txt1 = txt;
    });

    if (txt1 != "") {
      t?.cancel();
      t = Timer(500.milliseconds, () async {
        setState(() {
          fetching = true;
          results = {};
        });

        try {
          results = await compute(search, "$txt1{}${SystemInfo.shellVers}");
        } catch (e) {
          setState(() {
            txt1 = "";
          });
        }

        setState(() {
          fetching = false;
          if (results.isEmpty) {
            txt1 = "";
          }
          loadSrc = false;
        });
      });
    }
  }
}
