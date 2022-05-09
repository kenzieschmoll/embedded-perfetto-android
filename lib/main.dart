import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:perfetto_android/perfetto.dart';

void main() {
  runApp(const EmbeddedPerfettoPrototype());
}

class EmbeddedPerfettoPrototype extends StatelessWidget {
  const EmbeddedPerfettoPrototype({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    return MaterialApp(
      title: 'Embedded Perfetto',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Embedded Perfetto'),
        ),
        body: const Perfetto(),
      ),
    );
  }
}
