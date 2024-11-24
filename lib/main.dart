import 'package:flutter/material.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'notification/signal_service.dart'; // Import SignalService
import 'notification/notification.dart'; // Import NotificationService

// Importing UI pages
import 'ui/home/home_page.dart';
import 'ui/buy/buy_page.dart';
import 'ui/sell/sell_page.dart';
import 'ui/chart/chart_page.dart'; // Chart Page

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize notifications and time zones
  await NotificationService.init(); // Initialize NotificationService
  await SignalService.instance.initializeNotifications(); // Corrected SignalService initialization
  SignalService.instance.startFetchingSignals(); // Start fetching signals every 5 seconds
  tz.initializeTimeZones(); // Initialize time zones

  runApp(const PaperTradingApp());
}

class PaperTradingApp extends StatelessWidget {
  const PaperTradingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Paper Trading',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.dark,
      ),
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  // Tab pages
  final List<Widget> _pages = [
    const HomePage(), // HomePage with notification buttons
    const ChartPage(), // Chart tab
    const BuyPage(), // Buy tab
    const SellPage(), // Sell tab
  ];

  // Handle tab switching
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex], // Render selected tab
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex, // Highlight the current tab
        onTap: _onItemTapped, // Handle tab clicks
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.blueAccent,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Chart',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Buy',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.sell),
            label: 'Sell',
          ),
        ],
      ),
    );
  }
}