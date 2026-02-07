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
        bool skipFirst = false;
        if (lines.isNotEmpty) {
          final firstParts = lines.first.split(RegExp(r',|;|\t')).map((p) => p.replaceAll('"', '').trim().toLowerCase()).toList();
          if (firstParts.isNotEmpty && (firstParts[0].contains('id') || (firstParts.length > 1 && firstParts[1].contains('name')))) skipFirst = true;
        }
        for (var i = 0; i < lines.length; i++) {
          if (i == 0 && skipFirst) continue;
          final line = lines[i];
          if (line.trim().isEmpty) continue;
          final parts = line.split(RegExp(r',|;|\t'));
          if (parts.isEmpty) continue;
          String id = parts.length > 0 ? parts[0].trim() : '';
          String name = parts.length > 1 ? parts[1].trim() : '';
          // remove surrounding quotes
          id = id.replaceAll(RegExp(r'^"|"$'), '');
          name = name.replaceAll(RegExp(r'^"|"$'), '');
          if (id.isNotEmpty || name.isNotEmpty) parsed.add(Student(studentId: id, name: name));
        }
      } else if (lower.endsWith('.xls') || lower.endsWith('.xlsx')) {
        final bytes = await file.readAsBytes();
        final excel = Excel.decodeBytes(bytes);
        for (var sheetName in excel.tables.keys) {
          final sheet = excel.tables[sheetName]!;
          // detect header in first row
          bool skipFirst = false;
          if (sheet.maxRows > 0) {
            final firstRow = sheet.row(0);
            if (firstRow.isNotEmpty) {
              final a = (firstRow[0]?.value ?? '').toString().toLowerCase();
              final b = firstRow.length > 1 ? (firstRow[1]?.value ?? '').toString().toLowerCase() : '';
              if (a.contains('id') || b.contains('name')) skipFirst = true;
            }
          }
          for (var r = 0; r < sheet.maxRows; r++) {
            if (r == 0 && skipFirst) continue;
            final row = sheet.row(r);
            if (row.isEmpty) continue;
            final idCell = row.isNotEmpty && row[0] != null ? row[0] : null;
            final nameCell = row.length > 1 && row[1] != null ? row[1] : null;
            final id = idCell != null ? (idCell.value ?? idCell.toString()).toString().trim() : '';
            final name = nameCell != null ? (nameCell.value ?? nameCell.toString()).toString().trim() : '';
            if (id.isNotEmpty || name.isNotEmpty) parsed.add(Student(studentId: id, name: name));
          }
          break; // only process first sheet
        }
      }

      if (parsed.isNotEmpty) await addStudents(parsed);
    } catch (e) {
      if (kDebugMode) print('Import error: $e');
      rethrow;
    }
  }
}
