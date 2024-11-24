import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:collection/collection.dart'; // For deep equality comparison
import 'dart:convert';
import 'package:http/http.dart' as http;

class SignalService {
  static final SignalService instance = SignalService._();
  SignalService._();

  final StreamController<List<Map<String, dynamic>>> _signalController =
      StreamController.broadcast();
  late FlutterLocalNotificationsPlugin _notificationsPlugin;

  List<Map<String, dynamic>> _previousBuySignals = [];
  List<Map<String, dynamic>> _previousSellSignals = [];

  // Stream to provide signals to other parts of the app
  Stream<List<Map<String, dynamic>>> get signalStream =>
      _signalController.stream;

  // Initialize notifications
  Future<void> initializeNotifications() async {
    _notificationsPlugin = FlutterLocalNotificationsPlugin();

    const initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await _notificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );
  }

  // Handle notification tap
  Future<void> _onNotificationTapped(NotificationResponse response) async {
    debugPrint("Notification payload: ${response.payload}");
    // Navigate to the appropriate page or perform an action
  }

  // Start fetching signals every 5 seconds
  void startFetchingSignals() {
    Timer.periodic(const Duration(seconds: 5), (_) async {
      await _fetchSignals();
    });
  }

  // Fetch signals from Buy and Sell endpoints
  Future<void> _fetchSignals() async {
    try {
      final buyResponse =
          await http.get(Uri.parse('http://192.168.0.183:8000/buy.txt'));
      final sellResponse =
          await http.get(Uri.parse('http://192.168.0.183:8000/sell.txt'));

      if (buyResponse.statusCode == 200 && sellResponse.statusCode == 200) {
        // Process the buy signals
        final buySignals = _parseBuySignals(buyResponse.body);

        // Process the sell signals
        final sellSignals = _parseSellSignals(sellResponse.body);

        // Use deep comparison to find new signals
        final newBuySignals = _getNewSignals(
            buySignals, _previousBuySignals); // Compare deeply
        final newSellSignals = _getNewSignals(
            sellSignals, _previousSellSignals); // Compare deeply

        // Combine buy and sell signals
        final combinedSignals = [...buySignals, ...sellSignals];

        // Notify listeners of the new signals
        _signalController.add(combinedSignals);

        // Update previous signals for comparison in the next fetch
        _previousBuySignals = List.from(buySignals);
        _previousSellSignals = List.from(sellSignals);

        // Trigger a notification for new signals
        if (newBuySignals.isNotEmpty || newSellSignals.isNotEmpty) {
          await _showDetailedNotification(newBuySignals, newSellSignals);
        }
      }
    } catch (e) {
      debugPrint("Error fetching signals: $e");
    }
  }

  // Parse buy signals
  List<Map<String, dynamic>> _parseBuySignals(String data) {
    final signals = <Map<String, dynamic>>[];
    final blocks = data.split('\n\n');
    for (final block in blocks) {
      final lines = block.split('\n');
      signals.add({
        'instrument': lines[0].replaceAll('Buy signal in ', ''),
        'buyPrice': lines[1].split(':').last.trim(),
        'stopLoss': lines[2].split(':').last.trim(),
        'target': lines[3].split(':').last.trim(),
        'time': lines[4].split(':').last.trim(),
      });
    }
    return signals;
  }

  // Parse sell signals
  List<Map<String, dynamic>> _parseSellSignals(String data) {
    final signals = <Map<String, dynamic>>[];
    final blocks = data.split('\n\n');
    for (final block in blocks) {
      final lines = block.split('\n');
      signals.add({
        'instrument': lines[0].replaceAll('Sell signal in ', ''),
        'sellPrice': lines[1].split(':').last.trim(),
        'trailingSL': lines[2].split(':').last.trim(),
        'targets': [
          lines[3].split(':').last.trim(),
          lines[4].split(':').last.trim(),
          lines[5].split(':').last.trim(),
        ],
        'time': lines[6].split(':').last.trim(),
      });
    }
    return signals;
  }

  // Find new signals by comparing current signals to previous ones
  List<Map<String, dynamic>> _getNewSignals(
      List<Map<String, dynamic>> current, List<Map<String, dynamic>> previous) {
    const deepEquality = DeepCollectionEquality();
    return current
        .where((signal) =>
            !previous.any((prevSignal) => deepEquality.equals(signal, prevSignal)))
        .toList();
  }

  // Show detailed notification for new signals
  Future<void> _showDetailedNotification(List<Map<String, dynamic>> newBuySignals,
      List<Map<String, dynamic>> newSellSignals) async {
    String body = '';

    // Append buy signals to the notification body
    for (final signal in newBuySignals) {
      body +=
          'Buy: ${signal['instrument']}, Price: ${signal['buyPrice']}, SL: ${signal['stopLoss']}, Target: ${signal['target']}\n';
    }

    // Append sell signals to the notification body
    for (final signal in newSellSignals) {
      body +=
          'Sell: ${signal['instrument']}, Price: ${signal['sellPrice']}, SL: ${signal['trailingSL']}, Targets: ${signal['targets'].join(', ')}\n';
    }

    const androidDetails = AndroidNotificationDetails(
      'signal_channel',
      'Signals',
      importance: Importance.high,
      priority: Priority.high,
    );
    const notificationDetails = NotificationDetails(android: androidDetails);

    await _notificationsPlugin.show(
        0, 'New Signals Detected', body.trim(), notificationDetails);
  }

  // Dispose the stream controller
  void dispose() {
    _signalController.close();
  }
}