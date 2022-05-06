import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  MqttServerClient? client;
  String message = '';
  bool showNotification = false;

  void connect() async {
    client = MqttServerClient('10.0.2.2', 's');

    client!.autoReconnect = true;
    client!.resubscribeOnAutoReconnect = true;
    client!.keepAlivePeriod = 60;
    client!.port = 1883;

    /// ** New **
    client!.streamInterval = const Duration(milliseconds: 100);

    /// ** New **
    client!.streamBufferTime = const Duration(milliseconds: 1000);

    /// ** New **
    client!.maxConnectionAttempts = 5;

    /// ** New **
    client!.backoffDelay = 200;

    /// ** New **
    client!.onAutoReconnectMaxAttemptCallback =
        onAutoReconnectMaxAttemptCallback;

    client!.onConnected = onConnected;
    client!.onAutoReconnect = onAutoreconnect;
    client!.onDisconnected = onDisconnected;
    client!.pongCallback = onPongCallback;

    await client!.connect();

    update();
  }

  /// ** New **
  void onAutoReconnectMaxAttemptCallback() {
    if (showNotification == false) {
      showNotification = true;
      showModalBottomSheet<void>(
        context: context,
        isDismissible: false,
        builder: (BuildContext context) {
          return Container(
            height: 200,
            color: Colors.white,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  const Text('Koneksi terputus, cek jariangan ya'),
                  ElevatedButton(
                      child: const Text('Oke'),
                      onPressed: () {
                        showNotification = false;
                        Navigator.pop(context);
                      })
                ],
              ),
            ),
          );
        },
      );
    }
  }

  void onConnected() {
    print("onConnected");
    setState(() {});
  }

  void onAutoreconnect() {
    print("onAutoreconnect");
    print(client!.maxConnectionAttempts);
    setState(() {});
  }

  void onDisconnected() {
    print("onDisconnected");
    setState(() {});
  }

  void onPongCallback() {
    print("onPongCallback");
    setState(() {});
  }

  void subscribe() {
    print("sub test1");
    client!.subscribe('test1', MqttQos.exactlyOnce);
    setState(() {});
  }

  void update() {
    client!.updates!.listen((event) {
      final MqttPublishMessage recMessage =
          event.first.payload as MqttPublishMessage;

      final String pt =
          MqttPublishPayload.bytesToStringAsString(recMessage.payload.message);
      setState(() {
        message = pt.toString();
      });
      print('dari hp = ' + message);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Backpressure'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            if (client != null) Text(client!.connectionStatus!.state.name),
            Text(
              message,
            ),
            ElevatedButton(
              onPressed: () {
                connect();
              },
              child: Text('Connect'),
            ),
            ElevatedButton(
              onPressed: () {
                subscribe();
              },
              child: Text('Subscribe'),
            )
          ],
        ),
      ),
    );
  }
}
