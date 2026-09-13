import 'package:flutter/material.dart';

const int MK_Green = 0xFF0F6E56;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
    _PlaceholderScreen(title: 'Home', icon: Icons.home_outlined, message: 'Home screen : coming next'),
    _PlaceholderScreen(title: 'Analysis', icon: Icons.bar_chart, message: 'Analysis : coming soon'),
    _PlaceholderScreen(title: 'Stock Track', icon: Icons.inventory_2_outlined, message: 'Stock tracking : coming soon'),
    _PlaceholderScreen(title: 'More', icon: Icons.settings_outlined, message: 'Settings : coming soon'),
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

class _PlaceholderScreen extends StatelessWidget {
  final String title;
  final IconData icon;
  final String message;
  const _PlaceholderScreen({required this.title, required this.icon, required this.message});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 64, color: const Color(MK_Green).withOpacity(0.3)),
            const SizedBox(height: 16),
            Text(message, style: const TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}
