import 'dart:async';
import 'package:card_swiper/card_swiper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gtkthememanager/front_end/main_page.dart';
import 'package:gtkthememanager/theme_manager/gtk_to_theme.dart';

//the nice little start-up animation
class PreviewPage extends StatefulWidget {
  final dynamic  state;
  const PreviewPage({super.key, required this.state});

  @override
  State<PreviewPage> createState() => _PreviewPageState();
}

class _PreviewPageState extends State<PreviewPage> {
  List <Widget>widPrev=<Widget>[

  ];
  Timer? t;
  bool played=false;
 List <Widget> img=[];
  @override
  void initState() {
    // TODO: implement initState
    t=Timer(const Duration(seconds: 8), () {
      img.add(Image.asset(
          height: MediaQuery.sizeOf(context).height,
          width: MediaQuery.sizeOf(context).width,fit: BoxFit.fitWidth,
          "assets/p1.png"));
      img.add(Image.asset(
          height: MediaQuery.sizeOf(context).height,
          width: MediaQuery.sizeOf(context).width,fit: BoxFit.fitWidth,
          "assets/p2.png"));
      img.add(Image.asset(
          height: MediaQuery.sizeOf(context).height,
          width: MediaQuery.sizeOf(context).width,fit: BoxFit.fitWidth,
          "assets/p3.png"));
      played =true;
      setState(() {

      });
    });
    super.initState();
  }
  @override
  void dispose() {
    // TODO: implement dispose
    t?.cancel();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor:const Color(0xffd1e1fd),
        onPressed: () async {

          t?.cancel();
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const WidgetGTK()));
        },
child: const Icon(Icons.chevron_right),
      ),
      backgroundColor: const Color(0xffd1e1fd),
body: Stack(
  children: [

        AnimatedOpacity(opacity: played?0:1, duration: ThemeDt.d,
          child: Image.asset(
          height: MediaQuery.sizeOf(context).height,
          width: MediaQuery.sizeOf(context).width,fit: BoxFit.contain,
          "assets/preview.webp"),
    ).animate(
            effects: [
              FadeEffect(
                  delay: 100.milliseconds,
                  duration: 1.seconds
              )
            ]
        ),
        AnimatedOpacity(opacity: played?1:0, duration: ThemeDt.d, child:
       Swiper(itemCount: 3,autoplay: played,layout: SwiperLayout.STACK,
           itemWidth: MediaQuery.sizeOf(context).width,
    itemBuilder: (BuildContext context, int index) {
       try {
         return img[index] ;
       }  catch (e) {
         return Container(
           height: 100,width: 100,
         );
       }
    }
       ),

        )
  ],
));
  }
}
