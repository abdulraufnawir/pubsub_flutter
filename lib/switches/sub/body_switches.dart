import 'dart:core';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:mqtt_client/mqtt_client.dart' as mqtt;
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';


class Body extends StatelessWidget {
  static const String title = 'AC Control Dashboard';

  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    title: title,
    theme: ThemeData(primarySwatch: Colors.red),
    home:  const MainScreen(title: title),
  );
}


class MainScreen extends StatefulWidget {
  final String title;
  const MainScreen({
    required this.title,
  });

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  // const MainScreen({Key? key}) : super(key: key);
  //final _scaffoldState = GlobalKey<ScaffoldState>();
  bool _val1= false;
  bool _val2=false;
  bool _val3=false;
  bool _val4=false;
  bool _val5=false;
  bool _val6=false;
  //late BuildContext _context;


  void initState(){
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          body: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height:30),
              MainPage(val1: _val1, val2: _val2, val3: _val3, val4: _val4, val5: _val5, val6: _val6,
                  valChanged1: (value) {_val1=value;}, valChanged2: (value) {_val2=value;}, valChanged3: (value) {_val3=value;},
                  valChanged4: (value) {_val4=value;}, valChanged5: (value) {_val5=value;}, valChanged6: (value) {_val1=value;})
            ],


          )),
    );
  }
}


class MainPage extends StatefulWidget { //bottomsheetswitch

  const MainPage({
    required this.val1, required this.val2,required this.val3,
    required this.val4,required this.val5,
    required this.val6,required this.valChanged1,
    required this.valChanged2,required this.valChanged3,
    required this.valChanged4,required this.valChanged5,
    required this.valChanged6, });
  //
  //
  final bool val1 ; final bool val2 ;final bool val3 ;
  final bool val4 ;final bool val5 ; final bool val6 ;
  final ValueChanged valChanged1; final ValueChanged valChanged3;
  final ValueChanged valChanged2;  final ValueChanged valChanged4;
  final ValueChanged valChanged5;  final ValueChanged valChanged6;

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  late bool _val1; late bool _val2; late bool _val3;
  late bool _val4; late bool _val5; late bool _val6;

  final MqttServerClient client =
  MqttServerClient('aq2qlumjdi38g-ats.iot.us-east-1.amazonaws.com', '');


  void initState() {
    _val1 = widget.val1; _val2 = widget.val2; _val3 = widget.val3;
    _val4 = widget.val4; _val5 = widget.val5; _val6 = widget.val6;
    super.initState();
  }


  late StreamSubscription subscription;




  Future<int> mqttConnect(String uniqueID) async{ //

    ByteData rootCA = await rootBundle.load('assets/certs/RootCA.pem');
    ByteData deviceCert = await rootBundle.load('assets/certs/DeviceCertificate.crt');
    ByteData privateKey = await rootBundle.load('assets/certs/Private.key');

    SecurityContext context = SecurityContext.defaultContext;
    context.setClientAuthoritiesBytes(rootCA.buffer.asUint8List());
    context.useCertificateChainBytes(deviceCert.buffer.asUint8List());
    context.usePrivateKeyBytes(privateKey.buffer.asUint8List());
    client.securityContext = context; //same position (inside future)
    client.logging(on: true);         //same position (inside future)
    client.keepAlivePeriod = 20;      //same position (inside future)
    client.port = 443;               //same position (inside future)
    client.secure = true;             //same position (inside future)

    client.pongCallback = pong;
    final MqttConnectMessage connMess =
    MqttConnectMessage().withClientIdentifier(uniqueID).startClean();
    client.connectionMessage = connMess;

    await client.connect();
    if (client.connectionStatus!.state == MqttConnectionState.connected) {
      print("Connected to AWS Successfully!");
    }
    // Subscribe to topic1
    const topic1 = 'wemos/Switch1';
    client.subscribe(topic1, MqttQos.atMostOnce);
    subscription = client.updates!.listen(_onMessage1);
    return 0;
  }

    void pong() {
    print('Ping response client callback invoked');
  }





//client.updates!.listen((List<MqttReceivedMessage<MqttMessage>> c) ...
  void _onMessage1(List<mqtt.MqttReceivedMessage> event){ //event = c
    print(event.length);
    final mqtt.MqttPublishMessage recMess =  // Recmess
    event[0].payload as mqtt.MqttPublishMessage;
    final String message=  // message = pt
    mqtt.MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
    print(
        '[MQTT client] MQTT message : topic is <${event[0].topic}>,'
        'payload is <-- $message -->');
    print(client.connectionStatus!.state);
    print('[MQTT client] message with topic: ${event[0].topic}');
    print('[MQTT client] message with message: $message');
    setState(() {
      if(message=='on'){
        _val1=true;
        print ('value is equals to: $_val1');
      }
      else if(message == 'off'){
        _val1 = false;
        print ('value 1 is equal to : $_val1');
      }
    });
  }



  Widget _switches(){ //-lights
    return SafeArea(
      child:
      Container (
          child:MergeSemantics(
            child: ListTile(
            title: Text('SWITCH 1',
                style: TextStyle(
                    fontSize: 30,
                    color: Colors.green,
                    fontWeight: FontWeight.bold)),
            trailing:Switch.adaptive(
              activeColor:Colors.lightGreen,
              value: _val1,
              onChanged: (bool value) {
                setState((){
                  _val1 = value;
                  widget.valChanged1(value);
                  if (value== true) {
                    /// Lets publish to our topic
                    /// Use the payload builder rather than a raw buffer
                    /// Our known topic to publish to
                    const String pubTopic ='wemos/Switch1';
                    final mqtt.MqttClientPayloadBuilder builder=
                    mqtt.MqttClientPayloadBuilder();
                    builder.addString('on');
                    /// Subscribe to it
                    print('EXAMPLE::Subscribing to the wemos/Switch1 pubTopic');
                    client.subscribe(pubTopic, mqtt.MqttQos.atLeastOnce);
                    /// Publish it
                    print('EXAMPLE::Publishing our topic');
                    client.publishMessage(pubTopic, mqtt.MqttQos.atLeastOnce, builder.payload!);

                  }
                  else if(value == false) {
                    const String pubTopic = 'wemos/Switch1';
                    final mqtt.MqttClientPayloadBuilder builder =
                    mqtt.MqttClientPayloadBuilder();
                    builder.addString('off');

                    /// Subscribe to it
                    print('EXAMPLE::Subscribing to the wemos/Switch1 pubTopic');
                    client.subscribe(pubTopic, mqtt.MqttQos.atLeastOnce);

                    /// Publish it
                    print('EXAMPLE::Publishing our pubTopic');
                    client.publishMessage(pubTopic, mqtt.MqttQos.atLeastOnce, builder.payload!);

                  }
                });
              },
            ) ,
          ),
          ),
      ),

    );

  }
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return _switches();
  }

}

