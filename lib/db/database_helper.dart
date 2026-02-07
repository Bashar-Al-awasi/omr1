import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/student.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _db;

  Future<Database> get db async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'omr1.db');

    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  FutureOr<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE students (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        student_id TEXT,
        name TEXT
      )
    ''');
  }

  Future<int> insertStudent(Student s) async {
    final database = await db;
    return await database.insert('students', s.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Student>> getAllStudents() async {
    final database = await db;
    final res = await database.query('students', orderBy: 'name COLLATE NOCASE');
    return res.map((e) => Student.fromMap(e)).toList();
  }

  Future<Student?> getStudentByStudentId(String studentId) async {
    final database = await db;
    final res = await database.query('students', where: 'student_id = ?', whereArgs: [studentId]);
    if (res.isEmpty) return null;
    return Student.fromMap(res.first);
  }

  Future<void> clearStudents() async {
    final database = await db;
    await database.delete('students');
  }
}
