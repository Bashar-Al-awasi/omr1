import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:flutter/material.dart';

// Corner marker widget (smaller for inner corners)
pw.Widget cornerMarker({double size = 20}) => pw.Container(width: size, height: size, color: PdfColors.black);

// Helper for four inner markers inside a fixed-size box (smaller and with more padding)
pw.Widget fourInnerMarkers() {
  return pw.Stack(children: [
    pw.Positioned(left: 4, top: 4, child: cornerMarker(size: 12)),
    pw.Positioned(right: 4, top: 4, child: cornerMarker(size: 12)),
    pw.Positioned(left: 4, bottom: 4, child: cornerMarker(size: 12)),
    pw.Positioned(right: 4, bottom: 4, child: cornerMarker(size: 12)),
  ]);
}

/// Generates an OMR-style exam sheet PDF and fills bubbles according to
/// `selectedId` and `answerKey` if provided.
Future<Uint8List> printOmrExamPaper({
  required BuildContext context,
  required String examTitle,
  required int idDigits,
  required int numQuestions,
  required int numChoices,
  List<int>? selectedId, // length == idDigits, values 0-9 or -1 for none
  List<int>? answerKey, // length == numQuestions, values 0..numChoices-1 or -1
}) async {
  final pdf = pw.Document();

  // Helpers
  pw.Widget _blackMark() => pw.Container(width: 40, height: 8, color: PdfColors.black);

  pw.Widget _lineField(String label) {
    return pw.Expanded(
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text('$label:', style: const pw.TextStyle(fontSize: 10)),
          pw.Container(height: 14, decoration: const pw.BoxDecoration(border: pw.Border(bottom: pw.BorderSide()))),
        ],
      ),
    );
  }

  pw.Widget _instructionsBox() {
    return pw.Container(
      width: 200,
      padding: const pw.EdgeInsets.all(8),
      decoration: pw.BoxDecoration(border: pw.Border.all()),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text('INSTRUCTIONS:', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 4),
          pw.Text('• Use a Black or Dark Blue pen.', style: const pw.TextStyle(fontSize: 9)),
          pw.Text('• Darken the circle completely.', style: const pw.TextStyle(fontSize: 9)),
          pw.Text('• Do not fold or crease this paper.', style: const pw.TextStyle(fontSize: 9)),
        ],
      ),
    );
  }

  // Build dynamic questions column with optional filled choices
  pw.Widget _questionsColumnDynamic(int start, int end, int choices, List<int>? answers) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: List.generate(end - start + 1, (i) {
        final q = start + i;
        final sel = (answers != null && answers.length >= q) ? answers[q - 1] : -1;
        return pw.Padding(
          padding: const pw.EdgeInsets.symmetric(vertical: 1),
          child: pw.Row(
            children: [
              pw.SizedBox(width: 14, child: pw.Text('$q.', style: const pw.TextStyle(fontSize: 9))),
              ...List.generate(choices, (c) {
                final filled = sel == c;
                return pw.Container(
                  margin: const pw.EdgeInsets.symmetric(horizontal: 1),
                  width: 10,
                  height: 10,
                  decoration: pw.BoxDecoration(
                    shape: pw.BoxShape.circle,
                    border: pw.Border.all(width: 0.5),
                    color: filled ? PdfColors.black : PdfColors.white,
                  ),
                  child: pw.Center(
                    child: pw.Text(String.fromCharCode(65 + c), style: pw.TextStyle(fontSize: 5, color: filled ? PdfColors.white : PdfColors.black)),
                  ),
                );
              }),
            ],
          ),
        );
      }),
    );
  }

  // ID digit column with optional selection
  pw.Widget _idDigitColumnWithSelection(int colIndex) {
    final sel = (selectedId != null && selectedId.length > colIndex) ? selectedId[colIndex] : -1;
    return pw.Column(
      children: List.generate(10, (i) {
        final filled = sel == i;
        return pw.Container(
          margin: const pw.EdgeInsets.symmetric(vertical: 2, horizontal: 4),
          width: 12,
          height: 12,
          decoration: pw.BoxDecoration(shape: pw.BoxShape.circle, border: pw.Border.all(width: 0.6), color: filled ? PdfColors.black : PdfColors.white),
          child: pw.Center(child: pw.Text('$i', style: pw.TextStyle(fontSize: 6, color: filled ? PdfColors.white : PdfColors.black))),
        );
      }),
    );
  }

  // Page
  pdf.addPage(pw.Page(
    pageFormat: PdfPageFormat.a4,
    margin: const pw.EdgeInsets.all(24),
    build: (context) {
      // Split the answer section into columns each containing up to 10 questions
      final perCol = numQuestions > 10 ? 10 : numQuestions;
      final cols = (numQuestions / (perCol == 0 ? 1 : perCol)).ceil();

      return pw.Column(
        children: [
          pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [_blackMark(), _blackMark()]),
          pw.SizedBox(height: 12),
          pw.Text(examTitle.isEmpty ? 'OMR SCAN SHEET' : examTitle, style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 4),
          pw.Text('A4 STANDARD | $numQuestions QUESTIONS | ${idDigits}-DIGIT ID', style: const pw.TextStyle(fontSize: 10)),
          pw.SizedBox(height: 16),

          // info row
          pw.Row(children: [_lineField('NAME'), pw.SizedBox(width: 12), _lineField('EXAM')]),
          pw.SizedBox(height: 8),
          pw.Row(children: [_lineField('DATE'), pw.SizedBox(width: 12), _lineField('ID NUMBER')]),
          pw.SizedBox(height: 16),

          // ID + instructions
          pw.Row(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
            pw.Stack(children: [
              pw.Container(
                padding: const pw.EdgeInsets.all(14), // increased padding
                decoration: pw.BoxDecoration(border: pw.Border.all()),
                child: pw.Column(children: [
                  pw.Text('STUDENT ID', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
                  pw.SizedBox(height: 6),
                  pw.Row(children: List.generate(idDigits, (idx) => _idDigitColumnWithSelection(idx))),
                ]),
              ),
              pw.Positioned.fill(child: fourInnerMarkers()),
            ]),
            pw.SizedBox(width: 16),
            _instructionsBox(),
          ]),

          pw.SizedBox(height: 16),

          pw.Stack(children: [
            pw.Container(
              width: double.infinity,
              decoration: pw.BoxDecoration(border: pw.Border.all()),
              padding: const pw.EdgeInsets.all(14), // increased padding
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Container(width: double.infinity, padding: const pw.EdgeInsets.symmetric(vertical: 6), color: PdfColors.black, child: pw.Center(child: pw.Text('ANSWER SECTION', style: pw.TextStyle(color: PdfColors.white, fontSize: 12, fontWeight: pw.FontWeight.bold)))),
                  pw.SizedBox(height: 8),
                  pw.Row(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    mainAxisAlignment: pw.MainAxisAlignment.start,
                    children: List.generate(cols, (col) {
                      final start = col * perCol + 1;
                      final end = ((start + perCol - 1) > numQuestions) ? numQuestions : (start + perCol - 1);
                      return pw.Container(
                        margin: const pw.EdgeInsets.symmetric(horizontal: 2),
                        child: _questionsColumnDynamic(start, end, numChoices, answerKey),
                      );
                    }),
                  ),
                ],
              ),
            ),
            pw.Positioned.fill(child: fourInnerMarkers()),
          ]),

          pw.Spacer(),

          pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [_blackMark(), _blackMark()]),
        ],
      );
    },
  ));

  return pdf.save();
}
