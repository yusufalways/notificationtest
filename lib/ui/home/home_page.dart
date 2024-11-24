import 'package:flutter/material.dart';
import '../../notification/notification.dart'; // Import Notification Service

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const HomeTab(),
    const ChartTab(),
    const BuyTab(),
    const SellTab(),
  ];

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Chart'),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: 'Buy'),
          BottomNavigationBarItem(icon: Icon(Icons.sell), label: 'Sell'),
        ],
      ),
    );
  }
}

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Tab'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                NotificationService.showInstantNotification(
                  "Test Instant Notification", 
                  "This is an instant notification from Home Tab",
                );
              },
              child: const Text('Show Instant Notification'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {/*
                DateTime scheduledDate = DateTime.now().add(const Duration(seconds: 5));
                NotificationService.scheduleNotification(
                  0,
                  "Scheduled Notification",
                  "This notification is scheduled for 5 seconds later",
                  scheduledDate,
                );
              */},
              child: const Text('Schedule Notification'),
            ),
          ],
        ),
      ),
    );
  }
}

// Stub widgets for other tabs
class ChartTab extends StatelessWidget {
  const ChartTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Chart Tab Content'));
  }
}

class BuyTab extends StatelessWidget {
  const BuyTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Buy Tab Content'));
  }
}

class SellTab extends StatelessWidget {
  const SellTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Sell Tab Content'));
  }
}