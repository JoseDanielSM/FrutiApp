import 'package:flutter/material.dart';

class ProductoCard extends StatelessWidget {
  final String nombre;
  final int id;
  final int precio;

  const ProductoCard({
    super.key,
    required this.nombre,
    required this.id,
    required this.precio,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 8,
      ),
      child: ListTile(
        title: Text(
          nombre,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          'Precio: $precio colones',
        ),
        trailing: Text(
          'ID: $id',
        ),
      ),
    );
  }
}