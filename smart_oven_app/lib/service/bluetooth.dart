import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter/foundation.dart';
import 'dart:async';



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

  Future<void> _initializeBluetooth() async {
    FlutterBluePlus.setLogLevel(LogLevel.verbose, color: true);

    if (await FlutterBluePlus.isSupported == false) {
      print("Bluetooth not supported by this device");
      return;
    }

    _adapterStateSubscription = FlutterBluePlus.adapterState.listen((BluetoothAdapterState state) {
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
    await FlutterBluePlus.startScan(timeout: const Duration(seconds: 10));
    
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
    _connectionStateSubscription = device.connectionState.listen((BluetoothConnectionState state) {
      isConnected = (state == BluetoothConnectionState.connected);
      if (state == BluetoothConnectionState.disconnected) {
        print("Disconnected: ${device.disconnectReason?.code} ${device.disconnectReason?.description}");
      }
      notifyListeners();
    });

    device.cancelWhenDisconnected(_connectionStateSubscription!, delayed: true, next: true);


  // Connect to the device
    try {
        print("Connecting to ${device.remoteId}...");
        await device.connect();
        print("Connection successful!");

        List<BluetoothService> services = await device.discoverServices();
        print("Services discovered: ${services.length}");
        
        services.forEach((service) {
            // Here you would look for your specific oven service by its UUID
            print('Service found: ${service.uuid}');
            if(service.uuid.toString() == "YOUR_OVEN_SERVICE_UUID") {
            }      
            // TODO: Find your oven service and its characteristics
        });

    } catch (e) {
      print("ERROR connecting to device: $e");
    }
  }
}
