import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class CreateNewCurvePage extends StatefulWidget {
  const CreateNewCurvePage({super.key});

  @override
  State<CreateNewCurvePage> createState() => _CreateNewCurvePageState();
}

class _CreateNewCurvePageState extends State<CreateNewCurvePage> {
  final _formKey = GlobalKey<FormState>();

  final tempFinalController = TextEditingController();
  final tempAlvoController = TextEditingController();
  final tempoSubidaController = TextEditingController();
  final tempoManterController = TextEditingController();
  final tempoResfriarController = TextEditingController();

  bool _showGraph = false;

  List<FlSpot> _generateCurve() {
    final double t1 = double.parse(tempoSubidaController.text);
    final double t2 = t1 + double.parse(tempoManterController.text);
    final double t3 = t2 + double.parse(tempoResfriarController.text);

    final double y1 = double.parse(tempAlvoController.text);
    final double y2 = double.parse(tempFinalController.text);

    return [const FlSpot(0, 0), FlSpot(t1, y1), FlSpot(t2, y1), FlSpot(t3, y2)];
  }

  void _onSubmit() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _showGraph = true;
      });
    }
  }

  @override
  void dispose() {
    tempFinalController.dispose();
    tempAlvoController.dispose();
    tempoSubidaController.dispose();
    tempoManterController.dispose();
    tempoResfriarController.dispose();
    super.dispose();
  }

  Widget _buildInput(
    String label,
    TextEditingController controller,
    String suffix,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          labelText: label,
          suffixText: suffix,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) return 'Preencha este campo';
          final n = double.tryParse(value);
          if (n == null) return 'Digite um número válido';
          return null;
        },
      ),
    );
  }

  Widget _buildGraph() {
    final points = _generateCurve();

    return SizedBox(
      height: 250,
      child: LineChart(
        LineChartData(
          minX: 0,
          maxX: points.last.x + 1,
          minY: 0,
          maxY: points.map((e) => e.y).reduce((a, b) => a > b ? a : b) + 10,
          gridData: FlGridData(show: true),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: true, reservedSize: 40),
            ),
            bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true)),
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Criar Nova Curva')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildInput('Temperatura desejada', tempAlvoController, '°C'),
              _buildInput(
                'Tempo para atingir temperatura',
                tempoSubidaController,
                'min',
              ),
              _buildInput(
                'Tempo para manter temperatura',
                tempoManterController,
                'min',
              ),
              _buildInput(
                'Tempo de resfriamento',
                tempoResfriarController,
                'min',
              ),
              _buildInput('Temperatura final', tempFinalController, '°C'),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _onSubmit,
                child: const Text('Gerar Curva'),
              ),
              if (_showGraph) ...[
                const SizedBox(height: 30),
                _buildGraph(),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    // Enviar a curva — neste ponto você pode salvar em arquivo ou enviar para backend
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Curva enviada com sucesso!'),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text(
                    'Enviar Curva',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
