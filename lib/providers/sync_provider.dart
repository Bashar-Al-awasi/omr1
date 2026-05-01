import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:io';
import 'package:sqflite/sqflite.dart';
import '../db/database_helper.dart';
import '../models/student.dart';
import '../models/exam.dart';
import '../models/result.dart';
import '../models/question.dart';

class SyncProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final DatabaseHelper _db = DatabaseHelper();
  
  bool _isSyncing = false;
  bool get isSyncing => _isSyncing;

  /// Returns a summary of what was synced, or throws an error
  Future<String> syncToCloud(String userId) async {
    if (_isSyncing) return "Sync already in progress";
    _isSyncing = true;
    notifyListeners();

    try {
      final summary = await _performSync(userId);
      return summary;
    } catch (e) {
      debugPrint('Sync Error: $e');
      rethrow;
    } finally {
      _isSyncing = false;
      notifyListeners();
    }
  }

  Future<void> autoSync(String? userId) async {
    if (userId == null || _isSyncing) return;
    
    try {
      final result = await InternetAddress.lookup('google.com').timeout(const Duration(seconds: 3));
      if (result.isEmpty || result[0].rawAddress.isEmpty) return;

      // If local database is empty, pull from cloud first
      final stats = await _db.getDashboardStats(userId);
      if (stats['totalExams'] == 0 && stats['totalSheets'] == 0) {
        debugPrint('Local DB empty, pulling from cloud...');
        await pullFromCloud(userId);
      }

      await _performSync(userId);
    } catch (_) {
      // Silent fail for auto-sync
    } finally {
      _isSyncing = false;
      notifyListeners();
    }
  }

  Future<String> _performSync(String userId) async {
    final userDoc = _firestore.collection('users').doc(userId);
    int studentCount = 0;
    int examCount = 0;
    int resultCount = 0;

    // 1. Sync Students (Local -> Cloud)
    final students = await _db.getAllStudents(userId);
    if (students.isNotEmpty) {
      final studentBatch = _firestore.batch();
      for (var s in students) {
        final docRef = userDoc.collection('students').doc(s.studentId);
        studentBatch.set(docRef, s.toMap());
        studentCount++;
      }
      await studentBatch.commit();
    }

    // 2. Sync Exams (Local -> Cloud)
    final exams = await _db.getAllExams(userId);
    for (var e in exams) {
      if (e.id == null) continue;
      final examDoc = userDoc.collection('exams').doc(e.id.toString());
      await examDoc.set(e.toMap());
      examCount++;

      final questions = await _db.getQuestionsByExamId(e.id!);
      final qBatch = _firestore.batch();
      for (var q in questions) {
        final qDoc = examDoc.collection('questions').doc(q.questionNumber.toString());
        qBatch.set(qDoc, q.toMap());
      }
      await qBatch.commit();
    }

    // 3. Sync Results (Local -> Cloud)
    final results = await _db.getResultsByUserId(userId);
    if (results.isNotEmpty) {
      final resultBatch = _firestore.batch();
      for (var r in results) {
        final docId = '${r.examId}_${r.studentId}';
        final docRef = userDoc.collection('results').doc(docId);
        resultBatch.set(docRef, r.toMap());
        resultCount++;
      }
      await resultBatch.commit();
    }

    // 4. Data Repair
    await _db.repairOrphanedData(userId);

    return "Synced: $studentCount students, $examCount exams, $resultCount results";
  }

  /// Restores data from cloud to local device at high speed
  Future<String> pullFromCloud(String userId) async {
    if (_isSyncing) return "Sync already in progress";
    _isSyncing = true;
    notifyListeners();

    try {
      final userDoc = _firestore.collection('users').doc(userId);
      int studentCount = 0;
      int examCount = 0;
      int resultCount = 0;

      // Parallel fetch from Firestore
      final Future<QuerySnapshot<Map<String, dynamic>>> studentFetch = userDoc.collection('students').get();
      final Future<QuerySnapshot<Map<String, dynamic>>> examFetch = userDoc.collection('exams').get();
      final Future<QuerySnapshot<Map<String, dynamic>>> resultFetch = userDoc.collection('results').get();

      final results = await Future.wait([studentFetch, examFetch, resultFetch]);
      
      final studentSnap = results[0];
      final examSnap = results[1];
      final resultSnap = results[2];

      // Use a local DB transaction for speed
      final dbClient = await _db.db;
      await dbClient.transaction((txn) async {
        // 1. Process Students
        for (var doc in studentSnap.docs) {
          final s = Student.fromMap(doc.data());
          await txn.insert('students', s.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
          studentCount++;
        }

        // 2. Process Exams
        for (var doc in examSnap.docs) {
          final e = Exam.fromMap(doc.data());
          await txn.insert('exams', e.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
          examCount++;

          // Note: sub-collections still need separate fetches, but we can do them here
          final qSnap = await doc.reference.collection('questions').get();
          for (var qDoc in qSnap.docs) {
            final q = Question.fromMap(qDoc.data());
            await txn.insert('questions', q.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
          }
        }

        // 3. Process Results
        for (var doc in resultSnap.docs) {
          final r = Result.fromMap(doc.data());
          await txn.insert('results', r.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
          resultCount++;
        }
      });

      return "Restored: $studentCount students, $examCount exams, $resultCount results";
    } catch (e) {
      debugPrint('Restore Error: $e');
      rethrow;
    } finally {
      _isSyncing = false;
      notifyListeners();
    }
  }
}
