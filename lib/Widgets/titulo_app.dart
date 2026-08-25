import 'package:flutter/material.dart';

class TituloApp extends StatelessWidget {
  const TituloApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const Text(
      'FrutiApp',
      style: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}