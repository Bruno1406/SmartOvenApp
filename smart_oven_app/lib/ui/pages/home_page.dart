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
  bool _isRunning = false;

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
          children: [
            if (_lastTemperature != null && _lastTime != null)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text(
                    "Temperatura: ${_lastTemperature!.toStringAsFixed(2)}°C",
                  ),
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
              height: 200,
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
                    ),
                  ],
                  titlesData: const FlTitlesData(
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    leftTitles: AxisTitles(
                      axisNameWidget: Text("Temperatura (°C)"),
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      axisNameWidget: Text("Tempo (s)"),
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void _startMonitoring(
    OvenProgramManager manager,
    OvenBleService bluetoothService,
  ) {
    if (!bluetoothService.isBluetoothOn) {
      _showError("Erro: Bluetooth está desligado");
      return;
    }

    if (!bluetoothService.isConnected) {
      _showError("Erro: Dispositivo não conectado via Bluetooth");
      return;
    }

    if (manager.selectedCurve == null) {
      _showError("Erro: Nenhuma curva de temperatura foi selecionada");
      return;
    }

    setState(() {
      _isRunning = true;
      _graphPoints.clear();
      _lastTemperature = null;
      _lastTime = null;
    });

    manager.startMonitoring();
  }

  void _stopMonitoring(
    OvenProgramManager manager,
    OvenBleService bluetoothService,
  ) {
    if (!bluetoothService.isBluetoothOn || !bluetoothService.isConnected) {
      _showError("Erro: Bluetooth não está conectado");
      return;
    }

    setState(() {
      _isRunning = false;
    });

    manager.stopMonitoring();
  }

  @override
  Widget build(BuildContext context) {
    var bluetooth = context.watch<OvenBleService>();
    var programManager = context.watch<OvenProgramManager>();

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                ElevatedButton(
                  onPressed: () => _startMonitoring(programManager, bluetooth),
                  child: const Text('Start'),
                ),
                ElevatedButton(
                  onPressed: () => _stopMonitoring(programManager, bluetooth),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  child: const Text('Stop'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: bluetooth.isConnected
                  ? () => Navigator.pushNamed(
                      context,
                      '/temperature-curve-options',
                    )
                  : () => _showError(
                      "Erro: Conecte-se ao forno via Bluetooth primeiro",
                    ),
              child: const Text("Selecionar Curva de Temperatura"),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: _isRunning
                  ? _buildMonitoringPannel(programManager)
                  : Center(
                      child: !bluetooth.isConnected
                          ? const Text("Sem conexão Bluetooth.")
                          : (!programManager.isCurveSelected
                                ? const Text(
                                    "Selecione uma curva de temperatura.",
                                  )
                                : const Text(
                                    "Pressione Start para iniciar o monitoramento.",
                                  )),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
