import 'package:flutter_test/flutter_test.dart';
import 'package:frutiapp_web/models/access_record.dart';
import 'package:frutiapp_web/services/access_log_service.dart';

void main() {
  group('Access log behavior', () {
    test('stores valid access information without passwords', () {
      final service = AccessLogService();

      service.add(
        AccessRecord(
          usuario: 'admin@gmail.com',
          fechaHora: DateTime(2026, 9, 3, 10, 0, 0),
          exitoso: true,
        ),
      );

      expect(service.records.length, 1);
      expect(service.records.first.usuario, 'admin');
      expect(service.records.first.exitoso, isTrue);
      expect(service.exportJson(), isNot(contains('123456')));
    });

    test('imports JSON and clears invalid fields', () {
      final service = AccessLogService();
      const source = '''[
        {"usuario":"user1","fechaHora":"2026-09-03T10:00:00.000","exitoso":true},
        {"usuario":"user2","fechaHora":"2026-09-03T10:05:00.000","exitoso":false}
      ]''';

      service.importJson(source);

      expect(service.records.length, 2);
      expect(service.records[1].usuario, 'user2');
      expect(service.records[1].exitoso, isFalse);
    });
  });
}
