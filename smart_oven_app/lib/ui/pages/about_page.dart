import 'package:flutter/material.dart';

class SmartOvenAboutPage extends StatelessWidget {
  const SmartOvenAboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About Smart Oven'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Smart Oven App',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text(
              'Version 1.0.0',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 16),
            const Text(
              'This app allows you to control your smart oven, monitor cooking progress, and access detailed reports of your cooking history.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Navigate to the privacy policy page
                Navigator.pushNamed(context, '/privacy-policy');
              },
              child: const Text('Privacy Policy'),
            ),
          ],
        ),
      ),
    );
  }
}