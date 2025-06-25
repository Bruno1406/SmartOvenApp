import '../model/temperature_curve.dart';
import 'bluetooth.dart';
import 'dart:async';
import 'files.dart'; // <-- Certifique-se de importar corretamente

class OvenProgramManager {
  final OvenBleService _ovenBleService;

  final StreamController<List<double>> _ovenProcessedDataController =
      StreamController<List<double>>.broadcast();
  final StreamController<int> _ovenProcessedStatusController =
      StreamController<int>.broadcast();

  StreamSubscription? _ovenDataSubscription;
  StreamSubscription? _ovenStatusSubscription;
  static TemperatureCurve? _selectedCurve;

  OvenProgramManager(this._ovenBleService) {
    _ovenDataSubscription = _ovenBleService.ovenDataStream.listen(
      _processOvenData,
    );
    _ovenStatusSubscription = _ovenBleService.ovenStatusStream.listen(
      _processOvenStatus,
    );
  }

  // Selecionar curva por nome do arquivo
  static Future<void> selectCurve(String curveFileName) async {
    try {
      final curve = await CurveFileService.loadCurve(curveFileName);
      _selectedCurve = curve;
    } catch (e) {
      print("Erro ao carregar curva: $e");
      _selectedCurve = null;
    }
  }

  // Selecionar curva diretamente
  static void selectCurveFromObject(TemperatureCurve curve) {
    _selectedCurve = curve;
  }

  // Getter da curva selecionada
  static TemperatureCurve? get selectedCurve => _selectedCurve;

  // Monitoramento
  void startMonitoring() {
    print("Monitoramento iniciado.");
    // Adicione lógica aqui
  }

  void stopMonitoring() {
    print("Monitoramento parado.");
    // Adicione lógica aqui
  }

  void _processOvenData(List<int> data) {
    final temp =
        (data[0] | (data[1] << 8) | (data[2] << 16) | (data[3] << 24)) / 100.0;
    final timeInSeconds =
        (data[4] | (data[5] << 8) | (data[6] << 16) | (data[7] << 24)) / 100.0;
    _ovenProcessedDataController.add([temp, timeInSeconds]);

    print('Temperature: $temp ºC, Time: $timeInSeconds s');
  }

  void _processOvenStatus(List<int> status) {
    _ovenProcessedStatusController.add(status[0]);
    print('Oven status: ${status[0]}');
  }

  Stream<List<double>> get ovenProcessedDataStream =>
      _ovenProcessedDataController.stream;

  Stream<int> get ovenProcessedStatusStream =>
      _ovenProcessedStatusController.stream;

  void dispose() {
    _ovenDataSubscription?.cancel();
    _ovenStatusSubscription?.cancel();
    _ovenProcessedDataController.close();
    _ovenProcessedStatusController.close();
  }
}
