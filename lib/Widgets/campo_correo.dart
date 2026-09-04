import 'package:flutter/material.dart';

class CampoCorreo extends StatelessWidget {
  final TextEditingController controller;

  const CampoCorreo({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: const InputDecoration(
        labelText: 'Correo electrónico',
        border: OutlineInputBorder(),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Ingrese el correo';
        }

        if (!value.contains('@') || !value.contains('.')) {
          return 'Correo no válido';
        }

        return null;
      },
    );
  }
}