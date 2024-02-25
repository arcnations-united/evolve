import 'package:flutter/material.dart';
import 'package:gtkthememanager/back_end/app_data.dart';
import 'package:gtkthememanager/theme_manager/gtk_to_theme.dart';
import 'package:gtkthememanager/theme_manager/gtk_widgets.dart';

class AppSettings extends StatefulWidget {
  final Function state;
  const AppSettings({super.key, required this.state, });

  @override
  State<AppSettings> createState() => _AppSettingsState();
}
//the app specific settings page. Needs an UI update to match the rest of the application
class _AppSettingsState extends State<AppSettings> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10,),
        WidsManager().getText("App Settings", fontWeight: ThemeDt.boldText),
        WidsManager().getText("App specific settings. These do not affect the system.",color: "altfg",),
        const SizedBox(height: 10,),
        Row(
          children: <Widget>[
            WidsManager().getText("Improve Contrast"),
          Checkbox(value: AppData.DataFile["HCONTRAST"]=="TRUE"?true:false,
              hoverColor: Colors.transparent,
              checkColor:ThemeDt.themeColors["bg"] ,
              focusColor: Colors.transparent,
              fillColor: MaterialStateColor.resolveWith((states) => ThemeDt.themeColors["sltbg"]!),
              onChanged: (res){
                if(res ?? false){
                  AppData.DataFile["HCONTRAST"]="TRUE";
                }
                else {
                  AppData.DataFile["HCONTRAST"]="FALSE";
                }
                AppData().writeDataFile();
                AppSettingsToggle().toggleContrast();
                widget.state();


          }),
          ],
        ),
        Row(
          children: <Widget>[
            WidsManager().getText("Scale up"),
          Checkbox(value: AppData.DataFile["MAXSIZE"]=="TRUE"?true:false,
              hoverColor: Colors.transparent,
              checkColor:ThemeDt.themeColors["bg"] ,
              focusColor: Colors.transparent,
              fillColor: MaterialStateColor.resolveWith((states) => ThemeDt.themeColors["sltbg"]!),
              onChanged: (res){
                if(res ?? false){
                  AppData.DataFile["MAXSIZE"]="TRUE";
                }
                else {
                  AppData.DataFile["MAXSIZE"]="FALSE";
                }
                AppData().writeDataFile();
                AppSettingsToggle().toggleMaxSize();
                widget.state();


          }),
          ],
        ),
        const SizedBox(height: 10,),
        GetButtons(onTap: (){
          AppData().deleteData();
          WidsManager().showMessage(title: "Info", message: "All related Data deleted. Restart app.", context: context);
        }, text: "Delete Account Data",light: true,)

      ],
    );
  }
}

class AppSettingsToggle{
  //toggles settings accordingly
  toggleContrast(){
    if (AppData.DataFile["HCONTRAST"]=="TRUE"){
      ThemeDt.boldText=FontWeight.w400;
    }else{
      ThemeDt.boldText=FontWeight.w300;
    }

  }toggleMaxSize(){
    if (AppData.DataFile["MAXSIZE"]=="TRUE"){
      ThemeDt.boldText=FontWeight.w400;
    }else{
      ThemeDt.boldText=FontWeight.w300;
    }

  }
  updateAllParams(){
    toggleContrast();
    toggleMaxSize();
  }
}

