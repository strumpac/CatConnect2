import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class LoginScreen extends StatefulWidget {
  final Function(bool) onLogin;

  const LoginScreen({Key? key, required this.onLogin}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isRegistering = false;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();

  Future<void> _login() async {
    final response = await http.post(
      Uri.parse('http://192.168.1.239:5000/api/auth/login'),  // Usa l'URL del tuo backend
      body: json.encode({
        'email': _emailController.text,
        'password': _passwordController.text,
      }),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      // Usa il token ricevuto per gestire l'autenticazione
      widget.onLogin(true);
    } else {
      print('Errore nel login');
    }
  }

  Future<void> _register() async {
    final response = await http.post(
      Uri.parse('http://192.168.1.239:5000/api/auth/register'),  // Usa l'URL del tuo backend
      body: json.encode({
        'username': _usernameController.text,
        'email': _emailController.text,
        'password': _passwordController.text,
      }),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 201) {
      print('Registrazione avvenuta con successo');
      _login();  // Dopo la registrazione, prova a fare login automaticamente
    } else {
      print('Errore nella registrazione');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFFF3E0),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _isRegistering ? 'Registrati' : 'Accedi',
                style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              if (_isRegistering)
                TextField(
                  controller: _usernameController,
                  decoration: InputDecoration(
                    labelText: 'Username',
                    labelStyle: TextStyle(color: Colors.black),  // Cambia il colore del label
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue),  // Colore della borderline quando selezionata
                    ),
                  ),
                ),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  labelStyle: TextStyle(color: Colors.black),  // Cambia il colore del label
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue),  // Colore della borderline quando selezionata
                  ),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              TextField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Password',
                  labelStyle: TextStyle(color: Colors.black),  // Cambia il colore del label
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue),  // Colore della borderline quando selezionata
                  ),
                ),
                obscureText: true,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isRegistering ? _register : _login,
                child: Text(_isRegistering ? 'Registrati' : 'Accedi'),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 15, horizontal: 40),
                  textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    _isRegistering = !_isRegistering;
                  });
                },
                child: Text(
                  _isRegistering
                      ? 'Hai già un account? Accedi'
                      : 'Non hai un account? Registrati',
                  style: TextStyle(color: Colors.blue),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
