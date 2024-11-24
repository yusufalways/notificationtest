// Importing necessary Flutter packages for UI and HTTP operations.
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http; // For making HTTP requests.
import 'dart:convert'; // For decoding JSON and other data formats.

// The sellPage widget represents the sell tab in the app.
class SellPage extends StatefulWidget {
  const SellPage({super.key});

  @override
  State<SellPage> createState() => _sellPageState();
}

// The state class for sellPage handles data fetching and UI rendering.
class _sellPageState extends State<SellPage> {
  // List to hold parsed data from the server.
  List<Map<String, dynamic>> _sellSignals = [];

  // Boolean to indicate whether data is still loading.
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchsellSignals(); // Fetch data when the page is initialized.
  }

  // Function to fetch data from the local host.
  Future<void> _fetchsellSignals() async {
    try {
      // HTTP GET request to fetch the sell signal data.
      final response = await http.get(Uri.parse('http://192.168.0.183:8000/sell.txt'));

      // Check if the request was successful.
      if (response.statusCode == 200) {
        // Split the raw text into individual sell signal blocks.
        final List<String> rawSignals = response.body.split('\n\n');

        // Parse each block into a structured map.
        final signals = rawSignals.map((block) {
          final lines = block.split('\n'); // Split block into lines.
          return {
            'instrument': lines[0].replaceAll('sell signal in ', ''),
            'sellPrice': lines[1].split(':').last.trim(),
            'trailingSL': lines[2].split(':').last.trim(),
            'targets': [
              lines[3].split(':').last.trim(),
              lines[4].split(':').last.trim(),
              lines[5].split(':').last.trim(),
            ],
            'time': lines[6].split(':').last.trim(),
          };
        }).toList();

        // Update state with parsed signals.
        setState(() {
          _sellSignals = List<Map<String, dynamic>>.from(signals);
          _isLoading = false; // Data has finished loading.
        });
      } else {
        throw Exception('Failed to load sell signals');
      }
    } catch (e) {
      // Handle errors (e.g., network issues) gracefully.
      setState(() {
        _isLoading = false; // Stop the loading indicator.
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('sell Signals')), // Title for the sell tab.
      body: _isLoading
          ? const Center(child: CircularProgressIndicator()) // Show loader while data is loading.
          : ListView.builder(
              padding: const EdgeInsets.all(8.0), // Adds padding around the list.
              itemCount: _sellSignals.length, // Number of cards to display.
              itemBuilder: (context, index) {
                final signal = _sellSignals[index]; // Get the signal for the current card.
                return _buildsellCard(signal); // Build a card for each signal.
              },
            ),
    );
  }

  // Widget to build a card for a single sell signal.
  Widget _buildsellCard(Map<String, dynamic> signal) {
    // State variables for tick boxes.
    bool isOrdSelected = false;
    bool isTgtSelected = false;
    bool isSLSelected = false;

    return Card(
      elevation: 4.0, // Adds shadow to the card.
      margin: const EdgeInsets.symmetric(vertical: 8.0), // Space between cards.
      child: Padding(
        padding: const EdgeInsets.all(12.0), // Padding inside the card.
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, // Align items to the start.
          children: [
            // Display instrument name as a bold title.
            Text(
              signal['instrument'],
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8), // Space between title and details.
            // Display sell price.
            Text('sell Price: ${signal['sellPrice']}'),
            // Display trailing stop loss.
            Text('Trailing Stop Loss: ${signal['trailingSL']}'),
            // Display targets as a list.
            ...signal['targets'].asMap().entries.map((entry) {
              final targetIndex = entry.key + 1; // Target number (1-based index).
              final targetValue = entry.value; // Target value.
              return Text('Target $targetIndex: $targetValue');
            }).toList(),
            // Display time of the sell signal.
            Text('Time: ${signal['time']}'),
            const SizedBox(height: 16), // Space before checkboxes.
            // Row of checkboxes with labels.
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly, // Distribute checkboxes evenly.
              children: [
                Row(
                  children: [
                    Checkbox(
                      value: isOrdSelected, // Current state of the checkbox.
                      onChanged: (value) {
                        setState(() {
                          isOrdSelected = value ?? false; // Update state on selection.
                        });
                      },
                    ),
                    const Text('Ord'), // Label for the checkbox.
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