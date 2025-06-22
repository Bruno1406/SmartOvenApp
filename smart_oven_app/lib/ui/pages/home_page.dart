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
            const SizedBox(height: 20), // Adds some space between elements

            // 2. TextField replaces the "Chart Placeholder"
            TextField(
              controller: _textController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Oven Command',
                hintText: 'Type here and press Enter to send',
              ),
              // 3. onSubmitted invokes the write function
              onSubmitted: (String value) {
                if (value.isNotEmpty) {
                  // Convert the String to a List<int> (using UTF-8 encoding)
                  List<int> dataToSend = utf8.encode(value);
                  
                  // Call the write function from your service
                  bluetoothState.writeToOvenProgramCharacteristic(dataToSend);
                  
                  // Clear the text field for the next command
                  _textController.clear();
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}