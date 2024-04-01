import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:gtkthememanager/theme_manager/gtk_to_theme.dart';

class AppData{
  //Class to provide some important app data - Like release notes, version and more
  //Also maintains a data file for the user in json
  static var vers = "1.3.1";
  static var release = "beta";
  static Map DataFile={};
  static bool dt_not_present=false;
  getReleaseNotes()async{
    //gets the release notes stored as an asset
    return await rootBundle.loadString('assets/release_notes.txt');
  }
  fetchDataFile() async {
    //fetches the user data file where app data is stored
    File data = File("${SystemInfo.home}/.NexData/Evolve/data.json");
    if(await data.exists()){
     try {
        DataFile = jsonDecode(await data.readAsString());
      }catch(e) {
        await data.delete();
        dt_not_present=true;
        data.create(recursive: true);
      }
    }
    else {
      dt_not_present=true;
      data.create(recursive: true);
    }
  }
  writeDataFile()async{
    //writes to the user data file
    File data = File("${SystemInfo.home}/.NexData/Evolve/data.json");
    if(await data.exists()) {
      data.writeAsString(
        jsonEncode(DataFile),
      );
    }
  }

  Future<void> deleteData() async {
    //deletes user data
    File data = File("${SystemInfo.home}/.NexData/Evolve/data.json");
    if(await data.exists()) {
    await data.delete();
    }
  }
}