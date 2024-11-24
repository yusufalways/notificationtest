import 'package:flutter/material.dart';

class FullScreenImagePage extends StatelessWidget {
  final String imageUrl; // Image URL to display

  const FullScreenImagePage({Key? key, required this.imageUrl}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Full Screen Image'),
        backgroundColor: Colors.black,
      ),
      body: GestureDetector(
        onVerticalDragEnd: (details) {
          Navigator.of(context).pop(); // Close the screen on swipe up/down
        },
        child: Center(
          child: Image.network(
            imageUrl, // The full URL of the image
            fit: BoxFit.contain, // Ensures the image fits within the screen
            width: double.infinity, // Full width
            height: double.infinity, // Full height
          ),
        ),
      ),
    );
  }
}