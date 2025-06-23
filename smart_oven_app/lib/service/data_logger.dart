import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class DataLogger {
  /// Salva os dados da curva em formato JSON
  static Future<void> saveAsJson(
    String curveName,
    List<double> times,
    List<double> temperatures,
  ) async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/report_$curveName.json');
    final data = {
      'name': curveName,
      'data': List.generate(
        times.length,
        (i) => {'time': times[i], 'temperature': temperatures[i]},
      ),
    };
    await file.writeAsString(jsonEncode(data));
  }

  /// Salva os dados da curva em formato CSV
  static Future<void> saveAsCsv(
    String curveName,
    List<double> times,
    List<double> temperatures,
  ) async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/report_$curveName.csv');
    final buffer = StringBuffer();
    buffer.writeln('Time,Temperature');

    for (int i = 0; i < times.length; i++) {
      buffer.writeln('${times[i]},${temperatures[i]}');
    }

    await file.writeAsString(buffer.toString());
  }
}
