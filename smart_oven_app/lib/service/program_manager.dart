import '../model/temperature_curve.dart';
import 'bluetooth.dart';
import 'dart:async';


class OvenProgramManager {

  final OvenBleService _ovenBleService;
  final StreamController<List<double>> _ovenProcessedDataController = StreamController<List<double>>.broadcast();
  final StreamController<int> _ovenProcessedStatusController = StreamController<int>.broadcast();

  StreamSubscription? _ovenDataSubscription;
  StreamSubscription? _ovenStatusSubscription;
  TemperatureCurve? _selectedCurve;

  OvenProgramManager(OvenBleService ovenBleService)
    : _ovenBleService = ovenBleService {
      _ovenDataSubscription = _ovenBleService.ovenDataStream.listen(_processOvenData);
      _ovenStatusSubscription = _ovenBleService.ovenStatusStream.listen(_processOvenStatus);
    }

  void dispose() {
    _ovenDataSubscription?.cancel();
    _ovenStatusSubscription?.cancel();
    _ovenProcessedDataController.close();
    _ovenProcessedStatusController.close();
  }

  Stream<List<double>> get ovenProcessedDataStream => _ovenProcessedDataController.stream;
  Stream<int> get ovenProcessedStatusStream => _ovenProcessedStatusController.stream;

  void selectCurve(TemperatureCurve curveFileName) {
  //Todo Nathy, TemperatureCurve é a seleção da curva
  // Aqui você deve carregar a curva do arquivo ou banco de dados
  }

  void startMonitoring() {
    //Todo Bruno
  }

  void stopMonitoring() {
    //Todo Bruno
  }

  void _processOvenData(List<int> data) {
      // Example: data = [37562, 120500] (temp, time in ms)
      final temp = (data[0] | (data[1] << 8) | (data[2] << 16) | (data[3] << 24)) / 100.0; // 37.562 ºC
      final timeInSeconds = (data[4] | (data[5] << 8) | (data[6] << 16) | (data[7] << 24)) / 100.0; // 120.500 s
      _ovenProcessedDataController.add([temp, timeInSeconds]);

      // Now use the processed values
      print('Temperature: $temp ºC, Time: $timeInSeconds s');
  }

  void _processOvenStatus(List<int> status) {
    _ovenProcessedStatusController.add(status[0]);
    print('Oven status: ${status[0]}');
  }

}
