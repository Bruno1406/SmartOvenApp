import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../model/temperature_curve.dart';
import '../../service/files.dart';
import '../../service/program_manager.dart';

class CreateNewCurvePage extends StatefulWidget {
  const CreateNewCurvePage({super.key});

  @override
  State<CreateNewCurvePage> createState() => _CreateNewCurvePageState();
}

class _CreateNewCurvePageState extends State<CreateNewCurvePage> {
  final _formKey = GlobalKey<FormState>();

  final nomeController = TextEditingController();
  final tempFinalController = TextEditingController();
  final tempAlvoController = TextEditingController();
  final tempoSubidaController = TextEditingController();
  final tempoManterController = TextEditingController();
  final tempoResfriarController = TextEditingController();

  bool _showGraph = false;
  bool _salvarCurva = false;

  @override
  void dispose() {
    nomeController.dispose();
    tempFinalController.dispose();
    tempAlvoController.dispose();
    tempoSubidaController.dispose();
    tempoManterController.dispose();
    tempoResfriarController.dispose();
    super.dispose();
  }

  List<FlSpot> _generateCurve() {
    final double t1 = double.parse(tempoSubidaController.text);
    final double t2 = t1 + double.parse(tempoManterController.text);
    final double t3 = t2 + double.parse(tempoResfriarController.text);

    final double y1 = double.parse(tempAlvoController.text);
    final double y2 = double.parse(tempFinalController.text);

    return [
      FlSpot(0, 25), // Começa em 25°C no tempo 0
      FlSpot(t1, y1),
      FlSpot(t2, y1),
      FlSpot(t3, y2),
    ];
  }

  void _onSubmit() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _showGraph = true;
      });
    }
  }

  Future<void> _onSaveCurve() async {
    final points = _generateCurve();
    final times = points.map((e) => e.x).toList();
    final temps = points.map((e) => e.y).toList();

    final curve = TemperatureCurve(
      name: nomeController.text.trim(),
      targetTemperature: double.parse(tempAlvoController.text),
      finalTemperature: double.parse(tempFinalController.text),
      heatingTime: double.parse(tempoSubidaController.text),
      holdTime: double.parse(tempoManterController.text),
      coolingTime: double.parse(tempoResfriarController.text),
      times: times,
      temperatures: temps,
    );

    OvenProgramManager.selectCurveFromObject(curve);

    if (_salvarCurva) {
      await CurveFileService.saveCurve(curve);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _salvarCurva
              ? 'Curva salva e pronta para execução!'
              : 'Curva pronta para execução (não salva)',
        ),
      ),
    );

    // 🔽 PRINT da curva no terminal
    print(
      '============================= Curva enviada ==========================',
    );
    print('Nome: ${curve.name}');
    print('Tempos: ${curve.times}');
    print('Temperaturas: ${curve.temperatures}');
    print('=============================================================');

    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  Widget _buildNameInput() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: nomeController,
        keyboardType: TextInputType.text,
        decoration: InputDecoration(
          labelText: 'Nome da Curva',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return 'Insira um nome válido';
          }
          return null;
        },
      ),
    );
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
    return Scaffold(
      appBar: AppBar(title: const Text('Criar Nova Curva')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildNameInput(),
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
              _buildInput('Temperatura final', tempFinalController, '°C'),
              _buildInput(
                'Tempo de resfriamento',
                tempoResfriarController,
                'min',
              ),
              const SizedBox(height: 10),
              CheckboxListTile(
                title: const Text('Salvar esta curva?'),
                value: _salvarCurva,
                onChanged: (value) {
                  setState(() {
                    _salvarCurva = value ?? false;
                  });
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _onSubmit,
                icon: const Icon(Icons.show_chart),
                label: const Text('Gerar Curva'),
              ),
              if (_showGraph) ...[
                const SizedBox(height: 30),
                _buildGraph(),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _onSaveCurve,
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
