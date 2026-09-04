class AccessRecord {
  final String usuario;
  final DateTime fechaHora;
  final bool exitoso;
  final String origen;

  const AccessRecord({
    required this.usuario,
    required this.fechaHora,
    required this.exitoso,
    this.origen = 'Web',
  });

  Map<String, dynamic> toJson() => {
        'usuario': usuario,
        'fechaHora': fechaHora.toIso8601String(),
        'exitoso': exitoso,
        'origen': origen,
      };

  factory AccessRecord.fromJson(Map<String, dynamic> json) {
    final usuario = json['usuario'];
    if (usuario is! String || usuario.trim().isEmpty) {
      throw const FormatException('El campo "usuario" debe ser texto no vacío');
    }

    final fechaHoraValue = json['fechaHora'];
    if (fechaHoraValue is! String) {
      throw const FormatException('El campo "fechaHora" debe ser texto');
    }

    final fechaHora = DateTime.tryParse(fechaHoraValue);
    if (fechaHora == null) {
      throw const FormatException('El campo "fechaHora" no es una fecha válida');
    }

    final exitoso = json['exitoso'];
    if (exitoso is! bool) {
      throw const FormatException('El campo "exitoso" debe ser un valor booleano');
    }

    final origenValue = json['origen'];
    final origen = origenValue is String && origenValue.trim().isNotEmpty
        ? origenValue
        : 'Web';

    return AccessRecord(
      usuario: usuario,
      fechaHora: fechaHora,
      exitoso: exitoso,
      origen: origen,
    );
  }
}
