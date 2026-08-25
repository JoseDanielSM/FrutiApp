import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

void main() {
  runApp(const FrutiApp());
}

class FrutiApp extends StatelessWidget {
  const FrutiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'FrutiApp Web',
      home: const LoginPage(),
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();

  bool recordarme = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 400,
          ),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'FrutiApp',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 20),

                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Correo electrónico',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Ingrese el correo';
                        }

                        if (!value.contains('@') ||
                            !value.contains('.')) {
                          return 'Correo no válido';
                        }

                        return null;
                      },
                    ),

                    const SizedBox(height: 15),

                    TextFormField(
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
                    ),

                    Row(
                      children: [
                        Checkbox(
                          value: recordarme,
                          onChanged: (value) {
                            setState(() {
                              recordarme = value ?? false;
                            });
                          },
                        ),
                        const Text('Recordarme'),
                      ],
                    ),

                    const SizedBox(height: 15),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const HomePage(),
                              ),
                            );
                          }
                        },
                        child: const Text('Ingresar'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

Future<List<dynamic>> cargarProductos() async {
  final response = await http.get(
    Uri.parse(
      'https://jsonplaceholder.typicode.com/posts',
    ),
  );

  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  }

  throw Exception(
    'No se pudo cargar la información',
  );
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<List<dynamic>> productos;

  // Lista de frutas para el catálogo
  final List<String> frutas = [
    'Manzana',
    'Banano',
    'Naranja',
    'Fresa',
    'Mango',
    'Piña',
    'Sandía',
    'Melón',
    'Papaya',
    'Uva',
    'Pera',
    'Durazno',
    'Ciruela',
    'Kiwi',
    'Granada',
    'Coco',
    'Guayaba',
    'Maracuyá',
    'Mandarina',
    'Limón',
    'Frambuesa',
    'Mora',
    'Arándano',
    'Cereza',
    'Higo',
    'Tamarindo',
    'Guanábana',
    'Níspero',
    'Carambola',
    'Pitahaya',
    'Lichi',
    'Rambután',
    'Mangostán',
    'Caqui',
    'Membrillo',
    'Toronja',
    'Aguacate',
    'Zapote',
    'Mamey',
    'Granadilla',
    'Jocote',
    'Mamón',
    'Cas',
    'Pejibaye',
    'Acerola',
    'Camu Camu',
    'Uchuva',
    'Tuna',
    'Dátil',
    'Higo Chumbo',
    'Manzana Verde',
    'Manzana Roja',
    'Mango Dorado',
    'Mango Rosado',
    'Fresa Dulce',
    'Fresa Silvestre',
    'Piña Tropical',
    'Piña Dorada',
    'Melón Dulce',
    'Sandía Roja',
    'Sandía Amarilla',
    'Naranja Dulce',
    'Naranja Sanguina',
    'Limón Verde',
    'Limón Dulce',
    'Mandarina Roja',
    'Mandarina Dulce',
    'Uva Morada',
    'Uva Verde',
    'Uva Negra',
    'Pera Dulce',
    'Pera Verde',
    'Durazno Rosado',
    'Durazno Dorado',
    'Ciruela Morada',
    'Ciruela Roja',
    'Kiwi Verde',
    'Kiwi Dorado',
    'Guayaba Rosada',
    'Guayaba Blanca',
    'Maracuyá Amarilla',
    'Maracuyá Morada',
    'Pitahaya Roja',
    'Pitahaya Blanca',
    'Pitahaya Dorada',
    'Mango Volcánico',
    'Mango Celestial',
    'Fresa Lunar',
    'Piña Esmeralda',
    'Sandía Gigante',
    'Melón Tropical',
    'Naranja Solar',
    'Guayaba Tropical',
    'Frambuesa Real',
    'Mora Silvestre',
    'Cereza Rubí',
    'Granada Carmesí',
    'Fruta Estelar',
  ];

  @override
  void initState() {
    super.initState();
    productos = cargarProductos();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FrutiApp'),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: productos,
        builder: (context, snapshot) {
          // Estado de carga
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          // Estado de error
          if (snapshot.hasError) {
            return const Center(
              child: Text(
                'No se pudo cargar la información.',
                style: TextStyle(
                  fontSize: 18,
                ),
              ),
            );
          }

          // Estado exitoso
          final productos = snapshot.data!;

          return ListView.builder(
            itemCount: productos.length,
            itemBuilder: (context, index) {
              final producto = productos[index];

              final int id = producto['id'];

              // Asignamos una fruta según el ID recibido de la API
              final String nombre = frutas[(id - 1) % frutas.length];

              final int precio = id * 100;

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
            },
          );
        },
      ),
    );
  }
}