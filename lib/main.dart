import 'package:flutter/material.dart';
import 'splash.dart'; 

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // lab1 remove a faixa de debug
      title: 'NutriScan',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF344E41)),
        useMaterial3: true,
      ),
      home: const Scaffold(
        body:  Splash(),
      ),
    );
  }
}