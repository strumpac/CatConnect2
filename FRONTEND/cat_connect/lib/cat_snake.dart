import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';



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
  late Database database;

  final String catEmoji = '🐱';
  final String foodEmoji = '🥫';

  @override
  void initState() {
    super.initState();
    _initDatabase();
    startGame();
  }

  // === INIZIALIZZA DATABASE ===
  Future<void> _initDatabase() async {
    database = await openDatabase(
      join(await getDatabasesPath(), 'snake_scores.db'),
      onCreate: (db, version) {
        return db.execute('CREATE TABLE scores(id INTEGER PRIMARY KEY, score INTEGER)');
      },
      version: 1,
    );
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
      _saveScore();
      _showGameOverDialog();
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
 void _showGameOverDialog() async {
  
  //dbbbbbbb
  const topScores = [];

  showDialog(
    context: context as BuildContext,
    builder: (_) => AlertDialog(
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
            Navigator.pop(context as BuildContext);
            _restartGame();
          },
          child: const Text('Riprova'),
        ),
      ],
    ),
  );
}

  // === SALVA PUNTEGGIO ===
  Future<void> _saveScore() async {
    await database.insert('scores', {'score': score});
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
    return Scaffold(
      appBar: AppBar(title: const Text('Snake Gattino 🐱')),
      body: Column(
        children: [
          Expanded(
            child: GestureDetector(
              onVerticalDragUpdate: (details) {
                if (details.delta.dy < 0) changeDirection(Direction.up);
                if (details.delta.dy > 0) changeDirection(Direction.down);
              },
              onHorizontalDragUpdate: (details) {
                if (details.delta.dx < 0) changeDirection(Direction.left);
                if (details.delta.dx > 0) changeDirection(Direction.right);
              },
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
                    return Container(color: Colors.grey[300]);
                  }
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Text('Punteggio: $score', style: const TextStyle(fontSize: 20)),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    timer?.cancel();
    database.close();
    super.dispose();
  }
}