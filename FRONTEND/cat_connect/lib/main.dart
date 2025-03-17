import 'package:flutter/material.dart';
// Importo le varie schermate
import 'account.dart';
import 'add_post.dart';
import 'home.dart';
import 'search.dart';
import 'login.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int _selectedIndex = 0; // Indice della schermata selezionata
  bool _isLoggedIn = true;

  // Lista delle schermate per la BottomNavigationBar
  static List<Widget> _widgetOptions = <Widget>[
    HomeScreen(),
    SearchScreen(),
    AddPostScreen(),
    AccountScreen(),
  ];

  // Aggiorna l'indice della pagina selezionata
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // Funzione per gestire il login
  void _handleLogin(bool isLoggedIn) {
    setState(() {
      _isLoggedIn = isLoggedIn;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cat Connect',
      theme: ThemeData(
        primaryColor: const Color(0xFFFF9800), // Arancione caldo
        scaffoldBackgroundColor: const Color(0xFFFFF3E0), // Beige chiaro
        colorScheme: const ColorScheme.light(
          primary: Color(0xFFFF9800), // Arancione principale
          secondary: Color.fromARGB(255, 25, 0, 255), // Viola per accenti
          background: Color(0xFFFFF3E0), // Beige chiaro
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFFF9800), // Colore di sfondo dell'AppBar
          foregroundColor: Colors.white, // Colore del titolo (foreground)
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Color.fromARGB(255, 25, 0, 255), // Viola
          selectedItemColor: Colors.white, // Elemento selezionato in bianco
          unselectedItemColor: Colors.grey, // Elementi non selezionati in grigio
          elevation: 5.0,
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.black),
          bodyMedium: TextStyle(color: Colors.black87),
        ),
      ),
      home: _isLoggedIn
          ? Scaffold(
              appBar: AppBar(
                title: Text(
                  'Cat Connect',
                  style: TextStyle(
                    fontSize: 25, // Aumenta la dimensione del font
                    fontWeight: FontWeight.bold, // Font in grassetto
                    fontFamily: 'Roboto', // Usa un font personalizzato (se ne hai uno)
                    color: Color.fromARGB(255, 25, 0, 255), // Colore viola per il titolo
                    shadows: [
                      Shadow(
                        offset: Offset(2, 2), // Ombra del titolo
                        blurRadius: 5, // Raggio della sfocatura dell'ombra
                        color: Colors.black.withOpacity(0.4), // Colore dell'ombra
                      ),
                    ],
                  ),
                ),
                backgroundColor: Colors.yellow, // Colore di sfondo dell'AppBar
                foregroundColor: Color.fromARGB(255, 25, 0, 255), // Colore del titolo
              ),
              body: _widgetOptions.elementAt(_selectedIndex),
              bottomNavigationBar: Container(
                decoration: const BoxDecoration(
                  color: Color.fromARGB(255, 25, 0, 255), // Viola
                ),
                child: BottomNavigationBar(
                  backgroundColor: Colors.transparent,
                  selectedItemColor: Colors.white,
                  unselectedItemColor: Colors.grey,
                  currentIndex: _selectedIndex,
                  onTap: _onItemTapped,
                  type: BottomNavigationBarType.fixed,
                  items: const <BottomNavigationBarItem>[
                    BottomNavigationBarItem(
                      icon: Icon(Icons.home),
                      label: 'Home',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.search),
                      label: 'Search',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.add),
                      label: 'Add Post',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.account_circle),
                      label: 'Account',
                    ),
                  ],
                ),
              ),
            )
          : LoginScreen(onLogin: _handleLogin),
    );
  }
}
