import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class SearchedUserScreen extends StatefulWidget {
  final String? userId;  // Rendiamo userId facoltativo

  const SearchedUserScreen({super.key, this.userId});

  @override
  _SearchedUserScreenState createState() => _SearchedUserScreenState();
}

class _SearchedUserScreenState extends State<SearchedUserScreen> {
  String username = '';
  String profileImageUrl = '';
  int followers = 0;
  int following = 0;
  int posts = 0;
  List<String> userPosts = [];
  bool _isLoading = true;
  bool _isFollowing = false;
  String? _errorMessage;
  String userID = '';

  @override
  void initState() {
    super.initState();
    if (widget.userId != null) {
      _fetchUserData(); // Recupera i dati solo se userId è disponibile
    }
  }

  // Funzione per recuperare i dati dell'utente cliccato
  Future<void> _fetchUserData() async {
    if (widget.userId == null) return; // Se userId non è passato, non fare nulla

    try {
      final response = await http.get(
        Uri.parse('http://192.168.1.107:5000/api/auth/user/${widget.userId}'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        setState(() {
          username = data['username'];
          profileImageUrl = data['profilePictureUrl'];
          followers = data['followers'] != null ? data['followers'].length : 0;
          following = data['following'] != null ? data['following'].length : 0;
          posts = data['posts'] != null ? data['posts'].length : 0;
          userPosts = List<String>.from(data['posts'] ?? []);
          _isLoading = false;
          _isFollowing = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Errore nel recupero dei dati utente: ${response.statusCode}, ${response.body}';
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

  Future<void> _follow() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('authToken');

    try {
      final response = await http.get(
        Uri.parse('http://192.168.1.107:5000/api/auth/me'),
        headers: {
          'Authorization': '$token'
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['id'] != null) {
          setState(() {
            userID = data['id'];
          });
        }
      } else {
        setState(() {
          // Handle any error states if necessary
        });
      }
    } catch (e) {
      setState(() {
        // Handle network error if necessary
      });
    }

    setState(() {
      _isFollowing = !_isFollowing; // Inverte lo stato del follow
    });

    const String apiUrl1 = 'http://192.168.1.107:5000/api/auth/addFollowing';

    try {
      final response = await http.post(
        Uri.parse(apiUrl1),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'myId': userID,
          'otherId': widget.userId,
        }),
      );

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('following!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Errore durante il following ' )),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Errore di connessione: $error')),
      );
    }

     const String apiUrl2 = 'http://192.168.1.107:5000/api/auth/addFollower';

    try {
      final response = await http.post(
        Uri.parse(apiUrl2),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'myId': userID,
          'otherId': widget.userId,
        }),
      );

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('following!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Errore durante il following')),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Errore di connessione: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(username.isEmpty ? 'Caricamento...' : 'Account di $username')),
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
                                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                                ),
                                SizedBox(height: 8),
                                Text('$followers followers  •  $following following',
                                    style: TextStyle(fontSize: 16)),
                              ],
                            ),
                          ],
                        ),
                        SizedBox(height: 20),
                        // Bottone Follow
                        ElevatedButton(
                          onPressed: _follow, // Chiamata al metodo follow
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                          ),
                          child: Text(
                            _isFollowing ? 'Following' : 'Follow',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        SizedBox(height: 20),
                        Text('Post ($posts)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        SizedBox(height: 10),
                      ],
                    ),
                  ),
                ),
                userPosts.isEmpty
                    ? SliverFillRemaining(
                        child: Center(child: Text('Non ci sono post disponibili')),
                      )
                    : SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            return Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Image.network(userPosts[index]),
                            );
                          },
                          childCount: userPosts.length,
                        ),
                      ),
              ],
            ),
    );
  }
}
