import 'package:flutter/material.dart';
import 'services/database_helper.dart';
import 'screens/home_screen.dart';
import 'screens/analysis_screen.dart';
import 'screens/stock_track_screen.dart';
import 'screens/more_screen.dart';

const int MK_Green = 0xFF0F6E56;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Eagerly initialize SQLite database before rendering UI to prevent startup lock contention
  try {
    await DatabaseHelper.instance.database;
  } catch (e) {
    debugPrint('Database eager init exception: $e');
  }

  // Global Error Widget builder so runtime exceptions render error details on screen rather than crashing
  ErrorWidget.builder = (FlutterErrorDetails details) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F6),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 56),
              const SizedBox(height: 16),
              const Text('An error occurred:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 12),
              Text(
                details.exceptionAsString(),
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12, color: Colors.redAccent),
              ),
            ],
          ),
        ),
      ),
    );
  };

  runApp(const MusikaKhulaApp());
}

class MusikaKhulaApp extends StatelessWidget {
  const MusikaKhulaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MusikaKhula',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(MK_Green),
          primary: const Color(MK_Green),
        ),
        scaffoldBackgroundColor: const Color(0xFFF0F4F3),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Color(0xFF1A1A1A),
          elevation: 0,
          titleTextStyle: TextStyle(
            color: Color(0xFF1A1A1A),
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        useMaterial3: true,
      ),
      home: const MainShell(),
    );
  }
}

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    AnalysisScreen(),
    StockTrackScreen(),
    MoreScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        selectedItemColor: const Color(MK_Green),
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart_outlined), activeIcon: Icon(Icons.bar_chart), label: 'Analysis'),
          BottomNavigationBarItem(icon: Icon(Icons.list_alt_outlined), activeIcon: Icon(Icons.list_alt), label: 'Stock Track'),
          BottomNavigationBarItem(icon: Icon(Icons.more_horiz), label: 'More'),
        ],
      ),
    );
  }
}
