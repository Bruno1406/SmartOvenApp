import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../model/temperature_curve.dart';

class CurveDetailPage extends StatelessWidget {
  final TemperatureCurve curve;

  const CurveDetailPage({super.key, required this.curve});

  List<FlSpot> _generateCurve() {
    final double t1 = curve.heatingTime;
    final double t2 = t1 + curve.holdTime;
    final double t3 = t2 + curve.coolingTime;

    final double y1 = curve.targetTemperature;
    final double y2 = curve.finalTemperature;

    return [
      FlSpot(0, 25), // Começa em 25°C no tempo 0
      FlSpot(t1, y1),
      FlSpot(t2, y1),
      FlSpot(t3, y2),
      ];
  }


   Widget _buildGraph() {
    final points = _generateCurve();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(bottom: 8.0),
          child: Text(
            'Curva de Temperatura',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        SizedBox(
          height: 250,
          child: LineChart(
            LineChartData(
              minX: 0,
              maxX: points.last.x + 1,
              minY: 20,
              maxY: points.map((e) => e.y).reduce((a, b) => a > b ? a : b) + 10,
              gridData: FlGridData(show: true),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  axisNameWidget: const Text('Temperatura (°C)'),
                  axisNameSize: 28,
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 40,
                    interval: 10,
                    getTitlesWidget: (value, meta) {
                      return Text(
                        '${value.toInt()}',
                        style: const TextStyle(fontSize: 10),
                      );
                    },
                  ),
                ),
                bottomTitles: AxisTitles(
                  axisNameWidget: const Text('Tempo (min)'),
                  axisNameSize: 28,
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 32,
                    interval: 5,
                    getTitlesWidget: (value, meta) {
                      return Text(
                        '${value.toInt()}',
                        style: const TextStyle(fontSize: 10),
                      );
                    },
                  ),
                ),
                topTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                rightTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
              ),
              borderData: FlBorderData(show: true),
              lineBarsData: [
                LineChartBarData(
                  spots: points,
                  isCurved: false,
                  barWidth: 3,
                  color: Colors.deepOrange,
                  dotData: FlDotData(show: true),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

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

//todo fazer botão e voltar para a pagina inicial e volta para a select curve
