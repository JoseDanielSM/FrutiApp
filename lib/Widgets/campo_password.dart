import 'package:flutter/material.dart';

class CampoPassword extends StatelessWidget {
  final TextEditingController controller;
  final bool obscureText;
  final Widget? suffixIcon;

  const CampoPassword({
    super.key,
    required this.controller,
    this.obscureText = true,
    this.suffixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: 'Contraseña',
        border: const OutlineInputBorder(),
        suffixIcon: suffixIcon,
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