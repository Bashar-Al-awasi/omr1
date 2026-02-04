import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:omr1/screens/exam_results_screen.dart';

class ResultsOverviewScreen extends StatelessWidget {
  const ResultsOverviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!; // Access localization
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
                      value: '12',
                      label: loc.totalExams, // Localized
                      color: Color(0xFF007BFF),
                    ),
                    _ResultSummaryCard(
                      icon: Icons.document_scanner,
                      value: '340',
                      label: loc.sheets, // Localized
                      color: Color(0xFF43A047),
                    ),
                    _ResultSummaryCard(
                      icon: Icons.bar_chart,
                      value: '78%',
                      label: loc.avgScore, // Localized
                      color: Color(0xFFFB8C00),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            Text(loc.recentScans, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)), // Localized
            const SizedBox(height: 12),
            _ResultListTile(
              title: 'Math Final',
              date: '18/6/2025',
              score: '3 Sheets',
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => ExamResultsScreen(
                      examTitle: 'Math Final',
                      date: '18/6/2025',
                      students: [
                        {
                          'id': 'S001',
                          'name': 'Ali',
                          'score': 92,
                          'answers': [
                            {'question': 1, 'selected': 'A', 'correct': 'A', 'isCorrect': true},
                            {'question': 2, 'selected': 'B', 'correct': 'C', 'isCorrect': false},
                            {'question': 3, 'selected': 'D', 'correct': 'D', 'isCorrect': true},
                            {'question': 4, 'selected': 'C', 'correct': 'C', 'isCorrect': true},
                            {'question': 5, 'selected': 'B', 'correct': 'B', 'isCorrect': true},
                          ],
                        },
                        {
                          'id': 'S002',
                          'name': 'Ahmed',
                          'score': 88,
                          'answers': [
                            {'question': 1, 'selected': 'B', 'correct': 'A', 'isCorrect': false},
                            {'question': 2, 'selected': 'C', 'correct': 'C', 'isCorrect': true},
                            {'question': 3, 'selected': 'D', 'correct': 'D', 'isCorrect': true},
                            {'question': 4, 'selected': 'A', 'correct': 'C', 'isCorrect': false},
                            {'question': 5, 'selected': 'B', 'correct': 'B', 'isCorrect': true},
                          ],
                        },
                        {
                          'id': 'S003',
                          'name': 'Mohammed',
                          'score': 75,
                          'answers': [
                            {'question': 1, 'selected': 'C', 'correct': 'A', 'isCorrect': false},
                            {'question': 2, 'selected': 'B', 'correct': 'C', 'isCorrect': false},
                            {'question': 3, 'selected': 'D', 'correct': 'D', 'isCorrect': true},
                            {'question': 4, 'selected': 'C', 'correct': 'C', 'isCorrect': true},
                            {'question': 5, 'selected': 'B', 'correct': 'B', 'isCorrect': true},
                          ],
                        },
                      ],
                    ),
                  ),
                );
              },
            ),
            _ResultListTile(
              title: 'Science Quiz',
              date: '15/6/2025',
              score: '2 Sheets',
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => ExamResultsScreen(
                      examTitle: 'Science Quiz',
                      date: '15/6/2025',
                      students: [
                        {
                          'id': 'S002',
                          'name': 'Ahmed',
                          'score': 85,
                          'answers': [
                            {'question': 1, 'selected': 'B', 'correct': 'B', 'isCorrect': true},
                            {'question': 2, 'selected': 'A', 'correct': 'A', 'isCorrect': true},
                            {'question': 3, 'selected': 'C', 'correct': 'D', 'isCorrect': false},
                            {'question': 4, 'selected': 'D', 'correct': 'D', 'isCorrect': true},
                            {'question': 5, 'selected': 'A', 'correct': 'A', 'isCorrect': true},
                          ],
                        },
                        {
                          'id': 'S003',
                          'name': 'Mohammed',
                          'score': 80,
                          'answers': [
                            {'question': 1, 'selected': 'C', 'correct': 'B', 'isCorrect': false},
                            {'question': 2, 'selected': 'A', 'correct': 'A', 'isCorrect': true},
                            {'question': 3, 'selected': 'C', 'correct': 'D', 'isCorrect': false},
                            {'question': 4, 'selected': 'D', 'correct': 'D', 'isCorrect': true},
                            {'question': 5, 'selected': 'A', 'correct': 'A', 'isCorrect': true},
                          ],
                        },
                      ],
                    ),
                  ),
                );
              },
            ),
            _ResultListTile(
              title: 'History Midterm',
              date: '10/6/2025',
              score: '1 Sheet',
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => ExamResultsScreen(
                      examTitle: 'History Midterm',
                      date: '10/6/2025',
                      students: [
                        {
                          'id': 'S003',
                          'name': 'Saleh',
                          'score': 78,
                          'answers': [
                            {'question': 1, 'selected': 'C', 'correct': 'C', 'isCorrect': true},
                            {'question': 2, 'selected': 'D', 'correct': 'B', 'isCorrect': false},
                            {'question': 3, 'selected': 'A', 'correct': 'A', 'isCorrect': true},
                            {'question': 4, 'selected': 'B', 'correct': 'B', 'isCorrect': true},
                            {'question': 5, 'selected': 'C', 'correct': 'D', 'isCorrect': false},
                          ],
                        },
                      ],
                    ),
                  ),
                );
              },
            ),
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
