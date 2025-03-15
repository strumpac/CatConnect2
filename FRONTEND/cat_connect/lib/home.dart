import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:shared_preferences/shared_preferences.dart';

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

  //metodo che carica i post
  Future<void> loadPosts() async {
    final String response = await rootBundle.loadString('assets/posts.json');
    setState(() {
      posts = jsonDecode(response).map((post) {
        post['liked'] = false;
        return post;
      }).toList();
    });
  }

  //metodo per mettere e togliere i like dai post
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

  //metodo per aggiungere i commenti
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
      appBar: AppBar(title: Text('Home')),
      body: ListView.builder(
        //iterazione per mettere tutti i post
        itemCount: posts.length,
        itemBuilder: (context, index) {
          final post = posts[index];
          return Card(
            margin: EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                //immagine 
                Image.network(
                  post['imageUrl'],
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(Icons.error, color: Colors.red);
                  },
                ),
                //descrizione del post
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child:
                      Text(post['description'], style: TextStyle(fontSize: 16)),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    //like
                    IconButton(
                      icon: Icon(Icons.favorite),
                      color: post['liked'] == true
                          ? Colors.pinkAccent
                          : Colors.grey,
                      onPressed: () => toggleLike(index),
                    ),
                    //commento
                    IconButton(
                      icon: Icon(Icons.comment),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) {
                            TextEditingController commentController =
                                TextEditingController();
                            return AlertDialog(
                              title: Text('Aggiungi un commento'),
                              content: TextField(
                                controller: commentController,
                                decoration:
                                    InputDecoration(hintText: 'Scrivi qui...'),
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
                    )
                  ],
                ),
                FutureBuilder<List<String>>(
                  future: SharedPreferences.getInstance().then(
                    (prefs) =>
                        prefs.getStringList('comments_${post['id']}') ?? [],
                  ),
                  builder: (context, snapshot) { // lo snapshot contiene il risultato del future
                    if (!snapshot.hasData) return SizedBox.shrink(); //se snapshot.hasData è false restituisce una sized box vuota
                    return Column(
                      children: snapshot.data!
                          .map((comment) => ListTile(title: Text(comment)))
                          .toList(),
                    );
                  },
                )
              ],
            ),
          );
        },
      ),
    );
  }
}
