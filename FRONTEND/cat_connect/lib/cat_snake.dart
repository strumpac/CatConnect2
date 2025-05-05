import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';


// === POSIZIONE GRIGLIA ===
class Position {
  final int x;
  final int y;
  Position(this.x, this.y);
  bool equals(Position other) => x == other.x && y == other.y;
}

// === GIOCO PRINCIPALE ===
class SnakeGame extends StatefulWidget {
  const SnakeGame({super.key});
  @override
  State<SnakeGame> createState() => _SnakeGameState();
}

enum Direction { up, down, left, right }

class _SnakeGameState extends State<SnakeGame> {
  static const int rowSize = 10;
  static const Duration tickRate = Duration(milliseconds: 300);
  List<Position> snake = [Position(5, 5)];
  Direction direction = Direction.right;
  Position food = Position(7, 5);
  Timer? timer;
  int score = 0;
  bool gameOver = false;
  var topScores = []; 
  var userID;

  final String catEmoji = '🐱';
  final String foodEmoji = '🥫';

  @override
  void initState() {
    super.initState();
    startGame();
  }


  // === AVVIA GIOCO ===
  void startGame() {
    timer?.cancel();
    timer = Timer.periodic(tickRate, (_) => updateSnake());
  }

  // === GENERA CROCCHETTA ===
  void generateFood() {
    Random rand = Random();
    Position newFood;
    do {
      newFood = Position(rand.nextInt(rowSize), rand.nextInt(rowSize));
    } while (snake.any((s) => s.equals(newFood)));
    setState(() => food = newFood);
  }

  // === AGGIORNA POSIZIONE ===
  void updateSnake() {
    Position newHead;
    Position current = snake.first;

    switch (direction) {
      case Direction.up:
        newHead = Position(current.x, (current.y - 1 + rowSize) % rowSize);
        break;
      case Direction.down:
        newHead = Position(current.x, (current.y + 1) % rowSize);
        break;
      case Direction.left:
        newHead = Position((current.x - 1 + rowSize) % rowSize, current.y);
        break;
      case Direction.right:
        newHead = Position((current.x + 1) % rowSize, current.y);
        break;
    }

    if (snake.any((s) => s.equals(newHead))) {
      timer?.cancel();
      _GameOver();  
      return;
    }

    setState(() {
      snake.insert(0, newHead);
      if (newHead.equals(food)) {
        score++;
        generateFood();
      } else {
        snake.removeLast();
      }
    });
  }

  // === CAMBIA DIREZIONE ===
  void changeDirection(Direction newDirection) {
    if ((direction == Direction.left && newDirection != Direction.right) ||
        (direction == Direction.right && newDirection != Direction.left) ||
        (direction == Direction.up && newDirection != Direction.down) ||
        (direction == Direction.down && newDirection != Direction.up)) {
      setState(() => direction = newDirection);
    }
  }

  // === DIALOG FINE GIOCO ===
  void _GameOver() async {
    setState(() {
      gameOver = true;
    });
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('authToken');

    if (token == null) {
      setState(() {
        print('Non trovato il token. Effettua il login.');
      });
      return;
    }

    try {
      final response = await http.get(
        Uri.parse('http://10.1.0.6:5000/api/auth/me'),
        headers: {'Authorization': token},
      );


      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['id'] != null) {
          setState(() {
            userID = data['id'];
          });
        }
      }
    } catch (e) {
      setState(() {
      });
    }
   

     final response = await http.post(
      Uri.parse('http://10.1.0.6:5000/api/auth/addScore'),
      body: json.encode({'user': userID,
                          'score': score}),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
    
    } else {
      print('Errore nel commento: ${response.statusCode}');
    }

  }


  // === RIAVVIA GIOCO ===
  void _restartGame() {
    setState(() {
      snake = [Position(5, 5)];
      direction = Direction.right;
      score = 0;
      generateFood();
    });
    startGame();
  }

  @override
  Widget build(BuildContext context) {
    if(!gameOver){
        return Scaffold(
      appBar: AppBar(title: const Text('Snake Gattino 🐱')),
      body: Column(
        children: [
          Expanded(
            child: GridView.builder(
              itemCount: rowSize * rowSize,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: rowSize),
              itemBuilder: (context, index) {
                final x = index % rowSize;
                final y = index ~/ rowSize;
                final pos = Position(x, y);

                if (snake.any((s) => s.equals(pos))) {
                  return Center(child: Text(catEmoji, style: const TextStyle(fontSize: 20)));
                } else if (food.equals(pos)) {
                  return Center(child: Text(foodEmoji, style: const TextStyle(fontSize: 20)));
                } else {
                  return Container(color: Colors.lightGreen[300]);
                }
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Text('Punteggio: $score', style: const TextStyle(fontSize: 20)),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_upward),
                onPressed: () => changeDirection(Direction.up),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => changeDirection(Direction.left),
              ),
              IconButton(
                icon: const Icon(Icons.arrow_downward),
                onPressed: () => changeDirection(Direction.down),
              ),
              IconButton(
                icon: const Icon(Icons.arrow_forward),
                onPressed: () => changeDirection(Direction.right),
              ),
            ],
          ),
        ],
      ),
    );

    }
    else{
      return AlertDialog(
          title: const Text('Game Over'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Punteggio: $score\n'),
              const Text('🏆 Classifica:'),
              ...topScores.map((entry) => Text('• ${entry['score']} punti')).toList(),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);  // Usa il contesto del dialogo
                _restartGame();
              },
              child: const Text('Riprova'),
            ),
          ],
        );
    }
  }
    
 
  

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }
}
