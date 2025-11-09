// lib/main.dart
import 'package:flutter/material.dart';
import 'pages/homepage.dart';
import 'pages/profile_page.dart';
import 'pages/plans_page.dart';
import 'pages/report_page.dart';
import 'pages/activity_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Omegle Clone (Flutter WebRTC)',
      home: MainUIScreen(),
    );
  }
}

// ------------------ NEW UI STARTS HERE ------------------

class MainUIScreen extends StatefulWidget {
  const MainUIScreen({super.key});

  @override
  State<MainUIScreen> createState() => _MainUIScreenState();
}

class _MainUIScreenState extends State<MainUIScreen> {
  int _selectedIndex = 2; // Default index (Home)

  final List<Widget> _pages = const [
    ProfilePage(),
    PlansPage(),
    Homepage(), // using your existing homepage.dart here
    ReportPage(),
    ActivityPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    const Color backgroundColor = Colors.white;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        backgroundColor: backgroundColor,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: "Profile",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt_outlined),
            label: "Plans",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.report_outlined),
            label: "Report",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart_outlined),
            label: "Activity",
          ),
        ],
      ),
    );
  }
}
