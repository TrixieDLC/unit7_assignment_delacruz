import 'package:flutter/material.dart';
import 'package:flutter_expanded_tile/flutter_expanded_tile.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<dynamic>> futureData;

  @override
  void initState() {
    super.initState();
    futureData = fetchData();
  }

  Future<List<dynamic>> fetchData() async {
    final url = Uri.parse('https://api.disneyapi.dev/character');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      return jsonResponse['data'];
    } else {
      throw Exception("Failed to load data");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true, // Center the title
        title: const Text(
          "DISNEY CHARACTERS",
          style: TextStyle(
            color: Colors.white, // Change text color
            fontSize: 24, // Set font size
            fontWeight: FontWeight.bold, // Set font weight
            fontFamily: 'Arial', // Change font family if desired
          ),
        ),
        backgroundColor: Color.fromARGB(255, 113, 19, 110), // Set the app bar color
      ),
      backgroundColor: Color.fromARGB(255, 230, 200, 255), // Set a light purple background color for the page
      body: Padding(
        padding: const EdgeInsets.only(top: 16.0), // Adds space above the first tile
        child: FutureBuilder<List<dynamic>>(
          future: futureData,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text("Error: ${snapshot.error}"));
            } else if (snapshot.hasData) {
              final data = snapshot.data!;
              return ListView.builder(
                itemCount: data.length,
                itemBuilder: (context, index) {
                  final item = data[index];

                  // Extract data with fallback for missing fields
                  final String name = item['name'] ?? 'Unknown';
                  final String imageUrl = item['imageUrl'] ?? '';
                  final List<dynamic> films = item['films'] is List ? item['films'] : [];
                  final List<dynamic> tvShows = item['tvShows'] is List ? item['tvShows'] : [];

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0), // Space around each tile
                    child: Container(
                      decoration: BoxDecoration(
                        color: index.isEven ? Color.fromARGB(255, 239, 111, 205) : Color.fromARGB(255, 216, 103, 238),
                        borderRadius: BorderRadius.circular(12.0),
                        border: Border.all(color: Color.fromARGB(255, 113, 19, 110), width: 2), // Defined border
                      ),
                      child: ExpandedTile(
                        controller: ExpandedTileController(),
                        title: Text(
                          name,
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        theme: ExpandedTileThemeData(
                          headerColor: Colors.transparent, // Use container color instead
                          headerRadius: 12.0,
                          headerPadding: const EdgeInsets.all(8.0),
                          contentBackgroundColor: Colors.white,
                        ),
                        content: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Texts on the left
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  films.isNotEmpty
                                      ? Text("Films: ${films.join(", ")}", style: const TextStyle(color: Colors.black))
                                      : const Text('No films available', style: TextStyle(color: Colors.black)),
                                  const SizedBox(height: 8.0),
                                  tvShows.isNotEmpty
                                      ? Text("TV Shows: ${tvShows.join(", ")}", style: const TextStyle(color: Colors.black))
                                      : const Text('No TV Shows available', style: TextStyle(color: Colors.black)),
                                ],
                              ),
                            ),
                            // Image on the right
                            if (imageUrl.isNotEmpty)
                              Container(
                                margin: const EdgeInsets.only(left: 8.0),
                                width: 100,
                                height: 100,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8.0),
                                  border: Border.all(color: Color.fromARGB(255, 113, 19, 110), width: 2), // Border color for the image
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8.0), // Rounded corners for image
                                  child: Image.network(
                                    imageUrl,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return const Icon(Icons.broken_image, size: 50, color: Colors.grey);
                                    },
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            }
            return const Center(child: Text("No data available"));
          },
        ),
      ),
    );
  }
}
