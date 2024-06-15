import 'package:calender_app/home_screen.dart';
import 'package:calender_app/settings_screen.dart';
import 'package:calender_app/webview_screen.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  final List<Widget> _screens = [
    HomeScreen(),
    const WebviewScreen(
      url: 'https://workflow.mew.gov.kw',
    ),
    const WebviewScreen(
      url: 'https://procurement.mew.gov.kw/Account/Login',
    ),
    const WebviewScreen(
      url: 'https://portal.csc.gov.kw/webcenter/portal/CSCPortal',
    ),
    SettingsScreen(),
  ];

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        unselectedItemColor: Colors.black,
        unselectedLabelStyle: const TextStyle(color: Colors.blue),
        selectedItemColor: Colors.purple,
        selectedLabelStyle: const TextStyle(color: Colors.purple),
        onTap: _onTabTapped,
        currentIndex: _currentIndex,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.public),
            label: 'Workflow',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.public),
            label: 'Procurement',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.public),
            label: 'CSC Portal',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
