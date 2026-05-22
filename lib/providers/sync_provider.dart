import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
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

  void _safeNotifyListeners() {
    final binding = WidgetsBinding.instance;
    if (binding.schedulerPhase == SchedulerPhase.persistentCallbacks) {
      binding.addPostFrameCallback((_) => notifyListeners());
    } else {
      notifyListeners();
    }
  }

  /// Returns a summary of what was synced, or throws an error
  Future<String> syncToCloud(String userId) async {
    if (_isSyncing) return "Sync already in progress";
    _isSyncing = true;
    _safeNotifyListeners();

    try {
      final summary = await _performSync(userId);
      return summary;
    } catch (e) {
      debugPrint('Sync Error: $e');
      rethrow;
    } finally {
      _isSyncing = false;
      _safeNotifyListeners();
    }
  }

  /// Directly writes a single exam (+ its questions) to Firestore immediately.
  /// Use this right after inserting an exam to guarantee it appears in the cloud
  /// without waiting for the background autoSync cycle.
  Future<void> syncExamDirectly(String userId, int examId) async {
    try {
      final userDoc = _firestore.collection('users').doc(userId);

      // Ensure parent user document exists
      await userDoc.set({
        'uid': userId,
        'lastSyncedAt': DateTime.now().toIso8601String(),
      }, SetOptions(merge: true)).timeout(const Duration(seconds: 6));

      // Fetch exam from local DB
      final exam = await _db.getExamById(examId, userId);
      if (exam == null) {
        debugPrint('syncExamDirectly: exam $examId not found in local DB');
        return;
      }

      // Write exam document (strip SQLite 'id')
      final examDoc = userDoc.collection('exams').doc(examId.toString());
      final examData = exam.toMap()..remove('id');
      await examDoc.set(examData).timeout(const Duration(seconds: 8));
      debugPrint('syncExamDirectly: exam $examId written to Firestore ✓');

      // Write questions subcollection
      final questions = await _db.getQuestionsByExamId(examId);
      if (questions.isNotEmpty) {
        final qBatch = _firestore.batch();
        for (var q in questions) {
          final qDoc = examDoc.collection('questions').doc(q.questionNumber.toString());
          final qData = q.toMap()..remove('id');
          qBatch.set(qDoc, qData);
        }
        await qBatch.commit().timeout(const Duration(seconds: 8));
        debugPrint('syncExamDirectly: ${questions.length} questions written ✓');
      }
      // Mark exam as synced in local DB so autoSync skips it next time
      await _db.markExamSynced(examId);
    } catch (e, stack) {
      debugPrint('syncExamDirectly ERROR: $e\n$stack');
      rethrow; // Let the caller show a visible error
    }
  }

  Future<void> autoSync(String? userId) async {

    if (userId == null || _isSyncing) return;
    
    _isSyncing = true;
    _safeNotifyListeners();
    
    try {
      bool hasConnection = false;
      try {
        final result = await InternetAddress.lookup('google.com').timeout(const Duration(seconds: 4));
        hasConnection = result.isNotEmpty && result[0].rawAddress.isNotEmpty;
      } catch (e) {
        debugPrint('AutoSync: DNS lookup failed ($e). Attempting sync anyway as Firestore supports offline queueing.');
        // Firestore can cache writes offline, so we can still try to sync exams.
        // However, we set hasConnection to false so we skip the cloud pull phase to prevent blocking/hanging.
        hasConnection = false;
      }

      // Always ensure the user document exists, even for brand-new accounts
      if (hasConnection) {
        try {
          await _ensureUserDocument(userId);
        } catch (e) {
          debugPrint('AutoSync: Could not write user document: $e');
        }
      }

      // If local database is empty, pull from cloud first (only if we confirmed active internet connection)
      final stats = await _db.getDashboardStats(userId);
      if (hasConnection && stats['totalExams'] == 0 && stats['totalSheets'] == 0) {
        debugPrint('Local DB empty, pulling from cloud...');
        try {
          await _performPull(userId);
        } catch (e) {
          debugPrint('AutoSync: Pull from cloud failed (possibly offline): $e');
        }
      }

      await _performSync(userId);
      debugPrint('AutoSync completed successfully.');
    } on SocketException catch (e) {
      debugPrint('AutoSync Offline (SocketException): $e');
    } on TimeoutException catch (e) {
      debugPrint('AutoSync Offline (TimeoutException): $e');
    } catch (e, stack) {
      debugPrint('AutoSync Critical Error: $e\n$stack');
    } finally {
      _isSyncing = false;
      _safeNotifyListeners();
    }
  }

  /// Public wrapper — call this on account creation to immediately
  /// register the user in Firestore. Throws on failure so the caller can show an error.
  Future<void> ensureUserDocument(String userId) => _ensureUserDocument(userId);

  /// Creates (or updates) the top-level users/{uid} document so it
  /// appears in the Firestore console even if subcollections are empty.
  Future<void> _ensureUserDocument(String userId) async {
    final userDoc = _firestore.collection('users').doc(userId);
    await userDoc.set({
      'uid': userId,
      'lastSyncedAt': DateTime.now().toIso8601String(),
    }, SetOptions(merge: true)).timeout(const Duration(seconds: 6));
  }

  Future<String> _performSync(String userId) async {
    final userDoc = _firestore.collection('users').doc(userId);
    int studentCount = 0;
    int examCount = 0;
    int resultCount = 0;
    
    final List<Future<void>> syncFutures = [];

    // 0. Always ensure the parent user document exists in Firestore
    try {
      await _ensureUserDocument(userId);
    } catch (e) {
      debugPrint('Sync: Could not write user document: $e');
    }

    // 1. Sync Students — only unsynced ones
    final allStudents = await _db.getAllStudents(userId); // needed for deletion check
    final unsyncedStudents = await _db.getUnsyncedStudents(userId);
    if (unsyncedStudents.isNotEmpty) {
      final studentBatch = _firestore.batch();
      for (var s in unsyncedStudents) {
        final docRef = userDoc.collection('students').doc(s.studentId);
        final data = s.toMap()..remove('id')..remove('needs_sync');
        studentBatch.set(docRef, data);
        studentCount++;
      }
      syncFutures.add(
        studentBatch.commit().then((_) => Future.wait(
          unsyncedStudents.map((s) => _db.markStudentSynced(s.studentId)),
        )),
      );
    }

    // 2. Sync Exams — only unsynced ones
    final allExams = await _db.getAllExams(userId); // needed for deletion check
    final unsyncedExams = await _db.getUnsyncedExams(userId);
    for (var e in unsyncedExams) {
      if (e.id == null) continue;
      final examDoc = userDoc.collection('exams').doc(e.id.toString());
      final examData = e.toMap()..remove('id')..remove('needs_sync');
      final questions = await _db.getQuestionsByExamId(e.id!);

      Future<void> writeExam() async {
        await examDoc.set(examData);
        if (questions.isNotEmpty) {
          final qBatch = _firestore.batch();
          for (var q in questions) {
            final qDoc = examDoc.collection('questions').doc(q.questionNumber.toString());
            qBatch.set(qDoc, q.toMap()..remove('id'));
          }
          await qBatch.commit();
        }
        await _db.markExamSynced(e.id!);
      }

      syncFutures.add(writeExam());
      examCount++;
    }

    // 3. Sync Results — only unsynced ones
    final allResults = await _db.getResultsByUserId(userId); // needed for deletion check
    final unsyncedResults = await _db.getUnsyncedResults(userId);
    if (unsyncedResults.isNotEmpty) {
      final resultBatch = _firestore.batch();
      for (var r in unsyncedResults) {
        final docId = '${r.examId}_${r.studentId}';
        final docRef = userDoc.collection('results').doc(docId);
        final data = r.toMap()..remove('id')..remove('needs_sync');
        resultBatch.set(docRef, data);
        resultCount++;
      }
      syncFutures.add(
        resultBatch.commit().then((_) => Future.wait(
          unsyncedResults.map((r) => _db.markResultSynced(r.examId, r.studentId)),
        )),
      );
    }

    // 4. Sync Deletions (Cloud -> Deleted if not in Local)
    // A. Sync deleted students
    final localStudentIds = allStudents.map((s) => s.studentId).toSet();
    try {
      final cloudStudentsSnap = await userDoc.collection('students').get().timeout(const Duration(seconds: 5));
      for (var doc in cloudStudentsSnap.docs) {
        if (!localStudentIds.contains(doc.id)) {
          syncFutures.add(doc.reference.delete());
        }
      }
    } catch (e) {
      debugPrint('Sync Deletions: Students failed: $e');
    }

    // B. Sync deleted exams
    final localExamIds = allExams.map((e) => e.id.toString()).toSet();
    try {
      final cloudExamsSnap = await userDoc.collection('exams').get().timeout(const Duration(seconds: 5));
      for (var doc in cloudExamsSnap.docs) {
        if (!localExamIds.contains(doc.id)) {
          syncFutures.add(doc.reference.delete());
          final qSnap = await doc.reference.collection('questions').get().timeout(const Duration(seconds: 5));
          for (var qDoc in qSnap.docs) {
            syncFutures.add(qDoc.reference.delete());
          }
        }
      }
    } catch (e) {
      debugPrint('Sync Deletions: Exams failed: $e');
    }

    // C. Sync deleted results
    final localResultIds = allResults.map((r) => '${r.examId}_${r.studentId}').toSet();
    try {
      final cloudResultsSnap = await userDoc.collection('results').get().timeout(const Duration(seconds: 5));
      for (var doc in cloudResultsSnap.docs) {
        if (!localResultIds.contains(doc.id)) {
          syncFutures.add(doc.reference.delete());
        }
      }
    } catch (e) {
      debugPrint('Sync Deletions: Results failed: $e');
    }

    // Await all network operations in parallel with a timeout to avoid hanging indefinitely
    bool timedOut = false;
    if (syncFutures.isNotEmpty) {
      try {
        await Future.wait(syncFutures).timeout(const Duration(seconds: 10));
      } on TimeoutException {
        timedOut = true;
        debugPrint('Sync: Network write operations timed out. Changes queued for offline upload.');
      }
    }

    // 5. Data Repair
    await _db.repairOrphanedData(userId);

    if (timedOut) {
      return "Sync queued offline (Server did not respond in time)";
    }
    return "Synced: $studentCount students, $examCount exams, $resultCount results";
  }

  /// Internal helper to pull data from cloud without modifying the _isSyncing outer state
  Future<String> _performPull(String userId) async {
    final userDoc = _firestore.collection('users').doc(userId);
    int studentCount = 0;
    int examCount = 0;
    int resultCount = 0;

    // Parallel fetch from Firestore
    final Future<QuerySnapshot<Map<String, dynamic>>> studentFetch = userDoc.collection('students').get();
    final Future<QuerySnapshot<Map<String, dynamic>>> examFetch = userDoc.collection('exams').get();
    final Future<QuerySnapshot<Map<String, dynamic>>> resultFetch = userDoc.collection('results').get();

    final results = await Future.wait([studentFetch, examFetch, resultFetch]).timeout(const Duration(seconds: 10));
    
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
  }

  /// Restores data from cloud to local device at high speed
  Future<String> pullFromCloud(String userId) async {
    if (_isSyncing) return "Sync already in progress";
    _isSyncing = true;
    _safeNotifyListeners();

    try {
      final summary = await _performPull(userId);
      return summary;
    } catch (e) {
      debugPrint('Restore Error: $e');
      rethrow;
    } finally {
      _isSyncing = false;
      _safeNotifyListeners();
    }
  }
}
