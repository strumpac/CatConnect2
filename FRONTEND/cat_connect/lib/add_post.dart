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
  final cloudinary = CloudinaryPublic('dzyi6fulj', 'cat_connect', cache: false);

  @override
  void initState() {
    super.initState();
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
    filePath=pickedFile.path;
    _predictImage(image);
  }

  Future<void> _predictImage(File image) async {
    final imageBytes = await image.readAsBytes();
    img.Image? imageInput = img.decodeImage(imageBytes);

    if (imageInput == null) {
      setState(() {
        _result = "Errore nell'elaborazione dell'immagine";
        _backgroundColor = Colors.red;
        _showPostForm = false;
      });
      return;
    }

    img.Image resizedImage = img.copyResize(imageInput, width: 224, height: 224);

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
    var outputArray = List.generate(outputShape[0], (_) => List.filled(outputShape[1], 0.0));

    _interpreter.run(inputArray, outputArray);

    double prediction = outputArray[0][0];

    setState(() {
      if (prediction < 0.1) {
        _result = "È un gatto!";
        _backgroundColor = const Color.fromARGB(255, 135, 233, 135);
        _showPostForm = true;
      } else {
        _result = "Non è un gatto";
        _backgroundColor = const Color.fromARGB(255, 243, 173, 173);
        _showPostForm = false;
      }
    });
  }

  Future<void> _sendPost() async {

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('authToken');
    try {
        CloudinaryResponse response = await cloudinary.uploadFile(
          CloudinaryFile.fromFile(filePath, resourceType: CloudinaryResourceType.Image),
        );
        imageURL = response.secureUrl;
        print("URL immagine: $imageURL"); 
      } on DioException catch (e) {
        print('DioException: ${e.message}');
        setState(() {
          
        });
        return;
      } on CloudinaryException catch (e) {
        print(e.message);
        setState(() {
          
        });
        return;
      }
    
     if (token == null) {
      setState(() {
        
      });
      return;
    }

    //try {
    //   final response = await http.get(
    //     Uri.parse('http://10.1.0.13:5000/api/auth/me'),
    //     headers: {'Authorization': token},
    //   );

    //   if (response.statusCode == 200) {
    //     final data = json.decode(response.body);
          

    //     setState(() {
    //       userID = data['id'];
    //       _descriptionController.text = userID;
    //     });
    //   } else {
    //     setState(() {
    //       _descriptionController.text = 'erroraccio1';
    //     });
    //   }
    // } catch (e) {
    //   setState(() {
    //     _descriptionController.text = 'erroraccio2';
    //   });
    // }

    const String apiUrl = 'http://10.1.0.6:5000/api/auth/addPost'; 

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'imageUrl': imageURL, 
          'description': _descriptionController.text,
          'author': '67ded16dbad26670aa49f015', 
        }),
      );

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Post pubblicato con successo!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Errore durante la pubblicazione del post')),
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
      backgroundColor: _backgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: _pickImage,
              child: Text('Carica un\'immagine'),
            ),
            SizedBox(height: 20),
            Text(_result, style: TextStyle(fontSize: 24)),
            if (_showPostForm) ...[
              TextField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Descrizione del post'),
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: _sendPost,
                child: const Text('Invia Post'),
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
