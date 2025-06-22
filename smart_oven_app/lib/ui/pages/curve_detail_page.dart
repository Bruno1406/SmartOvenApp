import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../model/temperature_curve.dart';

class CurveDetailPage extends StatelessWidget {
  final TemperatureCurve curve;

  const CurveDetailPage({super.key, required this.curve});

  @override
  Widget build(BuildContext context) {
    final spots = List.generate(
      curve.times.length,
      (i) => FlSpot(curve.times[i], curve.temperatures[i]),
    );

    return Scaffold(
      appBar: AppBar(title: Text(curve.name)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              "Temperatura alvo: ${curve.targetTemperature} °C\n"
              "Tempo de aquecimento: ${curve.heatingTime} s\n"
              "Tempo de manutenção: ${curve.holdTime} s\n"
              "Tempo de resfriamento: ${curve.coolingTime} s\n"
              "Temperatura final: ${curve.finalTemperature} °C",
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: LineChart(
                LineChartData(
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      color: Colors.deepOrange,
                      dotData: FlDotData(show: false),
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
            ),
          ],
        ),
      ),
    );
  }
}
