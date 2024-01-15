import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gtkthememanager/front_end/main_page.dart';
import 'package:gtkthememanager/theme_manager/gtk_to_theme.dart';
import 'package:gtkthememanager/theme_manager/gtk_widgets.dart';
import 'package:url_launcher/url_launcher.dart';

class LoadingPage extends StatelessWidget {
  const LoadingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(12), bottomRight: Radius.circular(12)),
      child: Scaffold(

        body: Center(
      child: WidsManager().getText("e v o l v e", stylize: true),
        ),
      ),
    );
  }
}
class CheckValidity extends StatefulWidget {
  final Function() state;
  const CheckValidity({super.key, required this.state});

  @override
  State<CheckValidity> createState() => _CheckValidityState();
}

class _CheckValidityState extends State<CheckValidity> {
  double cde=0.0;
  @override
  void initState() {
    fetchCode();
    super.initState();
  }
  bool isLoading =true;
  fetchCode()async{
    await SystemInfo().getHome();
    File sysFl =File("${SystemInfo.home}/AT_Info/evolve.run");

    if(await sysFl.exists()) {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      WidgetGTK(state: widget.state)));
        }else{
          isLoading=false;
          setState(() {});
          await Future.delayed(const Duration(seconds: 10 ));
          proceed=true;
          setState(() {});
        }

  }
  bool proceed = false;
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
          borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(12), bottomRight: Radius.circular(12)),
      child: Scaffold(
        backgroundColor: ThemeDt.themeColors["bg"],
        body: Padding(
          padding: const EdgeInsets.only(left: 38.0,right: 38),
          child:Center(
            child:  (isLoading)?Text('evolve', style: GoogleFonts.gruppo(
                color: ThemeDt.themeColors["fg"], fontSize: 40
            ),):Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                WidsManager().getText("Welcome!",size: 40),
                WidsManager().getText("This is evolve - the brand new GTK Theme Manager for GNOME.",),
                const SizedBox(height: 20,),
                WidsManager().getText("The development process for apps like these take a lot of time. Especially when a single person is managing all the code, starting from designing the app to make it look almost native to GNOME, to coding all the back end part for the working of the app itself.",),

                const SizedBox(height: 20,),
      
                WidsManager().getText("Please take the time to visit my Patreon page to support projects like these and make the open source world a better place for everyone! By supporting me on Patreon you will get access to extra features inside the app itself - like enabling you to modify any GTK theme, according to your requirement.",size: 20),
                const SizedBox(height: 10,),
                WidsManager().getText("Sorry for the delay! Won't happen next time :)",),
                const SizedBox(height: 20,),
                Row(
                        children: <Widget>[
                          GetButtons(

                            ghost: true,
                            text:"Visit Patreon", onTap: () async {
                            await _launchUrl(Uri.parse("https://www.patreon.com/arcnations"));
                          },),
                          const SizedBox(width: 10,),
                          if(proceed)GetButtons(onTap: (){
                            File sysFl =File("${SystemInfo.home}/AT_Info/evolve.run");
                            sysFl.create(recursive: true);
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        WidgetGTK(state: widget.state)));
                          }, text: "Continue", light: true,)
                        ],
                      ),
                    ],
            ),
          ),
        ),
      ),
    );

  }
  Future<void> _launchUrl(url) async {
    if (!await launchUrl(url)) {
      throw Exception('Could not launch $url');
    }
  }
}
class FailPage extends StatelessWidget {
  const FailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(12), bottomRight: Radius.circular(12)),
      child: Scaffold(
        backgroundColor: ThemeDt.themeColors["bg"],
        body: Center(child: WidsManager().getText("Failed", size: 40)),
      ),
    );
  }
}


