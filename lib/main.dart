import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gtkthememanager/front_end/inital_page.dart';
import 'package:gtkthememanager/theme_manager/gtk_to_theme.dart';
import 'back_end/app_data.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
  doWhenWindowReady(() {
    appWindow.minSize = const Size(400, 700);
    appWindow.size = const Size(900, 730);
    appWindow.alignment = Alignment.center;
    appWindow.show();
  });
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  state(){
    setState(() {
    });
  }
  @override
  void initState() {
    // TODO: implement initState
    SystemInfo().getHome();
    initiateTheme();
    super.initState();
  }
  initiateTheme()async{

  }
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(15),
      child: MaterialApp(
          home: CheckValidity(state: state,)
      ).animate(
        effects: [
          ScaleEffect(
              begin: const Offset(0.8,0.8),
              end: const Offset(1,1),
              duration: (ThemeDt.d.inMilliseconds+400).milliseconds,
              curve: Curves.easeOutExpo,
            delay: 500.milliseconds
          ),
          FadeEffect(
              delay: 560.milliseconds,
              duration:  ((ThemeDt.d.inMilliseconds)+400).milliseconds,

    ),
        ]
      ),
    );
  }
}

