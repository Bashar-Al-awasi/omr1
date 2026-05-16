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
  String? _selectedListTitle;
  String? _selectedListSubject;
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

  /// Shows a bottom sheet with existing student lists + an import option.
  Future<void> _showStudentListPicker(AppLocalizations loc) async {
    final provider = Provider.of<StudentProvider>(context, listen: false);
    // Make sure all students are loaded first
    await provider.load();
    final groups = provider.getListGroups();

    if (!mounted) return;

    final result = await showModalBottomSheet<Map<String, String>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(ctx).size.height * 0.65,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Padding(
                padding: const EdgeInsets.only(top: 12, bottom: 4),
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF007BFF).withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.people_alt_rounded,
                          color: Color(0xFF007BFF), size: 24),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(loc.selectStudentList,
                              style: const TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.w800)),
                          Text(loc.selectOrImportHint,
                              style: TextStyle(
                                  color: Colors.grey[500], fontSize: 12)),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 20),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              // List of existing groups
              if (groups.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 32),
                  child: Column(
                    children: [
                      Icon(Icons.folder_off_outlined,
                          size: 48, color: Colors.grey[300]),
                      const SizedBox(height: 12),
                      Text(loc.noStudentsImported,
                          style: TextStyle(
                              color: Colors.grey[500],
                              fontWeight: FontWeight.w600)),
                      const SizedBox(height: 4),
                      Text(loc.importNewListHint,
                          style: TextStyle(
                              color: Colors.grey[400], fontSize: 12)),
                    ],
                  ),
                )
              else
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    itemCount: groups.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (_, i) {
                      final g = groups[i];
                      final isSelected =
                          _selectedListTitle == g['title'] &&
                              _selectedListSubject == g['subject'];
                      return Material(
                        color: isSelected
                            ? const Color(0xFF007BFF).withOpacity(0.08)
                            : Colors.grey[50],
                        borderRadius: BorderRadius.circular(14),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(14),
                          onTap: () {
                            Navigator.of(ctx).pop({
                              'title': g['title'] as String,
                              'subject': g['subject'] as String,
                            });
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 14),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? const Color(0xFF007BFF)
                                            .withOpacity(0.15)
                                        : Colors.blueGrey.withOpacity(0.08),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(Icons.folder_shared,
                                      color: isSelected
                                          ? const Color(0xFF007BFF)
                                          : Colors.blueGrey,
                                      size: 22),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(g['title'] as String,
                                          style: TextStyle(
                                              fontWeight: FontWeight.w700,
                                              fontSize: 15,
                                              color: isSelected
                                                  ? const Color(0xFF007BFF)
                                                  : Colors.black87)),
                                      const SizedBox(height: 2),
                                      Text(
                                          '${g['subject']}  •  ${loc.studentsCount(g['count'] as int)}',
                                          style: TextStyle(
                                              color: Colors.grey[500],
                                              fontSize: 12)),
                                    ],
                                  ),
                                ),
                                if (isSelected)
                                  const Icon(Icons.check_circle,
                                      color: Color(0xFF007BFF), size: 22)
                                else
                                  Icon(Icons.chevron_right,
                                      color: Colors.grey[400], size: 20),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              // Import new list button
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.add_circle_outline, size: 20),
                    label: Text(loc.importNewList,
                        style: const TextStyle(fontWeight: FontWeight.w700)),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF43A047),
                      side: const BorderSide(color: Color(0xFF43A047)),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: () {
                      Navigator.of(ctx).pop({'action': 'import'});
                    },
                  ),
                ),
              ),
              SizedBox(height: MediaQuery.of(ctx).padding.bottom + 8),
            ],
          ),
        );
      },
    );

    if (result == null) return;

    // User chose to import a new list
    if (result.containsKey('action') && result['action'] == 'import') {
      await _importNewStudentList(loc);
      return;
    }

    // User selected an existing list
    final title = result['title']!;
    final subject = result['subject']!;
    await provider.loadByGroup(title, subject);
    if (mounted) {
      setState(() {
        _selectedListTitle = title;
        _selectedListSubject = subject;
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(loc.studentsLoaded(provider.students.length)),
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF007BFF),
      ));
    }
  }

  /// Import a new student list (title/subject dialog + file picker).
  Future<void> _importNewStudentList(AppLocalizations loc) async {

    final meta = await showModalBottomSheet<Map<String, String>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final titleController = TextEditingController();
        final subjectController = TextEditingController();
        return Padding(
          padding: EdgeInsets.only(
              bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius:
                  BorderRadius.vertical(top: Radius.circular(28)),
            ),
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF43A047).withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.drive_folder_upload,
                          color: Color(0xFF43A047), size: 24),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(loc.newListInfo,
                              style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800)),
                          Text(loc.importDetailsSubtitle,
                              style: TextStyle(
                                  color: Colors.grey[500],
                                  fontSize: 12)),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 20),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(
                    labelText: loc.title,
                    prefixIcon: const Icon(Icons.title),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: subjectController,
                  decoration: InputDecoration(
                    labelText: loc.subject,
                    prefixIcon: const Icon(Icons.book_outlined),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      final t = titleController.text.trim();
                      final s = subjectController.text.trim();
                      if (t.isNotEmpty && s.isNotEmpty) {
                        Navigator.of(ctx)
                            .pop({'title': t, 'subject': s});
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF43A047),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      padding:
                          const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: Text(loc.next,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (meta == null) return;
    final String title = meta['title']!;
    final String subject = meta['subject']!;

    final fileResult = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv', 'txt', 'xls', 'xlsx', 'pdf'],
      withData: true,
    );
    if (fileResult == null) return;
    final file = fileResult.files.single;
    final provider = Provider.of<StudentProvider>(context, listen: false);
    final auth = Provider.of<AuthProvider>(context, listen: false);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );
    int importedCount = 0;
    try {
      if (file.path != null) {
        importedCount = await provider.importFromFileWithMeta(
            File(file.path!), subject, title);
      } else if (file.bytes != null) {
        final tmp = await Directory.systemTemp.createTemp('omr_students');
        final f = File('${tmp.path}/${file.name}');
        await f.writeAsBytes(file.bytes!);
        importedCount = await provider.importFromFileWithMeta(f, subject, title);
      }
      // Automatically select the newly imported list
      await provider.loadByGroup(title, subject);
      if (!mounted) return;
      setState(() {
        _selectedListTitle = title;
        _selectedListSubject = subject;
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(importedCount > 0 
          ? loc.studentsLoaded(importedCount)
          : "No students found in the file structure."),
        behavior: SnackBarBehavior.floating,
        backgroundColor: importedCount > 0 ? const Color(0xFF43A047) : Colors.orange[800],
      ));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(loc.importFailed(e.toString())),
            backgroundColor: Colors.red[700]));
      }
    } finally {
      if (mounted) Navigator.of(context).pop();
      if (mounted) {
        Provider.of<SyncProvider>(context, listen: false)
            .autoSync(auth.userId);
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
              // Student list selection card
              InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () => _showStudentListPicker(loc),
                child: Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                  elevation: 3,
                  margin: EdgeInsets.zero,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 18, vertical: 16),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: _selectedListTitle != null
                                ? const Color(0xFF007BFF).withOpacity(0.1)
                                : const Color(0xFF43A047).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Icon(
                            _selectedListTitle != null
                                ? Icons.people_alt_rounded
                                : Icons.playlist_add,
                            color: _selectedListTitle != null
                                ? const Color(0xFF007BFF)
                                : const Color(0xFF43A047),
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _selectedListTitle != null
                                    ? _selectedListTitle!
                                    : loc.selectStudentList,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  color: _selectedListTitle != null
                                      ? Colors.black87
                                      : Colors.grey[700],
                                ),
                              ),
                              const SizedBox(height: 2),
                              if (_selectedListTitle != null)
                                Consumer<StudentProvider>(
                                    builder: (_, prov, __) {
                                  return Text(
                                    '${_selectedListSubject ?? ""}  •  ${loc.studentsCount(prov.students.length)}',
                                    style: TextStyle(
                                        color: Colors.grey[500], fontSize: 12),
                                  );
                                })
                              else
                                Text(loc.selectOrImportHint,
                                    style: TextStyle(
                                        color: Colors.grey[400], fontSize: 12)),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: _selectedListTitle != null
                                ? const Color(0xFF007BFF)
                                : const Color(0xFF43A047),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _selectedListTitle != null
                                    ? Icons.swap_horiz
                                    : Icons.add,
                                color: Colors.white,
                                size: 18,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                _selectedListTitle != null
                                    ? loc.changeList
                                    : loc.chooseFile,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
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
