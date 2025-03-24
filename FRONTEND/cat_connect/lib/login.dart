import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'dart:io';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:dio/dio.dart'; // Importa Dio per gestire le eccezioni

class LoginScreen extends StatefulWidget {
  final Function(bool) onLogin;

  const LoginScreen({Key? key, required this.onLogin}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isRegistering = false;
  bool _isLoading = false;
  File? _profileImage;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();

  final cloudinary = CloudinaryPublic('dzyi6fulj', 'cat_connect', cache: false);

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _login() async {
    setState(() {
      _isLoading = true;
    });

    final response = await http.post(
      Uri.parse('http://192.168.1.239:5000/api/auth/login'),
      body: json.encode({
        'email': _emailController.text,
        'password': _passwordController.text,
      }),
      headers: {'Content-Type': 'application/json'},
    );

    setState(() {
      _isLoading = false;
    });

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      widget.onLogin(true);
    } else {
      print('Errore nel login: ${response.statusCode}, ${response.body}');
    }
  }

  Future<void> _register() async {
    setState(() {
      _isLoading = true;
    });

    String? imageUrl;

    if (_profileImage != null) {
      try {
        print("Percorso immagine: ${_profileImage?.path}"); // Verifica il percorso
        CloudinaryResponse response = await cloudinary.uploadFile(
          CloudinaryFile.fromFile(_profileImage!.path, resourceType: CloudinaryResourceType.Image),
        );
        imageUrl = response.secureUrl;
        print('Cloudinary URL: $imageUrl'); //Verifica Cloudinary URL
      } on DioException catch (e) {
        print('DioException durante il caricamento: ${e.message}');
        if (e.response != null) {
          print('DioException response data: ${e.response?.data}');
          print('DioException response status: ${e.response?.statusCode}');
        }
        setState(() {
          _isLoading = false;
        });
        return;
      } on CloudinaryException catch (e) {
        print(e.message);
        setState(() {
          _isLoading = false;
        });
        return;
      }
    }

    final response = await http.post(
      Uri.parse('http://192.168.1.239:5000/api/auth/register'),
      body: json.encode({
        'username': _usernameController.text,
        'email': _emailController.text,
        'password': _passwordController.text,
        'profilePictureUrl': imageUrl,
      }),
      headers: {'Content-Type': 'application/json'},
    );

    setState(() {
      _isLoading = false;
    });

    if (response.statusCode == 201) {
      print('Registrazione avvenuta con successo');
      _login();
    } else {
      print('Errore nella registrazione: ${response.statusCode}, ${response.body}');
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
                GestureDetector(
                  onTap: _pickImage,
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.grey[300],
                    backgroundImage: _profileImage != null ? FileImage(_profileImage!) : null,
                    child: _profileImage == null ? Icon(Icons.camera_alt, size: 50) : null,
                  ),
                ),
              SizedBox(height: 20),
              if (_isRegistering)
                TextField(
                  controller: _usernameController,
                  decoration: InputDecoration(
                    labelText: 'Username',
                    labelStyle: TextStyle(color: Colors.black),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue),
                    ),
                  ),
                ),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  labelStyle: TextStyle(color: Colors.black),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue),
                  ),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              TextField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Password',
                  labelStyle: TextStyle(color: Colors.black),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue),
                  ),
                ),
                obscureText: true,
              ),
              SizedBox(height: 20),
              if (_isLoading)
                CircularProgressIndicator(),
              if (!_isLoading)
                ElevatedButton(
                  onPressed: _isRegistering ? _register : _login,
                  child: Text(
                    _isRegistering ? 'Registrati' : 'Accedi',
                    style: TextStyle(color: Colors.black),
                  ),
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
                  _isRegistering ? 'Hai già un account? Accedi' : 'Non hai un account? Registrati',
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