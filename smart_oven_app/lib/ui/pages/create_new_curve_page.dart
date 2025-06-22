import 'package:flutter/material.dart';

class CreateNewCurvePage extends StatefulWidget {
  const CreateNewCurvePage({super.key});

  @override
  State<CreateNewCurvePage> createState() => _CreateNewCurvePageState();
}

class _CreateNewCurvePageState extends State<CreateNewCurvePage> {
  final TextEditingController _initialTempController = TextEditingController();
  final TextEditingController _initialTimeController = TextEditingController();
  final TextEditingController _holdTimeController = TextEditingController();
  final TextEditingController _coolingTimeController = TextEditingController();
  final TextEditingController _finalTempController = TextEditingController();

  void _saveCurve() {
    final temp = _initialTempController.text;
    final time = _initialTimeController.text;
    // Adicione lógica para validar e salvar
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Curva Criada'),
        content: Text('Temperatura inicial: $temp°C\nTempo inicial: $time min'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Criar Nova Curva')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            TextField(
              controller: _initialTempController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Temperatura Inicial (°C)',
              ),
            ),
            TextField(
              controller: _initialTimeController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Tempo Inicial (min)',
              ),
            ),
            TextField(
              controller: _holdTimeController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Tempo em Temperatura (min)',
              ),
            ),
            TextField(
              controller: _coolingTimeController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Tempo de Resfriamento (min)',
              ),
            ),
            TextField(
              controller: _finalTempController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Temperatura Final (°C)',
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveCurve,
              child: const Text('Salvar Curva'),
            ),
          ],
        ),
      ),
    );
  }
}
