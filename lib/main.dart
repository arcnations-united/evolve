import 'package:flutter/material.dart';
import 'package:gtkthememanager/front_end/inital_page.dart';
import 'package:gtkthememanager/theme_manager/gtk_to_theme.dart';
import 'package:window_manager/window_manager.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Must add this line.
  await windowManager.ensureInitialized();
  WindowOptions windowOptions = WindowOptions(
    size: Size(800, 600),
    center: true,
    backgroundColor: Colors.transparent,
    skipTaskbar: false,
    titleBarStyle: TitleBarStyle.normal,
  );
  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();

  });
  runApp(const MyApp());
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
  void initState() {
    SystemInfo().getHome();
    initiateTheme();
    super.initState();
  }
  initiateTheme()async{
    ThemeDt().initiateFallbackTheme();
    await ThemeDt().setTheme();
    setState(() {

    });
  }
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      color: Colors.transparent,
      home: CheckValidity(state: state,)
    );
  }
}

