import 'package:flutter_test/flutter_test.dart';
import 'package:frutiapp_web/models/access_record.dart';
import 'package:frutiapp_web/services/access_log_service.dart';
import 'package:frutiapp_web/services/auth_service.dart';

void main() {
  group('AccessLogService', () {
    test('exporta solo usuario, fechaHora y resultado', () {
      final service = AccessLogService();
      service.add(
        AccessRecord(
          usuario: 'admin',
          fechaHora: DateTime(2026, 9, 3, 12, 0, 0),
          exitoso: true,
        ),
      );

      final json = service.exportJson();

      expect(json, contains('"usuario": "admin"'));
      expect(json, contains('"exitoso": true'));
      expect(json, isNot(contains('password')));
      expect(json, isNot(contains('contraseña')));
    });

    test('importa registros desde JSON válido', () {
      final service = AccessLogService();
      const source = '''[
        {
          "usuario": "admin",
          "fechaHora": "2026-09-03T12:00:00.000",
          "exitoso": true
        },
        {
          "usuario": "guest",
          "fechaHora": "2026-09-03T12:05:00.000",
          "exitoso": false
        }
      ]''';

      service.importJson(source);

      expect(service.records.length, 2);
      expect(service.records.first.usuario, 'admin');
      expect(service.records.last.exitoso, isFalse);
    });

    test('lanza error si el JSON no es una lista', () {
      final service = AccessLogService();

      expect(
        () => service.importJson('{"usuario": "admin"}'),
        throwsA(isA<FormatException>()),
      );
    });

    test('lanza error si faltan campos obligatorios del registro', () {
      final service = AccessLogService();

      expect(
        () => service.importJson('[{"usuario": "admin", "fechaHora": "2026-09-03T12:00:00.000"}]'),
        throwsA(isA<FormatException>()),
      );
    });

    test('exporta origen y acepta JSON con origen opcional', () {
      final service = AccessLogService();

      service.add(
        AccessRecord(
          usuario: 'admin@gmail.com',
          fechaHora: DateTime(2026, 9, 3, 12, 0, 0),
          exitoso: true,
        ),
      );

      final exported = service.exportJson();
      expect(exported, contains('"origen": "Web"'));

      const source = '''[
        {
          "usuario": "guest@demo.com",
          "fechaHora": "2026-09-03T12:00:00.000",
          "exitoso": false,
          "origen": "Web"
        }
      ]''';

      service.importJson(source);
      expect(service.records.first.usuario, 'guest@demo.com');
      expect(service.records.first.origen, 'Web');
    });

    test('acepta las credenciales por defecto de la app', () {
      expect(
        AuthService.validateCredentials('admin@gmail.com', '123456'),
        isTrue,
      );

      expect(
        AuthService.validateCredentials('admin@gmail.com', '000000'),
        isFalse,
      );
    });
  });
}
