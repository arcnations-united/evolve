import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../back_end/app_data.dart';
import '../front_end/app_specific_settings.dart';
import 'package:process_run/process_run.dart';
import '../theme_manager/gtk_to_theme.dart';
import '../theme_manager/gtk_widgets.dart';
import 'about_page.dart';
import 'appearance.dart';
import 'extensions/extension_ui.dart';
import 'extensions/exts_surf.dart';
import 'icons.dart';
import '../theme_manager/tab_manage.dart';

class WidgetGTK extends StatefulWidget {
  const WidgetGTK({
    super.key,
  });

  @override
  State<WidgetGTK> createState() => _WidgetGTKState();
}

//added some welcome messagesjsonEncode
class _WidgetGTKState extends State<WidgetGTK> with TickerProviderStateMixin {
  bool firstLaunch = true;
  state() {
    setState(() {});
  }

  @override
  void initState() {
    AppData.DataFile["autoUpdateBackup"] ??= false;
    AppData.DataFile["GNOMEUI"] ??= false; //DEPRECATED
    // TODO: implement initState
    setLaunch();
    if (AppData.DataFile["DONE"] == null) {
      showMessage();
    }
    super.initState();
  }

  bool minButton = false;
  bool maxButton = false;
  setLaunch() async {
    String s1 = (await Shell().run(
            "gsettings get org.gnome.desktop.wm.preferences button-layout"))
        .outText;
    winLeft = s1.replaceAll("'", "").endsWith("icon") ? true : false;
    minButton = s1.contains("minimize") ? true : false;
    maxButton = s1.contains("maximize") ? true : false;
    await Future.delayed(500.milliseconds);
    setState(() {
      firstLaunch = false;
    });
  }

  showMessage() async {
    await Future.delayed(100.milliseconds);
    {
      WidsManager().showMessage(
        title: "Info",
        message:
            "By continuing to use the app you agree to the terms and conditions. Check the README file provided.",
        context: context,
        child: Row(mainAxisAlignment: MainAxisAlignment.end, children: <Widget>[
          GetButtons(
            onTap: () {
              Navigator.pop(context);
              WidsManager().showMessage(
                  title: "Info",
                  message:
                      "Your responsibility as an user is to help me provide high quality and performant apps. One way to do this is providing"
                      " comprehensive feedback of problems faced and errors encountered.\n\nMake sure to message me from 'Contact me' on https://bit.ly/evolvegtk with screenshots, log outputs and the theme/icon link the problem was "
                      "encountered with. Run this app from the terminal in order to get log outputs. You can DM me on Patreon too since I'm pretty active there.",
                  context: context,
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        GetButtons(
                            light: true,
                            text: "Okay",
                            onTap: () async {
                              {
                                AppData.DataFile["DONE"] = "TRUE";
                                AppData().writeDataFile();
                                Navigator.pop(context);
                              }
                            })
                      ]));
            },
            text: "Accept",
          )
        ]),
      );
    }
  }

  bool winLeft = false;
  bool loading = true;
  @override
  Widget build(BuildContext context) {
    double w = MediaQuery.sizeOf(context).width;
    TabManager.isLargeScreen = w > 600;
    TabManager.isSuperLarge = w > 1000;
    return Scaffold(
      backgroundColor: ThemeDt.themeColors["bg"],
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (WidsManager.activeTab == 3)
            GestureDetector(
                onTap: () {
                  if (WidsManager.activeTab == 3) {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const ExtsSurf()));
                  }
                },
                child: WidsManager().getContainer(
                    child: Icon(
                  Icons.shopping_cart,
                  color: ThemeDt.themeColors["fg"],
                ))),
        ],
      ),
      body: AnimatedOpacity(
        duration: ThemeDt.d,
        opacity: TabManager.freeze ? 0.7 : 1.0,
        child: IgnorePointer(
          ignoring: TabManager.freeze,
          child: Stack(
            // crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Positioned(
                left: TabManager.isLargeScreen ? -30 : 0,
                child: DrawerButton(
                  onPressed: () {
                    setState(() {
                      TabManager.isDrawerVisible = true;
                    });
                  },
                ),
              ),
              AnimatedPositioned(
                duration: ThemeDt.d,
                curve: ThemeDt.c,
                top: TabManager.isLargeScreen ? 0 : 30,
                right: 0,
                child: SizedBox(
                    width: MediaQuery.sizeOf(context).width -
                        ((TabManager.isLargeScreen) ? 165 : 0),
                    child: MainView(
                      state: state,
                    )),
              ),
              Positioned(
                left: TabManager.isLargeScreen
                    ? -MediaQuery.sizeOf(context).width
                    : TabManager.isDrawerVisible
                        ? 0
                        : -MediaQuery.sizeOf(context).width,
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      TabManager.isDrawerVisible = !TabManager.isDrawerVisible;
                    });
                  },
                  child: Container(
                    color: Colors.black.withOpacity(0.2),
                    height: MediaQuery.sizeOf(context).height,
                    width: MediaQuery.sizeOf(context).width,
                  ),
                ),
              ),
              AnimatedPositioned(
                  duration: ThemeDt.d,
                  curve: ThemeDt.c,
                  left: TabManager.isLargeScreen
                      ? 0
                      : TabManager.isDrawerVisible
                          ? 0
                          : -190,
                  child: Container(
                    decoration: BoxDecoration(
                      color: ThemeDt.themeColors["bg"],
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TabbedInterface(
                          state: state,
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Container(
                          height: MediaQuery.sizeOf(context).height,
                          width: 1,
                          color: ThemeDt.themeColors["fg"]
                              ?.withOpacity(TabManager.isLargeScreen ? 0.2 : 0),
                        )
                      ],
                    ),
                  )),
            ],
          ),
        ),
      ),
    );
  }
}

class TabbedInterface extends StatefulWidget {
  final Function() state;
  const TabbedInterface({super.key, required this.state});

  @override
  State<TabbedInterface> createState() => _TabbedInterfaceState();
}

class _TabbedInterfaceState extends State<TabbedInterface> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(left: 8.0, bottom: 8, top: 8),
          child: TabButton(
            Tab: 0,
            state: widget.state,
            text: 'Theme',
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 8.0, bottom: 8),
          child: TabButton(
            Tab: 1,
            state: widget.state,
            text: 'Icons',
          ),
        ),
        /*  Padding(
          padding: const EdgeInsets.only(left: 8.0, bottom: 8),
          child: TabButton(
            Tab: 2,
            state: widget.state,
            text: 'Config',
          ),
        ),*/
        Padding(
          padding: const EdgeInsets.only(left: 8.0, bottom: 8),
          child: TabButton(
            Tab: 3,
            state: widget.state,
            text: 'Extensions',
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 8.0, bottom: 8),
          child: TabButton(
            Tab: 4,
            state: widget.state,
            text: 'Settings',
          ),
        ),
        if (AppData.DataFile["GNOMEUI"] == false)
          Padding(
            padding: const EdgeInsets.only(left: 8.0, bottom: 8),
            child: TabButton(
              Tab: 5,
              state: widget.state,
              text: 'About',
            ),
          ),
      ],
    );
  }
}

class MainView extends StatefulWidget {
  final Function() state;
  const MainView({super.key, required this.state});

  @override
  State<MainView> createState() => _MainViewState();
}

class _MainViewState extends State<MainView> {
  @override
  Widget build(BuildContext context) {
    if (WidsManager.activeTab == 0) {
      return Padding(
        padding: const EdgeInsets.only(left: 12.0, right: 12),
        child: Appearances(
          state: widget.state,
        ),
      );
    } else if (WidsManager.activeTab == 1) {
      return Padding(
        padding: const EdgeInsets.only(left: 12.0, right: 12),
        child: SizedBox(
            height: MediaQuery.sizeOf(context).height - 60,
            child: IconPicker(
              state: widget.state,
            )),
      );
    } else if (WidsManager.activeTab == 2) {
      return Padding(
        padding: const EdgeInsets.all(12),
        child: Container(
            child: const Center(
          child: Text(
              "Configs had major changes, to be added in the next release."),
        )),
      );
    } else if (WidsManager.activeTab == 3) {
      return Padding(
        padding: const EdgeInsets.all(12),
        child: ExtensionUi(
          state: widget.state,
        ),
      );
    } else if (WidsManager.activeTab == 4) {
      return Padding(
        padding: const EdgeInsets.all(12),
        child: AppSettings(
          state: widget.state,
        ),
      );
    } else {
      return const AboutPage();
    }
  }
}
