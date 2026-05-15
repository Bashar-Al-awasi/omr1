import 'package:flutter/material.dart';
import 'package:omr1/screens/student_result_screen.dart';
import 'package:excel/excel.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:omr1/db/database_helper.dart';
import 'package:omr1/utils/report_generator.dart';

class ExamResultsScreen extends StatefulWidget {
  final int examId;
  final String examTitle;
  final String date;
  final List<Map<String, dynamic>> students;
  const ExamResultsScreen(
      {super.key,
      required this.examId,
      required this.examTitle,
      required this.date,
      required this.students});

  @override
  State<ExamResultsScreen> createState() => _ExamResultsScreenState();
}

class _ExamResultsScreenState extends State<ExamResultsScreen> {
  late TextEditingController _searchController;
  String _searchQuery = '';
  late List<Map<String, dynamic>> _students;

  @override
  void initState() {
    super.initState();
    _students = List.from(widget.students);
    _searchController = TextEditingController();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    // Filter students by search query (case-insensitive)
    final filteredStudents = _searchQuery.isEmpty
        ? _students
        : _students.where((student) {
            final name = (student['name'] ?? '').toString().toLowerCase();
            final id = (student['id'] ?? '').toString().toLowerCase();
            final query = _searchQuery.toLowerCase();
            return name.contains(query) || id.contains(query);
          }).toList();
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF007BFF)),
        title: Text('${loc.results}: ${widget.examTitle}',
            style: const TextStyle(
                color: Colors.black, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon:
                const Icon(Icons.assessment_rounded, color: Color(0xFFFB8C00)),
            tooltip: 'Generate Analysis Report',
            onPressed: () async {
              await ReportGenerator.generateClassReport(
                examTitle: widget.examTitle,
                subject:
                    'Exam Analysis', // We could pass the actual subject if available
                date: widget.date,
                students: _students,
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_sweep, color: Colors.red),
            tooltip: 'Clear all results',
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: Text(loc.clearAllResults),
                  content: Text(
                      loc.clearResultsConfirmation(widget.examTitle)),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(ctx).pop(false),
                      child: Text(loc.cancel),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.of(ctx).pop(true),
                      style:
                          ElevatedButton.styleFrom(backgroundColor: Colors.red),
                      child: Text(loc.viewAll), // Using viewAll as placeholder if no delete all key
                    ),
                  ],
                ),
              );
              if (confirm == true) {
                await DatabaseHelper().deleteResultsByExamId(widget.examId);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text(loc.allResultsDeleted),
                        backgroundColor: Colors.red),
                  );
                  Navigator.of(context).pop(); // Go back to overview
                }
              }
            },
          ),
          IconButton(
            icon: Icon(Icons.download, color: Color(0xFF007BFF)),
            tooltip: loc.exportAsExcel, // Localized
            onPressed: () async {
              await _exportToExcel(context);
            },
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(loc.students,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            // Search bar
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: loc.search,
                prefixIcon: Icon(Icons.search),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(18)),
                isDense: true,
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
              ),
            ),
            const SizedBox(height: 16),
            if (filteredStudents.isEmpty)
              Text(loc.studentNotFound,
                  style: TextStyle(
                      color: Colors.red[700], fontWeight: FontWeight.bold)),
            ...filteredStudents.map((student) => Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  margin: const EdgeInsets.only(bottom: 10),
                  elevation: 2,
                  child: ListTile(
                    leading: CircleAvatar(child: Text(student['name'] == 'Unknown Student' ? '?' : student['name'][0])),
                    title: Text(student['name'] == 'Unknown Student' ? loc.unknownStudent : student['name'],
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Text(
                        '${loc.studentId}: ${student['id']}  |  ${loc.score}: ${_getScoreDisplay(student['answers'])}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.delete_outline,
                              color: Colors.red),
                          onPressed: () async {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: Text(loc.deleteResult),
                                content: Text(
                                    loc.deleteResultConfirmation(student['name'] == 'Unknown Student' ? loc.unknownStudent : student['name'])),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.of(ctx).pop(false),
                                    child: Text(loc.cancel),
                                  ),
                                  ElevatedButton(
                                    onPressed: () =>
                                        Navigator.of(ctx).pop(true),
                                    style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.red),
                                    child: Text(loc.scan), // Using scan as placeholder if no delete key
                                  ),
                                ],
                              ),
                            );
                            if (confirm == true) {
                              if (student['db_id'] != null) {
                                await DatabaseHelper()
                                    .deleteResult(student['db_id']);
                                setState(() {
                                  _students.removeWhere(
                                      (s) => s['db_id'] == student['db_id']);
                                });
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content: Text(loc.resultDeleted),
                                        backgroundColor: Colors.red),
                                  );
                                }
                              }
                            }
                          },
                        ),
                        const Icon(Icons.chevron_right,
                            color: Color(0xFF007BFF)),
                      ],
                    ),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => StudentResultScreen(
                            examTitle: widget.examTitle,
                            studentId: student['id'],
                            studentName: student['name'],
                            date: widget.date,
                            score: student['score'],
                            answers: student['answers'],
                          ),
                        ),
                      );
                    },
                  ),
                )),
          ],
        ),
      ),
    );
  }

  String _getScoreDisplay(List<Map<String, dynamic>> answers) {
    int total = 0;
    int obtained = 0;
    for (var a in answers) {
      int mark = a['mark'] ?? 0;
      total += mark;
      if (a['isCorrect'] == true) obtained += mark;
    }
    return '$obtained / $total';
  }

  Future<void> _exportToExcel(BuildContext context) async {
    final loc = AppLocalizations.of(context)!; // Access localization
    final excel = Excel.createExcel();
    final Sheet sheet = excel['Results'];
    // Header
    sheet.appendRow([
      loc.studentId,
      loc.studentName,
      'Obtained Marks',
      'Total Marks',
      loc.score + ' %'
    ]);
    for (final student in _students) {
      int total = 0;
      int obtained = 0;
      final answers = student['answers'] as List;
      for (var a in answers) {
        int m = a['mark'] ?? 0;
        total += m;
        if (a['isCorrect'] == true) obtained += m;
      }

      final row = [
        student['id'] ?? '',
        student['name'],
        obtained,
        total,
        student['score'],
      ];
      sheet.appendRow(row);
    }
    // Save file to app directory (no permission required)
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/${widget.examTitle}-results.xlsx');
    await file.writeAsBytes(excel.encode()!);
    // Show dialog to view or share
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(loc.excelExported), // Localized
        content: Text('${loc.excelFileSaved}: ${file.path}'), // Localized
        actions: [
          TextButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              await OpenFile.open(file.path);
            },
            child: Text(loc.view), // Localized
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(loc.close), // Localized
          ),
        ],
      ),
    );
  }
}
