import 'package:flutter/material.dart';
import 'package:smart_oven_app/ui/pages/main_page.dart';
import 'package:smart_oven_app/service/bluetooth.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const SmartOvenApp());
}

class SmartOvenApp extends StatelessWidget {
  const SmartOvenApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
      return ChangeNotifierProvider(
      create:(context) => OvenBleService(),
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 7, 17, 73)),
        ),
        home: const SmartOvenMainPage(),
      )
    );
  }
}

