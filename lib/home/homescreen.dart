
import 'package:flutter/material.dart';
import 'package:pubsub_flutter/home/sub/body.dart';





class homeScreen extends StatelessWidget {
  static String routeName= '/homescreen';
  const homeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: Body(),
    );
  }
}

