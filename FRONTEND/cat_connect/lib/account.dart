import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cat_connect/main.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  _AccountScreenState createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  String username = '';
  String profileImageUrl = '';
  int followers = 0;
  int following = 0;
  int posts = 0;
  List<String> userPosts = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('authToken');

    if (token == null) {
      setState(() {
        _errorMessage = 'Non trovato il token. Effettua il login.';
        _isLoading = false;
      });
      return;
    }

    try {
      final response = await http.get(

        Uri.parse('http://10.1.0.13:5000/api/auth/me'),
        headers: {'Authorization': token},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          username = data['username'];
          profileImageUrl = data['profilePictureUrl'];
          followers = data['followers'] != null ? data['followers'].length : 0;
          following = data['following'] != null ? data['following'].length : 0;
          posts = data['posts'] != null ? data['posts'].length : 0;
          userPosts = List<String>.from(data['posts'] ?? []).reversed.toList();
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage =
              'Errore nel recupero dei dati utente: ${response.statusCode}, ${response.body}';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Errore di rete: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.remove('authToken'); // Rimuovi il token dalla memoria locale

            MyAppState? appState = context.findAncestorStateOfType<MyAppState>();
        if (appState != null) {
          appState.updateLogin(0); 
        }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Account'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Foto di profilo e informazioni dell'utente
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 50,
                              backgroundImage: NetworkImage(profileImageUrl),
                            ),
                            SizedBox(width: 16),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  username,
                                  style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold),
                                ),
                                SizedBox(height: 8),
                                Text(
                                    '$followers followers  •  $following following'),
                              ],
                            ),

                            // Icona di logout a destra
                            IconButton(
                              icon: const Icon(Icons.logout),
                              onPressed: _logout, // Funzione per il logout
                            ),
                          ],
                        ),
                        SizedBox(height: 20),
                        // Sezione post dell'utente
                        Text(
                          'Posts ($posts)',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 10),
                      ],
                    ),
                  ),
                ),
                userPosts.isEmpty
                    ? SliverFillRemaining(
                        child: Center(
                          child: Text('Non ci sono post disponibili'),
                        ),
                      )
                    : SliverPadding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        sliver: SliverGrid(
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 8,
                          ),
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              return ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  userPosts[index],
                                  fit: BoxFit.cover,
                                ),
                              );
                            },
                            childCount: userPosts.length,
                          ),
                        ),
                      ),
                if (_errorMessage != null)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        _errorMessage!,
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ),
              ],
            ),
    );
  }
}
