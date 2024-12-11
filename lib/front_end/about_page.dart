import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../back_end/app_data.dart';
import '../theme_manager/gtk_to_theme.dart';
import '../theme_manager/gtk_widgets.dart';
import '../theme_manager/tab_manage.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});
  @override
  Widget build(BuildContext context) {
    bool superLarge = TabManager.isSuperLarge;
    bool smallScreen = !TabManager.isLargeScreen;
    return SizedBox(
        height: MediaQuery.sizeOf(context).height,
        child: AnimatedSlide(
          duration: ThemeDt.d,
          curve: ThemeDt.c,
          offset: Offset(0, superLarge ? -0.1 : 0),
          child: Stack(
            // mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedPositioned(
                duration: ThemeDt.d,
                curve: ThemeDt.c,
                top: MediaQuery.sizeOf(context).height / 2 -
                    (superLarge ? 150 : 240),
                left: (MediaQuery.sizeOf(context).width -
                        (smallScreen
                            ? 150
                            : superLarge
                                ? 600
                                : 350)) /
                    2,
                child: Center(
                    child: Image.asset(
                  "assets/iconfile.png",
                  height: 150,
                  width: 150,
                )),
              ),
              AnimatedPositioned(
                duration: ThemeDt.d,
                curve: ThemeDt.c,
                top: MediaQuery.sizeOf(context).height / 2 -
                    (superLarge ? 140 : 80),
                left: (MediaQuery.sizeOf(context).width -
                        (smallScreen
                            ? 136
                            : superLarge
                                ? 270
                                : 333)) /
                    2,
                child: WidsManager().getText(
                  'Evolve Core',
                  size: 25,
                ),
              ),
              AnimatedPositioned(
                duration: ThemeDt.d,
                curve: ThemeDt.c,
                top: MediaQuery.sizeOf(context).height / 2 -
                    (superLarge ? 97 : 30),
                left: (MediaQuery.sizeOf(context).width -
                        (smallScreen
                            ? 230
                            : superLarge
                                ? 270
                                : 430)) /
                    2,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () async {
                        String release;
                        release = await AppData().getReleaseNotes();
                        showDialog(
                          context: context,
                          barrierColor: Colors.transparent,
                          builder: (BuildContext context) {
                            return Center(
                                child: WidsManager().getContainer(
                                    blur: true,
                                    height: 400,
                                    width: 500,
                                    child: SingleChildScrollView(
                                        child:
                                            WidsManager().getText(release))));
                          },
                        );
                      },
                      child: WidsManager().getTooltip(
                        text: "Click to read Release Notes",
                        child: WidsManager().getContainer(
                          child: WidsManager().getText(
                              "vers : ${AppData.vers.toString()}${superLarge ? "-${AppData.release}" : ""}"),
                        ),
                      ),
                    ),
                    if (!superLarge)
                      const SizedBox(
                        width: 8,
                      ),
                    if (!superLarge)
                      WidsManager().getContainer(
                        child:
                            WidsManager().getText(AppData.release.toString()),
                      ),
                    const SizedBox(
                      width: 8,
                    ),
                    GetButtons(
                      ghost: true,
                      text: "Patreon",
                      onTap: () async {
                        await _launchUrl(
                            Uri.parse("https://www.patreon.com/arcnations"));
                      },
                    ),
                  ],
                ),
              ),
              AnimatedPositioned(
                  duration: ThemeDt.d,
                  curve: ThemeDt.c,
                  top: MediaQuery.sizeOf(context).height / 2 +
                      (superLarge ? -50 : 35),
                  left: (MediaQuery.sizeOf(context).width -
                          (!TabManager.isLargeScreen
                              ? 210
                              : smallScreen
                                  ? 370
                                  : superLarge
                                      ? 260
                                      : 580)) /
                      2,
                  child: SizedBox(
                    width: superLarge || !TabManager.isLargeScreen
                        ? 200
                        : MediaQuery.sizeOf(context).width,
                    child: WidsManager().getText(
                        center: !TabManager.isLargeScreen,
                        "The powerful and modern alternative to Gnome Tweaks",
                        fontWeight: FontWeight.w400),
                  )),
              AnimatedPositioned(
                duration: ThemeDt.d,
                curve: ThemeDt.c,
                top: MediaQuery.sizeOf(context).height / 2 +
                    (superLarge ? 20 : 59),
                left: (MediaQuery.sizeOf(context).width -
                        (smallScreen ? 420 : 600)) /
                    2,
                child: AnimatedOpacity(
                  opacity: (!TabManager.isLargeScreen) ? 0 : 1,
                  duration: ThemeDt.d,
                  child: SizedBox(
                    width: 400,
                    child: WidsManager().getText(
                        center: true,
                        """Report problems, 'Contact me' on https://bit.ly/evolvegtk Make sure to send the log output after starting the app from the terminal. If you have used the official install script then just run ~/nex/apps/evolvecore/evolvecore in terminal. Mention the name of the page where you have faced the problem along with the link to the GTK Theme which caused the issue if required.""",
                        size: 10),
                  ),
                ),
              ),
              AnimatedPositioned(
                duration: ThemeDt.d,
                curve: ThemeDt.c,
                top: MediaQuery.sizeOf(context).height / 2 + 200,
                left: (MediaQuery.sizeOf(context).width -
                        (smallScreen ? 136 : 330)) /
                    2,
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        WidsManager().getText("Designed by  "),
                        Text(
                          'N E X',
                          style: GoogleFonts.gruppo(
                              color: ThemeDt.themeColors["fg"], fontSize: 15),
                        ),
                      ],
                    ),
                    WidsManager().getText(
                        "Shell Version : ${SystemInfo.exactShellVers}",
                        size: 9),
                  ],
                ),
              )
            ],
          ),
        ));
  }

  Future<void> _launchUrl(url) async {
    if (!await launchUrl(url)) {
      throw Exception('Could not launch $url');
    }
  }
}
