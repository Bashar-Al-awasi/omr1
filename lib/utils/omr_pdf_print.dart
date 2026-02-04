import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'dart:typed_data';
import 'package:flutter/material.dart';

Future<Uint8List> printOmrExamPaper({
  required BuildContext context,
  required String examTitle,
  required int idDigits,
  required int numQuestions,
  required int numChoices,
}) async {
  final pdf = pw.Document();
  pdf.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(32),
      build: (pw.Context ctx) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.stretch,
          children: [
            // Header Section
            pw.Text(examTitle, style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 16),
            // Student ID Section
            pw.Container(
              padding: const pw.EdgeInsets.all(4),
              width: idDigits * 12 + 8, // Adjust width based on bubble size and spacing
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.black, width: 1),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('Student ID', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
                  pw.SizedBox(height: 4),
                  pw.Wrap(
                    spacing: 2,
                    runSpacing: 2,
                    children: List.generate(idDigits, (index) => pw.Column(
                      children: List.generate(10, (digit) => pw.Container(
                        width: 10,
                        height: 10,
                        margin: const pw.EdgeInsets.symmetric(vertical: 1),
                        decoration: pw.BoxDecoration(
                          shape: pw.BoxShape.circle,
                          border: pw.Border.all(color: PdfColors.black, width: 0.5),
                        ),
                        child: pw.Center(
                          child: pw.Text('$digit', style: pw.TextStyle(fontSize: 6)),
                        ),
                      )),
                    )),
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 20),
            // Questions Section
            pw.Container(
              padding: const pw.EdgeInsets.all(4),
              width: numChoices * 12 + 8, // Adjust width based on bubble size and spacing
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.black, width: 1),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('Questions', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
                  pw.SizedBox(height: 4),
                  pw.Wrap(
                    spacing: 2,
                    runSpacing: 2,
                    children: List.generate(numQuestions, (index) => pw.Row(
                      children: [
                        pw.Text('Q${index + 1}', style: pw.TextStyle(fontSize: 10)),
                        pw.SizedBox(width: 4),
                        ...List.generate(numChoices, (choice) => pw.Container(
                          width: 10,
                          height: 10,
                          margin: const pw.EdgeInsets.symmetric(horizontal: 1),
                          decoration: pw.BoxDecoration(
                            shape: pw.BoxShape.circle,
                            border: pw.Border.all(color: PdfColors.black, width: 0.5),
                          ),
                          child: pw.Center(
                            child: pw.Text(String.fromCharCode(65 + choice), style: pw.TextStyle(fontSize: 6)),
                          ),
                        )),
                      ],
                    )),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    ),
  );
  return await pdf.save();
}
