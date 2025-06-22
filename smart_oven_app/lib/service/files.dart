import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../model/temperature_curve.dart';

class CurveFileService {
  /// Salva uma curva no armazenamento como um arquivo .json
  static Future<void> saveCurve(TemperatureCurve curve) async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/${curve.name}.json');

    final jsonData = jsonEncode(curve.toJson());
    await file.writeAsString(jsonData);
  }

  /// Carrega todas as curvas salvas no armazenamento
  static Future<List<TemperatureCurve>> loadAllCurves() async {
    final dir = await getApplicationDocumentsDirectory();
    final files = dir.listSync().where((f) => f.path.endsWith('.json'));

    final List<TemperatureCurve> curves = [];

    for (var file in files) {
      final content = await File(file.path).readAsString();
      final json = jsonDecode(content);
      curves.add(TemperatureCurve.fromJson(json));
    }

    return curves;
  }

  /// Carrega uma curva específica pelo nome do arquivo
  static Future<TemperatureCurve> loadCurve(String fileName) async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/$fileName');
    final content = await file.readAsString();
    final json = jsonDecode(content);
    return TemperatureCurve.fromJson(json);
  }
}
