//Author - Ishadya Abeysinghe
/* About App - here I fetched item list from a REST api
and display them in the home screen When one item is tapped it will
 got to a another screen which will display a detailed view of the item
 */

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;    // http package (for HTTP requests)
import 'dart:convert';    //convert package (for JSON decoding)

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Item List App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ItemListScreen(), // Set the home screen to ItemListScreen
    );
  }
}

class ItemListScreen extends StatefulWidget {
  @override
  _ItemListScreenState createState() => _ItemListScreenState();
}

class _ItemListScreenState extends State<ItemListScreen> {
  late Future<List<Map<String, String>>> _itemsFuture;

  @override
  void initState() {
    super.initState();
    _itemsFuture = fetchItems();  // Fetch items from the API
  }

  Future<List<Map<String, String>>> fetchItems() async {
    //HTTP GET request
    final response = await http.get(Uri.parse('https://jsonplaceholder.typicode.com/posts'));

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((item) => {
        'title': item['title'].toString(),
        'subtitle': 'Post ID: ${item['id'].toString()}',
        'details': item['body'].toString(),
      }).toList();
    } else {
      throw Exception('Failed to load items');  //error handling for request fails
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Item List'),
      ),
      body: FutureBuilder<List<Map<String, String>>>(
        future: _itemsFuture, // future to fetches items
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());  // Show loading indicator while waiting
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}')); // Show error message if an error occurs
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No items found'));  // Show a message if no data is found
          } else {
            final items = snapshot.data!;
            return ListView.builder(
              itemCount: items.length,  // getting Number of items in the list
              itemBuilder: (context, index) {
                final item = items[index];
                return ListTile(
                  leading: Icon(Icons.star), // Icon for each list item I used start here
                  title: Text(item['title']!), // Title for each list item
                  subtitle: Text(item['subtitle']!),  // Subtitle for each list item
                  onTap: () {
                    Navigator.push( // Navigate to the detail screen when an item is tapped
                      context,
                      MaterialPageRoute(
                        builder: (context) => ItemDetailScreen(item: item),
                      ),
                    );
                  },
                );
              },
            );
          }
        },
      ),
    );
  }
}

class ItemDetailScreen extends StatelessWidget {
  final Map<String, String> item;

  ItemDetailScreen({required this.item});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(item['title']!), // Display the item title in the app bar
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(item['details']!),  // Display the item details in the body
      ),
    );
  }
}
