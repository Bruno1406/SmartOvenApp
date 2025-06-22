import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:convert'; // Import for utf8 encoding

// Make sure this import path is correct for your project structure
import 'package:smart_oven_app/service/bluetooth.dart';

class SmartOvenHome extends StatefulWidget {
  const SmartOvenHome({super.key});

  @override
  State<SmartOvenHome> createState() => SmartOvenHomeState();
}

class SmartOvenHomeState extends State<SmartOvenHome> {
  // Controller to manage the TextField's input
  final _textController = TextEditingController();

  // It's crucial to dispose of the controller when the widget is removed
  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Watch for changes in the OvenBleService. The widget will rebuild
    // when notifyListeners() is called in the service.
    var bluetoothState = context.watch<OvenBleService>();

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                const ElevatedButton(
                  // You can later link this to bluetoothState.startScanning() for example
                  onPressed: null,
                  child: Text('Start'),
                ),
                // 1. Temperature text now dynamically shows the 'test' field
                Text("Temperature: ${bluetoothState.test}°C"),
                const Text("Time: 0 min"), // This text remains static
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/temperature-curve-options');
              },
              child: const Text("Selecionar Curva de Temperatura"),
            ),
            const SizedBox(height: 20),
            const Text("Chart Placeholder"),
          ],
        ),
      ),
    );
  }
}
