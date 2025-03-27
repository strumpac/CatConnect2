import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:image/image.dart' as img;
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:dio/dio.dart';

class AddPostScreen extends StatefulWidget {
  @override
  _AddPostScreenState createState() => _AddPostScreenState();
}

class _AddPostScreenState extends State<AddPostScreen> {
  late Interpreter _interpreter;
  String _result = 'Carica un\'immagine';
  Color _backgroundColor = Colors.white;
  bool _showPostForm = false;
  final TextEditingController _descriptionController = TextEditingController();
  String userID = '';
  String imageURL = '';
  String filePath = '';
  bool _isLoading = false; // Flag per la rotella di caricamento
  bool _showButton =
      false; // Flag per mostrare il bottone "Carica un'altra immagine"
  final cloudinary = CloudinaryPublic('dzyi6fulj', 'cat_connect', cache: false);

  @override
  void initState() {
    super.initState();
    _pickImage(); // Automatically open the image picker on page load
    _loadModel();
  }

  Future<void> _loadModel() async {
    final appDocDir = await getApplicationDocumentsDirectory();
    final modelPath = '${appDocDir.path}/cat_detector.tflite';

    final file = File(modelPath);
    if (!file.existsSync()) {
      final ByteData data = await rootBundle.load('assets/cat_detector.tflite');
      final buffer = data.buffer.asUint8List();
      file.writeAsBytesSync(buffer);
    }

    final modelFile = File(modelPath);
    _interpreter = Interpreter.fromFile(modelFile);
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile == null) return;

    final image = File(pickedFile.path);
    filePath = pickedFile.path;
    _predictImage(image);
  }

  Future<void> _predictImage(File image) async {
    setState(() {
      _isLoading = true; // Mostra la rotella di caricamento
    });

    final imageBytes = await image.readAsBytes();
    img.Image? imageInput = img.decodeImage(imageBytes);

    if (imageInput == null) {
      setState(() {
        _result = "Errore nell'elaborazione dell'immagine";
        _backgroundColor = Colors.red;
        _showPostForm = false;
        _isLoading = false; // Nascondi la rotella
      });
      return;
    }

    img.Image resizedImage =
        img.copyResize(imageInput, width: 224, height: 224);
    var input = Float32List(1 * 224 * 224 * 3);
    var pixelIndex = 0;

    for (int y = 0; y < resizedImage.height; y++) {
      for (int x = 0; x < resizedImage.width; x++) {
        var pixel = resizedImage.getPixel(x, y);
        input[pixelIndex++] = pixel.r / 255.0;
        input[pixelIndex++] = pixel.g / 255.0;
        input[pixelIndex++] = pixel.b / 255.0;
      }
    }

    var inputShape = _interpreter.getInputTensor(0).shape;
    var outputShape = _interpreter.getOutputTensor(0).shape;

    var inputArray = input.reshape(inputShape);
    var outputArray =
        List.generate(outputShape[0], (_) => List.filled(outputShape[1], 0.0));

    _interpreter.run(inputArray, outputArray);

    double prediction = outputArray[0][0];

    setState(() {
      if (prediction < 0.1) {
        _backgroundColor = const Color.fromARGB(255, 135, 233, 135);
        _showPostForm = true;
      } else {
        _backgroundColor = const Color.fromARGB(255, 243, 173, 173);
        _showPostForm = false;
      }
      _isLoading = false; // Nascondi la rotella
      _showButton = true; // Mostra il bottone "Carica un'altra immagine"
    });
  }

  Future<void> _sendPost() async {
    setState(() {
      _isLoading = true;
    });

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('authToken');
    try {
      CloudinaryResponse response = await cloudinary.uploadFile(
        CloudinaryFile.fromFile(filePath,
            resourceType: CloudinaryResourceType.Image),
      );
      imageURL = response.secureUrl;
      print("URL immagine: $imageURL");
    } on DioException catch (e) {
      print('DioException: ${e.message}');
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

    if (token == null) {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    try {
      final response = await http.get(
<<<<<<< HEAD
        Uri.parse('http://192.168.1.239:5000/api/auth/me'),
        headers: {'Authorization': '$token'},
=======
        Uri.parse('http://192.168.1.107:5000/api/auth/me'),
        headers: {
          'Authorization': '$token'
        },
>>>>>>> 7cc3b2d53b00378dbe2e228b2204006f1fb795d0
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
          _descriptionController.text =
              'Errore nella risposta: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        _descriptionController.text = 'Errore durante la richiesta: $e';
      });
    }

    const String apiUrl = 'http://192.168.1.107:5000/api/auth/addPost';

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'imageUrl': imageURL,
          'description': _descriptionController.text,
          'author': '$userID',
        }),
      );

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Post pubblicato con successo!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Errore durante la pubblicazione del post')),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Errore di connessione: $error')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (filePath.isNotEmpty)
              Image.file(
                File(filePath),
                width: 200,
                height: 200,
                fit: BoxFit.cover,
              ),
            SizedBox(height: 20),
            if (_isLoading)
              CircularProgressIndicator(), // Mostra la rotella durante il caricamento
            if (!_isLoading && _showButton)
              ElevatedButton(
                onPressed: _pickImage,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white, // Colore di sfondo bianco
                  foregroundColor: Colors.black, // Colore del testo nero
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(15), // Bordi arrotondati
                  ),
                  padding: EdgeInsets.symmetric(
                      vertical: 12, horizontal: 25), // Spaziatura interna
                  shadowColor: Colors.black.withOpacity(0.2), // Ombra leggera
                  elevation: 5, // Elevazione per l'ombra
                  side: BorderSide(
                      color: Colors.grey,
                      width: 1), // Bordo grigio per il bottone
                ),
                child: const Text(
                  'Seleziona un\'altra immagine', // Testo del bottone
                  style: TextStyle(
                    fontSize: 16, // Dimensione del font
                    fontWeight: FontWeight.bold, // Testo in grassetto
                  ),
                ),
              ),
            if (_showPostForm) ...[
              Padding(
                padding: const EdgeInsets.all(8.0), // Aggiungi margine di 8px
                child: TextField(
                  controller: _descriptionController,
                  decoration: InputDecoration(
                    labelText: 'Descrizione del post',
                    labelStyle: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide(color: Colors.grey, width: 1),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide(color: Colors.blue, width: 2),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide(color: Colors.grey, width: 1),
                    ),
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                    hintText: 'Aggiungi una descrizione...',
                    hintStyle: TextStyle(color: Colors.grey),
                  ),
                  maxLines: 3,
                  minLines: 1,
                ),
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: _sendPost,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white, // Colore di sfondo bianco
                  foregroundColor: Colors.black, // Colore del testo nero
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(15), // Bordi arrotondati
                  ),
                  padding: EdgeInsets.symmetric(
                      vertical: 12, horizontal: 25), // Spaziatura interna
                  shadowColor: Colors.black.withOpacity(0.2), // Ombra leggera
                  elevation: 5, // Elevazione per l'ombra
                  side: BorderSide(
                      color: Colors.grey,
                      width: 1), // Bordo grigio per il bottone
                ),
                child: const Text(
                  'Carica', // Testo del bottone
                  style: TextStyle(
                    fontSize: 16, // Dimensione del font
                    fontWeight: FontWeight.bold, // Testo in grassetto
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _interpreter.close();
    super.dispose();
  }
}
