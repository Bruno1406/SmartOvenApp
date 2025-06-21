import 'package:flutter/material.dart';
import 'reports_page.dart';
import 'home_page.dart';
import 'about_page.dart';

class SmartOvenMainPage extends StatefulWidget {
  const SmartOvenMainPage({super.key});

  @override
  State<SmartOvenMainPage> createState() => SmartOvenMainPageState();
}

class SmartOvenMainPageState extends State<SmartOvenMainPage> {
  // This variable keeps track of the currently selected page.
  int _selectedIndex = 0;

  // This list holds the pages that can be navigated to.
  final List<Widget> _pages = [
    const SmartOvenHome(),
    const SmartOvenReportsPage(),
    const SmartOvenAboutPage(),
  ];

  // This method is called when a new tab is selected.
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Smart Oven App'),
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
              onTap: () => _onItemTapped(0),
            ),
            ListTile(
              leading: const Icon(Icons.report),
              title: const Text('Reports'),
              onTap: () => _onItemTapped(1),
            ),
            ListTile(
              leading: const Icon(Icons.info),
              title: const Text('About'),
              onTap: () => _onItemTapped(2),
            ),
          ],
        ),
      ),
    );
  }
}
