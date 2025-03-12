import 'package:flutter/material.dart';
//importo le varie schermate
import 'account.dart';
import 'add_post.dart';
import 'home.dart';
import 'search.dart';
import 'login.dart';
//import delle librerie utilizzate

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

//setState del nuovo indice della pagina
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
      title: 'Flutter App con BottomNavBar',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.white, // Colore di sfondo del body
      ),
      home: _isLoggedIn
          ?  Scaffold(
        appBar: AppBar(
          title: Text('Cat Connect'),
        ),
        body: _widgetOptions
            .elementAt(_selectedIndex), // Mostra la schermata selezionata
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex, // Indica l'indice della schermata corrente
          onTap: _onItemTapped, // Cambia schermata quando selezionato un item
          backgroundColor: Colors.black, // Imposta il colore di sfondo a nero
          selectedItemColor: Colors.black, // Colore dell'elemento selezionato (bianco)
          unselectedItemColor: Colors.grey, // Colore degli elementi non selezionati (grigio)
          iconSize: 35.0, // Imposta la dimensione dell'icona (35.0 è un buon valore per ingrandirle)
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
      )
  
          : LoginScreen(onLogin: _handleLogin), // Se non loggato, mostra la pagina di login
    );
  }
}