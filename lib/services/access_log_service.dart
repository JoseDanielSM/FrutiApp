import 'dart:convert';

import '../models/access_record.dart';

class AccessLogService {
  final List<AccessRecord> _records = [];

  List<AccessRecord> get records => List.unmodifiable(_records);

  void add(AccessRecord record) => _records.add(record);

  void clear() => _records.clear();

  String exportJson({List<AccessRecord>? items}) {
    final data = (items ?? _records).map((record) => record.toJson()).toList();
    return const JsonEncoder.withIndent(' ').convert(data);
  }

  void importJson(String source) {
    final decoded = jsonDecode(source);

    if (decoded is! List) {
      throw const FormatException('El JSON debe contener una lista');
    }

    final loaded = <AccessRecord>[];

    for (final item in decoded) {
      if (item is! Map) {
        throw const FormatException('Cada elemento del JSON debe ser un objeto');
      }

      final recordMap = Map<String, dynamic>.from(item);
      loaded.add(AccessRecord.fromJson(recordMap));
    }

    _records
      ..clear()
      ..addAll(loaded);
  }
}
