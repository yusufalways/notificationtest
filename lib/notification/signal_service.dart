import 'package:http/http.dart' as http;
import 'dart:async';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:collection/collection.dart';

class SignalService {
  SignalService._privateConstructor();
  static final SignalService instance = SignalService._privateConstructor();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  List<Map<String, dynamic>> _previousSignals = [];
  final _signalStreamController = StreamController<List<Map<String, dynamic>>>.broadcast();
  Stream<List<Map<String, dynamic>>> get signalStream => _signalStreamController.stream;

  // Initialize Notification Plugin
  Future<void> initializeNotifications() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initializationSettings = InitializationSettings(android: androidSettings);
    await _notificationsPlugin.initialize(initializationSettings);
  }

  // Start periodic fetching of buy signals
  void startFetchingSignals() {
    Timer.periodic(const Duration(seconds: 5), (_) => _fetchBuySignals());
  }

  Future<void> _fetchBuySignals() async {
    try {
      final response = await http.get(Uri.parse('http://192.168.0.183:8000/buy.txt'));

      if (response.statusCode == 200) {
        final rawSignals = response.body.split('\n\n');
        final List<Map<String, dynamic>> signals = rawSignals
            .map((block) {
              final cleanedBlock = block.trim();
              final lines = cleanedBlock.split('\n').where((line) => line.trim().isNotEmpty).toList();

              if (lines.length >= 7) {
                return {
                  'instrument': lines[0].replaceAll('Buy signal in ', '').trim(),
                  'buyPrice': lines[1].split(':').last.trim(),
                  'stopLoss': lines[2].split(':').last.trim(),
                  'target': lines[3].split(':').last.trim(),
                  'time': lines[6].substring(lines[6].indexOf(':') + 1).trim(),
                };
              } else {
                return null;
              }
            })
            .where((signal) => signal != null)
            .map((signal) => Map<String, dynamic>.from(signal!))
            .toList();

        // Notify listeners
        _signalStreamController.add(signals);

        // Check for changes
        if (_previousSignals.isEmpty || !_listEquals(_previousSignals, signals)) {
          _sendDetailedNotification(signals);
          _previousSignals = List<Map<String, dynamic>>.from(signals);
        }
      }
    } catch (e) {
      // Handle errors gracefully
    }
  }

  // Send local notification with detailed information
  Future<void> _sendDetailedNotification(List<Map<String, dynamic>> signals) async {
    final latestSignal = signals.isNotEmpty ? signals.first : null;

    if (latestSignal != null) {
      final details = '''
Instrument: ${latestSignal['instrument']}
Buy Price: ${latestSignal['buyPrice']}
Stop Loss: ${latestSignal['stopLoss']}
Target: ${latestSignal['target']}
Time: ${latestSignal['time']}
      ''';

      const androidDetails = AndroidNotificationDetails(
        'channel_id',
        'Buy Signals',
        importance: Importance.max,
        priority: Priority.high,
      );
      const notificationDetails = NotificationDetails(android: androidDetails);

      await _notificationsPlugin.show(
        0,
        'New Buy Signal: ${latestSignal['instrument']}',
        details,
        notificationDetails,
      );
    }
  }

  bool _listEquals(List<Map<String, dynamic>> list1, List<Map<String, dynamic>> list2) {
    if (list1.length != list2.length) return false;
    for (int i = 0; i < list1.length; i++) {
      if (!MapEquality().equals(list1[i], list2[i])) return false;
    }
    return true;
  }

  void dispose() {
    _signalStreamController.close();
  }
}