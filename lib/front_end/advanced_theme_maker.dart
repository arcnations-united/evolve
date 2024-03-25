import 'package:flutter/material.dart';
import 'package:gtkthememanager/back_end/css_handler.dart';
import 'package:gtkthememanager/back_end/gtk_theme_manager.dart';
import 'package:gtkthememanager/theme_manager/gtk_to_theme.dart';
import 'package:gtkthememanager/theme_manager/gtk_widgets.dart';

class AdvancedThemeMaker extends StatefulWidget {
  final String originalThemePath;
  final String newThemePath;
  const AdvancedThemeMaker({super.key, required this.originalThemePath, required this.newThemePath});

  @override
  State<AdvancedThemeMaker> createState() => _AdvancedThemeMakerState();
}

class _AdvancedThemeMakerState extends State<AdvancedThemeMaker> {
  late CSS newGtk3CSS, newGtk4CSS, newShellCSS;
  late CSS oldGtk3CSS, oldGtk4CSS, oldShellCSS;
  String themeName="";
  bool isLoading=true;
  @override
  void initState() {
    // TODO: implement initState
   fetchGTKs();
    super.initState();
  }

  fetchGTKs()async{
    oldGtk3CSS=CSS("${widget.originalThemePath}/gtk-3.0/gtk.css");
    newGtk3CSS=CSS("${widget.newThemePath}/gtk-3.0/gtk.css");
    oldGtk4CSS=CSS("${widget.originalThemePath}/gtk-4.0/gtk.css");
    newGtk4CSS=CSS("${widget.newThemePath}/gtk-4.0/gtk.css");
    oldShellCSS=CSS("${widget.originalThemePath}/gnome-shell/gnome-shell.css");
    newShellCSS=CSS("${widget.newThemePath}/gnome-shell/gnome-shell.css");
    await oldGtk3CSS.fetchCSS();
    await oldGtk4CSS.fetchCSS();
    await oldShellCSS.fetchCSS();
    await newGtk3CSS.fetchCSS();
    await newGtk4CSS.fetchCSS();
    await newShellCSS.fetchCSS();
    setState(() {
      isLoading=false;
    });
  }
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            GestureDetector(
              onTap: (){
                newGtk3CSS.saveCSS();
                newShellCSS.saveCSS();
                newGtk4CSS.saveCSS();
                setState(() {

                });
              },
              child: const Icon(
                Icons.save_rounded
              ),
            ),
          ],
        ),
        backgroundColor: ThemeDt.themeColors["bg"],
        foregroundColor: ThemeDt.themeColors["fg"],
      ),
      backgroundColor: ThemeDt.themeColors["bg"],
      body: isLoading? Center(child: CircularProgressIndicator(color: ThemeDt.themeColors["fg"],strokeWidth: 10,strokeCap: StrokeCap.round,)):
      Padding(
        padding: const EdgeInsets.all(18.0),
        child: ListView(
          children: [
            WidsManager().getText("GNOME Shell"),
            const SizedBox(height: 10,),
            WidsManager().getContainer(
              //height: 500,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  WidsManager().getText("Modded Theme (${newShellCSS.themeName})",fontWeight: FontWeight.w500, size: 18),
                  WidsManager().getText("No contents displayed if modded theme does not have matching definitions with another theme.",size: 10),
                  WidsManager().getContainer(
                    child: Wrap(
                      //direction: Axis.vertical,
                      spacing: 8.0, // gap between adjacent chips
                      runSpacing: 4.0, // gap between lines
                      children: <Widget>[
                        for(int i=0;i<newShellCSS.namedParts.length;i++)
                          if(oldShellCSS.namedParts.contains(newShellCSS.namedParts[i]))
                            GetPopMenuButton(
                              tooltip: "Click to replace",
                              widgetOnTap: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  GestureDetector(
                                      onTap:(){
                                        WidsManager().showMessage(title: "Select Variable",icoSize: 20,
                                            height: MediaQuery.sizeOf(context).height/1.1,isDismisible: true,
                                            message: "Select one of the following vars to continue.", context: context,
                                            child: Expanded(
                                              child: Padding(
                                                padding: const EdgeInsets.all(8.0),
                                                child: ListView(
                                                  children: [
                                                    Wrap(
                                                      spacing: 8.0,
                                                      runSpacing: 4.0,
                                                      children: [

                                                        for(int i1=0;i1<oldShellCSS.namedParts.length;i1++)
                                                          GestureDetector(
                                                            onTap : (){
                                                              Navigator.pop(context);
                                                              Navigator.pop(context);
                                                              if(newShellCSS.editedIndices.contains(i)==false) {
                                                                newShellCSS.replaceNamedPortion(
                                                                    index: i,
                                                                    otherCSS: oldShellCSS,
                                                                  otherIndex: i1
                                                                );
                                                              }
                                                              setState(() {

                                                              });
                                            },
                                                            child: WidsManager().getContainer(
                                                              //  width: 100,
                                                                border: oldShellCSS.editedIndices.contains(i1),
                                                                colour: "bg",child: WidsManager().getText(cleanString(oldShellCSS.namedParts[i1]))
                                                            ),
                                                          )
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            )
                                        );
                                      },
                                      child: WidsManager().getText("Choose transfer variable")),
                                  GestureDetector(
                                      onTap: () {
                                        Navigator.pop(context);
                                        if(newShellCSS.editedIndices.contains(i)==false) {
                                          newShellCSS.replaceNamedPortion(
                                              index: i,
                                              otherCSS: oldShellCSS);
                                        }
                                        setState(() {

                                        });
                                      },

                                      child: WidsManager().getText(newShellCSS.editedIndices.contains(i)?"Replacement done.":"Replace variable...")),
                                ],
                              ),
                              child: WidsManager().getContainer(
                                //  width: 100,
                                border: newShellCSS.editedIndices.contains(i),
                                  colour: "bg",child: WidsManager().getText(cleanString(newShellCSS.namedParts[i]))
                              ),
                            )
                      ],
                    ),
                  ),
                  const SizedBox(height: 10,),
                  GetPopMenuButton(widgetOnTap:
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        for(int i=0;i<ThemeManager.GTKThemeList.length;i++)
                          if(ThemeManager.themeSupport.values.elementAt(i)["shell"]==true)
                        GestureDetector(
                          onTap: () async {
                            Navigator.pop(context);
                            themeName=ThemeManager.GTKThemeList[i];
                            oldShellCSS=CSS("${ThemeManager.GTKThemeList[i]}/gnome-shell/gnome-shell.css");
                            await oldShellCSS.fetchCSS();
                            setState(() {

                            });
                          },
                          child: Container(
                            color: Colors.black.withOpacity(0),
                            padding: const EdgeInsets.all(3.0),
                            child: WidsManager().getText(ThemeManager.GTKThemeList[i].split("/").last),
                          ),
                        )
                      ],
                    )
                    , child:
                  WidsManager().getText(oldShellCSS.themeName,fontWeight: FontWeight.w500, size: 18
                  ),
                  ),
                  WidsManager().getText("No contents displayed if original theme does not have any extra definitions.",size: 10),
                  WidsManager().getContainer(
                    child: Wrap(
                       //direction: Axis.vertical,
                      spacing: 8.0, // gap between adjacent chips
                      runSpacing: 4.0, // gap between lines
                            children: <Widget>[
                              for(int i=0;i<oldShellCSS.namedParts.length;i++)
                                if(!newShellCSS.namedParts.contains(oldShellCSS.namedParts[i]))
                                WidsManager().getContainer(
                                //  width: 100,
                                  colour: "bg",child: WidsManager().getText(cleanString(oldShellCSS.namedParts[i])))
                            ],
                          ),
                  ),
                ],
              ),
                  ),


            const SizedBox(height: 20,),
            WidsManager().getText("GTK 3.0"),
            const SizedBox(height: 10,),
            WidsManager().getContainer(
              //height: 500,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  WidsManager().getText("Modded Theme (${newGtk3CSS.themeName})",fontWeight: FontWeight.w500, size: 18),
                  WidsManager().getText("No contents displayed if modded theme does not have matching definitions with another theme.",size: 10),
                  WidsManager().getContainer(
                    child: Wrap(
                      //direction: Axis.vertical,
                      spacing: 8.0, // gap between adjacent chips
                      runSpacing: 4.0, // gap between lines
                      children: <Widget>[
                        for(int i=0;i<newGtk3CSS.namedParts.length;i++)
                          if(oldGtk3CSS.namedParts.contains(newGtk3CSS.namedParts[i]))
                            GetPopMenuButton(
                              tooltip: "Click to replace",
                              widgetOnTap: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  GestureDetector(
                                      onTap:(){
                                        WidsManager().showMessage(title: "Select Variable",icoSize: 20,
                                            height: MediaQuery.sizeOf(context).height/1.1,isDismisible: true,
                                            message: "Select one of the following vars to continue.", context: context,
                                            child: Expanded(
                                              child: Padding(
                                                padding: const EdgeInsets.all(8.0),
                                                child: ListView(
                                                  children: [
                                                    Wrap(
                                                      spacing: 8.0,
                                                      runSpacing: 4.0,
                                                      children: [

                                                        for(int i1=0;i1<oldGtk3CSS.namedParts.length;i1++)
                                                          GestureDetector(
                                                            onTap:(){
                                                              Navigator.pop(context);
                                                              Navigator.pop(context);
                                                              if(newGtk3CSS.editedIndices.contains(i)==false) {
                                                                newGtk3CSS.replaceNamedPortion(
                                                                    index: i,
                                                                    otherCSS: oldGtk3CSS,
                                                                    otherIndex: i1
                                                                );
                                                              }
                                                              setState(() {

                                                              });
                                                            },
                                                            child: WidsManager().getContainer(
                                                              //  width: 100,
                                                                border: oldGtk3CSS.editedIndices.contains(i1),
                                                                colour: "bg",child: WidsManager().getText(cleanString(oldGtk3CSS.namedParts[i1]))
                                                            ),
                                                          )
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            )
                                        );
                                      },
                                      child: WidsManager().getText("Choose transfer variable")),
                                  GestureDetector(
                                      onTap: () {
                                        Navigator.pop(context);
                                        if(newGtk4CSS.editedIndices.contains(i)==false) {
                                          newGtk4CSS.replaceNamedPortion(
                                              index: i,
                                              otherCSS: oldGtk4CSS);
                                        }
                                        setState(() {

                                        });
                                      },

                                      child: WidsManager().getText(newGtk3CSS.editedIndices.contains(i)?"Replacement done.":"Replace variable...")),
                                ],
                              ),
                              child: WidsManager().getContainer(
                                //  width: 100,
                                border: newGtk3CSS.editedIndices.contains(i),
                                  colour: "bg",child: WidsManager().getText(cleanString(newGtk3CSS.namedParts[i]))
                              ),
                            )
                      ],
                    ),
                  ),
                  
                  
                  const SizedBox(height: 10,),
                  GetPopMenuButton(widgetOnTap:
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        for(int i=0;i<ThemeManager.GTKThemeList.length;i++)
                          if(ThemeManager.themeSupport.values.elementAt(i)["gtk3"]==true)
                        GestureDetector(
                          onTap: () async {
                            Navigator.pop(context);
                            themeName=ThemeManager.GTKThemeList[i];
                            oldGtk3CSS=CSS("${ThemeManager.GTKThemeList[i]}/gtk-3.0/gtk.css");
                            await oldGtk3CSS.fetchCSS();
                            setState(() {

                            });
                          },
                          child: Container(
                            color: Colors.black.withOpacity(0),
                            padding: const EdgeInsets.all(3.0),
                            child: WidsManager().getText(ThemeManager.GTKThemeList[i].split("/").last),
                          ),
                        )
                      ],
                    )
                    , child:
                  WidsManager().getText(oldGtk3CSS.themeName,fontWeight: FontWeight.w500, size: 18
                  ),
                  ),
                  WidsManager().getText("No contents displayed if original theme does not have any extra definitions.",size: 10),
                  WidsManager().getContainer(
                    child: Wrap(
                       //direction: Axis.vertical,
                      spacing: 8.0, // gap between adjacent chips
                      runSpacing: 4.0, // gap between lines
                            children: <Widget>[
                              for(int i=0;i<oldGtk3CSS.namedParts.length;i++)
                                if(!newGtk3CSS.namedParts.contains(oldGtk3CSS.namedParts[i]))
                                WidsManager().getContainer(
                                //  width: 100,
                                  colour: "bg",child: WidsManager().getText(cleanString(oldGtk3CSS.namedParts[i]))
                                )
                            ],
                          ),
                  ),
                ],
              ),
                  ), 
            
            
            const SizedBox(height: 20,),
            WidsManager().getText("GTK 4.0"),
            const SizedBox(height: 10,),
            WidsManager().getContainer(
              //height: 500,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  WidsManager().getText("Modded Theme (${newGtk4CSS.themeName})",fontWeight: FontWeight.w500, size: 18),
                  WidsManager().getText("No contents displayed if modded theme does not have matching definitions with another theme.",size: 10),
                  WidsManager().getContainer(
                    child: Wrap(
                      //direction: Axis.vertical,
                      spacing: 8.0,
                      runSpacing: 4.0,
                      children: <Widget>[
                        for(int i=0;i<newGtk4CSS.namedParts.length;i++)
                          if(oldGtk4CSS.namedParts.contains(newGtk4CSS.namedParts[i]))
                            GetPopMenuButton(
                              tooltip: "Click to replace",
                              widgetOnTap: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  GestureDetector(
                                      onTap:(){
                                        WidsManager().showMessage(title: "Select Variable",icoSize: 20,
                                            height: MediaQuery.sizeOf(context).height/1.1,isDismisible: true,
                                            message: "Select one of the following vars to continue.", context: context,
                                          child: Expanded(
                                            child: Padding(
                                              padding: const EdgeInsets.all(8.0),
                                              child: ListView(
                                                children: [
                                                  Wrap(
                                                    spacing: 8.0,
                                                    runSpacing: 4.0,
                                                    children: [
                                            
                                                      for(int i1=0;i1<oldGtk4CSS.namedParts.length;i1++)
                                                          GestureDetector(
                                                            onTap:(){
                                                              Navigator.pop(context);
                                                              Navigator.pop(context);
                                                              if(newGtk4CSS.editedIndices.contains(i)==false) {
                                                                newGtk4CSS.replaceNamedPortion(
                                                                    index: i,
                                                                    otherCSS: oldGtk4CSS,
                                                                    otherIndex: i1
                                                                );
                                                              }
                                                              setState(() {

                                                              });
                                                            },
                                                            child: WidsManager().getContainer(
                                                              //  width: 100,
                                                                border: oldGtk4CSS.editedIndices.contains(i1),
                                                                colour: "bg",child: WidsManager().getText(cleanString(oldGtk4CSS.namedParts[i1]))
                                                            ),
                                                          )
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          )
                                        );
                                      },
                                      child: WidsManager().getText("Choose transfer variable")),
                                  GestureDetector(
                                      onTap: () {
                                        Navigator.pop(context);
                                        if(newGtk4CSS.editedIndices.contains(i)==false) {
                                          newGtk4CSS.replaceNamedPortion(
                                              index: i,
                                              otherCSS: oldGtk4CSS);
                                        }
                                        setState(() {

                                        });
                                      },

                                      child: WidsManager().getText(newGtk4CSS.editedIndices.contains(i)?"Replacement done.":"Replace variable...")),
                                ],
                              ),
                              child: WidsManager().getContainer(
                                //  width: 100,
                                border: newGtk4CSS.editedIndices.contains(i),
                                  colour: "bg",child: WidsManager().getText(cleanString(newGtk4CSS.namedParts[i]))
                              ),
                            )
                      ],
                    ),
                  ),
                  
                  
                  const SizedBox(height: 10,),
                  GetPopMenuButton(widgetOnTap:
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        for(int i=0;i<ThemeManager.GTKThemeList.length;i++)
                          if(ThemeManager.themeSupport.values.elementAt(i)["gtk4"]==true)
                        GestureDetector(
                          onTap: () async {
                            Navigator.pop(context);
                            themeName=ThemeManager.GTKThemeList[i];
                            oldGtk4CSS=CSS("${ThemeManager.GTKThemeList[i]}/gtk-4.0/gtk.css");
                            await oldGtk4CSS.fetchCSS();
                            setState(() {

                            });
                          },
                          child: Container(
                            color: Colors.black.withOpacity(0),
                            padding: const EdgeInsets.all(3.0),
                            child: WidsManager().getText(ThemeManager.GTKThemeList[i].split("/").last),
                          ),
                        )
                      ],
                    )
                    , child:
                  WidsManager().getText(oldGtk4CSS.themeName,fontWeight: FontWeight.w500, size: 18
                  ),
                  ),
                  WidsManager().getText("No contents displayed if original theme does not have any extra definitions.",size: 10),
                  WidsManager().getContainer(
                    child: Wrap(
                       //direction: Axis.vertical,
                      spacing: 8.0, // gap between adjacent chips
                      runSpacing: 4.0, // gap between lines
                            children: <Widget>[
                              for(int i=0;i<oldGtk4CSS.namedParts.length;i++)
                                if(!newGtk4CSS.namedParts.contains(oldGtk4CSS.namedParts[i]))
                                WidsManager().getContainer(
                                //  width: 100,
                                  colour: "bg",child: WidsManager().getText(cleanString(oldGtk4CSS.namedParts[i]))
                                                                  )
                            ],
                          ),
                  ),
                ],
              ),
                  ),
          ],
        ),
      ),
    );
  }

  String cleanString(String namedPart) {
    return namedPart.replaceAll("*", '').replaceAll('\n', '').replaceAll('/', '').replaceAll('\\', '').trim();
  }
}
