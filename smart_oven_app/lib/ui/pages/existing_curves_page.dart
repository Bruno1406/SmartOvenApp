import 'package:flutter/material.dart';

class ExistingCurvesPage extends StatelessWidget {
  final List<String> curves = [
    "Curva A - Resina epóxi",
    "Curva B - Resina poliéster",
    "Curva C - Resina breu",
  ];

  ExistingCurvesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Curvas Existentes')),
      body: ListView.builder(
        itemCount: curves.length,
        itemBuilder: (context, index) {
          return ListTile(
            leading: const Icon(Icons.thermostat),
            title: Text(curves[index]),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Selecionado: ${curves[index]}')),
              );
              Navigator.pop(context); // Volta para home com seleção feita
            },
          );
        },
      ),
    );
  }
}
