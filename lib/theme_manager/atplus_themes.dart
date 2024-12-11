import 'dart:convert';
import 'dart:io';
import '../theme_manager/gtk_to_theme.dart';

//manages premium theme-packs provided from AT+, patreon
class PThemes {
  static Map themeMap = {};
  Future<void> populatePThemes() async {
    themeMap = {};
    Directory atplus = Directory("${SystemInfo.home}/AT");
    List fileList = atplus.listSync();
    if (await atplus.exists()) {
      for (FileSystemEntity folder in fileList) {
        if (folder is Directory) {
          int ID = int.parse(folder.path.substring(
            folder.path.indexOf("UID") + 3,
          ));
          if (ID > 5) {
            File themeData = File("${folder.path}/ev.json");
            if (await themeData.exists()) {
              themeMap[ID] = jsonDecode(await themeData.readAsString());
            } else if (await File("${folder.path}/ev.nex").exists()) {
              print(
                  "This theme is encrypted and hence can't be decrypted in the opensource edition");
            }
          } else {}
        }
      }
    }
  }
}
