import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class StudentResultScreen extends StatelessWidget {
  final String examTitle;
  final String studentId;
  final String studentName;
  final String date;
  final int score;
  final List<Map<String, dynamic>> answers;

  const StudentResultScreen({
    super.key,
    required this.examTitle,
    required this.studentId,
    required this.studentName,
    required this.date,
    required this.score,
    required this.answers,
  });

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!; // Access localization
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF007BFF)),
        title: Text('${loc.result}: $examTitle', style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)), // Localized
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(studentName, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    Text('${loc.studentId}: $studentId', style: const TextStyle(color: Colors.grey)), // Localized
                    const SizedBox(height: 6),
                    Text('${loc.date}: $date', style: const TextStyle(color: Colors.grey)), // Localized
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(Icons.emoji_events, color: Color(0xFF43A047), size: 32),
                        const SizedBox(width: 10),
                        Builder(
                          builder: (context) {
                            int total = 0;
                            int obtained = 0;
                            for (var a in answers) {
                              int m = a['mark'] ?? 0;
                              total += m;
                              if (a['isCorrect'] == true) obtained += m;
                            }
                            return Text(
                              '${loc.score}: $obtained / $total',
                              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF43A047)),
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(loc.answers, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)), // Localized
            const SizedBox(height: 12),
            ...answers.map((a) => _AnswerTile(
              question: a['question'],
              selected: a['selected'],
              correct: a['correct'],
              isCorrect: a['isCorrect'],
            )),
          ],
        ),
      ),
    );
  }
}

class _AnswerTile extends StatelessWidget {
  final int question;
  final String selected;
  final String correct;
  final bool isCorrect;
  const _AnswerTile({required this.question, required this.selected, required this.correct, required this.isCorrect});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!; // Access localization
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.only(bottom: 8),
      color: isCorrect ? Color(0xFFE8F5E9) : Color(0xFFFFEBEE),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isCorrect ? Color(0xFF43A047) : Color(0xFFDC3545),
          child: Icon(isCorrect ? Icons.check : Icons.close, color: Colors.white),
        ),
        title: Text('${loc.question} $question: ${loc.yourAnswer}: $selected'), // Localized
        subtitle: !isCorrect ? Text('${loc.correct}: $correct', style: TextStyle(color: Color(0xFF007BFF))) : null, // Localized
        trailing: isCorrect
            ? Text(loc.correct, style: TextStyle(color: Color(0xFF43A047), fontWeight: FontWeight.bold))
            : Text(loc.incorrect, style: TextStyle(color: Color(0xFFDC3545), fontWeight: FontWeight.bold)),
      ),
    );
  }
}
