import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:http/http.dart' as http;

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<String> posts = [];
  List<String> following = [];
  String? _errorMessage;
  var id = '';

  @override
  void initState() {
    super.initState();
    _identifyUser();
  }

  Future<void> _identifyUser() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('authToken');

    if (token == null) {
      setState(() {
        _errorMessage = 'Non trovato il token. Effettua il login.';
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
          id = data['id'];
          following = List<String>.from(data['following'] ?? []);
          loadPosts();
        });
      } else {
        setState(() {
          _errorMessage =
              'Errore nel recupero dei dati utente: ${response.statusCode}, ${response.body}';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Errore di rete: $e';
      });
    }
  }

  Future<void> loadPosts() async {
    try {
      final response = await http.post(
        Uri.parse('http://10.1.0.13:5000/api/auth/followingPosts'),
        body: json.encode({
          'id': id
        }),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          posts = List<String>.from(data).reversed.toList(); 
        });
      } else {
        setState(() {
          _errorMessage =
              'Errore nel caricamento dei post: ${response.statusCode}, ${response.body}';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Errore di rete: $e';
      });
    }
  }

  // Future<void> toggleLike(int index) async {
  //   final prefs = await SharedPreferences.getInstance();
  //   final likedPosts = prefs.getStringList('likedPosts') ?? [];
  //   final postId = posts[index]['id'].toString();

  //   setState(() {
  //     if (likedPosts.contains(postId)) {
  //       likedPosts.remove(postId);
  //       posts[index]['liked'] = false;
  //     } else {
  //       likedPosts.add(postId);
  //       posts[index]['liked'] = true;
  //     }
  //   });

  //   await prefs.setStringList('likedPosts', likedPosts);
  // }

  // Future<void> addComment(int index, String comment) async {
  //   final prefs = await SharedPreferences.getInstance();
  //   final postId = posts[index]['id'].toString();
  //   final comments = prefs.getStringList('comments_$postId') ?? [];

  //   comments.add(comment);
  //   await prefs.setStringList('comments_$postId', comments);
  //   setState(() {});
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: AnimationLimiter(
          child: ListView.builder(
            itemCount: posts.length,
            itemBuilder: (context, index) {
              final post = posts[index];
              return AnimationConfiguration.staggeredList(
                position: index,
                child: SlideAnimation(
                  verticalOffset: 50.0,
                  child: FadeInAnimation(
                    child: Card(
                      margin: EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      elevation: 8,
                      shadowColor: Colors.black54,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius:
                                BorderRadius.vertical(top: Radius.circular(20)),
                            child: CachedNetworkImage(
                              imageUrl: posts[index],
                              height: 300,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Container(
                                color: Colors.grey[300],
                                child: Icon(Icons.image, color: Colors.grey),
                              ),
                              errorWidget: (context, url, error) =>
                                  Icon(Icons.error, color: Colors.red),
                            ),
                          ),
                          // Padding(
                          //   padding: const EdgeInsets.all(10.0),
                          //   child: Text(
                          //     post['description'],
                          //     style: TextStyle(
                          //         fontSize: 16, fontWeight: FontWeight.w500),
                          //     maxLines: 3,
                          //     overflow: TextOverflow.ellipsis,
                          //   ),
                          // ),
                          // Padding(
                          //   padding: const EdgeInsets.symmetric(horizontal: 10),
                          //   child: Row(
                          //     children: [
                          //       // Icona del Like
                          //       IconButton(
                          //         icon: Icon(Icons.favorite, size: 30),
                          //         color: post['liked']
                          //             ? Colors.pinkAccent
                          //             : Colors.grey,
                          //         onPressed: () => toggleLike(index),
                          //       ),

                          //       // Icona del Commento
                          //       IconButton(
                          //         icon: Icon(Icons.comment,
                          //             size: 28, color: Colors.black54),
                          //         onPressed: () {},
                          //       ),
                          //     ],
                          //   ),
                          // ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
