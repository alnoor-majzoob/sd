import 'package:excel/excel.dart';

class ParsingUtils {
  static String asString(Data? cell) {
    final value = cell?.value;
    if (value == null) return '';
    return value.toString().trim();
  }

  static int asInt(Data? cell, {int defaultValue = 0}) {
    final raw = asString(cell);
    if (raw.isEmpty) return defaultValue;
    return int.tryParse(raw.split('.').first) ?? defaultValue;
  }

  static num asNum(Data? cell, {num defaultValue = 0}) {
    final raw = asString(cell);
    if (raw.isEmpty) return defaultValue;
    return num.tryParse(raw) ?? defaultValue;
  }

  static bool asBoolFromYesNo(Data? cell) {
    final raw = asString(cell).toLowerCase();
    return raw == 'yes' || raw == 'true' || raw == '1';
  }

  static DateTime? asDate(Data? cell) {
    if (cell == null) return null;
    final value = cell.value;
    if (value == null) return null;

    if (value is DateCellValue) return value.asDateTimeLocal();
    if (value is DateTimeCellValue) return value.asDateTimeLocal();

    final raw = value.toString().trim();
    if (raw.isEmpty || raw == 'null') return null;

    final parsed = DateTime.tryParse(raw);
    if (parsed != null) return parsed;

    final serial = double.tryParse(raw);
    if (serial != null) {
      return DateTime(1899, 12, 30).add(Duration(days: serial.floor()));
    }

    return null;
  }

  static List<String> splitCsv(String raw) => raw
      .split(',')
      .map((e) => e.trim())
      .where((e) => e.isNotEmpty)
      .toList();

  static List<DateTime> splitDateList(String raw) => raw
      .split(';')
      .map((e) => DateTime.tryParse(e.trim()))
      .whereType<DateTime>()
      .toList();
}
