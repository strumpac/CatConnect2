import 'package:flutter/material.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Dati statici per l'utente
    final String username = "Strumpa";
    final String profileImage = 'assets/profilo.jpg'; // Usa il tuo asset 'profilo.jpg'
    final int followers = 1200;
    final int following = 350;
    final int posts = 5;

    // Lista di post fittizi
    final List<String> userPosts = List.generate(5, (index) => 'assets/prova.jpg'); // Usa 'profilo.jpg' per tutti i post

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView( // Usa SingleChildScrollView per evitare l'overflow
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Foto di profilo e informazioni dell'utente
              Row(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: AssetImage(profileImage),
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
                      Text('$followers followers  •  $following following'),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 20),

              // Sezione post dell'utente
              Text(
                'Post ($posts)',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),

              // Griglia di post dell'utente
              userPosts.isEmpty
                  ? Center(child: Text('Non ci sono post disponibili'))
                  : GridView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(), // Disabilita lo scroll separato
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                      ),
                      itemCount: userPosts.length,
                      itemBuilder: (context, index) {
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.asset(
                            userPosts[index],
                            fit: BoxFit.cover,
                          ),
                        );
                      },
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
