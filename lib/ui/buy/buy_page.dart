import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:flutter_background/flutter_background.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:collection/collection.dart'; // Import collection package for MapEquality
import '../../notification/signal_service.dart'; // Import SignalService

class BuyPage extends StatefulWidget {
  const BuyPage({super.key});

  @override
  State<BuyPage> createState() => _BuyPageState();
}

class _BuyPageState extends State<BuyPage> {
  List<Map<String, dynamic>> _buySignals = [];
  List<Map<String, dynamic>> _previousSignals = [];
  bool _isLoading = true;
  late Timer _timer;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    _setupBackground();
    _fetchBuySignals();
    _startPeriodicRequest();
  }

  // Set up background execution
  Future<void> _setupBackground() async {
    await FlutterBackground.initialize();
    await FlutterBackground.enableBackgroundExecution();
  }

  // Start periodic data fetch every 5 seconds
  void _startPeriodicRequest() {
    _timer = Timer.periodic(const Duration(seconds: 5), (_) {
      _fetchBuySignals();
    });
  }

  // Fetch buy signal data
  Future<void> _fetchBuySignals() async {
    try {
      final response = await http.get(Uri.parse('http://192.168.0.183:8000/buy.txt'));

      if (response.statusCode == 200) {
        // Process raw signals from the response
        final rawSignals = response.body.split('\n\n');
        final List<Map<String, dynamic>> signals = rawSignals
            .map((block) {
              final cleanedBlock = block.trim();
              final lines = cleanedBlock.split('\n').where((line) => line.trim().isNotEmpty).toList();

              if (lines.length >= 7) {
                // Return a properly typed Map<String, dynamic>
                return {
                  'instrument': lines[0].replaceAll('Buy signal in ', '').trim(),
                  'buyPrice': lines[1].split(':').last.trim(),
                  'stopLoss': lines[2].split(':').last.trim(),
                  'target': lines[3].split(':').last.trim(),
                  'time': lines[6].substring(lines[6].indexOf(':') + 1).trim(),
                };
              } else {
                return null; // For invalid blocks, return null
              }
            })
            .where((signal) => signal != null) // Filter out null values
            .map((signal) => Map<String, dynamic>.from(signal!)) // Cast to Map<String, dynamic>
            .toList();

        setState(() {
          _buySignals = signals; // Assign properly typed signals
          _isLoading = false;
        });

        // Check for changes
        _checkForChanges(signals);
      } else {
        throw Exception('Failed to load buy signals');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  // Compare previous and current data to detect changes
  void _checkForChanges(List<Map<String, dynamic>> newSignals) {
    if (_previousSignals.isEmpty || !_listEquals(_previousSignals, newSignals)) {
      _sendNotification();
      _previousSignals = List<Map<String, dynamic>>.from(newSignals); // Ensure the type is List<Map<String, dynamic>>
    }
  }

  // Send local notification if there's a change in data
  void _sendNotification() async {
    const androidDetails = AndroidNotificationDetails(
      'channel_id',
      'Buy Signals',
      importance: Importance.max,
      priority: Priority.high,
    );
    const notificationDetails = NotificationDetails(android: androidDetails);

    await flutterLocalNotificationsPlugin.show(
      0,
      'New Buy Signal Updates!',
      'There are new updates to the buy signals.',
      notificationDetails,
    );
  }

  // Helper function to compare two lists
  bool _listEquals(List<Map<String, dynamic>> list1, List<Map<String, dynamic>> list2) {
    if (list1.length != list2.length) {
      return false;
    }
    // Use MapEquality to compare individual maps
    for (int i = 0; i < list1.length; i++) {
      if (!MapEquality().equals(list1[i], list2[i])) {
        return false;
      }
    }
    return true;
  }

  @override
  void dispose() {
    _timer.cancel(); // Cancel the timer when the page is disposed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Buy Signals')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: _buySignals.length,
              itemBuilder: (context, index) {
                final signal = _buySignals[index];
                return _buildBuyCard(signal);
              },
            ),
    );
  }

  // Builds each signal card
  Widget _buildBuyCard(Map<String, dynamic> signal) {
    bool isOrdSelected = false;
    bool isTgtSelected = false;
    bool isSLSelected = false;

    return Card(
      elevation: 4.0,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              signal['instrument'],
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('Buy: ${signal['buyPrice']}'),
            Text('Stop Loss: ${signal['stopLoss']}'),
            Text('Target: ${signal['target']}'),
            Text('Time: ${signal['time']}'),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Row(
                  children: [
                    Checkbox(
                      value: isOrdSelected,
                      onChanged: (value) {
                        setState(() {
                          isOrdSelected = value ?? false;
                        });
                      },
                    ),
                    const Text('Ord'),
                  ],
                ),
                Row(
                  children: [
                    Checkbox(
                      value: isTgtSelected,
                      onChanged: (value) {
                        setState(() {
                          isTgtSelected = value ?? false;
                        });
                      },
                    ),
                    const Text('Tgt'),
                  ],
                ),
                Row(
                  children: [
                    Checkbox(
                      value: isSLSelected,
                      onChanged: (value) {
                        setState(() {
                          isSLSelected = value ?? false;
                        });
                      },
                    ),
                    const Text('SL'),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}