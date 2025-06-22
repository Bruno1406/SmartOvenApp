import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
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
  double _currentTemperature = 0.0;
  double _currentTime = 0.0;
  late Timer _timer;
  final List<FlSpot> _graphPoints = [];

  @override
  void initState() {
    super.initState();
    _checkBluetoothConnection();
  }

  Future<void> _checkBluetoothConnection() async {
    final connectedDevices = await FlutterBluePlus.connectedDevices;
    setState(() {
      _isConnected = connectedDevices.isNotEmpty;
    });
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

    _timer = Timer.periodic(const Duration(seconds: 3), (timer) async {
      // 🔄 Simulação de leitura Bluetooth (substitua por dados reais!) TODO @BRUNO
      double simulatedTemp = 100 + 20 * sin(_currentTime / 10);

      setState(() {
        _currentTemperature = simulatedTemp;
        _graphPoints.add(FlSpot(_currentTime, _currentTemperature));
        _currentTime += 3;
      });
    });
  }

  @override
  void dispose() {
    if (_isRunning) _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          ElevatedButton.icon(
            icon: const Icon(Icons.show_chart),
            label: const Text('Selecionar/Criar Curva'),
            onPressed: () {
              Navigator.pushNamed(context, '/curve-options');
            },
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            icon: const Icon(Icons.play_arrow),
            label: const Text('Start'),
            onPressed: _isRunning ? null : _startMonitoring,
          ),
          const SizedBox(height: 20),
          Text("Temperatura: ${_currentTemperature.toStringAsFixed(1)} °C"),
          Text("Tempo: ${_currentTime.toStringAsFixed(0)} s"),
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
              : !_isConnected
              ? const Text("Sem conexão Bluetooth.")
              : const Text("Pressione Start para iniciar o gráfico."),
        ],
      ),
    );
  }
}
