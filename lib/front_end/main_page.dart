
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gtkthememanager/back_end/app_data.dart';
import 'package:gtkthememanager/front_end/app_specific_settings.dart';
import 'package:gtkthememanager/front_end/install_theme.dart';
import '../theme_manager/gtk_to_theme.dart';
import '../theme_manager/gtk_widgets.dart';
import 'about_page.dart';
import 'appearance.dart';
import 'icons.dart';
import 'package:gtkthememanager/theme_manager/tab_manage.dart';



class WidgetGTK extends StatefulWidget {

  const WidgetGTK({super.key, });

  @override
  State<WidgetGTK> createState() => _WidgetGTKState();
}
//added some welcome messages
class _WidgetGTKState extends State<WidgetGTK> with TickerProviderStateMixin {
  bool firstLaunch=true;
  state(){
    setState(() {

    });
  }
@override
  void initState() {
    // TODO: implement initState
  setLaunch();
  if(AppData.DataFile["DONE"]==null){
    showMessage();
  }
    super.initState();
  }
  setLaunch()async{
    await Future.delayed(500.milliseconds);
  setState(() {
    firstLaunch=false;
  });
  }
  showMessage() async {
  await Future.delayed(100.milliseconds);
  {
    WidsManager().showMessage(title: "Info",
      message: "By continuing to use the app you agree to the terms and conditions. Check the README file provided.",
      context: context,
      child: Row(
          mainAxisAlignment: MainAxisAlignment.end,

          children: <Widget>[
            GetButtons(onTap: (){
              Navigator.pop(context);
              WidsManager().showMessage(title: "Info",
                  message:  "Your responsibility as an open-source community member is to help developers provide high quality and performant apps. One way to do this is providing"
                      " comprehensive feedback of problems faced and errors encountered.\n\nMake sure to email me at nexindia.dev@gmail.com with screenshots, log outputs and the theme/icon link the problem was "
                      "encountered with. Run this app from the terminal in order to get log outputs.",
                  context: context,
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        GetButtons(

                            light: true,
                            text: "Okay",
                            onTap: () async {
                              {
                                AppData.DataFile["DONE"] = "TRUE";
                                AppData().writeDataFile();
                           Navigator.pop(context);
                              }
                            })]));

            }, text: "Accept",)
          ]
      ),
    );


  }
  }


  bool loading=true;
  @override
  Widget build(BuildContext context) {
    double w = MediaQuery.sizeOf(context).width;
    double h = MediaQuery.sizeOf(context).height;
    TabManager.isLargeScreen = w>600;
    TabManager.isSuperLarge = w>1000;
    return Scaffold(
      backgroundColor: ThemeDt.themeColors["bg"],
      floatingActionButton: (WidsManager.activeTab<2)?GetButtons(
        light: true,
        ltVal: 1.2,
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (context)=>Installer(state: state,))).then((value) {

          });
        },
        child: WidsManager().getText("Install New +"),
      ):null,
      body: Column(
        children: [
          GestureDetector(
            onDoubleTap: (){
              appWindow.maximizeOrRestore();
            },
              onPanUpdate: (dt){
                appWindow.startDragging();
              },
              child: AnimatedContainer(duration: ThemeDt.d, curve: ThemeDt.c,
                width: MediaQuery.sizeOf(context).width,
                height: 60,
                color: ThemeDt.themeColors["bg"],
                child:
              Stack(
                children: [
                  AnimatedPositioned(
                    duration: ThemeDt.d, curve: ThemeDt.c,
                      left:  AppData.DataFile["GNOMEUI"]==true?
                      !TabManager.isLargeScreen?TabManager.isDrawerVisible?60:-120:60:
                    MediaQuery.sizeOf(context).width/2 - 20,
                    top: 18, bottom: 18,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                        WidsManager().getText("Evolve", fontWeight: FontWeight.w600),
                          const SizedBox(width: 40,),
                          AnimatedOpacity(
                            duration: 100.milliseconds,
                            opacity: AppData.DataFile["GNOMEUI"]==true?1:0,
                            child: GestureDetector(onTap: (){
                              showMenu(context: context,color: Colors.transparent,elevation: 0,
                                  position: const RelativeRect.fromLTRB(60, 40, 60, 0),
                                  items: [
                                   PopupMenuItem(
                                     enabled: false,
                                     child: GestureDetector(
                                       onTap:(){
                                         WidsManager().showAboutPage(context, AnimationController(vsync: this));
                                       },
                                         child: WidsManager().getContainer(child: WidsManager().getText('About'))),
                                      )
                                    ]);
                            },child: Icon(Icons.more_vert,color: ThemeDt.themeColors["fg"],size: 20,))
                          )
                      ],
                    ),
                  ),
                  AnimatedPositioned(
                    duration: ThemeDt.d, curve: ThemeDt.c,
                      left:  TabManager.isLargeScreen?-100:TabManager.isDrawerVisible?-100:20,
                    top: 18, bottom: 18,
                    child: GestureDetector(
                        onTap: (){
                          setState(() {
                            TabManager.isDrawerVisible=!TabManager.isDrawerVisible;
                          });

                        },
                        child: Icon(Icons.menu_rounded, color: ThemeDt.themeColors["fg"],)),
                  ),


                  AnimatedSlide(
                    duration: ThemeDt.d,
                    curve: ThemeDt.c,
                    offset: Offset(TabManager.isLargeScreen?0.1:0,0),
                    child: AnimatedOpacity(
                      duration: 100.milliseconds,
                      opacity: AppData.DataFile["GNOMEUI"]==true?1:0,child: Center(
                        child: WidsManager().getText(WidsManager.tabs[WidsManager.activeTab],fontWeight: FontWeight.w600))),
                  ),
                  Positioned(
                   // duration: ThemeDt.d, curve: ThemeDt.c,
                    left:   (MediaQuery.sizeOf(context).width)-40, top: 18, bottom: 18,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                       GestureDetector(
                         onTap:(){
                           appWindow.close();
                         },
                         child: Container(
                           height: 15,
                           width: 15,
                           decoration: BoxDecoration(
                             color: Colors.red[300],
                             shape: BoxShape.circle
                           ),
                         ),
                       )
                      ],
                    ),
                  ),
                ],
              )
                ,)),
          Expanded(
            child: Stack(
             // crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[

                AnimatedPositioned(
                  duration: ThemeDt.d,
                  curve: ThemeDt.c,
                  right: 0,
                  child: Container(
                      width:    MediaQuery.sizeOf(context).width-((TabManager.isLargeScreen)?165:0),

                      child: MainView(state:state,)),
                ),
                Positioned(
                  left: TabManager.isLargeScreen?-MediaQuery.sizeOf(context).width: TabManager.isDrawerVisible?0:-MediaQuery.sizeOf(context).width,
                  child: GestureDetector(
                    onTap: (){
                      setState(() {
                        TabManager.isDrawerVisible=!TabManager.isDrawerVisible;

                      });
                    },
                    child: Container(
                      color: Colors.black.withOpacity(0.2),
                      height: MediaQuery.sizeOf(context).height,
                      width: MediaQuery.sizeOf(context).width,
                    ),
                  ),) ,
                AnimatedPositioned(
                    duration: ThemeDt.d,
                    curve: ThemeDt.c,
                    left: TabManager.isLargeScreen?0: TabManager.isDrawerVisible?0:-190,
                    child: Container(
                      decoration: BoxDecoration(color: ThemeDt.themeColors["bg"],),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TabbedInterface(state: state,),
                          const SizedBox(width: 10,),
                          Container(
                            height: MediaQuery.sizeOf(context).height-60,
                            width: 1.7,color: ThemeDt.themeColors["fg"]?.withOpacity(TabManager.isLargeScreen?0.2:0),)
                        ],
                      ),
                    )),

              ],
            ),
          ),

        ],
      ),
    );
  }
}
class TabbedInterface extends StatefulWidget {
  final Function() state;
  const TabbedInterface({super.key,required this.state});

  @override
  State<TabbedInterface> createState() => _TabbedInterfaceState();
}

class _TabbedInterfaceState extends State<TabbedInterface> {
  @override
  Widget build(BuildContext context) {
    return  Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(left: 8.0, bottom: 8, top: 8),
          child: TabButton(
            Tab: 0,
            state : widget.state,
            text: 'Theme', ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 8.0, bottom: 8),
          child: TabButton(
            Tab: 1,
            state : widget.state,
            text: 'Icons',  ),
        ), Padding(
          padding: const EdgeInsets.only(left: 8.0, bottom: 8),
          child: TabButton(
            Tab: 2,
            state : widget.state,
            text: 'Settings',  ),
        ),
     if(AppData.DataFile["GNOMEUI"]==false)   Padding(
          padding: const EdgeInsets.only(left: 8.0, bottom: 8),
          child: TabButton(
            Tab: 3,
            state : widget.state,
            text: 'About',  ),
        ),
      ],
    );
  }
}

class MainView extends StatefulWidget {
  final Function() state;
  const MainView({super.key, required this.state});

  @override
  State<MainView> createState() => _MainViewState();
}

class _MainViewState extends State<MainView> {


  @override
  Widget build(BuildContext context) {
    if(WidsManager.activeTab==0){
      return Padding(
        padding: const EdgeInsets.only(left: 18.0, right: 10),
        child: Appearances(state: widget.state,),
      );
    }else if(WidsManager.activeTab==1){
      return Padding(
        padding: const EdgeInsets.only(left: 18.0, right: 10),
        child: Container(
            height: MediaQuery.sizeOf(context).height-60,
            child: IconPicker(state: widget.state,)),
      );
    }else if(WidsManager.activeTab==2){
      return Padding(
        padding: const EdgeInsets.only(left: 18.0, right: 10),
        child: AppSettings(state: widget.state,),
      );
    }
    else{
      return const AboutPage();
    }
  }
}
