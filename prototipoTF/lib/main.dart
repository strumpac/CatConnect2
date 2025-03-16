import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:image/image.dart' as img;

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gatto o Non Gatto',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late Interpreter _interpreter;
  String _result = 'Carica un\'immagine';

  @override
  void initState() {
    super.initState();
    _loadModel();
  }

  // Carica il modello TFLite
  Future<void> _loadModel() async {
    final appDocDir = await getApplicationDocumentsDirectory();
    final modelPath = '${appDocDir.path}/cat_detector.tflite';

    // Se il modello non è già nella cartella dell'app, copialo
    final file = File(modelPath);
    if (!file.existsSync()) {
      final ByteData data = await rootBundle.load('assets/cat_detector.tflite');
      final buffer = data.buffer.asUint8List();
      file.writeAsBytesSync(buffer);
    }

    final modelFile = File(modelPath);
    _interpreter = Interpreter.fromFile(modelFile);

    print("Modello TFLite caricato.");
    print(_interpreter.getInputTensor(0).shape);
    print(_interpreter.getOutputTensor(0).shape);
  }

  // Funzione per selezionare l'immagine
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile == null) return;

    final image = File(pickedFile.path);
    _predictImage(image);
  }

  // Funzione per fare la predizione
  // Funzione per fare la predizione
Future<void> _predictImage(File image) async {
  final imageBytes = await image.readAsBytes();
  img.Image? imageInput = img.decodeImage(imageBytes);

  if (imageInput == null) {
    setState(() {
      _result = "Errore nell'elaborazione dell'immagine";
    });
    return;
  }

  img.Image resizedImage = img.copyResize(
    imageInput,
    width: 224,
    height: 224,
  );

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
    } else {
      _result = "Non è un gatto";
    }
  });
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Riconoscimento Gatto')),
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
