import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../../notification/signal_service.dart';

class BuyPage extends StatefulWidget {
  const BuyPage({super.key});

  @override
  State<BuyPage> createState() => _BuyPageState();
}

class _BuyPageState extends State<BuyPage> {
  List<Map<String, dynamic>> _buySignals = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    SignalService.instance.initializeNotifications();
    SignalService.instance.startFetchingSignals();

    // Listen for updates from SignalService
    SignalService.instance.signalStream.listen((signals) {
      setState(() {
        _buySignals = signals;
        _isLoading = false;
      });
    });
  }

  @override
  void dispose() {
    SignalService.instance.dispose();
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

  Widget _buildBuyCard(Map<String, dynamic> signal) {
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
          ],
        ),
      ),
    );
  }
}