import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
  double _currentTemperature = 0.0;
  double _currentTime = 0.0;
  late Timer _timer;
  final List<FlSpot> _graphPoints = [];

  @override
  void dispose() {
    if (_isRunning) _timer.cancel();
    super.dispose();
  }

  void _startMonitoring() {
    final bluetoothState = context.read<OvenBleService>();

    if (!bluetoothState.isConnected) {
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

    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      // 🔄 Simulação — substitua por leitura real do Bluetooth
      double simulatedTemp = 100 + 20 * sin(_currentTime / 10);

      setState(() {
        _currentTemperature = simulatedTemp;
        _graphPoints.add(FlSpot(_currentTime, _currentTemperature));
        _currentTime += 3;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final bluetoothState = context.watch<OvenBleService>();

    return Scaffold(
      appBar: AppBar(title: const Text("Smart Oven")),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  ElevatedButton(
                    onPressed: _isRunning ? null : _startMonitoring,
                    child: const Text('Start'),
                  ),
                  Text(
                    "Temperatura: ${_currentTemperature.toStringAsFixed(1)}°C",
                  ),
                  Text("Tempo: ${_currentTime.toInt()} s"),
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
              Expanded(
                child: _isRunning
                    ? LineChart(
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
                      )
                    : bluetoothState.isConnected
                    ? const Text("Pressione Start para iniciar o gráfico.")
                    : const Text("Sem conexão Bluetooth."),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
