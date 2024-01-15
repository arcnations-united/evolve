import 'dart:io';
import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/material.dart';
import 'package:gtkthememanager/back_end/gtk_theme_manager.dart';
import 'package:gtkthememanager/theme_manager/gtk_to_theme.dart';
import 'package:gtkthememanager/theme_manager/gtk_widgets.dart';

class ChangeColors extends StatefulWidget {
  final String filePath;
  final Function() state;
  final bool? update;
  const ChangeColors({super.key, required this.filePath, required this.state,  this.update});

  @override
  State<ChangeColors> createState() => _ChangeColorsState();
}

class _ChangeColorsState extends State<ChangeColors> {
  late int active;
  List <Color> col=[];
  List <Color> oldCol=[];
  @override
  void initState() {
    try {
      col = ThemeManager().convertFile(widget.filePath, demo: true);
      oldCol = List.of(col);
      active = 0;

    }catch (e){
     badGTK=true;
     WidsManager().showMessage(title: "Error", message: "The GTK Theme is invalid", icon: Icons.error_rounded, child: GetButtons(
         text: "Close",
         onTap: (){
           Navigator.pop(context);
           Navigator.pop(context);
         }), context: context);
    }

    super.initState();
  }
  bool badGTK = false;
  List <int>editedIndex=[];
  @override
  Widget build(BuildContext context) {
    try {
      return ClipRRect(
        borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(12), bottomRight: Radius.circular(12)),
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: ThemeDt.themeColors["bg"],
            foregroundColor: ThemeDt.themeColors["fg"],

          ),
          backgroundColor: ThemeDt.themeColors["bg"],
          body:(badGTK)?Container(

          ): Row(
            children: [
          Expanded(child: GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: (MediaQuery.sizeOf(context).width/150).floor()),
            itemCount: col.length,
            itemBuilder: (BuildContext context, int index) {
          return GetButtons(
            ghost: index==active,
              moreResponsive:!(col[index]==ThemeDt.themeColors["bg"]||col[index]==ThemeDt.themeColors["fg"]) ,
              light: (col[index]==ThemeDt.themeColors["bg"]||col[index]==ThemeDt.themeColors["fg"]),
              onTap: () {
                setState(() {
                  active=index;
                });
              },
              child: Container(
                decoration: BoxDecoration(
                  color: col[index],
                  borderRadius: BorderRadius.circular(5)
                ),
                ));
            }, )),
              Padding(
                padding: const EdgeInsets.only(right: 8.0, bottom: 8,left: 8),
                child: WidsManager().getContainer(
                  width: 500,
                  child:Column(
                    children: [
                      ColorPicker(
                          title: WidsManager().getText(
                            'Pick a colour',
                          ),
                          color: col[active],
                          pickersEnabled: const {
                            ColorPickerType.wheel: true,
                            ColorPickerType.primary: false,
                            ColorPickerType.accent: false,
                            ColorPickerType.both: false
                          },
                          wheelDiameter: 300,
                          enableTonalPalette: true,
                          enableShadesSelection: true,
                          onColorChangeEnd: (clr) async {
                            try {
                              col[active]=clr;
                              editedIndex.add(active);
                              editedIndex=editedIndex.toSet().toList();
                              await ThemeManager().updateColors(test : true, path: widget.filePath, col: col, editedIndex: editedIndex, oldCol: oldCol, update : widget.update);
                              oldCol=List.of(col);
                              widget.state();
                            } on Exception catch (e) {
                              WidsManager().showMessage(
                                  title: "Error",
                                  message: "Theme could not be updated.\n\n$e",
                                  context: context);
                            }
                          },
                          onColorChanged: (clr) {}),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: <Widget>[
                          IconButton(onPressed: (){
                            WidsManager().showMessage(title: "Info", message: "Possible foreground and background colours are specially highlighted. Named colours cannot be edited as of now.", context: context);
                          }, icon: Icon(Icons.info_rounded, color: ThemeDt.themeColors["fg"]?.withOpacity(0.5),)),
                          const SizedBox(width:20,),
                          GetButtons(onTap: ()async{
                            Navigator.pop(context);
                            var path = "${widget.filePath}-new";
                            File fl = File(path);
                            if(await fl.exists()){
                              await fl.delete();
                            }
                            ThemeDt.themeColors = ThemeDt().extractColors(filePath: widget.filePath);
                            ThemeDt().generateTheme();
                            widget.state();
                          }, text: "Reset",ghost: true,),

                          const SizedBox(width: 10,),
                          GetButtons(onTap: ()async{
                           var path = "${widget.filePath}-new";
                            File fl = File(path);
                            File flOrg = File(widget.filePath);
                            if(await fl.exists()){
                              Navigator.pop(context);
                               flOrg.delete();
                               fl.rename(widget.filePath);
                            }

                          }, text: "Apply (System)",ghost: true,),
                        ],
                      ),
                    ],
                  ),

                ),
              )
            ],
          ),
        ),
      );
    }  catch (e) {
      
      return Scaffold(

          backgroundColor: ThemeDt.themeColors["bg"],
          body: Center(
          child: WidsManager().getContainer(
            width: 400,
            height: 160,
              child:Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  WidsManager().getText(
                      "Some issues in the css file reading is causing this problem. Please switch to a different mode. Some themes import url instead of directly writing the css file. Such themes are not supported yet."
                  " (light/dark) and try again."),
                  GetButtons(onTap: (){
                    Navigator.pop(context);
                  }, text: "Close",)
                ],
              ))));
    }
  }
}
