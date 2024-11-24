import 'package:flutter/material.dart';

class FullScreenImagePage extends StatelessWidget {
  final String imageUrl; // Image URL to display

  const FullScreenImagePage({Key? key, required this.imageUrl}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Black background for better contrast
      body: GestureDetector(
        onVerticalDragEnd: (details) {
          Navigator.of(context).pop(); // Close the screen on swipe up/down
        },
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top, // Add padding equal to the status bar height
            ),
            child: Center(
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover, // Use cover to fill the width entirely
                width: MediaQuery.of(context).size.width, // Full width of the screen
              ),
            ),
          ),
        ),
      ),
    );
  }
}
