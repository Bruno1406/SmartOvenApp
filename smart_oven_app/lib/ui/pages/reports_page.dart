import 'package:flutter/material.dart';
import '../../model/temperature_curve.dart';
import '../../service/files.dart';
import 'curve_detail_page.dart';

class SmartOvenReportsPage extends StatefulWidget {
  const SmartOvenReportsPage({super.key});

  @override
  State<SmartOvenReportsPage> createState() => _SmartOvenReportsPageState();
}

class _SmartOvenReportsPageState extends State<SmartOvenReportsPage> {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Relatórios')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _curves.isEmpty
          ? const Center(child: Text('Nenhum relatório disponível.'))
          : ListView.builder(
              itemCount: _curves.length,
              itemBuilder: (context, index) {
                final curve = _curves[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 8.0,
                    vertical: 4.0,
                  ),
                  child: ListTile(
                    leading: const Icon(Icons.receipt_long),
                    title: Text(curve.name),
                    subtitle: Text("Criado em: ${curve.createdAt.toLocal()}"),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16.0),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => CurveDetailPage(curve: curve),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}
