import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:convert'; // Import for utf8 encoding

// Make sure this import path is correct for your project structure
import 'package:smart_oven_app/service/bluetooth.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:fl_chart/fl_chart.dart';

class SmartOvenHome extends StatefulWidget {
  const SmartOvenHome({super.key});

  @override
  State<SmartOvenHome> createState() => SmartOvenHomeState();
}

class SmartOvenHomeState extends State<SmartOvenHome> {
  bool _isRunning = false;
  bool _isConnected = false;
  // double _currentTemperature = 0.0;
  // double _currentTime = 0.0;
  // late Timer _timer;
  final List<FlSpot> _graphPoints = [];

  // It's crucial to dispose of the controller when the widget is removed
  @override
  void dispose() {
      super.dispose();
  }

  void _startMonitoring() {
    if (!_isConnected) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Erro: Sem conexão Bluetooth")),
      );
      return;
    }

    setState(() {
      _isRunning = true;
      _currentTime = 0;
      _graphPoints.clear();
    });

  }

  _timer = Timer.periodic(const Duration(seconds: 3), (timer) async {
      // 🔄 Simulação de leitura Bluetooth (substitua por dados reais!) TODO @BRUNO
      double simulatedTemp = 100 + 20 * sin(_currentTime / 10);

      setState(() {
        _currentTemperature = simulatedTemp;
        _graphPoints.add(FlSpot(_currentTime, _currentTemperature));
        _currentTime += 3;
      });
    });

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
             _isRunning
              ? SizedBox(
                  height: 300,
                  child: LineChart(
                    LineChartData(
                      lineBarsData: [
                        LineChartBarData(
                          spots: _graphPoints,
                          isCurved: true,
                          color: Colors.orange,
                          dotData: FlDotData(show: false),
                          belowBarData: BarAreaData(show: false),
                        ),
                      ],
                      titlesData: FlTitlesData(
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: true),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: true),
                        ),
                      ),
                    ),
                  ),
                )
              : !bluetoothState.isConnected
              ? const Text("Sem conexão Bluetooth.")
              : const Text("Pressione Start para iniciar o gráfico."),
        ],
      ),
    );
  }
}
