import 'package:flutter/material.dart';

class SmartOvenReportsPage extends StatefulWidget {
  const SmartOvenReportsPage({super.key});

  @override
  State<SmartOvenReportsPage> createState() => _SmartOvenReportsPageState();
}

class _SmartOvenReportsPageState extends State<SmartOvenReportsPage> {
  // This list will hold the names of the report files.
  // We initialize it as empty and will populate it later.
  List<String> _reportFileNames = [];

  // A flag to track if the data is still being loaded.
  bool _isLoading = true;

  // This method is called once when the widget is first created.
  // It's the perfect place to load our initial data.
  @override
  void initState() {
    super.initState();
    // Start the process of loading the report files.
    _loadReportFiles();
  }

  /// Simulates loading report file names from the device storage.
  ///
  /// In a real app, this is where you would put your logic to find
  /// all the .json, .csv, or other report files.
  Future<void> _loadReportFiles() async {
    // Show the loading indicator.
    setState(() {
      _isLoading = true;
    });

    // Simulate a network or file system delay.
    await Future.delayed(const Duration(seconds: 1));

    // --- REAL IMPLEMENTATION ---
    // Here, you would use a package like 'path_provider' to get the
    // correct directory and 'dart:io' to list the files.
    // For example:
    // final directory = await getApplicationDocumentsDirectory();
    // final files = directory.listSync();
    // _reportFileNames = files.map((file) => file.path.split('/').last).toList();
    // --- END REAL IMPLEMENTATION ---

    // For this example, we'll use a hardcoded list of dummy file names.
    final dummyFiles = [
      '2024-06-20_14-30_RoastChicken.json',
      '2024-06-19_18-00_SourdoughBread.json',
      '2024-06-19_12-15_PizzaMargherita.csv',
      '2024-06-18_20-00_BakedSalmon.json',
      '2024-06-17_08-45_MorningCroissants.json',
    ];

    // Update the state with the loaded data and turn off the loading indicator.
    setState(() {
      _reportFileNames = dummyFiles;
      _isLoading = false;
    });
  }

  /// Handles the action when a user taps on a report item.
  void _onReportTapped(String fileName) {
    // For now, we just print to the console.
    // In the next step, you would use Navigator.push to go to a new page
    // where you would parse and display the contents of the tapped file.
    print('User tapped on report: $fileName');

    // You can also show a simple dialog (SnackBar) at the bottom.
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Loading report for $fileName...'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: _isLoading
          ? const Center(
              // A spinning progress indicator.
              child: CircularProgressIndicator(),
            )
          : ListView.builder(
              // The number of items the list will have.
              itemCount: _reportFileNames.length,
              // The builder function is called for each item.
              // `context` is the build context, `index` is the item's position.
              itemBuilder: (context, index) {
                final fileName = _reportFileNames[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                  child: ListTile(
                    leading: const Icon(Icons.receipt_long, color: Colors.grey),
                    title: Text(
                      fileName,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16.0),
                    onTap: () => _onReportTapped(fileName),
                  ),
                );
              },
            ),
    );
  }
}
