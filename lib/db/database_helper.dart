import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/student.dart';
import '../models/exam.dart';
import '../models/result.dart';
import '../models/question.dart';

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

    return await openDatabase(
      path,
      version: 4, // v4: added needs_sync flag to reduce Firestore writes
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  FutureOr<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE results ADD COLUMN student_name TEXT');
    }
    if (oldVersion < 3) {
      await db.execute('ALTER TABLE students ADD COLUMN user_id TEXT');
      await db.execute('ALTER TABLE exams ADD COLUMN user_id TEXT');
      await db.execute('ALTER TABLE results ADD COLUMN user_id TEXT');
    }
    if (oldVersion < 4) {
      // Mark all existing rows as needing sync (1 = unsynced)
      await db.execute('ALTER TABLE students ADD COLUMN needs_sync INTEGER DEFAULT 1');
      await db.execute('ALTER TABLE exams ADD COLUMN needs_sync INTEGER DEFAULT 1');
      await db.execute('ALTER TABLE results ADD COLUMN needs_sync INTEGER DEFAULT 1');
      await db.execute('UPDATE students SET needs_sync = 1');
      await db.execute('UPDATE exams SET needs_sync = 1');
      await db.execute('UPDATE results SET needs_sync = 1');
    }
  }

  FutureOr<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE students (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        student_id TEXT,
        name TEXT,
        subject TEXT,
        notes TEXT,
        title TEXT,
        user_id TEXT,
        needs_sync INTEGER DEFAULT 1
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
        answer_key TEXT,
        user_id TEXT,
        needs_sync INTEGER DEFAULT 1
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
        student_name TEXT,
        score INTEGER,
        answers TEXT,
        date TEXT,
        user_id TEXT,
        needs_sync INTEGER DEFAULT 1,
        FOREIGN KEY(exam_id) REFERENCES exams(id),
        FOREIGN KEY(student_id) REFERENCES students(student_id)
      )
    ''');
  }

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

  // Student methods
  Future<int> insertStudent(Student s) async {
    final database = await db;
    return await database.insert('students', s.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Student>> getAllStudents(String? userId) async {
    final database = await db;
    final res = await database.query(
      'students', 
      where: 'user_id = ? OR user_id IS NULL', 
      whereArgs: [userId], 
      orderBy: 'name COLLATE NOCASE'
    );
    return res.map((e) => Student.fromMap(e)).toList();
  }

  Future<Student?> getStudentByStudentId(String studentId, String? userId) async {
    final database = await db;
    final res = await database.query(
      'students', 
      where: 'student_id = ? AND (user_id = ? OR user_id IS NULL)', 
      whereArgs: [studentId, userId]
    );
    if (res.isEmpty) return null;
    return Student.fromMap(res.first);
  }

  Future<void> clearStudents(String? userId) async {
    final database = await db;
    await database.delete('students', where: 'user_id = ?', whereArgs: [userId]);
  }

  Future<void> deleteStudentsByGroup(String title, String subject, String? userId) async {
    final database = await db;
    await database.delete(
      'students', 
      where: 'title = ? AND subject = ? AND (user_id = ? OR user_id IS NULL)', 
      whereArgs: [title, subject, userId]
    );
  }

  // Exam methods
  Future<int> insertExam(Exam exam) async {
    final database = await db;
    return await database.insert('exams', exam.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Exam>> getAllExams(String? userId) async {
    final database = await db;
    final res = await database.query(
      'exams', 
      where: 'user_id = ? OR user_id IS NULL', 
      whereArgs: [userId], 
      orderBy: 'date DESC'
    );
    return res.map((e) => Exam.fromMap(e)).toList();
  }

  Future<Exam?> getExamById(int id, String? userId) async {
    final database = await db;
    final res = await database.query(
      'exams', 
      where: 'id = ? AND (user_id = ? OR user_id IS NULL)', 
      whereArgs: [id, userId]
    );
    if (res.isEmpty) return null;
    return Exam.fromMap(res.first);
  }

  Future<void> clearExams(String? userId) async {
    final database = await db;
    await database.delete('exams', where: 'user_id = ?', whereArgs: [userId]);
  }

  Future<int> updateExam(Exam exam) async {
    final database = await db;
    final data = exam.toMap()..['needs_sync'] = 1; // flag for re-sync
    return await database.update(
      'exams',
      data,
      where: 'id = ?',
      whereArgs: [exam.id],
    );
  }

  Future<int> updateQuestion(Question question) async {
    final database = await db;
    return await database.update(
      'questions',
      question.toMap(),
      where: 'id = ?',
      whereArgs: [question.id],
    );
  }

  /// Deletes an exam and ALL its questions + results (cascade)
  Future<void> deleteExam(int examId, String? userId) async {
    final database = await db;
    await database.delete('results', where: 'exam_id = ?', whereArgs: [examId]);
    await database.delete('questions', where: 'exam_id = ?', whereArgs: [examId]);
    await database.delete('exams', where: 'id = ? AND (user_id = ? OR user_id IS NULL)', whereArgs: [examId, userId]);
  }

  Future<void> deleteResultsByExamId(int examId) async {
    final database = await db;
    await database.delete('results', where: 'exam_id = ?', whereArgs: [examId]);
  }

  Future<void> deleteResult(int resultId) async {
    final database = await db;
    await database.delete('results', where: 'id = ?', whereArgs: [resultId]);
  }

  // Result methods
  Future<int> insertResult(Result result) async {
    final database = await db;
    return await database.insert('results', result.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Result>> getResultsByExamId(int examId, String? userId) async {
    final database = await db;
    final res = await database.query(
      'results', 
      where: 'exam_id = ? AND (user_id = ? OR user_id IS NULL)', 
      whereArgs: [examId, userId], 
      orderBy: 'score DESC'
    );
    return res.map((e) => Result.fromMap(e)).toList();
  }

  Future<List<Result>> getResultsByStudentId(String studentId, String? userId) async {
    final database = await db;
    final res = await database.query(
      'results', 
      where: 'student_id = ? AND (user_id = ? OR user_id IS NULL)', 
      whereArgs: [studentId, userId], 
      orderBy: 'date DESC'
    );
    return res.map((e) => Result.fromMap(e)).toList();
  }

  Future<void> clearResults(String? userId) async {
    final database = await db;
    await database.delete('results', where: 'user_id = ?', whereArgs: [userId]);
  }

  Future<List<Result>> getResultsByUserId(String? userId) async {
    final database = await db;
    final res = await database.query(
      'results', 
      where: 'user_id = ? OR user_id IS NULL', 
      whereArgs: [userId], 
      orderBy: 'date DESC'
    );
    return res.map((e) => Result.fromMap(e)).toList();
  }

  // Dashboard Stats
  Future<Map<String, dynamic>> getDashboardStats(String? userId) async {
    final database = await db;
    
    final examCount = Sqflite.firstIntValue(await database.rawQuery(
      'SELECT COUNT(*) FROM exams WHERE user_id = ? OR user_id IS NULL', [userId]
    )) ?? 0;
    final resultCount = Sqflite.firstIntValue(await database.rawQuery(
      'SELECT COUNT(*) FROM results WHERE user_id = ? OR user_id IS NULL', [userId]
    )) ?? 0;
    
    final avgScoreRes = await database.rawQuery(
      'SELECT AVG(score) as avgScore FROM results WHERE user_id = ? OR user_id IS NULL', [userId]
    );
    double avgScore = 0;
    if (avgScoreRes.isNotEmpty && avgScoreRes.first['avgScore'] != null) {
      avgScore = (avgScoreRes.first['avgScore'] as num).toDouble();
    }

    return {
      'totalExams': examCount,
      'totalSheets': resultCount,
      'avgScore': avgScore,
    };
  }

  Future<void> repairOrphanedData(String userId) async {
    final database = await db;
    // Update students
    await database.update(
      'students', 
      {'user_id': userId}, 
      where: 'user_id IS NULL'
    );
    // Update exams
    await database.update(
      'exams', 
      {'user_id': userId}, 
      where: 'user_id IS NULL'
    );
    // Update results
    await database.update(
      'results', 
      {'user_id': userId}, 
      where: 'user_id IS NULL'
    );
  }

  // ── Needs-sync helpers ─────────────────────────────────────────────────────

  /// Returns only students that haven't been pushed to Firestore yet.
  Future<List<Student>> getUnsyncedStudents(String? userId) async {
    final database = await db;
    final res = await database.query(
      'students',
      where: '(user_id = ? OR user_id IS NULL) AND needs_sync = 1',
      whereArgs: [userId],
    );
    return res.map((e) => Student.fromMap(e)).toList();
  }

  /// Returns only exams that haven't been pushed to Firestore yet.
  Future<List<Exam>> getUnsyncedExams(String? userId) async {
    final database = await db;
    final res = await database.query(
      'exams',
      where: '(user_id = ? OR user_id IS NULL) AND needs_sync = 1',
      whereArgs: [userId],
      orderBy: 'date DESC',
    );
    return res.map((e) => Exam.fromMap(e)).toList();
  }

  /// Returns only results that haven't been pushed to Firestore yet.
  Future<List<Result>> getUnsyncedResults(String? userId) async {
    final database = await db;
    final res = await database.query(
      'results',
      where: '(user_id = ? OR user_id IS NULL) AND needs_sync = 1',
      whereArgs: [userId],
    );
    return res.map((e) => Result.fromMap(e)).toList();
  }

  Future<void> markStudentSynced(String studentId) async {
    final database = await db;
    await database.update('students', {'needs_sync': 0},
        where: 'student_id = ?', whereArgs: [studentId]);
  }

  Future<void> markExamSynced(int examId) async {
    final database = await db;
    await database.update('exams', {'needs_sync': 0},
        where: 'id = ?', whereArgs: [examId]);
  }

  Future<void> markResultSynced(int examId, String studentId) async {
    final database = await db;
    await database.update('results', {'needs_sync': 0},
        where: 'exam_id = ? AND student_id = ?',
        whereArgs: [examId, studentId]);
  }

  Future<List<Map<String, dynamic>>> getRecentScans(int limit, String? userId) async {
    final database = await db;
    final List<Map<String, dynamic>> res = await database.rawQuery('''
      SELECT e.title as exam_title, MAX(r.date) as date, COUNT(r.id) as student_count, r.exam_id
      FROM results r
      JOIN exams e ON r.exam_id = e.id
      WHERE r.user_id = ? OR r.user_id IS NULL
      GROUP BY r.exam_id
      ORDER BY date DESC
      LIMIT ?
    ''', [userId, limit]);
    return res;
  }
}
