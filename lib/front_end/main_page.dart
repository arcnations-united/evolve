import 'package:flutter/material.dart';
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

class _WidgetGTKState extends State<WidgetGTK> {

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(12), bottomRight: Radius.circular(12)),
      child: Scaffold(
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
        body: Row(
          children: <Widget>[
            TabbedInterface(state: widget.state,),
            const SizedBox(width: 16,),
            Container(width: 1.7,color: ThemeDt.themeColors["sltbg"],),
            Container(
                width:    (WidsManager.activeTab==2) ?  MediaQuery.sizeOf(context).width-(MediaQuery.sizeOf(context).width/5)-30 : null,

                child: MainView(state:widget.state,)),
          ],
        ),
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
        ),
        Padding(
          padding: const EdgeInsets.only(left: 8.0, bottom: 8),
          child: TabButton(
            Tab: 2,
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
    }
    else{
      return const AboutPage();
    }
  }
}
