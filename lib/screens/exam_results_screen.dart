import 'package:flutter/material.dart';
import 'package:omr1/screens/student_result_screen.dart';
import 'package:excel/excel.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:omr1/db/database_helper.dart';
class ExamResultsScreen extends StatefulWidget {
  final int examId;
  final String examTitle;
  final String date;
  final List<Map<String, dynamic>> students;
  const ExamResultsScreen({super.key, required this.examId, required this.examTitle, required this.date, required this.students});

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
        title: Text('${loc.results}: ${widget.examTitle}', style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep, color: Colors.red),
            tooltip: 'Clear all results',
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Clear All Results'),
                  content: Text('Are you sure you want to delete ALL results for ${widget.examTitle}?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(ctx).pop(false),
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.of(ctx).pop(true),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                      child: const Text('Clear All'),
                    ),
                  ],
                ),
              );
              if (confirm == true) {
                await DatabaseHelper().deleteResultsByExamId(widget.examId);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('All results deleted'), backgroundColor: Colors.red),
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
            Text(loc.students, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            // Search bar
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: loc.search,
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(18)),
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
              ),
            ),
            const SizedBox(height: 16),
            if (filteredStudents.isEmpty)
              Text(loc.studentNotFound, style: TextStyle(color: Colors.red[700], fontWeight: FontWeight.bold)),
            ...filteredStudents.map((student) => Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              margin: const EdgeInsets.only(bottom: 10),
              elevation: 2,
              child: ListTile(
                leading: CircleAvatar(child: Text(student['name'][0])),
                title: Text(student['name'], style: TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Text('${loc.studentId}: ${student['id']}  |  ${loc.score}: ${student['score']}%'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      onPressed: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text('Delete Result'),
                            content: Text('Are you sure you want to delete this result for ${student['name']}?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(ctx).pop(false),
                                child: const Text('Cancel'),
                              ),
                              ElevatedButton(
                                onPressed: () => Navigator.of(ctx).pop(true),
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                child: const Text('Delete'),
                              ),
                            ],
                          ),
                        );
                        if (confirm == true) {
                          if (student['db_id'] != null) {
                            await DatabaseHelper().deleteResult(student['db_id']);
                            setState(() {
                              _students.removeWhere((s) => s['db_id'] == student['db_id']);
                            });
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Result deleted'), backgroundColor: Colors.red),
                              );
                            }
                          }
                        }
                      },
                    ),
                    const Icon(Icons.chevron_right, color: Color(0xFF007BFF)),
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

  Future<void> _exportToExcel(BuildContext context) async {
    final loc = AppLocalizations.of(context)!; // Access localization
    final excel = Excel.createExcel();
    final Sheet sheet = excel['Results'];
    // Header
    sheet.appendRow([loc.studentId, loc.studentName, loc.score]); // Localized
    for (final student in _students) {
      final row = [
        student['id'] ?? '',
        student['name'],
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
