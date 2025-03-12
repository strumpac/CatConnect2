import 'package:flutter/material.dart';

class AddPostScreen extends StatelessWidget {
  const AddPostScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ElevatedButton(
        onPressed: () {
          // Azioni per aggiungere un post
        },
        child: Text('Aggiungi un Nuovo Post'),
      ),
    );
  }
}
