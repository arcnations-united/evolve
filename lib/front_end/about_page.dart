import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gtkthememanager/back_end/app_data.dart';
import 'package:gtkthememanager/theme_manager/gtk_to_theme.dart';
import 'package:gtkthememanager/theme_manager/gtk_widgets.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});
//returns an about page for the application
//added a nice little shimmer effect
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
    AnimatedSlide(
      offset: const Offset(0,0.1  ),
      duration: Duration.zero,
      child: Stack(
      children: [
      Center(
      child: ImageFiltered(
      imageFilter: ImageFilter.blur(
      sigmaY: 35,
          sigmaX: 35
      ),
      child: Image.asset("assets/iconfile.png", height: 200, width: 200, opacity: const AlwaysStoppedAnimation(.22),)).animate(
          effects: [
            FadeEffect(
              delay: 300.milliseconds,
                duration: 1.seconds
            )]),
      ),
      Center(child: Image.asset("assets/iconfile.png", height: 150, width: 150,)).animate(
          effects: [
            FadeEffect(
                duration: 300.milliseconds
            )]),
      ],
      ),
    ),
        AnimatedSlide(
          offset: const Offset(0,-0.6),
          duration: Duration.zero,
          child: WidsManager().getText(
            'E V O L V E',
          size: 25  ,
          ).animate(
            effects: [
              ShimmerEffect(
                color: ThemeDt.themeColors["bg"],
                duration: 2.seconds
              )
            ]
          )),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
          GestureDetector(
            onTap: ()async{
              String release;
              release = await AppData().getReleaseNotes();
              showDialog(context: context,barrierColor: Colors.transparent,
                builder: (BuildContext context) {
                return Center(child: WidsManager().getContainer(blur: true, height: 400, width: 500,
                    child: SingleChildScrollView(
                        child: WidsManager().getText(
                            release
                        ))));
                }, );
            },
              child: WidsManager().getTooltip(
                text: "Click to read Release Notes",
                child: WidsManager().getContainer(
                  child: WidsManager().getText("vers : ${AppData.vers.toString()}"),
                ),
              ),
            ).animate(
              effects: [
                ShimmerEffect(
                    color: ThemeDt.themeColors["bg"],
                    delay: 2.seconds,
                    duration: 1.seconds
                )
              ]
          ),
            const SizedBox(
              width: 8,
            ),
            WidsManager().getContainer(
              child: WidsManager().getText(AppData.release.toString()),
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
            ).animate(
                effects: [
                  ShimmerEffect(
                      color: ThemeDt.themeColors["bg"],
                      delay: 3.seconds,
                      duration: 1.seconds
                  )
                ]
            ),
          ],
        ),
        const SizedBox(
          height: 30,
        ),
        WidsManager()
            .getText("The powerful and modern alternative to Gnome Tweaks",fontWeight: FontWeight.w400),
        const SizedBox(
          height: 10,
        ),
        SizedBox(
          width: MediaQuery.sizeOf(context).width / 1.8,
          child: WidsManager().getText(
              center: true,
"""I have conducted comprehensive testing using Everforest-GTK on Fedora 39 with GNOME 45 environment. For any issues encountered, please forward them to nexindia.dev@gmail.com. Kindly include the name of the theme you experienced issues with, along with details of your operating system and GNOME version. If available, please provide log outputs. Running the application from the terminal may also yield additional insights.
""",
              size: 10),
        ),
        const SizedBox(
          height: 10,
        ),
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
        )
      ],
    );
  }

  Future<void> _launchUrl(url) async {
    if (!await launchUrl(url)) {
      throw Exception('Could not launch $url');
    }
  }
}
