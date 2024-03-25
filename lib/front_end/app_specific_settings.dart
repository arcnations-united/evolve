import 'dart:io';

import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gtkthememanager/back_end/app_data.dart';
import 'package:gtkthememanager/theme_manager/gtk_to_theme.dart';
import 'package:gtkthememanager/theme_manager/gtk_widgets.dart';
import 'package:gtkthememanager/theme_manager/tab_manage.dart';
import 'package:process_run/process_run.dart';

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
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        WidsManager().gtkColumn(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              WidsManager().getText("App Settings", fontWeight: ThemeDt.boldText),
              WidsManager().getText("App specific settings. These do not affect the system.",color: "altfg",),
              const SizedBox(height: 13,)
            ],
          ),
          width: TabManager.isSuperLarge?900.0:MediaQuery.sizeOf(context).width-((TabManager.isLargeScreen)?170:0),
            children: [
              Row(
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
              Row(
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  WidsManager().getText("Respect GNOME UI"),
                  GetToggleButton(value: AppData.DataFile["GNOMEUI"] ?? false,
                    onTap: () async {
                      AppData.DataFile["GNOMEUI"] ??= false;
                      AppData.DataFile["GNOMEUI"] = !AppData.DataFile["GNOMEUI"];
                     widget.state();
                      AppData().writeDataFile();
                      await AppSettingsToggle().updateGnomeUI();
                      widget.state();
                    },),
                ],
              ),  Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  WidsManager().getText("Toggle animations"),
                  GetToggleButton(value: (AppData.DataFile["ANIMATE"] ?? true),
                    onTap: () async {
                      AppData.DataFile["ANIMATE"] ??= true;
                      AppData.DataFile["ANIMATE"] = !AppData.DataFile["ANIMATE"];
                      AppData().writeDataFile();
                      AppSettingsToggle().updateAnimation();
                      widget.state();
                    },),
                ],
              ),

            ],
          ),
        const SizedBox(height: 25,),
        WidsManager().gtkColumn(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              WidsManager().getText("Theme Settings", fontWeight: ThemeDt.boldText),
              WidsManager().getText("System level changes. May require admin privileges",color: "altfg",),
              const SizedBox(height: 13,)
            ],
          ),
          width: TabManager.isSuperLarge?900.0:MediaQuery.sizeOf(context).width-((TabManager.isLargeScreen)?170:0),
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  WidsManager().getText("Apply Flatpak Theme"),
                  GetToggleButton(value: AppData.DataFile["FLATPAK"] ?? false,
                    onTap: (){
                      AppData.DataFile["FLATPAK"] ??= false;
                      AppData.DataFile["FLATPAK"] = !AppData.DataFile["FLATPAK"];
                      AppData().writeDataFile();
                      widget.state();
                    },)
                ],
              ),
              GestureDetector(
                onTap: (){
                  AppSettingsToggle().makeShellEditable(context);
                },
                child: Container(
                  color: Colors.white.withOpacity(0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      WidsManager().getText("Make Default Shell Editable"),
                      Icon(Icons.chevron_right, color: ThemeDt.themeColors["fg"],)
                    ],
                  ),
                ),
              ),

            ],
          ),
        const SizedBox(height: 24,),
        AnimatedAlign(
          alignment: TabManager.isSuperLarge?Alignment.bottomCenter:Alignment.bottomRight,
          duration: ThemeDt.d,
          curve: ThemeDt.c,
          child: GetButtons(
            pillShaped: true,
            onTap: () async {
            AppData().deleteData();
            WidsManager().showMessage(title: "Info", message: "All related settings reset. Evolve will close now.", context: context, child: Container());
            await Future.delayed(3.seconds);
            appWindow.close();
          }, text: "Reset Settings",light: true,),
        ),

      ],
    );
  }
}

class AppSettingsToggle{
  //toggles settings accordingly
  toggleContrast(){
    if(AppData.DataFile["HCONTRAST"]==null){
      AppData.DataFile["HCONTRAST"]=false;
    }
    if(AppData.DataFile["HCONTRAST"]=="TRUE"){
      AppData.DataFile["HCONTRAST"]=true;
    }else if(AppData.DataFile["HCONTRAST"]=="FALSE"){
      AppData.DataFile["HCONTRAST"]=false;
    }
    if (AppData.DataFile["HCONTRAST"] == true){
      ThemeDt.boldText=FontWeight.w500;
    }else{
      ThemeDt.boldText=FontWeight.w300;
    }

  }
  toggleMaxSize(){
    if(AppData.DataFile["MAXSIZE"]==null){
      AppData.DataFile["MAXSIZE"]=false;
    }
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
  updateGnomeUI()async{
    if(AppData.DataFile["GNOMEUI"]==null){
      AppData.DataFile["GNOMEUI"]=false;
    }
    if(AppData.DataFile["GNOMEUI"]==true){
     await WidsManager().loadFontAndApply();
    }
  }
  updateAllParams() async {
    toggleContrast();
    toggleMaxSize();
    await updateGnomeUI();
    updateAnimation();
  }

  void updateAnimation() {
    if(AppData.DataFile["ANIMATE"]==false){
      ThemeDt.d=Duration.zero;
    }else{
      ThemeDt.d=const Duration(milliseconds: 300);

    }
  }

  void makeShellEditable(BuildContext context) {
    WidsManager().showMessage(

        title: "Info", message: "Copy the original GNOME Shell theme to make it editable.", context: context,
    child: Row(mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          GetButtons(
            onTap: (){
              Navigator.pop(context);
            },
          text: "Exit",
          ),
          const SizedBox(width: 10,),
          GetButtons(
            onTap: (){
              Navigator.pop(context);
              WidsManager().showMessage(title: "Set-up Theme", message: "Enter a name for the copy. (eg : Adwaita-Copy)", context: context,
                  child: GetTextBox(
                    onDone: (tx)async{
                      Directory dir = Directory("${SystemInfo.home}/.themes/$tx/gnome-shell");
                      if(await dir.exists()){
                        WidsManager().showMessage(title: "Error", message: "A theme with the same name already exists. Try a different name.", context: context,
                        );
                      }
                      else{
                       String out = (await Shell().run("""
                        which gresource
                        """)).outText;
                       if(out.contains("no gresource")){
                         WidsManager().showMessage(title: "Error", message: "PLease install gresource to continue", context: context,
                         );
                       }
                       else{
                         await dir.create(recursive: true);
                         await Shell().run(
                           """cp /usr/share/gnome-shell/gnome-shell-theme.gresource ${dir.path}
                           """
                         );
                         List m = await ThemeDt().listResFile("${dir.path}/gnome-shell-theme.gresource");
                         for(String name in m){
                          if(name.contains("gnome-shell-dark")){
                            await Shell().run("""bash -c 'gresource extract ${dir.path}/gnome-shell-theme.gresource $name > ${dir.path}/gnome-shell.css'""");
                            break;
                          }
                         }
                         Navigator.pop(context);
                       }
                      }
                    },
                  ),);
            },
          text: "Continue",
          ),
        ],
      ),
    );
  }
}

