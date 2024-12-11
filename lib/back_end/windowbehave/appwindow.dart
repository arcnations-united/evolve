import 'package:flutter/services.dart';
import '../../back_end/app_data.dart';

class appWindow{
  static close()async{
    await AppData().writeDataFile();
    SystemChannels.platform.invokeMethod('SystemNavigator.pop');
  }
  static minimize(){}
  static maximizeOrRestore(){}
  static startDragging(){}
}