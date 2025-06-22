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
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              ElevatedButton(onPressed: null, child: Text('Start')),
              SizedBox(width: 10),
              Text("Temperature: 0°C"),
              SizedBox(width: 10),
              Text("Time: 0 min"),
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
        ],
      ),
    );
  }
}
