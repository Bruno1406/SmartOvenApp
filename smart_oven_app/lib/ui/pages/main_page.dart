import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_oven_app/service/bluetooth.dart'; // Make sure this path is correct
import 'reports_page.dart';
import 'home_page.dart';
import 'about_page.dart';

class SmartOvenMainPage extends StatefulWidget {
  const SmartOvenMainPage({super.key});

  @override
  State<SmartOvenMainPage> createState() => SmartOvenMainPageState();
}

class SmartOvenMainPageState extends State<SmartOvenMainPage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const SmartOvenHome(),
    const SmartOvenReportsPage(),
    const SmartOvenAboutPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // Method to show the Bluetooth devices dialog
  void _showBluetoothDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // Use a Consumer to listen for changes in OvenBleService
        return Consumer<OvenBleService>(
          builder: (context, bluetoothService, child) {
            return AlertDialog(
              title: const Text('Bluetooth Devices'),
              content: SizedBox(
                width: double.maxFinite,
                // Column to hold the list and the button
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    // This is the container for the list of devices
                    Expanded(
                      child: _buildDeviceList(bluetoothService),
                    ),
                    const SizedBox(height: 20),
                    // This is the scan button
                    ElevatedButton(
                      // Disable button while scanning
                      onPressed: bluetoothService.isScanning
                          ? null
                          : () {
                              bluetoothService.startScanning();
                            },
                      child: const Text('Scan for Devices'),
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('Close'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }
  
  // Helper widget to build the content of the device list area
  Widget _buildDeviceList(OvenBleService bluetoothService) {
    if (bluetoothService.isScanning) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 10),
            Text("Scanning..."),
          ],
        ),
      );
    } else if (bluetoothService.discoveredDevices.isEmpty) {
      return const Center(
        child: Text(
          "No devices found. Click 'Scan for Devices' to start.",
          textAlign: TextAlign.center,
        ),
      );
    } else {
      // Display the list of discovered devices
      return ListView.builder(
        shrinkWrap: true,
        itemCount: bluetoothService.discoveredDevices.length,
        itemBuilder: (context, index) {
          final device = bluetoothService.discoveredDevices[index];
          return ListTile(
            title: Text(device.name),
            subtitle: Text(device.id.toString()),
            onTap: () {
              // When a device is tapped, connect to it
              bluetoothService.connectToDevice(device.id);
              // Close the dialog after attempting to connect
              Navigator.of(context).pop(); 
            },
          );
        },
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Smart Oven App'),
        // Add the actions property for the button
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.bluetooth),
            tooltip: 'Open Bluetooth Devices',
            onPressed: _showBluetoothDialog, // Call the method to show the dialog
          ),
        ],
      ),
      body: _pages[_selectedIndex],
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text('Smart Oven Menu'),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Home'),
              onTap: () {
                _onItemTapped(0);
                Navigator.pop(context); // Close the drawer
              },
            ),
            ListTile(
              leading: const Icon(Icons.report),
              title: const Text('Reports'),
              onTap: () {
                 _onItemTapped(1);
                 Navigator.pop(context); // Close the drawer
              },
            ),
            ListTile(
              leading: const Icon(Icons.info),
              title: const Text('About'),
              onTap: () {
                 _onItemTapped(2);
                 Navigator.pop(context); // Close the drawer
              },
            ),
          ],
        ),
      ),
    );
  }
}
