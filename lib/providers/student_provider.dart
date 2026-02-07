import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:excel/excel.dart';
import '../db/database_helper.dart';
import '../models/student.dart';

class StudentProvider extends ChangeNotifier {
  final DatabaseHelper _db = DatabaseHelper();
  List<Student> students = [];

  StudentProvider() {
    load();
  }

  Future<void> load() async {
    students = await _db.getAllStudents();
    notifyListeners();
  }

  Future<void> addStudents(List<Student> list) async {
    for (var s in list) {
      await _db.insertStudent(s);
    }
    await load();
  }

  Future<Student?> findByStudentId(String id) async {
    if (id.trim().isEmpty) return null;
    // try in-memory first
    try {
      final inMem = students.firstWhere((s) => s.studentId == id, orElse: () => Student(studentId: '', name: ''));
      if (inMem.studentId.isNotEmpty) return inMem;
    } catch (_) {}
    // fallback to DB
    return await _db.getStudentByStudentId(id);
  }

  Future<void> importFromFile(File file) async {
    final lower = file.path.toLowerCase();
    final List<Student> parsed = [];

    try {
      if (lower.endsWith('.csv') || lower.endsWith('.txt')) {
        final content = await file.readAsString();
        final lines = content.split(RegExp(r"\r?\n"));
        for (var line in lines) {
          if (line.trim().isEmpty) continue;
          final parts = line.split(',');
          if (parts.isEmpty) continue;
          final id = parts.length > 0 ? parts[0].trim() : '';
          final name = parts.length > 1 ? parts[1].trim() : '';
          if (id.isNotEmpty || name.isNotEmpty) parsed.add(Student(studentId: id, name: name));
        }
      } else if (lower.endsWith('.xls') || lower.endsWith('.xlsx')) {
        final bytes = await file.readAsBytes();
        final excel = Excel.decodeBytes(bytes);
        for (var sheetName in excel.tables.keys) {
          final sheet = excel.tables[sheetName]!;
          for (var row in sheet.rows) {
            if (row.isEmpty) continue;
            final id = row.isNotEmpty && row[0] != null ? '${row[0]}' : '';
            final name = row.length > 1 && row[1] != null ? '${row[1]}' : '';
            if (id.isNotEmpty || name.isNotEmpty) parsed.add(Student(studentId: id, name: name));
          }
        }
      }

      if (parsed.isNotEmpty) await addStudents(parsed);
    } catch (e) {
      if (kDebugMode) print('Import error: $e');
      rethrow;
    }
  }
}
