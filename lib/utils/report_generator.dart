import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';

class ReportGenerator {
  static Future<void> generateClassReport({
    required String examTitle,
    required String subject,
    required String date,
    required List<Map<String, dynamic>> students,
  }) async {
    final pdf = pw.Document();

    // 1. Calculate Statistics
    int totalStudents = students.length;
    if (totalStudents == 0) {
      return;
    }

    double sumScore = 0;
    int passCount = 0;
    int failCount = 0;
    
    // Grade Distribution
    int gradeA = 0; // 90-100
    int gradeB = 0; // 80-89
    int gradeC = 0; // 70-79
    int gradeD = 0; // 60-69
    int gradeF = 0; // <60

    // Question Analysis
    Map<int, int> questionCorrectCounts = {};
    int maxQIndex = 0;

    for (var student in students) {
      double score = double.tryParse(student['score'].toString()) ?? 0.0;
      sumScore += score;

      if (score >= 50) {
        passCount++;
      } else {
        failCount++;
      }

      if (score >= 90) {
        gradeA++;
      } else if (score >= 80) {
        gradeB++;
      } else if (score >= 70) {
        gradeC++;
      } else if (score >= 60) {
        gradeD++;
      } else {
        gradeF++;
      }

      // Analyze answers for difficulty breakdown
      final answers = student['answers'] as List;
      for (var ans in answers) {
        int qIdx = ans['qIndex'] ?? 0;
        bool isCorrect = ans['isCorrect'] ?? false;
        if (qIdx > maxQIndex) {
          maxQIndex = qIdx;
        }
        if (isCorrect) {
          questionCorrectCounts[qIdx] = (questionCorrectCounts[qIdx] ?? 0) + 1;
        }
      }
    }


    // We'll calculate a 'Class Total Mark' for the summary boxes
    int classTotalMarks = 0;
    int classObtainedMarks = 0;
    for (var student in students) {
      final answers = student['answers'] as List;
      for (var ans in answers) {
        int m = ans['mark'] ?? 0;
        classTotalMarks += m;
        if (ans['isCorrect'] == true) classObtainedMarks += m;
      }
    }
    double classAvgObtained = totalStudents > 0 ? classObtainedMarks / totalStudents : 0;
    double classAvgTotal = totalStudents > 0 ? classTotalMarks / totalStudents : 0;

    // 2. Build PDF Content
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            // Header
            pw.Header(
              level: 0,
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('Smart OMR - Class Analysis Report', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold, color: PdfColors.blue)),
                      pw.Text('Generated on: $date', style: const pw.TextStyle(color: PdfColors.grey)),
                    ],
                  ),
                  pw.PdfLogo(),
                ],
              ),
            ),
            pw.SizedBox(height: 20),

            // Exam Info
            pw.Container(
              padding: const pw.EdgeInsets.all(10),
              decoration: const pw.BoxDecoration(color: PdfColors.grey100),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
                children: [
                  _infoBox('Exam Title', examTitle),
                  _infoBox('Subject', subject),
                  _infoBox('Total Students', totalStudents.toString()),
                ],
              ),
            ),
            pw.SizedBox(height: 30),

            // Key Statistics
            pw.Text('Key Performance Indicators', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
            pw.Divider(color: PdfColors.blue),
            pw.SizedBox(height: 10),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                _statCard('Average Score', '${classAvgObtained.toStringAsFixed(1)} / ${classAvgTotal.toStringAsFixed(0)}', PdfColors.blue),
                _statCard('Pass Rate', '${((passCount / totalStudents) * 100).toStringAsFixed(1)}%', PdfColors.green),
                _statCard('Fail Rate', '${((failCount / totalStudents) * 100).toStringAsFixed(1)}%', PdfColors.red),
              ],
            ),
            pw.SizedBox(height: 40),

            // Grade Distribution Chart (Custom Implementation for Stability)
            pw.Text('Grade Distribution', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 20),
            _buildGradeBarChart(
              totalStudents: totalStudents,
              grades: {
                'A': gradeA,
                'B': gradeB,
                'C': gradeC,
                'D': gradeD,
                'F': gradeF,
              },
            ),
            pw.SizedBox(height: 40),

            // Question Difficulty Table
            pw.Text('Question Accuracy Analysis', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 10),
            pw.Table(
              border: pw.TableBorder.all(color: PdfColors.grey300),
              children: [
                pw.TableRow(
                  decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                  children: [
                    pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Text('Q#', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                    pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Text('Correct Count', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                    pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Text('Accuracy (%)', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                    pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Text('Difficulty', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                  ],
                ),
                ...List.generate(maxQIndex + 1, (index) {
                  int correct = questionCorrectCounts[index] ?? 0;
                  double acc = (correct / totalStudents) * 100;
                  String difficulty = acc >= 70 ? 'Easy' : acc >= 40 ? 'Medium' : 'Hard';
                  PdfColor diffColor = acc >= 70 ? PdfColors.green : acc >= 40 ? PdfColors.orange : PdfColors.red;

                  return pw.TableRow(
                    children: [
                      pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Text('${index + 1}')),
                      pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Text('$correct')),
                      pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Text('${acc.toStringAsFixed(1)}%')),
                      pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Text(difficulty, style: pw.TextStyle(color: diffColor))),
                    ],
                  );
                }),
              ],
            ),
          ];
        },
      ),
    );

    // Save and Open
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/Class_Report_${examTitle.replaceAll(' ', '_')}.pdf');
    await file.writeAsBytes(await pdf.save());
    await OpenFile.open(file.path);
  }

  static pw.Widget _buildGradeBarChart({required int totalStudents, required Map<String, int> grades}) {
    const double maxHeight = 150.0;
    
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: pw.CrossAxisAlignment.end,
      children: grades.entries.map((entry) {
        double percentage = totalStudents > 0 ? entry.value / totalStudents : 0;
        double barHeight = maxHeight * percentage;
        
        return pw.Column(
          children: [
            pw.Text('${entry.value}', style: const pw.TextStyle(fontSize: 10)),
            pw.SizedBox(height: 4),
            pw.Container(
              width: 30,
              height: barHeight > 0 ? barHeight : 2, // At least 2px line if 0
              decoration: const pw.BoxDecoration(
                color: PdfColors.blue,
                borderRadius: pw.BorderRadius.vertical(top: pw.Radius.circular(4)),
              ),
            ),
            pw.SizedBox(height: 8),
            pw.Text(entry.key, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          ],
        );
      }).toList(),
    );
  }

  static pw.Widget _infoBox(String label, String value) {
    return pw.Column(
      children: [
        pw.Text(label, style: const pw.TextStyle(color: PdfColors.grey700, fontSize: 10)),
        pw.Text(value, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14)),
      ],
    );
  }

  static pw.Widget _statCard(String label, String value, PdfColor color) {
    return pw.Container(
      width: 150,
      padding: const pw.EdgeInsets.all(15),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: color, width: 2),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(10)),
      ),
      child: pw.Column(
        children: [
          pw.Text(label, style: const pw.TextStyle(fontSize: 12)),
          pw.SizedBox(height: 5),
          pw.Text(value, style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold, color: color)),
        ],
      ),
    );
  }
}
