import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_oven_app/service/bluetooth.dart';
import 'package:smart_oven_app/service/program_manager.dart';
import 'package:smart_oven_app/ui/pages/create_new_curve_page.dart';
import 'package:smart_oven_app/ui/pages/existing_curves_page.dart';
import 'package:smart_oven_app/ui/pages/main_page.dart';
import 'package:smart_oven_app/ui/pages/temperature_curve_options_page.dart';

void main() {
  runApp(const SmartOvenApp());
}

class SmartOvenApp extends StatelessWidget {
  const SmartOvenApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // 1. Provide the base Bluetooth service
        ChangeNotifierProvider(create: (context) => OvenBleService()),

        // 2. FINAL CORRECTION: Use ChangeNotifierProxyProvider with both create and update.
        ChangeNotifierProxyProvider<OvenBleService, OvenProgramManager>(
          // `create` is required in your provider version for the initial build.
          create: (context) => OvenProgramManager(
            // We get the initial dependency here.
            // `listen: false` is crucial inside create/update callbacks.
            Provider.of<OvenBleService>(context, listen: false),
          ),
          // `update` is called for subsequent builds if OvenBleService changes.
          // This will create a new manager if the service updates.
          // The 'previousProgramManager' parameter can be used to preserve state if needed,
          // but creating a new one is the simplest approach.
          update: (context, ovenBleService, previousProgramManager) =>
              OvenProgramManager(ovenBleService),
        ),
      ],
      child: MaterialApp(
        title: 'Smart Oven App',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color.fromARGB(255, 7, 17, 73),
          ),
          useMaterial3: true,
        ),
        initialRoute: '/',
        routes: {
          '/': (context) => const SmartOvenMainPage(),
          '/temperature-curve-options': (context) =>
              const TemperatureCurveOptionsPage(),
          '/existing-curves': (context) => ExistingCurvesPage(),
          '/create-new-curve': (context) => const CreateNewCurvePage(),
        },
      ),
    );
  }
}
