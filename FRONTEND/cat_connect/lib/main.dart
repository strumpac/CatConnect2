import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'account.dart';
import 'add_post.dart';
import 'home.dart';
import 'search.dart';
import 'login.dart';
import 'searched.dart'; 
import 'cat_snake.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  int _selectedIndex = 0;
  bool _isLoggedIn = false;
  String? _selectedUserId;

  static List<Widget> _widgetOptions = <Widget>[
    HomeScreen(),
    SearchScreen(),
    AddPostScreen(),
    SnakeGame(),
    AccountScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _checkLoginStatus(); // verifica il login all'avvio
  }

  // ✅ Verifica se esiste un token salvato
  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('authToken');

    if (token != null) {
      setState(() {
        _isLoggedIn = true;
      });
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      _selectedUserId = null;
    });
  }

  void _handleLogin(bool isLoggedIn) {
    setState(() {
      _isLoggedIn = isLoggedIn;
    });
  }

  void showUserProfileScreen(String userId) {
    setState(() {
      _selectedUserId = userId;
    });
  }

  void updateSelectedIndex(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void updateLogin(int index) {
    setState(() {
      _isLoggedIn = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cat Connect',
      theme: ThemeData(
        primaryColor: Colors.black,
        scaffoldBackgroundColor: Colors.white,
        colorScheme: const ColorScheme.light(
          primary: Colors.white,
          secondary: Colors.black,
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
                toolbarHeight: 48,
                title: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.pets, color: Colors.black, size: 24),
                    const SizedBox(width: 6),
                    Text(
                      'Cat Connect',
                      style: GoogleFonts.londrinaSolid(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Icon(Icons.pets, color: Colors.black, size: 24),
                  ],
                ),
                centerTitle: true,
                backgroundColor: Colors.white,
                foregroundColor: const Color(0x548ac6),
              ),
              body: _selectedUserId == null
                  ? _widgetOptions.elementAt(_selectedIndex)
                  : SearchedUserScreen(userId: _selectedUserId!),
              bottomNavigationBar: Container(
                decoration: const BoxDecoration(
                  color: Colors.black,
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
                      icon: Icon(Icons.gamepad),
                      label: 'Game',
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
