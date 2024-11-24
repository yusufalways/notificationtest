import 'package:flutter/material.dart';
import '../../notification/signal_service.dart';

class SellPage extends StatefulWidget {
  const SellPage({super.key});

  @override
  State<SellPage> createState() => _SellPageState();
}

class _SellPageState extends State<SellPage> {
  List<Map<String, dynamic>> _sellSignals = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    SignalService.instance.initializeNotifications();
    SignalService.instance.startFetchingSignals();

    // Listen for updates from SignalService
    SignalService.instance.signalStream.listen((signals) {
      setState(() {
        _sellSignals = signals;
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
      appBar: AppBar(title: const Text('Sell Signals')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: _sellSignals.length,
              itemBuilder: (context, index) {
                final signal = _sellSignals[index];
                return _buildSellCard(signal);
              },
            ),
    );
  }

  Widget _buildSellCard(Map<String, dynamic> signal) {
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
            Text('Sell: ${signal['price']}'),
            Text('Stop Loss: ${signal['stopLoss']}'),
            Text('Target: ${signal['target']}'),
            Text('Time: ${signal['time']}'),
          ],
        ),
      ),
    );
  }
}