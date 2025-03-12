import 'package:flutter/material.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Benvenuto nel tuo Account!',
        style: TextStyle(fontSize: 24),
      ),
    );
  }
}
