import 'dart:convert';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'Widgets/boton_ingresar.dart';
import 'Widgets/campo_correo.dart';
import 'Widgets/campo_password.dart';
import 'Widgets/producto_card.dart';
import 'Widgets/titulo_app.dart';
import 'models/access_record.dart';
import 'services/access_log_service.dart';
import 'services/auth_service.dart';
import 'utils/json_download.dart' as json_download;

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
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
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
  final usuarioController = TextEditingController();
  final passwordController = TextEditingController();
  final logService = AccessLogService();

  bool recordarme = false;
  bool mostrarPassword = false;
  String mensaje = '';
  String filtroActual = 'Todos';

  List<AccessRecord> get registrosFiltrados {
    final registros = logService.records;
    switch (filtroActual) {
      case 'Exitosos':
        return registros.where((registro) => registro.exitoso).toList();
      case 'Fallidos':
        return registros.where((registro) => !registro.exitoso).toList();
      case 'Todos':
      default:
        return registros;
    }
  }

  int get totalRegistros => logService.records.length;
  int get totalExitosos => logService.records.where((r) => r.exitoso).length;
  double get tasaExito {
    if (totalRegistros == 0) return 0;
    return (totalExitosos / totalRegistros) * 100;
  }

  void validarAcceso() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final usuario = usuarioController.text.trim();
    final password = passwordController.text;
    final exitoso = AuthService.validateCredentials(usuario, password);

    logService.add(
      AccessRecord(
        usuario: usuario,
        fechaHora: DateTime.now(),
        exitoso: exitoso,
      ),
    );

    setState(() {
      mensaje = exitoso ? 'Acceso autorizado' : 'Usuario o contraseña incorrectos';
    });

    if (exitoso) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    }
  }

  Future<void> exportarBitacora() async {
    final registros = registrosFiltrados;
    if (registros.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No hay registros para exportar.')),
      );
      return;
    }

    final contenido = logService.exportJson(items: registros);
    await json_download.downloadJson(contenido, 'bitacora_accesos.json');
  }

  Future<void> importarBitacora() async {
    const typeGroup = XTypeGroup(
      label: 'JSON',
      extensions: ['json'],
      mimeTypes: ['application/json'],
    );

    final archivo = await openFile(acceptedTypeGroups: [typeGroup]);
    if (archivo == null) return;

    try {
      final contenido = await archivo.readAsString();
      logService.importJson(contenido);
      setState(() {});
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Importado correctamente')),
      );
    } on FormatException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Importado incorrectamente: ${error.message}')),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Importado incorrectamente')),
      );
    }
  }

  @override
  void dispose() {
    usuarioController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final anchoFormulario = constraints.maxWidth < 900 ? constraints.maxWidth * 0.92 : 420.0;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1100),
                  child: Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 24,
                    runSpacing: 24,
                    children: [
                      SizedBox(
                        width: anchoFormulario,
                        child: Card(
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const TituloApp(),
                                  const SizedBox(height: 20),
                                  CampoCorreo(controller: usuarioController),
                                  const SizedBox(height: 15),
                                  CampoPassword(
                                    controller: passwordController,
                                    obscureText: !mostrarPassword,
                                    suffixIcon: IconButton(
                                      onPressed: () {
                                        setState(() {
                                          mostrarPassword = !mostrarPassword;
                                        });
                                      },
                                      icon: Icon(
                                        mostrarPassword ? Icons.visibility_off : Icons.visibility,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
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
                                      const Expanded(child: Text('Recordarme')),
                                    ],
                                  ),
                                  const SizedBox(height: 15),
                                  BotonIngresar(
                                    onPressed: validarAcceso,
                                  ),
                                  if (mensaje.isNotEmpty) ...[
                                    const SizedBox(height: 16),
                                    Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: mensaje.contains('Autorizado')
                                            ? Colors.green.shade50
                                            : Colors.red.shade50,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        mensaje,
                                        style: TextStyle(
                                          color: mensaje.contains('Autorizado')
                                              ? Colors.green.shade800
                                              : Colors.red.shade800,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: constraints.maxWidth < 900 ? constraints.maxWidth * 0.92 : 520,
                        child: Card(
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Bitácora de accesos',
                                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  children: [
                                    ElevatedButton.icon(
                                      onPressed: exportarBitacora,
                                      icon: const Icon(Icons.download),
                                      label: const Text('Exportar JSON'),
                                    ),
                                    const SizedBox(width: 12),
                                    OutlinedButton.icon(
                                      onPressed: importarBitacora,
                                      icon: const Icon(Icons.upload_file),
                                      label: const Text('Importar JSON'),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Wrap(
                                  spacing: 8,
                                  children: ['Todos', 'Exitosos', 'Fallidos']
                                      .map(
                                        (filtro) => ChoiceChip(
                                          label: Text(filtro),
                                          selected: filtroActual == filtro,
                                          onSelected: (_) {
                                            setState(() {
                                              filtroActual = filtro;
                                            });
                                          },
                                        ),
                                      )
                                      .toList(),
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  children: [
                                    _Badge(label: 'Total', value: totalRegistros.toString()),
                                    const SizedBox(width: 12),
                                    _Badge(
                                      label: 'Éxitos',
                                      value: totalExitosos.toString(),
                                      color: Colors.green,
                                    ),
                                    const SizedBox(width: 12),
                                    _Badge(
                                      label: 'Tasa',
                                      value: '${tasaExito.toStringAsFixed(0)}%',
                                      color: Colors.blue,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                if (registrosFiltrados.isEmpty)
                                  const Padding(
                                    padding: EdgeInsets.symmetric(vertical: 12),
                                    child: Text('Sin registros para mostrar.'),
                                  )
                                else
                                  SizedBox(
                                    height: 350,
                                    child: ListView.builder(
                                      itemCount: registrosFiltrados.length,
                                      itemBuilder: (context, index) {
                                        final registro = registrosFiltrados[index];
                                        return ListTile(
                                          leading: Icon(
                                            registro.exitoso ? Icons.check_circle : Icons.cancel,
                                            color: registro.exitoso ? Colors.green : Colors.red,
                                          ),
                                          title: Text(
                                            registro.usuario.isEmpty ? '(sin usuario)' : registro.usuario,
                                            style: const TextStyle(fontWeight: FontWeight.w600),
                                          ),
                                          subtitle: Text(registro.fechaHora.toString()),
                                          trailing: Text(
                                            registro.exitoso ? 'OK' : 'FALLÓ',
                                            style: TextStyle(
                                              color: registro.exitoso ? Colors.green : Colors.red,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _Badge({
    required this.label,
    required this.value,
    this.color = Colors.grey,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 12)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

Future<List<dynamic>> cargarProductos() async {
  final response = await http.get(
    Uri.parse('https://jsonplaceholder.typicode.com/posts'),
  );

  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  }

  throw Exception('No se pudo cargar la información');
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<List<dynamic>> productos;

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
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(
              child: Text(
                'No se pudo cargar la información.',
                style: TextStyle(fontSize: 18),
              ),
            );
          }

          final datos = snapshot.data!;
          return ListView.builder(
            itemCount: datos.length,
            itemBuilder: (context, index) {
              final producto = datos[index];
              final int id = producto['id'];
              final String nombre = frutas[(id - 1) % frutas.length];
              final int precio = id * 100;

              return ProductoCard(nombre: nombre, id: id, precio: precio);
            },
          );
        },
      ),
    );
  }
}