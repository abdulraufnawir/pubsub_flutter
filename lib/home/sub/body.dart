import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';


class Body extends StatefulWidget {
  @override
  State<Body> createState() => _BodyState();
}

class _BodyState extends State<Body> {
  String statusText= "status Text";
  bool isConnected=false;
  final MqttServerClient client =
  MqttServerClient('aq2qlumjdi38g-ats.iot.us-east-1.amazonaws.com', ''); // ('server',clientId,port )

  @override
  bool value = false;

  onUpdate() {
    setState(() {
      value = !value;
    });
  }


  //
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Text("Temperature",
                style: TextStyle(
                    fontSize: 25,
                    color : Colors.green,//kPrimaryColor,
                    fontWeight: FontWeight.bold)),
          ),

          Center(
            child: Container(
              height: 200,
              width: 200,
              decoration: BoxDecoration(
                color: Colors.green,//kPrimaryColor,
                shape: BoxShape.circle,
              ),

              child: StreamBuilder<dynamic>(
                stream: client.updates,
                builder: (context, snapshot) {
                  if (!snapshot.hasData)
                    return Center (
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    )
                  );
                      else
                  {
                    final mqttReceivedMessages = snapshot.data as List<MqttReceivedMessage<MqttMessage ?>>?;
                  final recMess = mqttReceivedMessages![0].payload as MqttPublishMessage;
                  final pt= MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
                  print(
                  'EXAMPLE::Change notification:: topic is <${mqttReceivedMessages[0].topic}>, payload is <-- $pt -->');
                  print('');}
                  //
                    return Column(
                      children: [
                        SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Column(

                              children: [
                                SizedBox(height: 20),
                                SizedBox(height: 0.5),
                                // Padding(
                                //   padding: const EdgeInsets.all(5.0),
                                //    child: bodyStream(),
                  // // final mqttReceivedMessages = snapshot.data as List<MqttReceivedMessage<MqttMessage?>>?;
                  // //                 final mqttReceivedMessages = snapshot.data as List<mqtt.MqttReceivedMessage>mqttReceivedMessages;
                  // //
                  // //                 final recMess = mqttReceivedMessages![0].payload as MqttPublishMessage;
                  //                 client.updates!.listen((List.MqttReceivedMessage<MqttReceivedMessage<MqttMessage>> c) {
                  //                   final recMess = c[0].payload as MqttPublishMessage;
                  //                   final pt= MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
                  //                 })
                  //                     // style: TextStyle(
                  //                     //     color: Colors.white, fontSize: 40)),
                                //),
                                Padding(
                                  padding: const EdgeInsets.all(2.0),
                                  child: Text("KWH",
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 30,
                                          fontWeight: FontWeight.bold)),
                                ),
                              ],
                            ),
                          ],
                        ),
                        SizedBox(height: 20)
                      ],
                    );
                  }
                ),
            ),
          ),
        ],
      ),
    );

  }

  Future<int> mqttConnect(String uniqueId) async {
    //


    //After adding your certificates to the pubspec.yaml, you can use Security Context.

    ByteData rootCA = await rootBundle.load('assets/certs/AmazonRootCA1.pem');
    ByteData deviceCert =
    await rootBundle.load('assets/certs/certificate.crt');
    ByteData privateKey = await rootBundle.load('assets/certs/Private.key');

    SecurityContext context = SecurityContext.defaultContext;
    context.setClientAuthoritiesBytes(rootCA.buffer.asUint8List());
    context.useCertificateChainBytes(deviceCert.buffer.asUint8List());
    context.usePrivateKeyBytes(privateKey.buffer.asUint8List());

    client.securityContext = context;


    client.logging(on: true);
    client.keepAlivePeriod = 60;
    client.port = 8883;
    client.secure = true;
    client.onConnected = onConnected;
    client.pongCallback = pong;


    final MqttConnectMessage connMess =
    MqttConnectMessage().withClientIdentifier(uniqueId).startClean();
    client.connectionMessage = connMess;

    await client.connect();
    if (client.connectionStatus!.state == MqttConnectionState.connected) {
      print("Connected to AWS Successfully!");
    } else {
      return 0;
    }
  //

    // Publish to a topic of your choice
    // const topic = '/test/topic';
    // final builder = MqttClientPayloadBuilder();
    // builder.addString('Hello World');
    // // Important: AWS IoT Core can only handle QOS of 0 or 1. QOS 2 (exactlyOnce) will fail!
    // client.publishMessage(topic, MqttQos.atLeastOnce, builder.payload!);

    // Subscribe to the same topic
    const topic = 'wemos/kwhmeter';
    client.subscribe(topic, MqttQos.atMostOnce);

    return 0;
  }

  void setStatus(String content) {
    setState(() {
      statusText = content;
    });
  }

  void onConnected() {
    print("Client connection was successful");
  }



  void pong() {
    print('Ping response client callback invoked');
  }

}









  // Widget bodyStream() {
  //   return Container(
  //     color: Colors.black,
  //     child: StreamBuilder(
  //       stream: client.updates,
  //       builder: (context,snapshot) {
  //         if (!snapshot.hasData)
  //           return Center(
  //             child: CircularProgressIndicator(
  //               valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
  //             ),
  //           );
  //         else {
            // final mqttReceivedMessages =
            // snapshot.data as List<MqttReceivedMessage<MqttMessage>>;
            //
            // final recMess =
            // mqttReceivedMessages![0].payload as MqttPublishMessage;
            //
            //  return ;

            // client.updates!.listen((List<MqttReceivedMessage<MqttMessage>> c) {
            //   final recMess = c[0].payload as MqttPublishMessage;
            //   final pt =
            //   MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
            //   print(
            //       'EXAMPLE::Change notification:: topic is <${c[0].topic}>, payload is <-- $pt -->');
            //   print('');
            // });


    //       } else {
    // print(
    // 'ERROR MQTT client connection failed - disconnecting, state is ${client.connectionStatus!.state}');
    // client.disconnect();
    // }

  //       },
  //
  //
  //
  //     ),
  //   );
  // }







