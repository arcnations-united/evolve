import 'package:flutter/cupertino.dart';
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
        Align(child:WidsManager().getText("App Settings", fontWeight: ThemeDt.boldText),alignment: Alignment.topRight,),
        Align(child:WidsManager().getText("App specific settings. These do not affect the system.",color: "altfg",),alignment: Alignment.topLeft,),

        const SizedBox(height: 10,),
        WidsManager().getContainer(
          colour: "bg",
          borderOpacity: 0.2,
          border: true,
          pad: 0,
          width: MediaQuery.sizeOf(context).width/1.36,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    WidsManager().getText("Improve Contrast"),
                    GetToggleButton(value: AppData.DataFile["HCONTRAST"] ?? false,
                      onTap: (){
                        AppData.DataFile["HCONTRAST"] ??= false;
                        AppData.DataFile["HCONTRAST"] = !AppData.DataFile["HCONTRAST"];
                        AppData().writeDataFile();
                        AppSettingsToggle().toggleContrast();
                        widget.state();
                      },)
                  ],
                ),
              ),
              Container(
                height: 1,
                color: ThemeDt.themeColors["fg"]?.withOpacity(0.2),
              ),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    WidsManager().getText("Scale up"),
                    GetToggleButton(value: AppData.DataFile["MAXSIZE"] ?? false,
                      onTap: (){
                        AppData.DataFile["MAXSIZE"] ??= false;
                        AppData.DataFile["MAXSIZE"] = !AppData.DataFile["MAXSIZE"];
                        AppData().writeDataFile();
                        AppSettingsToggle().toggleMaxSize();
                        widget.state();
                      },),
                  ],
                ),
              ),

            ],
          ),
        ),
        const SizedBox(height: 10,),
        GetButtons(
          pillShaped: true,
          onTap: (){
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
    if(AppData.DataFile["HCONTRAST"]=="TRUE"){
      AppData.DataFile["HCONTRAST"]=true;
    }else if(AppData.DataFile["HCONTRAST"]=="FALSE"){
      AppData.DataFile["HCONTRAST"]=false;
    }
    if (AppData.DataFile["HCONTRAST"] ?? false){
      ThemeDt.boldText=FontWeight.w400;
    }else{
      ThemeDt.boldText=FontWeight.w300;
    }

  }
  toggleMaxSize(){
    if(AppData.DataFile["MAXSIZE"]=="TRUE"){
      AppData.DataFile["MAXSIZE"]=true;
    }else if(AppData.DataFile["MAXSIZE"]=="FALSE"){
      AppData.DataFile["MAXSIZE"]=false;
    }
    if (AppData.DataFile["MAXSIZE"] ?? false){
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

