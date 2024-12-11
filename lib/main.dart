import 'package:flutter/material.dart';
import '../front_end/inital_page.dart';
import '../theme_manager/gtk_to_theme.dart';

import 'back_end/app_data.dart';

Future<void> main() async {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  state() {
    setState(() {});
  }

  @override
  void initState() {
    // TODO: implement initState
    initiateTheme();
    super.initState();
  }

  initiateTheme() async {
    await SystemInfo().getHome();
    await SystemInfo().getShellVersion();
    await ThemeDt().setTheme();
    await AppData().fetchDataFile();
    AppData.DataFile["GNOMEUI"] = false;
    setState(() {
      load = false;
    });
  }

  bool load = true;
  @override
  Widget build(BuildContext context) {
    if (load) return Container();
    return MaterialApp(
        theme: ThemeDt.themeData,
        darkTheme: ThemeDt.themeData,
        home: CheckValidity(
          state: state,
        ));
  }
}
