import 'package:file_picker/file_picker.dart';
// removed unused imports: excel, typed_data
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../utils/omr_pipeline.dart';
import 'package:provider/provider.dart';
import '../providers/student_provider.dart';
// no direct Student model import needed here

class OmrScanScreen extends StatefulWidget {
  const OmrScanScreen({super.key});

  @override
  State<OmrScanScreen> createState() => _OmrScanScreenState();
}

class _OmrScanScreenState extends State<OmrScanScreen> {
  String? _studentFileName;
  String? _scanResult;
  File? _selectedImage;
  // removed manual lookup fields
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
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv', 'txt', 'xls', 'xlsx'],
      withData: true,
    );
    if (result == null) return;
    final file = result.files.single;
    _studentFileName = file.name;
    final provider = Provider.of<StudentProvider>(context, listen: false);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );
    try {
      if (file.path != null) {
        await provider.importFromFile(File(file.path!));
      } else if (file.bytes != null) {
        final tmp = await Directory.systemTemp.createTemp('omr_students');
        final f = File('${tmp.path}/${file.name}');
        await f.writeAsBytes(file.bytes!);
        await provider.importFromFile(f);
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(loc.studentsLoaded(provider.students.length))));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Import failed: $e')));
    } finally {
      if (mounted) Navigator.of(context).pop();
      if (mounted) setState(() {});
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

  // manual lookup removed per request; upload uses StudentProvider.importFromFile
  


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
                            Consumer<StudentProvider>(builder: (_, prov, __) {
                              return prov.students.isNotEmpty
                                  ? Padding(
                                      padding: const EdgeInsets.only(top: 2),
                                      child: Text('(${prov.students.length} ${loc.students})', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                                    )
                                  : const SizedBox.shrink();
                            }),
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
              // no manual lookup UI; upload stores students to DB via provider
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
              Consumer<StudentProvider>(builder: (_, prov, __) {
                if (prov.students.isEmpty && _scanResult == null) {
                  return Column(children: [
                    const SizedBox(height: 18),
                    Text(
                      loc.uploadStudentListRequired,
                      style: TextStyle(color: Colors.red[700], fontWeight: FontWeight.bold, fontSize: 15),
                      textAlign: TextAlign.center,
                    ),
                  ]);
                }
                return const SizedBox.shrink();
              }),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
