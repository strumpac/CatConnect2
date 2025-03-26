import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  TextEditingController _searchController = TextEditingController();
  List<Map<String, String>> _searchResults = [];
  bool _isLoading = false;

  // Funzione per cercare gli utenti
  Future<void> _searchUsers(String query) async {
    if (query.isEmpty) {
      setState(() {
        _searchResults.clear();
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.get(Uri.parse(
          'http://10.1.0.6:5000/api/auth/searchUsers?query=$query'));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          _searchResults = data
              .map((user) => {
                    'username': user['username'].toString(),
                    'profilePictureUrl': user['profilePictureUrl'].toString()
                  })
              .toList();
        });
      }
    } catch (e) {
      print('Errore nella ricerca: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            // Barra di ricerca
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: TextField(
                controller: _searchController,
                onChanged: _searchUsers, // Chiama la ricerca mentre si digita
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  hintText: 'Cerca utenti...',
                  prefixIcon: Icon(Icons.search, color: Colors.black54),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            // Mostra i risultati della ricerca
            Expanded(
              child: _isLoading
                  ? Center(child: CircularProgressIndicator())
                  : _searchResults.isEmpty
                      ? Center(
                          child: Text(
                            'Nessun utente trovato',
                            style: TextStyle(fontSize: 18, color: Colors.grey),
                          ),
                        )
                      : ListView.builder(
                          itemCount: _searchResults.length,
                          itemBuilder: (context, index) {
                            return ListTile(
                              leading: CircleAvatar(
                                backgroundImage: NetworkImage(
                                    _searchResults[index]
                                        ['profilePictureUrl']!),
                              ),
                              title: Text(_searchResults[index]['username']!),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
