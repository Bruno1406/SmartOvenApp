import 'package:flutter/material.dart';

import '../../model/temperature_curve.dart';
import '../../service/files.dart';
import '../../service/program_manager.dart';
import 'curve_detail_page.dart';

class ExistingCurvesPage extends StatefulWidget {
  const ExistingCurvesPage({super.key});

  @override
  State<ExistingCurvesPage> createState() => _ExistingCurvesPageState();
}

class _ExistingCurvesPageState extends State<ExistingCurvesPage> {
  List<TemperatureCurve> _curves = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCurves();
  }

  Future<void> _loadCurves() async {
    final allCurves = await CurveFileService.loadAllCurves();
    setState(() {
      _curves = allCurves;
      _isLoading = false;
    });
  }

  Future<void> _onCurveTap(TemperatureCurve curve) async {
    final fileName = '${curve.name}.json';

    try {
      await OvenProgramManager.selectCurve(fileName);

      // Agora podemos navegar para a tela de detalhes
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => CurveDetailPage(curve: curve)),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao carregar a curva selecionada.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Curvas Existentes')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _curves.isEmpty
          ? const Center(child: Text('Nenhuma curva encontrada.'))
          : ListView.builder(
              itemCount: _curves.length,
              itemBuilder: (context, index) {
                final curve = _curves[index];
                return ListTile(
                  leading: const Icon(Icons.thermostat),
                  title: Text(curve.name),
                  subtitle: Text("Criada em: ${curve.createdAt.toLocal()}"),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CurveDetailPage(curve: curve),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
