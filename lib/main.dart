import 'package:flutter/material.dart';
import 'screens/main_menu_screen.dart';

void main() {
  runApp(const CarmoleApp());
}

class CarmoleApp extends StatelessWidget {
  const CarmoleApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Carmole',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.brown,
        brightness: Brightness.dark,
      ),
      home: const MainMenuScreen(),
    );
  }
}

// COMMENT FOR COMMIT 