import 'package:flutter/material.dart';
//font
import 'package:google_fonts/google_fonts.dart';
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
        primaryColor: Colors.white,
        scaffoldBackgroundColor: Colors.white,
        colorScheme: const ColorScheme.light(
          primary: Colors.white,
          secondary: Colors.black,
          background: Color(0xFFFFF3E0),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.white,
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Colors.black,
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.grey,
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
                title: Row(
                  mainAxisSize: MainAxisSize
                      .min, // Mantiene gli elementi centrati e compatti
                  children: [
                    Icon(Icons.pets,
                        color: Colors.black, size: 30), // Zampetta a sinistra
                    const SizedBox(width: 8), // Spazio tra icona e testo
                    Text(
                      'Cat Connect',
                      style: GoogleFonts.londrinaSolid(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(width: 8), // Spazio tra testo e icona
                    Icon(Icons.pets,
                        color: Colors.black, size: 30), // Zampetta a destra
                  ],
                ),
                centerTitle: true, // Mantiene il tutto centrato
                backgroundColor: Colors.white,
                foregroundColor: Color(0x548ac6), // Colore del titolo
              ),
              body: _widgetOptions.elementAt(_selectedIndex),
              bottomNavigationBar: Container(
                decoration: const BoxDecoration(
                  color: Colors.black, // Viola
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
