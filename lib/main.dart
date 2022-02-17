import 'package:flutter/material.dart';
import 'package:pubsub_flutter/home/homepage.dart';
import 'package:pubsub_flutter/home/homescreen.dart';





void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Wallet',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

