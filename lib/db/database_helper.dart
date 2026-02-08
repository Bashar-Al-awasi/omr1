import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/student.dart';
import '../models/exam.dart';
import '../models/result.dart';
import '../models/question.dart';

class DatabaseHelper {
    // Question methods
    Future<int> insertQuestion(Question question) async {
      final database = await db;
      return await database.insert('questions', question.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
    }

    Future<List<Question>> getQuestionsByExamId(int examId) async {
      final database = await db;
      final res = await database.query('questions', where: 'exam_id = ?', whereArgs: [examId], orderBy: 'question_number ASC');
      return res.map((e) => Question.fromMap(e)).toList();
    }

    Future<void> clearQuestions() async {
      final database = await db;
      await database.delete('questions');
    }
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
        student_id TEXT UNIQUE,
        name TEXT,
        subject TEXT,
        notes TEXT,
        title TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE exams (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT,
        subject TEXT,
        date TEXT,
        num_questions INTEGER,
        num_choices INTEGER,
        answer_key TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE questions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        exam_id INTEGER,
        question_number INTEGER,
        correct_choice INTEGER,
        mark INTEGER,
        FOREIGN KEY(exam_id) REFERENCES exams(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE results (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        exam_id INTEGER,
        student_id TEXT,
        score INTEGER,
        answers TEXT,
        date TEXT,
        FOREIGN KEY(exam_id) REFERENCES exams(id),
        FOREIGN KEY(student_id) REFERENCES students(student_id)
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

  // Exam methods
  Future<int> insertExam(Exam exam) async {
    final database = await db;
    return await database.insert('exams', exam.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Exam>> getAllExams() async {
    final database = await db;
    final res = await database.query('exams', orderBy: 'date DESC');
    return res.map((e) => Exam.fromMap(e)).toList();
  }

  Future<Exam?> getExamById(int id) async {
    final database = await db;
    final res = await database.query('exams', where: 'id = ?', whereArgs: [id]);
    if (res.isEmpty) return null;
    return Exam.fromMap(res.first);
  }

  Future<void> clearExams() async {
    final database = await db;
    await database.delete('exams');
  }

  // Result methods
  Future<int> insertResult(Result result) async {
    final database = await db;
    return await database.insert('results', result.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Result>> getResultsByExamId(int examId) async {
    final database = await db;
    final res = await database.query('results', where: 'exam_id = ?', whereArgs: [examId], orderBy: 'score DESC');
    return res.map((e) => Result.fromMap(e)).toList();
  }

  Future<List<Result>> getResultsByStudentId(String studentId) async {
    final database = await db;
    final res = await database.query('results', where: 'student_id = ?', whereArgs: [studentId], orderBy: 'date DESC');
    return res.map((e) => Result.fromMap(e)).toList();
  }

  Future<void> clearResults() async {
    final database = await db;
    await database.delete('results');
  }
}
