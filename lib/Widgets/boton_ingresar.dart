import 'package:flutter/material.dart';

class BotonIngresar extends StatelessWidget {
  final VoidCallback onPressed;

  const BotonIngresar({
    super.key,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        child: const Text('Ingresar'),
      ),
    );
  }
}