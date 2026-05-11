import 'package:flutter/material.dart';
import 'package:isloation/feature/isloation_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
      
        colorScheme: .fromSeed(seedColor: Colors.deepPurple),
      ),
      home: TweenAnimationScreen()
    );
  }
}