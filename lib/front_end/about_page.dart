import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gtkthememanager/back_end/app_data.dart';
import 'package:gtkthememanager/theme_manager/gtk_to_theme.dart';
import 'package:gtkthememanager/theme_manager/gtk_widgets.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});
//returns an about page for the application
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'evolve',
          style: GoogleFonts.gruppo(
              color: ThemeDt.themeColors["fg"], fontSize: 60),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            WidsManager().getContainer(
              child: WidsManager().getText("vers : ${AppData.vers.toString()}"),
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
            ),
          ],
        ),
        const SizedBox(
          height: 30,
        ),
        WidsManager()
            .getText("The powerful and modern alternative to Gnome Tweaks"),
        const SizedBox(
          height: 10,
        ),
        SizedBox(
          width: MediaQuery.sizeOf(context).width / 1.8,
          child: WidsManager().getText(
              center: true,
              """Supporting the development of high-quality open-source applications is made possible through contributions on Patreon. By making a donation, you gain access to an array of additional sophisticated features within this application. Your generosity not only helps sustain the project but also enhances your user experience with exclusive functionalities. Join our community of patrons and elevate your interaction with this exceptional application through your support.""",
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
