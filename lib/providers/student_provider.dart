import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:excel/excel.dart';
import '../db/database_helper.dart';
import '../models/student.dart';

class StudentProvider extends ChangeNotifier {
  final DatabaseHelper _db = DatabaseHelper();
  List<Student> students = [];
  String? _userId;

  void updateUserId(String? id) {
    if (_userId != id) {
      _userId = id;
      load();
    }
  }

  Future<void> load() async {
    students = await _db.getAllStudents(_userId);
    notifyListeners();
  }

  Future<void> addStudents(List<Student> list) async {
    for (var s in list) {
      final sWithUser = Student(
        studentId: s.studentId,
        name: s.name,
        subject: s.subject,
        notes: s.notes,
        title: s.title,
        userId: _userId,
      );
      await _db.insertStudent(sWithUser);
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
    return await _db.getStudentByStudentId(id, _userId);
  }

  Future<void> importFromFileWithMeta(File file, String subject, String title) async {
    final lower = file.path.toLowerCase();
    final List<Student> parsed = [];

    try {
      if (lower.endsWith('.csv') || lower.endsWith('.txt')) {
        final content = await file.readAsString();
        final lines = content.split(RegExp(r"\r?\n"));
        bool skipFirst = false;
        if (lines.isNotEmpty) {
          final firstParts = lines.first.split(RegExp(r',|;|\t')).map((p) => p.replaceAll('"', '').trim().toLowerCase()).toList();
          if (firstParts.any((p) => p.contains('sno') || p.contains('id') || p.contains('name') || p.contains('title'))) skipFirst = true;
        }
        for (var i = 0; i < lines.length; i++) {
          if (i == 0 && skipFirst) continue;
          final line = lines[i];
          if (line.trim().isEmpty) continue;
          final parts = line.split(RegExp(r',|;|\t'));
          if (parts.length < 3) continue;
          final sno = parts[0].trim();
          String name = parts[1].trim();
          String id = parts[2].trim();
          if (sno.isEmpty || int.tryParse(sno) == null) continue;
          id = id.replaceAll(RegExp(r'^"|"$'), '');
          name = name.replaceAll(RegExp(r'^"|"$'), '');
          if (id.isNotEmpty && name.isNotEmpty) {
            parsed.add(Student(
              studentId: id, 
              name: name, 
              subject: subject, 
              title: title, 
              userId: _userId
            ));
          }
        }
      } else if (lower.endsWith('.xls') || lower.endsWith('.xlsx')) {
        final bytes = await file.readAsBytes();
        final excel = Excel.decodeBytes(bytes);
        for (var sheetName in excel.tables.keys) {
          final sheet = excel.tables[sheetName]!;
          bool skipFirst = false;
          if (sheet.maxRows > 0) {
            final firstRow = sheet.row(0);
            if (firstRow.isNotEmpty) {
              final values = firstRow.map((cell) => (cell?.value ?? '').toString().toLowerCase()).toList();
              if (values.any((v) => v.contains('sno') || v.contains('id') || v.contains('name') || v.contains('title'))) skipFirst = true;
            }
          }
          for (var r = 0; r < sheet.maxRows; r++) {
            if (r == 0 && skipFirst) continue;
            final row = sheet.row(r);
            if (row.length < 3) continue;
            final snoCell = row[0];
            final nameCell = row[1];
            final idCell = row[2];
            final sno = (snoCell?.value ?? snoCell.toString()).toString().trim();
            final name = (nameCell?.value ?? nameCell.toString()).toString().trim();
            final id = (idCell?.value ?? idCell.toString()).toString().trim();
            if (sno.isEmpty || int.tryParse(sno) == null) continue;
            if (id.isNotEmpty && name.isNotEmpty) {
              parsed.add(Student(
                studentId: id, 
                name: name, 
                subject: subject, 
                title: title, 
                userId: _userId
              ));
            }
          }
          break;
        }
      }

      if (parsed.isNotEmpty) await addStudents(parsed);
    } catch (e) {
      if (kDebugMode) print('Import error: $e');
      rethrow;
    }
  }
}
