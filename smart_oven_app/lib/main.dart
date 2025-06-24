import 'package:flutter/material.dart';
import 'package:smart_oven_app/ui/pages/main_page.dart';
import 'package:smart_oven_app/ui/pages/temperature_curve_options_page.dart';
import 'package:smart_oven_app/ui/pages/existing_curves_page.dart';
import 'package:smart_oven_app/ui/pages/create_new_curve_page.dart';
import 'package:smart_oven_app/service/bluetooth.dart';
import 'package:smart_oven_app/service/program_manager.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const SmartOvenApp());
}

class SmartOvenApp extends StatelessWidget {
  const SmartOvenApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Use MultiProvider to provide multiple services
    return MultiProvider(
      providers: [
        // 1. Provide the base Bluetooth service
        ChangeNotifierProvider(create: (context) => OvenBleService()),

        // 2. Use ProxyProvider to create OvenProgramManager.
        // It depends on OvenBleService and will be updated if OvenBleService ever changes.
        // The `dispose` parameter ensures the manager's dispose method is called automatically.
        ProxyProvider<OvenBleService, OvenProgramManager>(
          update: (context, ovenBleService, previousProgramManager) =>
              OvenProgramManager(ovenBleService),
          dispose: (context, manager) => manager.dispose(),
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
