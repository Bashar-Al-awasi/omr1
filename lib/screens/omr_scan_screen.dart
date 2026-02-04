import 'package:file_picker/file_picker.dart';
import 'package:excel/excel.dart' as ex;
import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../utils/omr_pipeline.dart';

class StudentInfo {
  final String id;
  final String name;
  StudentInfo({required this.id, required this.name});
}

class OmrScanScreen extends StatefulWidget {
  const OmrScanScreen({super.key});

  @override
  State<OmrScanScreen> createState() => _OmrScanScreenState();
}

class _OmrScanScreenState extends State<OmrScanScreen> {
  List<StudentInfo> _students = [];
  String? _studentFileName;
  String? _scanResult;
  File? _selectedImage;
  Future<void> _pickImageFromCamera() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.camera);
    if (picked != null) {
      setState(() {
        _selectedImage = File(picked.path);
      });
    }
  }

  Future<void> _pickImageFromGallery() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _selectedImage = File(picked.path);
      });
    }
  }

  Future<void> _pickStudentFile(AppLocalizations loc) async {
    // Use file_picker to let the user select a file
    // Only allow Excel files with the .xlsx extension to be picked
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom, // Custom type lets us specify allowed extensions
      allowedExtensions: ['xlsx'], // Only .xlsx files are allowed for upload
    );
    if (result != null && result.files.single.bytes != null) {
      final Uint8List bytes = result.files.single.bytes!;
      final excel = ex.Excel.decodeBytes(bytes);
      final students = <StudentInfo>[];
      for (final table in excel.tables.keys) {
        final sheet = excel.tables[table]!;
        for (var i = 1; i < sheet.maxRows; i++) { // skip header
          final row = sheet.row(i);
          if (row.length >= 2 && row[0] != null && row[1] != null) {
            students.add(StudentInfo(id: row[0]!.value.toString().trim(), name: row[1]!.value.toString().trim()));
          }
        }
        break; // Only first sheet
      }
      setState(() {
        _students = students;
        _studentFileName = result.files.single.name;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.studentsLoaded(students.length))),
      );
    }
  }

  Future<void> _runOmrScan() async {
    if (_selectedImage == null) {
      setState(() {
        _scanResult = 'Please upload or capture an image first.';
      });
      return;
    }
    setState(() {
      _scanResult = null;
    });
    try {
      final imagePath = _selectedImage!.path;
      final omr = OMRScanner();
      final answers = omr.processImage(imagePath);
      // Example correct answers (should be loaded or set elsewhere)
      final correctAnswers = [2, 2, 2, 2, 4];
      List<String> results = [];
      for (int i = 0; i < answers.length; i++) {
        if (answers[i] == -1) {
          results.add('Q${i + 1}: Blank');
        } else if (answers[i] == correctAnswers[i]) {
          results.add('Q${i + 1}: Correct');
        } else {
          results.add('Q${i + 1}: Wrong (Your: ${answers[i]}, Correct: ${correctAnswers[i]})');
        }
      }
      setState(() {
        _scanResult = 'Highlighted bubbles (index per row, -1=blank):\n${answers.toString()}\n\nResult per question:\n${results.join("\n")}';
      });
    } catch (e) {
      setState(() {
        _scanResult = 'Error:\n$e';
      });
    }
  }
  


  @override
  Widget build(BuildContext context) {
  final loc = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF007BFF)),
        title: Text(loc.scanOmrSheet, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Student file upload card
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                elevation: 3,
                margin: EdgeInsets.zero,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
                  child: Row(
                    children: [
                      Icon(Icons.upload_file, color: Color(0xFF43A047), size: 32),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(loc.uploadStudentList, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            if (_studentFileName != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(_studentFileName!, style: TextStyle(fontSize: 13, color: Colors.grey[700]), overflow: TextOverflow.ellipsis),
                              ),
                            if (_students.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 2),
                                child: Text('(${_students.length} ${loc.students})', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: () => _pickStudentFile(loc),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF43A047),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                        ),
                        child: Text(loc.chooseFile, style: const TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Camera/gallery image preview
              Container(
                width: double.infinity,
                height: 220,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4))],
                ),
                child: _selectedImage == null
                    ? Stack(
                        alignment: Alignment.center,
                        children: [
                          Icon(Icons.camera_alt, size: 70, color: Colors.grey[400]),
                          Positioned(
                            bottom: 16,
                            child: Text(loc.alignOmrInstruction, style: TextStyle(color: Colors.grey[700], fontSize: 13)),
                          ),
                        ],
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: Image.file(_selectedImage!, fit: BoxFit.cover, width: double.infinity, height: 220),
                      ),
              ),
              const SizedBox(height: 24),
              // Scan and upload image buttons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.qr_code_scanner),
                      label: Text(loc.scan, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                      onPressed: _pickImageFromCamera,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF007BFF),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        elevation: 2,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.upload_file),
                      label: Text(loc.uploadImage, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                      onPressed: _pickImageFromGallery,
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        side: const BorderSide(color: Color(0xFF007BFF)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.analytics),
                      label: const Text('OMR'),
                      onPressed: _runOmrScan,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        elevation: 2,
                      ),
                    ),
                  ),
                ],
              ),
              if (_scanResult != null) ...[
                const SizedBox(height: 28),
                Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                  elevation: 4,
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.assignment_turned_in, color: Color(0xFF007BFF), size: 36),
                        const SizedBox(width: 18),
                        Expanded(
                          child: Text(_scanResult!, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w500)),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
              if (_students.isEmpty && _scanResult == null) ...[
                const SizedBox(height: 18),
                Text(
                  loc.uploadStudentListRequired,
                  style: TextStyle(color: Colors.red[700], fontWeight: FontWeight.bold, fontSize: 15),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
