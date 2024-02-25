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



class WidgetGTK extends StatefulWidget {
  final Function() state;

  const WidgetGTK({super.key, required this.state});

  @override
  State<WidgetGTK> createState() => _WidgetGTKState();
}
//added some welcome messages
class _WidgetGTKState extends State<WidgetGTK> {
  bool firstLaunch=true;
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
    return Scaffold(
      backgroundColor: ThemeDt.themeColors["bg"],
      floatingActionButton: (WidsManager.activeTab<2)?GetButtons(
        light: true,
        ltVal: 1.2,
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (context)=>Installer(state: widget.state,))).then((value) {

          });
        },
        child: WidsManager().getText("Install New +"),
      ):null,
      body: Stack(
        children: [

          Row(
            children: <Widget>[
              TabbedInterface(state: widget.state,),
              const SizedBox(width: 16,),
              Container(width: 1.7,color: ThemeDt.themeColors["fg"]?.withOpacity(0.2),),
              Container(
                  width:    (WidsManager.activeTab==3) ?  MediaQuery.sizeOf(context).width-(MediaQuery.sizeOf(context).width/5)-30 : null,

                  child: MainView(state:widget.state,)),
            ],
          ),
          if(loading)Container(
            color: const Color(0xffd1e1fd),
            height: MediaQuery.sizeOf(context).height,width: MediaQuery.sizeOf(context).width,).animate(
            onComplete: (dt){
              loading=false;
              setState(() {

              });
            },
              effects: [
                FadeEffect(
                    delay: 200.milliseconds,
                    duration: 1.seconds,
                    curve: Curves.easeOutExpo,
                    begin: 1,
                    end: 0
                )
              ]
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
        Padding(
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
      return Expanded(
        child: Padding(
          padding: const EdgeInsets.only(left: 18.0, right: 10),
          child: Appearances(state: widget.state,),
        ),
      );
    }else if(WidsManager.activeTab==1){
      return Expanded(
        child: Padding(
          padding: const EdgeInsets.only(left: 18.0, right: 10),
          child: IconPicker(state: widget.state,),
        ),
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
