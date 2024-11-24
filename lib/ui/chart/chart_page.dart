import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as html;
import 'full_screen_image_page.dart';  // Import the new full-screen image page

class ChartPage extends StatefulWidget {
  const ChartPage({Key? key}) : super(key: key);

  @override
  _ChartPageState createState() => _ChartPageState();
}

class _ChartPageState extends State<ChartPage> {
  List<String> _imageNames = []; // List to store image file names
  bool _isLoading = true; // To manage loading state

  @override
  void initState() {
    super.initState();
    _fetchImageNames(); // Fetch image names on init
  }

  // Function to fetch image names (list of .png files) from the server
  Future<void> _fetchImageNames() async {
    try {
      final response = await http.get(Uri.parse('http://192.168.0.183:8000'));

      if (response.statusCode == 200) {
        // Assuming the response body is an HTML directory listing.
        final document = html.parse(response.body);

        // Find all <a> tags with .png in the href attribute
        final imageLinks = document.querySelectorAll('a[href*=".png"]');

        setState(() {
          _imageNames = imageLinks
              .map((element) => element.attributes['href'] ?? '')
              .toList();
          _isLoading = false; // Set loading to false once data is fetched
        });
      } else {
        throw Exception('Failed to load images: ${response.statusCode}');
      }
    } catch (e) {
      // Handle network errors or unexpected issues
      setState(() {
        _isLoading = false; // Set loading to false on error
      });
      debugPrint('Error fetching images: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chart Page')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator()) // Loading indicator
          : _imageNames.isEmpty
              ? const Center(child: Text("No images found."))
              : ListView.builder(
                  itemCount: _imageNames.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(_imageNames[index]),
                      onTap: () {
                        // Navigate to FullScreenImagePage when an image name is tapped
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => FullScreenImagePage(
                              imageUrl: 'http://192.168.0.183:8000/${_imageNames[index]}',
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
    );
  }
}