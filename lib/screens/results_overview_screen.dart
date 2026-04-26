import 'package:flutter/material.dart';
import 'package:omr1/db/database_helper.dart';
import 'package:omr1/models/exam.dart';
import 'dart:convert';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:omr1/screens/exam_results_screen.dart';

class ResultsOverviewScreen extends StatefulWidget {
  const ResultsOverviewScreen({super.key});

  @override
  State<ResultsOverviewScreen> createState() => _ResultsOverviewScreenState();
}

class _ResultsOverviewScreenState extends State<ResultsOverviewScreen> {
  List<Map<String, dynamic>> _examSummaries = [];
  int _totalExams = 0;
  int _totalSheets = 0;
  double _avgScore = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final db = DatabaseHelper();
    final exams = await db.getAllExams();
    _totalExams = exams.length;
    _totalSheets = 0;
    double totalScoreSum = 0;
    int totalResultCount = 0;

    List<Map<String, dynamic>> summaries = [];

    for (var exam in exams) {
      final results = await db.getResultsByExamId(exam.id!);
      _totalSheets += results.length;
      
      for (var r in results) {
        totalScoreSum += r.score;
        totalResultCount++;
      }

      // Use pre-stored student names for each result with a fallback lookup
      List<Map<String, dynamic>> studentResults = [];
      for (var r in results) {
        String displayName = r.studentName;
        
        // Auto-repair: If the stored name is "Unknown", try finding it now
        if (displayName == 'Unknown Student') {
          final student = await db.getStudentByStudentId(r.studentId);
          if (student != null) {
            displayName = student.name;
          }
        }

        studentResults.add({
          'id': r.studentId,
          'name': displayName,
          'score': r.score,
          'answers': List<Map<String, dynamic>>.from(jsonDecode(r.answers)),
        });
      }

      summaries.add({
        'exam': exam,
        'count': results.length,
        'studentResults': studentResults,
      });
    }

    _avgScore = totalResultCount > 0 ? (totalScoreSum / totalResultCount) : 0;

    if (mounted) {
      setState(() {
        _examSummaries = summaries;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text(loc.resultsOverview)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF007BFF)),
        title: Text(loc.resultsOverview, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)), // Localized
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Summary Cards
            SizedBox(
              height: 120, // Match card height
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _ResultSummaryCard(
                      icon: Icons.assignment,
                      value: _totalExams.toString(),
                      label: loc.totalExams,
                      color: const Color(0xFF007BFF),
                    ),
                    _ResultSummaryCard(
                      icon: Icons.document_scanner,
                      value: _totalSheets.toString(),
                      label: loc.sheets,
                      color: const Color(0xFF43A047),
                    ),
                    _ResultSummaryCard(
                      icon: Icons.bar_chart,
                      value: '${_avgScore.toStringAsFixed(1)}%',
                      label: loc.avgScore,
                      color: const Color(0xFFFB8C00),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            Text(loc.recentScans, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            if (_examSummaries.isEmpty)
              Center(child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text(loc.noScansYet),
              )),
            ..._examSummaries.map((summary) {
              final Exam exam = summary['exam'];
              return _ResultListTile(
                title: exam.title,
                date: exam.date.split('T').first, // Simple date display
                score: '${summary['count']} ${loc.sheets}',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => ExamResultsScreen(
                        examTitle: exam.title,
                        date: exam.date.split('T').first,
                        students: List<Map<String, dynamic>>.from(summary['studentResults']),
                      ),
                    ),
                  );
                },
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}

class _ResultSummaryCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;
  const _ResultSummaryCard({required this.icon, required this.value, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 140,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
        border: Border(
          left: BorderSide(color: color, width: 6),
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
      clipBehavior: Clip.hardEdge,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 6),
            Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 2),
            Text(label, style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}

class _ResultListTile extends StatelessWidget {
  final String title;
  final String date;
  final String score;
  final VoidCallback onTap;
  const _ResultListTile({required this.title, required this.date, required this.score, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 2,
      child: ListTile(
        leading: Icon(Icons.description, color: Theme.of(context).primaryColor),
        title: Text(title, style: TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(date),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Color(0xFF007BFF).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(score, style: TextStyle(color: Color(0xFF007BFF), fontWeight: FontWeight.bold)),
        ),
        onTap: onTap,
      ),
    );
  }
}
