import '../model/temperature_curve.dart';
import 'bluetooth.dart';
import '../service/files.dart';

// class ProgramManager {
//   static TemperatureCurve? _selectedCurve;
//   static bool _isRunning = false;

//   static TemperatureCurve? get selectedCurve => _selectedCurve;
//   static bool get isRunning => _isRunning;

//   /// Define a curva atual que será usada no programa
//   static void selectCurve(TemperatureCurve curve) {
//     _selectedCurve = curve;
//     _isRunning = false;
//   }

//   /// Inicia o envio da curva para o dispositivo via Bluetooth
//   static Future<void> startProgram() async {
//     if (_selectedCurve == null) return;

//     _isRunning = true;

//     final steps = generateProgramSteps();
//     for (var step in steps) {
//       if (!_isRunning) break;

//       // Envia tempo e temperatura desejada
//       await BluetoothService.sendStep(step['time']!, step['temperature']!);

//       // Aguarda resposta/atualização do Bluetooth (ex: temperatura real)
//       final tempAtual = await BluetoothService.receiveTemperature();

//       // Aqui você pode armazenar ou processar a resposta recebida
//       print('Recebido: $tempAtual °C');
//     }

//     _isRunning = false;
//   }

//   /// Interrompe o programa
//   static void stopProgram() {
//     _isRunning = false;
//   }

//   /// Gera os passos a partir da curva
//   static List<Map<String, double>> generateProgramSteps() {
//     if (_selectedCurve == null) return [];

//     final curve = _selectedCurve!;
//     final steps = <Map<String, double>>[];

//     for (int i = 0; i < curve.times.length; i++) {
//       steps.add({'time': curve.times[i], 'temperature': curve.temperatures[i]});
//     }

//     return steps;
//   }
// }

class OvenProgramManager {
  static TemperatureCurve? _selectedCurve;

  /// Seleciona uma curva com base no nome do arquivo salvo (.json)
  static Future<void> selectCurve(String curveFileName) async {
    try {
      final curve = await CurveFileService.loadCurve(curveFileName);
      _selectedCurve = curve;
    } catch (e) {
      print("Erro ao carregar curva: $e");
      _selectedCurve = null;
    }
  }

  /// Seleciona uma curva diretamente do objeto TemperatureCurve (sem salvar no disco)
  static void selectCurveFromObject(TemperatureCurve curve) {
    _selectedCurve = curve;
  }

  /// Getter para obter a curva selecionada
  static TemperatureCurve? get selectedCurve => _selectedCurve;

  static sendCurve() {
    //Todo Bruno
  }
}
