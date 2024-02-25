import 'package:flutter/material.dart';
import 'package:gtkthememanager/front_end/app_specific_settings.dart';
import 'package:gtkthememanager/front_end/inital_page.dart';
import 'package:gtkthememanager/theme_manager/gtk_to_theme.dart';
import 'back_end/app_data.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
  @override
  void initState() {
    // TODO: implement initState
    SystemInfo().getHome();
    initiateTheme();
    super.initState();
  }
  initiateTheme()async{
    await ThemeDt().setTheme();
    await AppData().fetchDataFile();
    AppSettingsToggle().updateAllParams();
    setState(() {

    });
  }
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: CheckValidity(state: state,)
    );
  }
}

