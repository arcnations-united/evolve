import 'dart:io';
import 'package:flutter/material.dart';
import '../theme_manager/tab_manage.dart';
import '../back_end/gtk_theme_manager.dart';
import '../theme_manager/gtk_to_theme.dart';
import '../theme_manager/gtk_widgets.dart';

//Show the icon page interface
class IconPicker extends StatefulWidget {
  final Function() state;
  const IconPicker({super.key, required this.state});

  @override
  State<IconPicker> createState() => _IconPickerState();
}

class _IconPickerState extends State<IconPicker> {
  double opacity =0.0;
  @override
  void initState() {
    if(ThemeDt.IconName=="") getIcoTheme();
    if(ThemeDt.IconName!="")opacity=1.0;
    super.initState();
  }
  getIcoTheme()async{
    ThemeDt.IconName=await ThemeDt().getIconThemeName();
    ThemeDt.isIcoFolderMade=await ThemeManager().populateIconList();
    setState(() {
      opacity=1.0;
    });
  }
  @override
  Widget build(BuildContext context) {
    if(!ThemeDt.isIcoFolderMade){
      return AnimatedOpacity(
        duration: ThemeDt.d,
        opacity: opacity,
        child: Center(
          child: WidsManager().getContainer(
            height: 220,
            width: 200,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Icon(Icons.warning_rounded, color: ThemeDt.themeColors["fg"],size: 100,),
                WidsManager().getText("Icon folder not found! Create icon folder and unpack icons into\n${SystemInfo.home}/.icons", size: 10, center: true),
                const SizedBox(height: 10,),
                GetButtons(onTap: ()async{
                  Directory ico = Directory("${SystemInfo.home}/.icons");
                  if(!(await ico.exists())){
                    await ico.create();
                  }
                  ThemeDt.IconName="";
                  getIcoTheme();
                }, text: "Create icon folder", light: true,)
              ],
            ),
          ),
        ),
      );
    }
    if(ThemeManager.iconPathList.isEmpty){
      return AnimatedOpacity(
        duration: ThemeDt.d,
        opacity: opacity,
        child: Center(
          child: WidsManager().getContainer(
            height: 220,
            width: 200,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(Icons.warning_rounded, color: ThemeDt.themeColors["fg"],size: 100,),
                const SizedBox(height: 5,),
                WidsManager().getText("No icons found! Unpack icons into\n${SystemInfo.home}/.icons", size: 10, center: true),
                const SizedBox(height: 10,),
                GetButtons(onTap: ()async{
                  getIcoTheme();
                }, text: "Refresh", light: true,)
              ],
            ),
          ),
        ),
      );
    }
    return AnimatedOpacity(
      duration: ThemeDt.d,
      opacity: opacity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(
            height: 10,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              WidsManager().getText("Icons", fontWeight: ThemeDt.boldText),
              IconButton(icon: Icon(Icons.undo_rounded, color: ThemeDt.themeColors["fg"],), onPressed: () {
                ThemeDt().setIcon(packName: "Adwaita");
                widget.state();
              },)
            ],
          ),
          const SizedBox(
            height: 10,
          ),
          Expanded(
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: (MediaQuery.sizeOf(context).width/(TabManager.isLargeScreen?200:150)).floor(),
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10
              ),
              itemCount: ThemeManager.iconPathList.length,
              itemBuilder: (BuildContext context, int index) {
                return GetIcons(icoPackPath: ThemeManager.iconPathList[index], state: widget.state,);
              },),
          ),
        ],
      ),
    );
  }
}


