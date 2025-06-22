import 'package:flutter/material.dart';

class TemperatureCurveOptionsPage extends StatelessWidget {
  const TemperatureCurveOptionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Curvas de Temperatura')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/existing-curves');
              },
              child: const Text('Selecionar Curva Existente'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/create-new-curve');
              },
              child: const Text('Criar Nova Curva'),
            ),
          ],
        ),
      ),
    );
  }
}
