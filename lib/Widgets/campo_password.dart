import 'package:flutter/material.dart';

class CampoPassword extends StatelessWidget {
  const CampoPassword({super.key});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      obscureText: true,
      decoration: const InputDecoration(
        labelText: 'Contraseña',
        border: OutlineInputBorder(),
      ),
      validator: (value) {
        if (value == null || value.length < 6) {
          return 'La contraseña debe tener al menos 6 caracteres';
        }

        return null;
      },
    );
  }
}