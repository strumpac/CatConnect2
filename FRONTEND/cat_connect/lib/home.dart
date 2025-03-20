import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<dynamic> posts = [];

  @override
  void initState() {
    super.initState();
    loadPosts();
  }
  //
  Future<void> loadPosts() async {
    final String response = await rootBundle.loadString('assets/posts.json');
    setState(() {
      posts = jsonDecode(response).map((post) {
        post['liked'] = false;
        return post;
      }).toList();
    });
  }

  Future<void> toggleLike(int index) async {
    final prefs = await SharedPreferences.getInstance();
    final likedPosts = prefs.getStringList('likedPosts') ?? [];
    final postId = posts[index]['id'].toString();

    setState(() {
      if (likedPosts.contains(postId)) {
        likedPosts.remove(postId);
        posts[index]['liked'] = false;
      } else {
        likedPosts.add(postId);
        posts[index]['liked'] = true;
      }
    });

    await prefs.setStringList('likedPosts', likedPosts);
  }

  Future<void> addComment(int index, String comment) async {
    final prefs = await SharedPreferences.getInstance();
    final postId = posts[index]['id'].toString();
    final comments = prefs.getStringList('comments_$postId') ?? [];

    comments.add(comment);
    await prefs.setStringList('comments_$postId', comments);
    setState(() {});
  }

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
                            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                            child: CachedNetworkImage(
                              imageUrl: post['imageUrl'],
                              height: 300,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Container(
                                color: Colors.grey[300],
                                child: Icon(Icons.image, color: Colors.grey),
                              ),
                              errorWidget: (context, url, error) => Icon(Icons.error, color: Colors.red),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Text(
                              post['description'],
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Row(
                              children: [
                                // Icona del Like
                                IconButton(
                                  icon: Icon(Icons.favorite, size: 30),
                                  color: post['liked'] ? Colors.pinkAccent : Colors.grey,
                                  onPressed: () => toggleLike(index),
                                ),
                                
                                // Icona del Commento
                                IconButton(
                                  icon: Icon(Icons.comment, size: 28, color: Colors.black54),
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (context) {
                                        TextEditingController commentController = TextEditingController();
                                        return AlertDialog(
                                          title: Text('Aggiungi un commento'),
                                          content: TextField(
                                            controller: commentController,
                                            decoration: InputDecoration(hintText: 'Scrivi qui...'),
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () => Navigator.pop(context),
                                              child: Text('Annulla'),
                                            ),
                                            ElevatedButton(
                                              onPressed: () {
                                                addComment(index, commentController.text);
                                                Navigator.pop(context);
                                              },
                                              child: Text('Invia'),
                                            )
                                          ],
                                        );
                                      },
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                          FutureBuilder<List<String>>(
                            future: SharedPreferences.getInstance().then(
                              (prefs) => prefs.getStringList('comments_${post['id']}') ?? [],
                            ),
                            builder: (context, snapshot) {
                              if (!snapshot.hasData || snapshot.data!.isEmpty) return SizedBox.shrink();
                              return Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: snapshot.data!
                                      .map((comment) => Padding(
                                            padding: const EdgeInsets.symmetric(vertical: 2),
                                            child: Text(
                                              '- $comment',
                                              style: TextStyle(color: Colors.black87, fontSize: 14),
                                            ),
                                          ))
                                      .toList(),
                                ),
                              );
                            },
                          )
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
