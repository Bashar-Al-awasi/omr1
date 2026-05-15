import 'package:file_picker/file_picker.dart';
import 'live_scan_screen.dart';
// removed unused imports: excel, typed_data
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../utils/omr_pipeline.dart';
import 'package:provider/provider.dart';
import '../providers/student_provider.dart';
import '../db/database_helper.dart';
import '../models/exam.dart';
import '../models/result.dart';
import '../models/question.dart';
import 'dart:convert';
import '../providers/auth_provider.dart';
import '../providers/sync_provider.dart';

class OmrScanScreen extends StatefulWidget {
  const OmrScanScreen({super.key});

  @override
  State<OmrScanScreen> createState() => _OmrScanScreenState();
}

class _OmrScanScreenState extends State<OmrScanScreen> {
  String? _studentFileName;
  String? _scanResult;
  File? _selectedImage;
  String? _tempIdResult;
  List<Exam> _exams = [];
  Exam? _selectedExam;

  @override
  void initState() {
    super.initState();
    _loadExams();
  }

  Future<void> _loadExams() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final exams = await DatabaseHelper().getAllExams(auth.userId);
    setState(() {
      _exams = exams;
    });
  }

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
    String? title;
    String? subject;
    await showDialog(
      context: context,
      builder: (ctx) {
        final titleController = TextEditingController();
        final subjectController = TextEditingController();
        return AlertDialog(
          title: const Text('New List Info'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Title'),
              ),
              TextField(
                controller: subjectController,
                decoration: const InputDecoration(labelText: 'Subject'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                title = titleController.text.trim();
                subject = subjectController.text.trim();
                Navigator.of(ctx).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
    if (title == null || title!.isEmpty || subject == null || subject!.isEmpty)
      return;

    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv', 'txt', 'xls', 'xlsx'],
      withData: true,
    );
    if (result == null) return;
    final file = result.files.single;
    _studentFileName = file.name;
    final provider = Provider.of<StudentProvider>(context, listen: false);
    final auth = Provider.of<AuthProvider>(context, listen: false);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );
    try {
      if (file.path != null) {
        await provider.importFromFileWithMeta(
            File(file.path!), subject!, title!);
      } else if (file.bytes != null) {
        final tmp = await Directory.systemTemp.createTemp('omr_students');
        final f = File('${tmp.path}/${file.name}');
        await f.writeAsBytes(file.bytes!);
        await provider.importFromFileWithMeta(f, subject!, title!);
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(loc.studentsLoaded(provider.students.length))));
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(loc.importFailed(e.toString()))));
    } finally {
      if (mounted) Navigator.of(context).pop();
      if (mounted) {
        Provider.of<SyncProvider>(context, listen: false).autoSync(auth.userId);
        setState(() {});
      }
    }
  }

  Future<void> _runOmrScan() async {
    final loc = AppLocalizations.of(context)!;
    if (_selectedExam == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(loc.selectExamFirst)));
      return;
    }
    if (_selectedImage == null) {
      setState(() {
        _scanResult = loc.uploadImageFirst;
      });
      return;
    }
    setState(() {
      _scanResult = null;
      _tempIdResult = null;
    });
    try {
      final imagePath = _selectedImage!.path;
      final omr = OMRScanner();
      final result = omr.processImage(imagePath);
      final scannedAnswers = result['answers'] as List<int>;
      final idDigits = result['id'] as List<int>;
      final studentIdStr = idDigits.join();

      // Fetch correct answers for this exam
      final db = DatabaseHelper();
      final correctQuestions =
          await db.getQuestionsByExamId(_selectedExam!.id!);

      int totalMaxMark = 0;
      int studentMark = 0;
      List<Map<String, dynamic>> answerData = [];

      for (int i = 0; i < scannedAnswers.length; i++) {
        final qNum = i + 1;
        // Find matching correct question from DB
        final correctQ = correctQuestions.firstWhere(
            (q) => q.questionNumber == qNum,
            orElse: () => Question(
                examId: -1, questionNumber: -1, correctChoice: -1, mark: 0));

        String selectedLabel = loc.blank;
        if (scannedAnswers[i] >= 0) {
          selectedLabel = String.fromCharCode(65 + scannedAnswers[i]);
        } else if (scannedAnswers[i] == -2) {
          selectedLabel = loc.multi;
        }

        String correctLabel = 'N/A';
        if (correctQ.correctChoice >= 0) {
          correctLabel = String.fromCharCode(65 + correctQ.correctChoice);
        }

        bool isCorrect = (scannedAnswers[i] == correctQ.correctChoice) &&
            (scannedAnswers[i] >= 0);

        if (correctQ.id != null && correctQ.id != -1) {
          totalMaxMark += correctQ.mark;
          if (isCorrect) studentMark += correctQ.mark;
        }

        answerData.add({
          'question': qNum,
          'selected': selectedLabel,
          'correct': correctLabel,
          'isCorrect': isCorrect,
        });
      }

      int scorePercentage =
          totalMaxMark > 0 ? ((studentMark / totalMaxMark) * 100).round() : 0;

      // Lookup student name
      final auth = Provider.of<AuthProvider>(context, listen: false);
      final student = await db.getStudentByStudentId(studentIdStr, auth.userId);
      final studentName = student?.name ?? 'Unknown Student';

      // Save result to database
      final resultToSave = Result(
        examId: _selectedExam!.id!,
        studentId: studentIdStr,
        studentName: studentName,
        score: scorePercentage,
        answers: jsonEncode(answerData),
        date: DateTime.now().toIso8601String(),
        userId: auth.userId,
      );
      await db.insertResult(resultToSave);

      setState(() {
        _scanResult =
            '${loc.examLabel}: ${_selectedExam!.title}\n${loc.studentName}: ${studentName == 'Unknown Student' ? loc.unknownStudent : studentName}\n${loc.scoreLabel}: $scorePercentage%\n${loc.studentId}: $studentIdStr\n\n${loc.results}:\n${answerData.map((a) => "${loc.question}${a['question']}: ${a['selected']} (${a['isCorrect'] ? loc.correct : loc.incorrect})").join("\n")}';
        _tempIdResult = 'Extracted ID: $studentIdStr';
      });

      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(loc.resultSaved)));
      // Trigger auto-sync
      if (mounted) {
        Provider.of<SyncProvider>(context, listen: false).autoSync(auth.userId);
      }
    } catch (e) {
      setState(() {
        _scanResult = loc.scanError(e.toString());
        _tempIdResult = null;
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
        title: Text(loc.scanOmrSheet,
            style: const TextStyle(
                color: Colors.black, fontWeight: FontWeight.bold)),
        actions: [
          if (_selectedExam != null)
            Padding(
              padding: const EdgeInsets.only(right: 10),
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => LiveScanScreen(exam: _selectedExam!),
                    ),
                  );
                },
                icon: const Icon(Icons.videocam, size: 20),
                label: Text(loc.liveScan,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade600,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                ),
              ),
            ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Exam Selection Card
              Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
                elevation: 3,
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: DropdownButtonFormField<Exam>(
                    decoration: InputDecoration(
                      labelText: loc.createExam,
                      prefixIcon: const Icon(Icons.assignment,
                          color: Color(0xFF007BFF)),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                    value: _selectedExam,
                    items: _exams
                        .map((e) => DropdownMenuItem(
                            value: e, child: Text('${e.title} (${e.subject})')))
                        .toList(),
                    onChanged: (v) => setState(() => _selectedExam = v),
                    validator: (v) =>
                        v == null ? loc.selectExam : null,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Student file upload card
              //base
              Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
                elevation: 3,
                margin: EdgeInsets.zero,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
                  child: Row(
                    children: [
                      Icon(Icons.upload_file,
                          color: Color(0xFF43A047), size: 32),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(loc.uploadStudentList,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16)),
                            if (_studentFileName != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(_studentFileName!,
                                    style: TextStyle(
                                        fontSize: 13, color: Colors.grey[700]),
                                    overflow: TextOverflow.ellipsis),
                              ),
                            Consumer<StudentProvider>(builder: (_, prov, __) {
                              return prov.students.isNotEmpty
                                  ? Padding(
                                      padding: const EdgeInsets.only(top: 2),
                                      child: Text(
                                          '(${prov.students.length} ${loc.students})',
                                          style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey[600])),
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
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 18, vertical: 12),
                        ),
                        child: Text(loc.chooseFile,
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
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
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black12,
                        blurRadius: 8,
                        offset: Offset(0, 4))
                  ],
                ),
                child: _selectedImage == null
                    ? Stack(
                        alignment: Alignment.center,
                        children: [
                          Icon(Icons.camera_alt,
                              size: 70, color: Colors.grey[400]),
                          Positioned(
                            bottom: 16,
                            child: Text(loc.alignOmrInstruction,
                                style: TextStyle(
                                    color: Colors.grey[700], fontSize: 13)),
                          ),
                        ],
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: Image.file(_selectedImage!,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: 220),
                      ),
              ),
              const SizedBox(height: 24),
              // Scan and upload image buttons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.qr_code_scanner),
                      label: Text(loc.scan,
                          style: const TextStyle(
                              fontSize: 17, fontWeight: FontWeight.bold)),
                      onPressed: _pickImageFromCamera,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF007BFF),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18)),
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        elevation: 2,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.upload_file),
                      label: Text(loc.uploadImage,
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w600)),
                      onPressed: _pickImageFromGallery,
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18)),
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
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18)),
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        elevation: 2,
                      ),
                    ),
                  ),
                ],
              ),
              // Controls for number of questions and choices removed (auto-detect)
              // no manual lookup UI; upload stores students to DB via provider
              if (_tempIdResult != null) ...[
                const SizedBox(height: 18),
                Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18)),
                  elevation: 4,
                  color: Colors.yellow[50],
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Icon(Icons.perm_identity,
                            color: Colors.deepOrange, size: 30),
                        const SizedBox(width: 14),
                        Expanded(
                            child: Text(_tempIdResult!,
                                style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600))),
                      ],
                    ),
                  ),
                ),
              ],
              if (_scanResult != null) ...[
                const SizedBox(height: 18),
                Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18)),
                  elevation: 4,
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.assignment_turned_in,
                            color: Color(0xFF007BFF), size: 36),
                        const SizedBox(width: 18),
                        Expanded(
                          child: Text(_scanResult!,
                              style: const TextStyle(
                                  fontSize: 17, fontWeight: FontWeight.w500)),
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
                      style: TextStyle(
                          color: Colors.red[700],
                          fontWeight: FontWeight.bold,
                          fontSize: 15),
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
