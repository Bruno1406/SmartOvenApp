import '../model/temperature_curve.dart';
import 'bluetooth.dart';
import 'dart:async';
import 'files.dart'; // <-- Certifique-se de importar corretamente
import 'package:flutter/foundation.dart';

class OvenProgramManager extends ChangeNotifier {
  final OvenBleService _ovenBleService;

  final StreamController<List<double>> _ovenProcessedDataController =
      StreamController<List<double>>.broadcast();
  final StreamController<int> _ovenProcessedStatusController =
      StreamController<int>.broadcast();
  bool isCurveSelected = false;

  StreamSubscription? _ovenDataSubscription;
  StreamSubscription? _ovenStatusSubscription;
  TemperatureCurve? _selectedCurve;

  OvenProgramManager(this._ovenBleService) {
    _ovenDataSubscription = _ovenBleService.ovenDataStream.listen(
      _processOvenData,
    );
    _ovenStatusSubscription = _ovenBleService.ovenStatusStream.listen(
      _processOvenStatus,
    );
  }

  // Selecionar curva por nome do arquivo
  Future<void> selectCurve(String curveFileName) async {
    try {
      final curve = await CurveFileService.loadCurve(curveFileName);
      _selectedCurve = curve;
      await _sendCurve();
      isCurveSelected = true;
      notifyListeners(); // Notifica os ouvintes sobre a mudança
    } catch (e) {
      print("Erro ao carregar curva: $e");
      _selectedCurve = null;
    }
  }

  // Selecionar curva diretamente
  void selectCurveFromObject(TemperatureCurve curve) {
    _selectedCurve = curve;
  }

  // Getter da curva selecionada
  TemperatureCurve? get selectedCurve => _selectedCurve;

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
        (data[4] | (data[5] << 8) | (data[6] << 16) | (data[7] << 24)) / 1000.0;
    _ovenProcessedDataController.add([temp, timeInSeconds]);

    print('Temperature: $temp ºC, Time: $timeInSeconds s');
  }

  void _processOvenStatus(List<int> status) {
    _ovenProcessedStatusController.add(status[0]);
    print('Oven status: ${status[0]}');
  }

  Future<void> _sendCurve() async{
    if (_selectedCurve == null) {
      throw Exception("No curve selected");
    }

    final serialized = <int>[];

    // Serializa os pontos da curva
    final targetTemp = (_selectedCurve!.targetTemperature * 100).toInt();
    final finalTemp = (_selectedCurve!.finalTemperature * 100).toInt();
    final heatingTime = (_selectedCurve!.heatingTime * 6000).toInt();
    final holdTime = (_selectedCurve!.holdTime * 60000).toInt();
    final coolingTime = (_selectedCurve!.coolingTime * 60000).toInt();

    serialized.addAll([
      targetTemp & 0xFF,
      (targetTemp >> 8) & 0xFF,
      (targetTemp >> 16) & 0xFF,
      (targetTemp >> 24) & 0xFF,
      finalTemp & 0xFF,
      (finalTemp >> 8) & 0xFF,
      (finalTemp >> 16) & 0xFF,
      (finalTemp >> 24) & 0xFF,
      heatingTime & 0xFF,
      (heatingTime >> 8) & 0xFF,
      (heatingTime >> 16) & 0xFF,
      (heatingTime >> 24) & 0xFF,
      holdTime & 0xFF,
      (holdTime >> 8) & 0xFF,
      (holdTime >> 16) & 0xFF,
      (holdTime >> 24) & 0xFF,
      coolingTime & 0xFF,
      (coolingTime >> 8) & 0xFF,
      (coolingTime >> 16) & 0xFF,
      (coolingTime >> 24) & 0xFF
    ]);

    await _ovenBleService.writeToOvenProgramCharacteristic(serialized);

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
