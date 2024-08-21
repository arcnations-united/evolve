import 'dart:io';
import 'package:flutter/material.dart';
import 'package:gtkthememanager/theme_manager/gtk_to_theme.dart';
import 'package:gtkthememanager/theme_manager/gtk_widgets.dart';
import 'package:process_run/process_run.dart';
import '../back_end/gtk_theme_manager.dart';
import 'advanced_theme_maker.dart';

//Lets you create new themes
//tooltip styles aren't updated yet
class NewTheme extends StatefulWidget {
  final String name;
  const NewTheme({super.key, required this.name});

  @override
  State<NewTheme> createState() => _NewThemeState();
}

class _NewThemeState extends State<NewTheme> {
  late String gtk3,gtk4,shell, name, modOf;
  bool checkGlobal(name){
    if (!(ThemeManager.themeSupport[name]
    ?["gtk3"] ??
        false)) return false;
    if (!(ThemeManager.themeSupport[name]
    ?["gtk4"] ??
        false)) return false;
    if (!(ThemeManager.themeSupport[name]
    ?["shell"] ??
        false)) return false;
    return true;
  }
  
  @override
  void initState() {
    // TODO: implement initState
    name = "${widget.name.split("/").last}-MOD";
    modOf = widget.name;
    gtk3 = "Not Set";
    gtk4 = gtk3;
    shell = gtk3;
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(12), bottomRight: Radius.circular(12)),
      child: Scaffold(
        appBar: WidsManager().gtkAppBar(
          context,
          backgroundColor: ThemeDt.themeColors["bg"],
          foregroundColor: ThemeDt.themeColors["fg"],

        ),
        backgroundColor: ThemeDt.themeColors["bg"],
        body: Padding(
          padding: const EdgeInsets.only(left: 18.0, right: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              WidsManager().getText("Create a new theme", size: 25),
              const SizedBox(height: 10,),
              WidsManager().getContainer(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  WidsManager().getText("Name",),
                  const SizedBox(height: 10,),

                  GetTextBox(initText: name,onDone: (txt){
                    name = txt;
                  },)

                ],
              )),
              const SizedBox(height: 10,),
              Row(
                children: [
                  WidsManager().
                  getContainer(child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [
                      WidsManager().getText("MOD of",),
                      const SizedBox(height: 10,),
                      PopupMenuButton(
                        tooltip: "",
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                        ),
                        color: ThemeDt.themeColors["altbg"],
                        elevation: 0,
                        itemBuilder: (BuildContext context) {
                          return [
                            for (int i = 0; i < ThemeManager.GTKThemeList.length; i++)
                              if(checkGlobal(ThemeManager.GTKThemeList[i]))
                              PopupMenuItem(
                                  child: Row(
                                    children: [
                                      Expanded(
                                          child: GestureDetector(
                                            onTap: () async {
                                              modOf=ThemeManager.GTKThemeList[i];
                                              Navigator.pop(context);
                                              setState(() {

                                              });
                                            },child: WidsManager().getText(ThemeManager.GTKThemeList[i].split("/").last),
                                          ),
                                      ),
                                    ],
                                  ))
                          ];
                        },
                        child: WidsManager().getContainer(
                            child: WidsManager().getText(modOf.split("/").last)),
                      ),


                    ],
                  )),
                  const SizedBox(width: 10,),
                  WidsManager().
                  getContainer(child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [
                      WidsManager().getText("GTK-3.0",),
                      const SizedBox(height: 10,),
                      PopupMenuButton(
                        tooltip: "",
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                        ),
                        color: ThemeDt.themeColors["altbg"],
                        elevation: 0,
                        itemBuilder: (BuildContext context) {
                          return [
                            for (int i = 0; i < ThemeManager.GTKThemeList.length; i++)
                              if(checkGlobal(ThemeManager.GTKThemeList[i]))
                                PopupMenuItem(
                                    child: Row(
                                      children: [
                                        Expanded(
                                            child: GestureDetector(
                                              onTap: () async {
                                                gtk3=ThemeManager.GTKThemeList[i];
                                                Navigator.pop(context);
                                                setState(() {

                                                });
                                              },child: WidsManager().getText(ThemeManager.GTKThemeList[i].split("/").last),
                                            ),),
                                      ],
                                    ))
                          ];
                        },
                        child: WidsManager().getContainer(
                            child: WidsManager().getText(gtk3.split("/").last)),
                      ),


                    ],
                  )),
                  const SizedBox(width: 10,),

                  WidsManager().
                  getContainer(child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [
                      WidsManager().getText("GTK-4.0",),
                      const SizedBox(height: 10,),
                      PopupMenuButton(
                        tooltip: "",
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                        ),
                        color: ThemeDt.themeColors["altbg"],
                        elevation: 0,
                        itemBuilder: (BuildContext context) {
                          return [
                            for (int i = 0; i < ThemeManager.GTKThemeList.length; i++)
                              if (ThemeManager.themeSupport[ThemeManager.GTKThemeList[i]]
                              ?["gtk4"] ??
                                  false)
                                PopupMenuItem(
                                    child: Row(
                                      children: [
                                        Expanded(
                                            child: GestureDetector(
                                              onTap: () async {
                                                gtk4=ThemeManager.GTKThemeList[i];
                                                Navigator.pop(context);
                                                setState(() {

                                                });
                                              },child: WidsManager().getText(ThemeManager.GTKThemeList[i].split("/").last),
                                            ),),
                                      ],
                                    ))
                          ];
                        },
                        child: WidsManager().getContainer(
                            child: WidsManager().getText(gtk4.split("/").last)),
                      ),


                    ],
                  )),
                  const SizedBox(width: 10,),

                  WidsManager().
                  getContainer(child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [
                      WidsManager().getText("gnome-shell",),
                      const SizedBox(height: 10,),
                      PopupMenuButton(
                        tooltip: "",
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                        ),
                        color: ThemeDt.themeColors["altbg"],
                        elevation: 0,
                        itemBuilder: (BuildContext context) {
                          return [
                            for (int i = 0; i < ThemeManager.GTKThemeList.length; i++)
                              if (ThemeManager.themeSupport[ThemeManager.GTKThemeList[i]]
                              ?["shell"] ??
                                  false)
                                PopupMenuItem(
                                    child: Row(
                                      children: [
                                        Expanded(
                                            child: GestureDetector(
                                              onTap: () async {
                                                shell=ThemeManager.GTKThemeList[i];
                                                Navigator.pop(context);
                                                setState(() {

                                                });
                                              },child: WidsManager().getText(ThemeManager.GTKThemeList[i].split("/").last),
                                            ),),
                                      ],
                                    ))
                          ];
                        },
                        child: WidsManager().getContainer(
                            child: WidsManager().getText(shell.split("/").last)),
                      ),


                    ],
                  )),
                  const SizedBox(width: 10,),
                  Expanded(
                    child: WidsManager().getContainer(
                        height: 90,
                        child: Center(child: WidsManager().getText("Set each component of theme from here!"))
                    ),
                  )
                ],
              ),
              const SizedBox(height: 10,),

              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  GetButtons(
                    onTap: ()async{
                      await generateTheme();
                      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>AdvancedThemeMaker(newThemePath: "${SystemInfo.home}/.themes/$name", originalThemePath: modOf,)));
                    },
                    text: "Advanced Mode", light: true,),
                  const SizedBox(width: 10,),
                  GetButtons(
                    onTap: ()async{
                      await generateTheme();
                    },
                    text: "Create Theme", light: true, ghost: true,),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
//Generates a theme-MOD

  Future<void>generateTheme()async{
    try {
      Directory thms = Directory("${SystemInfo.home}/.themes");
      if(!(await thms.exists())){
       await thms.create();
      }
      await Shell().run("""cp -r $modOf ${SystemInfo.home}/.themes/$name""");
      String themePath = "${SystemInfo.home}/.themes/$name";
      Directory gtk_3 = Directory("$themePath/gtk-3.0");
      Directory gtk_4 = Directory("$themePath/gtk-4.0");
      Directory gnome_shell = Directory("$themePath/gnome-shell");
      if(await(gtk_3.exists())&& gtk3!="Not Set"){
        await gtk_3.delete(recursive: true);
        await Shell().run("""cp -r $gtk3/gtk-3.0 ${SystemInfo.home}/.themes/$name""");
      }if(await(gtk_4.exists())&& gtk4!="Not Set"){
        await gtk_4.delete(recursive: true);
        await Shell().run("""cp -r $gtk4/gtk-4.0 ${SystemInfo.home}/.themes/$name""");
      }if(await(gnome_shell.exists())&& shell!="Not Set"){
        await gnome_shell.delete(recursive: true);
        await Shell().run("""cp -r $shell/gnome-shell ${SystemInfo.home}/.themes/$name""");
      }
      if(context.mounted) {
        WidsManager().showMessage(title: "Info", message: "Theme successfully created",
            child:GetButtons(onTap: (){
              Navigator.pop(context);
              Navigator.pop(context);
            },
              text: "Close",),context: context);
      }
    } catch (e) {
      if(context.mounted)WidsManager().showMessage(title: "Error", message: e.toString(), context: context);
    }

  }
}
