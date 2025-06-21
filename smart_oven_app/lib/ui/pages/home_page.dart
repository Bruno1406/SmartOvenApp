
import 'package:flutter/material.dart';

class SmartOvenHome extends StatefulWidget {
  const SmartOvenHome({super.key});

  @override
  State<SmartOvenHome> createState() => SmartOvenHomeState();
}

class SmartOvenHomeState extends State<SmartOvenHome> {
  final bool _isRunning = false;
  final double _temperature = 0.0;
  final int _time = 0;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: <Widget>[
          const Row (
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              ElevatedButton(
                onPressed: null,
                child: Text('Start'),
              ),
              Text("Temperature: 0°C"),
              Text("Time: 0 min"),
            ]
          ),
          Text("Chart Placeholder")
        ]
      )
    );
  }
}