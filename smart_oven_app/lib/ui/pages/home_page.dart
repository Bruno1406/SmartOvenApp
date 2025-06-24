import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_oven_app/service/bluetooth.dart';
import 'package:smart_oven_app/service/program_manager.dart';
import 'package:fl_chart/fl_chart.dart';

class SmartOvenHome extends StatefulWidget {
  const SmartOvenHome({super.key});

  @override
  State<SmartOvenHome> createState() => SmartOvenHomeState();
}

class SmartOvenHomeState extends State<SmartOvenHome> {

  final List<FlSpot> _graphPoints = [];
  bool _isRunning = true;
  final bool _isCurveSelected = false; 

  double? _lastTemperature;
  double? _lastTime;

  @override
  void dispose() {
    super.dispose();
  }
  Widget _buildMonitoringPannel(OvenProgramManager programManager) {
    return StreamBuilder<List<double>>(
      stream: programManager.ovenProcessedDataStream,
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data!.isNotEmpty) {
          final data = snapshot.data!;
          _lastTemperature = data[0];
          _lastTime = data[1];

          _graphPoints.add(FlSpot(_lastTime!, _lastTemperature!));
        }

        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Display the last known data, or a waiting message.
            if (_lastTemperature != null && _lastTime != null)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text("Temperatura: ${_lastTemperature!.toStringAsFixed(2)}°C"),
                  Text("Tempo: ${_lastTime!.toStringAsFixed(2)} s"),
                ],
              )
            else
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: Text("Aguardando os primeiros dados do forno..."),
              ),
            const SizedBox(height: 20),
        
            SizedBox(
              height: 200, // Giving the chart a fixed height is good practice
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: true),
                  borderData: FlBorderData(show: true),
                  lineBarsData: [
                    LineChartBarData(
                      spots: _graphPoints,
                      isCurved: true,
                      color: Colors.orange,
                      barWidth: 3,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(show: false),
                    ),
                  ],
                  titlesData: const FlTitlesData(
                    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    leftTitles: AxisTitles(
                      axisNameWidget: Text("Temperatura (°C)"),
                      sideTitles: SideTitles(showTitles: true, reservedSize: 40),
                    ),
                    bottomTitles: AxisTitles(
                      axisNameWidget: Text("Tempo (s)"),
                      sideTitles: SideTitles(showTitles: true, reservedSize: 30),
                    ),
                  ),
                ),
              ),
            )
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    var bluetoothState = context.watch<OvenBleService>();
    var programManager = context.watch<OvenProgramManager>();

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                ElevatedButton(
                  onPressed: () {
                    if (!bluetoothState.isConnected) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Erro: Sem conexão Bluetooth")),
                      );
                      return;
                    }

                    if (!_isCurveSelected) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Erro: Selecione uma curva de temperatura")),
                      );
                      return;
                    }
                    
                    // Reset state for a new run
                    setState(() {
                      _isRunning = true;
                      _graphPoints.clear();
                      _lastTemperature = null;
                      _lastTime = null;
                    });
                    programManager.startMonitoring();
                  },
                  child: const Text('Start'),
                ),
                 ElevatedButton(
                  onPressed: () {
                    // Logic to stop monitoring
                    setState(() {
                      _isRunning = false;
                    });
                    programManager.stopMonitoring(); // Assuming you have a stop method
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  child: const Text('Stop'),
                ),
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
            // The main content area that changes based on the running state.
            Expanded(
              child: _isRunning
                  ? _buildMonitoringPannel(programManager)
                  : Center(
                      child: !bluetoothState.isConnected
                          ? const Text("Sem conexão Bluetooth.")
                          : const Text("Pressione Start para iniciar o monitoramento."),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}