import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  final Function onLogin; // Funzione per gestire il login

  LoginScreen({required this.onLogin});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Simuliamo un login con email e password predefiniti
  void _attemptLogin() {
    String email = _emailController.text;
    String password = _passwordController.text;

    if (email == "user@example.com" && password == "password123") {
      // Simula un login riuscito
      widget.onLogin(true);  // Chiama la funzione di login con successo
    } else {
      // Mostra un messaggio di errore se la login non è riuscito
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Credenziali errate')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _attemptLogin,
              child: Text('Login'),
            ),
          ],
        ),
      ),
    );
  }
}
