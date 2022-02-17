
import 'package:flutter/material.dart';
import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:pubsub_flutter/home/homescreen.dart';
import 'package:pubsub_flutter/switches/switches.dart';






class MyHomePage extends StatefulWidget {
  static String routeName= '/homescreen';
    @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int selectedPage = 0;
  final _pageOptions= [homeScreen(),Switches()];

  @override
  Widget build(BuildContext context) {

    return Scaffold(

        body: _pageOptions[selectedPage],
        bottomNavigationBar: ConvexAppBar(backgroundColor:Colors.lightBlue,
          items: [
            TabItem(icon: Icons.home, title: 'home'),
            //TabItem(icon: Icons.timeline, title: 'Statistics'),
            TabItem(icon: Icons.outlet, title: 'switches'),
            //TabItem(icon: Icons.settings, title: 'settings'),
          ],
          initialActiveIndex: 0,// optional, default as 0
          onTap: (int i)  {
            setState((){
              selectedPage=i;
            });
          },// ,
        )
    );
  }
}
