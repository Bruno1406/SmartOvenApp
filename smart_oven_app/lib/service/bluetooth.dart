import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter/foundation.dart';
import 'dart:async';

const String serviceUuid = "ffe0";
const String dataCharUuid = "ffe1";
const String programCharUuid = "ffe2";
const String statusCharUuid = "ffe3";

// A simple data class to hold only the information the UI needs.
class DiscoveredDevice {
  final DeviceIdentifier id;
  final String name;

  DiscoveredDevice({required this.id, required this.name});
}

class OvenBleService extends ChangeNotifier {
  StreamSubscription<BluetoothAdapterState>? _adapterStateSubscription;
  StreamSubscription<List<ScanResult>>? _scanResultsSubscription;
  StreamSubscription<BluetoothConnectionState>? _connectionStateSubscription;
  StreamSubscription<List<int>>? _ovenDataCharacteristicSubscription;
  StreamSubscription<List<int>>? _ovenStatusCharacteristicSubscription;
  BluetoothCharacteristic? _ovenProgramCharacteristic;
  final StreamController<List<int>> _ovenDataController =
      StreamController<List<int>>.broadcast();
  final StreamController<List<int>> _ovenStatusController =
      StreamController<List<int>>.broadcast();

  final Map<DeviceIdentifier, ScanResult> _scanResults = {};

  bool isBluetoothOn = false;
  bool isConnected = false;
  bool isScanning = false;

  OvenBleService() {
    _initializeBluetooth();
  }

  // This method is automatically called when the ChangeNotifier is disposed.
  @override
  void dispose() {
    // It's crucial to cancel all subscriptions when the service is no longer needed.
    _adapterStateSubscription?.cancel();
    _scanResultsSubscription?.cancel();
    _connectionStateSubscription?.cancel();
    _ovenDataCharacteristicSubscription?.cancel();
    print("BluetoothService disposed, all subscriptions cancelled.");
    super.dispose();
  }

  List<DiscoveredDevice> get discoveredDevices {
    return _scanResults.values.map((scanResult) {
      String displayName = scanResult.advertisementData.advName;
      if (displayName.isEmpty) {
        displayName = scanResult.device.remoteId.toString();
      }

      return DiscoveredDevice(
        id: scanResult.device.remoteId,
        name: displayName,
      );
    }).toList();
  }

  Stream<List<int>> get ovenDataStream => _ovenDataController.stream;

  Stream<List<int>> get ovenStatusStream => _ovenStatusController.stream;

  BluetoothCharacteristic get ovenProgramCharacteristic {
    if (_ovenProgramCharacteristic == null) {
      throw Exception("Oven program characteristic not initialized");
    }
    return _ovenProgramCharacteristic!;
  }

  Future<void> _initializeBluetooth() async {
    FlutterBluePlus.setLogLevel(LogLevel.verbose, color: true);

    if (await FlutterBluePlus.isSupported == false) {
      print("Bluetooth not supported by this device");
      return;
    }

    _adapterStateSubscription = FlutterBluePlus.adapterState.listen((
      BluetoothAdapterState state,
    ) {
      isBluetoothOn = (state == BluetoothAdapterState.on);
      notifyListeners(); // Notify listeners about the state change
    });
  }

  Future<void> startScanning() async {
    if (isScanning) return; // Don't start a scan if one is already running.

    isScanning = true;
    notifyListeners();

    _scanResults.clear(); // Clear previous results before a new scan.

    // Cancel any previous subscription before creating a new one.
    await _scanResultsSubscription?.cancel();
    _scanResultsSubscription = FlutterBluePlus.scanResults.listen((results) {
      // Update the map with the latest results.
      for (ScanResult r in results) {
        _scanResults[r.device.remoteId] = r;
      }
      notifyListeners(); // Notify UI about the new devices.
    }, onError: (e) => print(e));

    // Start scanning
    await FlutterBluePlus.startScan(timeout: const Duration(seconds: 5));

    // Wait for scanning to stop and update the state.
    await FlutterBluePlus.isScanning.where((val) => val == false).first;
    isScanning = false;
    notifyListeners();
  }

  Future<void> connectToDevice(DeviceIdentifier deviceId) async {
    final result = _scanResults[deviceId];
    if (result == null) {
      print("Device not found in scan results");
      return;
    }

    final device = result.device;

    await _connectionStateSubscription?.cancel();
    _connectionStateSubscription = device.connectionState.listen((
      BluetoothConnectionState state,
    ) {
      isConnected = (state == BluetoothConnectionState.connected);
      if (state == BluetoothConnectionState.disconnected) {
        print(
          "Disconnected: ${device.disconnectReason?.code} ${device.disconnectReason?.description}",
        );
      }
      notifyListeners();
    });

    device.cancelWhenDisconnected(
      _connectionStateSubscription!,
      delayed: true,
      next: true,
    );

    // Connect to the device
    try {
      print("Connecting to ${device.remoteId}...");
      await device.connect();
      print("Connection successful!");

      List<BluetoothService> services = await device.discoverServices();
      for (BluetoothService service in services) {
        final serviceId = service.uuid.toString().toLowerCase();
        print("Service found: $serviceId");

        if (serviceId == serviceUuid) {
          for (BluetoothCharacteristic characteristic
              in service.characteristics) {
            final charId = characteristic.uuid.toString().toLowerCase();
            print("Characteristic found: $charId");

            if (charId == dataCharUuid) {
              // Cancel previous subscription if any
              _ovenDataCharacteristicSubscription?.cancel();

              // Listen to incoming data
              await characteristic.setNotifyValue(true);
              _ovenDataCharacteristicSubscription = characteristic
                  .onValueReceived
                  .listen((data) {
                    print("Data received: $data");
                    _ovenDataController.add(data);
                  });
              // Auto-cancel subscription when disconnected
              device.cancelWhenDisconnected(
                _ovenDataCharacteristicSubscription!,
              );
              print("Notification enabled for data characteristic.");
            } else if (charId == statusCharUuid) {
              // Assuming this is the status characteristic
              await characteristic.setNotifyValue(true);
              _ovenStatusCharacteristicSubscription = characteristic
                  .onValueReceived
                  .listen((data) {
                    print("Status data received: $data");
                    _ovenStatusController.add(data);
                  });
              device.cancelWhenDisconnected(
                _ovenStatusCharacteristicSubscription!,
              );
              print("Notification enabled for status characteristic.");
            } else if (charId == programCharUuid) {
              _ovenProgramCharacteristic = characteristic;
              print("Program characteristic assigned: $charId");
            }
          }
        }
      }
    } catch (e) {
      print("❌ ERROR connecting to device: $e");
    }
  }

  Future<void> writeToOvenProgramCharacteristic(List<int> data) async {
    if (_ovenProgramCharacteristic == null) {
      print("Oven program characteristic not found");
      return;
    }

    try {
      for (int i = 0; i < 10; i++) {
        await _ovenProgramCharacteristic!.write(data, withoutResponse: false);
        print("Data written to oven program characteristic: $data");

        // Small delay to allow device to update its characteristic (optional, depends on device)
        await Future.delayed(const Duration(milliseconds: 100));

        // Read the characteristic value back
        List<int> readData = await _ovenProgramCharacteristic!.read();
        print("Data read back from oven program characteristic: $readData");

        // Compare sent and received data
        if (readData.length == data.length && _listEquals(readData, data)) {
          print("Message confirmed successfully on attempt ${i + 1}");
          return;
        } else {
          print("Mismatch on attempt ${i + 1}, retrying...");
        }
      }
      throw Exception("Failed to confirm message");
    } catch (e) {
      print("ERROR writing to oven program characteristic: $e");
    }
  }

  bool _listEquals(List<int> a, List<int> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

}
