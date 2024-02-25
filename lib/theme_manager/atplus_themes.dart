import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:gtkthememanager/theme_manager/gtk_to_theme.dart';

//manages premium theme-packs provided from AT+, patreon
class PThemes{
  static Map themeMap={};
 Future <void> populatePThemes()async{
   themeMap={};
    Directory atplus = Directory("${SystemInfo.home}/AT");
    List fileList = atplus.listSync();
    if(await atplus.exists()){
      for(Directory folder in fileList){
        int ID = int.parse(folder.path.substring(folder.path.indexOf("UID")+3,));
        if(ID>4){
          File themeData = File("${folder.path}/themedata.json");
          if(await themeData.exists()){
            themeMap[ID]=jsonDecode(await themeData.readAsString());
          }
        }else{
          if(ID==1){
            themeMap.addAll({
              1 :
              {
                "NAME" : "Evergreen",
                "THEME" : "Everforest-Dark-B",
                "ICON" : "Everforest-Dark",
                "COLOR1" : Colors.green[100]?.value,
                "COLOR2" : Colors.green[200]?.value,
                "COLOR3" : Colors.green[900]?.value,
                "VERS" : "N/A",
                "DESC" : "Pastel inspired green colours. Calm and minimalist dark theme with muted colours."
              }});
          }
          else if(ID==2) {
            themeMap.addAll({
              2: {
                "NAME": "Frosty Mountains",
                "THEME": "Pastel-Mountains",
                "ICON": "Nordzy-cyan-dark",
                "COLOR1": Colors.blue[100]?.value,
                "COLOR2": Colors.blue[200]?.value,
                "COLOR3": Colors.blue[900]?.value,
                "VERS": "N/A",
                "DESC" : "Pastel inspired blue colours. Calm and minimalist dark theme with muted colours."
              },
            });
          }
          else if(ID==3) {
            themeMap.addAll({
              3 : {
                "NAME" : "Purple Pastels",
                "THEME" : "Catppuccin-Mocha-B",
                "ICON" : "Zafiro-Nord-Black-Blue",
                "COLOR1" : Colors.purple[100]?.value,
                "COLOR2" : Colors.purple[200]?.value,
                "COLOR3" : Colors.purple[900]?.value,
                "VERS" : "N/A",
                "DESC" : "Pastel inspired purple colours. Calm and minimalist dark theme with muted colours."

              },
            });
          }
          else if(ID==4) {
            themeMap.addAll({
              4 :
              {
                "NAME" : "Mac X Nord",
                "THEME" : "Mac-Theme",
                "ICON" : "Mkos-Big-Sur",
                "COLOR1" : 0xffd8dee9,
                "COLOR2" : 0xff4c566a,
                "COLOR3" : 0xff2e3440,
                "VERS" : "N/A",
                "DESC" : "The fusion of the Mac look along with Nord Colours!"

              },
            });
          }
        }
      }
    }
  }
}