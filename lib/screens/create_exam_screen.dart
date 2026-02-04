import 'package:flutter/material.dart';
import 'package:omr1/utils/omr_pdf_print.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart'; // Localization import
import 'package:document_file_save_plus/document_file_save_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:open_file/open_file.dart';

class CreateExamScreen extends StatefulWidget {
  const CreateExamScreen({super.key});

  @override
  State<CreateExamScreen> createState() => _CreateExamScreenState();
}

class _CreateExamScreenState extends State<CreateExamScreen> {
  final _formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();
  int _step = 0;
  String? _title;
  String? _subject;
  int _numQuestions = 10;
  int _numChoices = 5;
  int _idDigits = 6; // Default student ID digits
  List<String?> _answerKey = List.filled(10, null);
  bool _manualEntry = true;
  List<TextEditingController> _marksControllers = List.generate(10, (_) => TextEditingController(text: '1'));

  List<String> get _choiceLabels => List.generate(_numChoices, (i) => String.fromCharCode(65 + i));

  @override
  void dispose() {
    for (final c in _marksControllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!; // Access localizations
    return ScaffoldMessenger(
      key: _scaffoldMessengerKey,
      child: Scaffold(
        backgroundColor: const Color(0xFFF4F6FB),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 2,
          iconTheme: const IconThemeData(color: Color(0xFF007BFF)),
          title: Text(loc.createExam, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          centerTitle: true,
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
            child: Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 700),
                padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
                child: Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: _step == 0 ? _buildExamDetails(loc) : _buildAnswerKey(loc),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildExamDetails(AppLocalizations loc) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(loc.examTitle, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          TextFormField(
            decoration: InputDecoration(
              labelText: loc.examTitle,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(24)),
            ),
            onChanged: (v) => _title = v,
            validator: (v) => v == null || v.trim().isEmpty ? loc.examTitle : null,
          ),
          const SizedBox(height: 20),
          DropdownButtonFormField<String>(
            decoration: InputDecoration(
              labelText: loc.subject,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(24)),
            ),
            items: [
              ...['Math', 'Science', 'History', 'English']
                  .map((s) => DropdownMenuItem(value: s, child: Text(s))),
              if (_subject != null && !_subject!.isEmpty && !_isDuplicateSubject(_subject!))
                DropdownMenuItem(value: _subject, child: Text(_subject!)),
              DropdownMenuItem(value: 'add_new', child: Text('+ ${loc.subject}')),
            ],
            value: _subject,
            onChanged: (v) async {
              if (v == 'add_new') {
                final newSubject = await showDialog<String>(
                  context: context,
                  builder: (context) {
                    String? tempSubject;
                    return AlertDialog(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                      title: Text(loc.subject),
                      content: TextField(
                        autofocus: true,
                        decoration: InputDecoration(labelText: loc.subject),
                        onChanged: (val) => tempSubject = val,
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: Text(loc.back),
                        ),
                        ElevatedButton(
                          onPressed: () => Navigator.of(context).pop(tempSubject),
                          child: Text(loc.next),
                        ),
                      ],
                    );
                  },
                );
                if (newSubject != null && newSubject.trim().isNotEmpty) {
                  setState(() {
                    _subject = newSubject.trim();
                  });
                }
              } else {
                setState(() => _subject = v);
              }
            },
            validator: (v) => v == null || v.isEmpty ? loc.subject : null,
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: Text('${loc.numQuestions}: $_numQuestions', style: const TextStyle(fontSize: 16)),
              ),
              IconButton(
                icon: Icon(Icons.remove_circle_outline, color: Color(0xFF007BFF)),
                onPressed: _numQuestions > 1 ? () => setState(() {
                  _numQuestions--;
                  if (_answerKey.length > _numQuestions) {
                    _answerKey = _answerKey.sublist(0, _numQuestions);
                  }
                  if (_marksControllers.length > _numQuestions) {
                    _marksControllers = _marksControllers.sublist(0, _numQuestions);
                  }
                }) : null,
              ),
              IconButton(
                icon: Icon(Icons.add_circle_outline, color: Color(0xFF007BFF)),
                onPressed: () => setState(() {
                  _numQuestions++;
                  if (_answerKey.length < _numQuestions) {
                    _answerKey = List<String?>.from(_answerKey)..add(null);
                  }
                  if (_marksControllers.length < _numQuestions) {
                    _marksControllers.add(TextEditingController(text: '1'));
                  }
                }),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Text('${loc.numChoices}: $_numChoices', style: const TextStyle(fontSize: 16)),
              ),
              IconButton(
                icon: Icon(Icons.remove_circle_outline, color: Color(0xFF007BFF)),
                onPressed: _numChoices > 2 ? () => setState(() {
                  _numChoices--;
                }) : null,
              ),
              IconButton(
                icon: Icon(Icons.add_circle_outline, color: Color(0xFF007BFF)),
                onPressed: _numChoices < 8 ? () => setState(() {
                  _numChoices++;
                }) : null,
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: Text('${loc.studentIdDigits}: $_idDigits', style: const TextStyle(fontSize: 16)),
              ),
              IconButton(
                icon: Icon(Icons.remove_circle_outline, color: Color(0xFF007BFF)),
                onPressed: _idDigits > 3 ? () => setState(() {
                  _idDigits--;
                }) : null,
              ),
              IconButton(
                icon: Icon(Icons.add_circle_outline, color: Color(0xFF007BFF)),
                onPressed: _idDigits < 12 ? () => setState(() {
                  _idDigits++;
                }) : null,
              ),
            ],
          ),
          const SizedBox(height: 32),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton(
              onPressed: () {
                if (_formKey.currentState?.validate() ?? false) {
                  setState(() => _step = 1);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF007BFF),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
              ),
              child: Text(loc.next, style: const TextStyle(fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnswerKey(AppLocalizations loc) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back, color: Color(0xFF007BFF)),
              onPressed: () => setState(() => _step = 0),
            ),
            const SizedBox(width: 8),
            Text(loc.answerKey, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: ChoiceChip(
                label: Text(loc.manualEntry, overflow: TextOverflow.ellipsis),
                selected: _manualEntry,
                onSelected: (v) => setState(() => _manualEntry = true),
                selectedColor: const Color(0xFF007BFF),
                labelStyle: TextStyle(color: _manualEntry ? Colors.white : Colors.black),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ChoiceChip(
                label: Text(loc.autoEntry, overflow: TextOverflow.ellipsis),
                selected: !_manualEntry,
                onSelected: (v) => setState(() => _manualEntry = false),
                selectedColor: const Color(0xFF007BFF),
                labelStyle: TextStyle(color: !_manualEntry ? Colors.white : Colors.black),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (_manualEntry) ...[
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _numQuestions,
            itemBuilder: (context, i) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Text('Q${i + 1}', style: const TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Wrap(
                        spacing: 8,
                        children: _choiceLabels.map((opt) {
                          final selected = _answerKey[i] == opt;
                          return ChoiceChip(
                            label: Text(opt),
                            selected: selected,
                            selectedColor: const Color(0xFF007BFF),
                            labelStyle: TextStyle(color: selected ? Colors.white : Colors.black),
                            onSelected: (_) => setState(() => _answerKey[i] = opt),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(width: 12),
                    SizedBox(
                      width: 60,
                      child: TextField(
                        controller: _marksControllers[i],
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: loc.mark,
                          isDense: true,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          if (_answerKey.any((a) => a == null))
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(loc.answerKey, style: const TextStyle(color: Colors.red)),
            ),
        ] else ...[
          Container(
            height: 120,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.upload_file, size: 36, color: Color(0xFF007BFF)),
                  const SizedBox(height: 8),
                  Text(loc.autoEntry, style: TextStyle(color: Colors.grey[700])),
                ],
              ),
            ),
          ),
        ],
        const SizedBox(height: 32),
        Align(
          alignment: Alignment.centerRight,
          child: ElevatedButton(
            onPressed: () {
              if (_manualEntry && _answerKey.any((a) => a == null)) {
                setState(() {});
                return;
              }
              _showA4PreviewDialog(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF007BFF),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
            ),
            child: Text(loc.save, style: const TextStyle(fontSize: 16)),
          ),
        ),
      ],
    );
  }

  void _showA4PreviewDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.18),
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
          insetPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 24),
          backgroundColor: Colors.transparent,
          child: Container(
            constraints: const BoxConstraints(maxWidth: 600, maxHeight: 800),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.10),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Title Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _title ?? '',
                              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _subject ?? '',
                              style: const TextStyle(fontSize: 15, color: Colors.black54),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded, size: 28, color: Colors.black54),
                        splashRadius: 22,
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1, thickness: 1),
                // Main Content
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
                    child: Center(
                      child: Container(
                        constraints: const BoxConstraints(maxWidth: 480),
                        child: AspectRatio(
                          aspectRatio: 210 / 297, // A4 aspect ratio
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(color: Colors.grey[300]!, width: 1.5),
                              borderRadius: BorderRadius.circular(18),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.04),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
                            child: SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Student ID Section
                                  LayoutBuilder(
                                    builder: (context, constraints) {
                                      return Builder(
                                        builder: (context) {
                                          final loc = AppLocalizations.of(context)!;
                                          double maxWidth = constraints.maxWidth - 90; // label + spacing
                                          double minBubble = 14;
                                          double maxBubble = 22;
                                          double bubble = (_idDigits * (maxBubble + 8) > maxWidth)
                                            ? (maxWidth / _idDigits) - 8
                                            : maxBubble;
                                          bubble = bubble.clamp(minBubble, maxBubble);
                                          return Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(loc.studentId, style: const TextStyle(fontWeight: FontWeight.w600)),
                                                  const SizedBox(width: 12),
                                                  Expanded(
                                                    child: Wrap(
                                                      spacing: 8,
                                                      runSpacing: 2,
                                                      children: List.generate(_idDigits, (d) => Column(
                                                        mainAxisSize: MainAxisSize.min,
                                                        children: [
                                                          for (int n = 0; n < 10; n++)
                                                            Padding(
                                                              padding: const EdgeInsets.symmetric(vertical: 1.2),
                                                              child: Container(
                                                                width: bubble,
                                                                height: bubble,
                                                                decoration: BoxDecoration(
                                                                  shape: BoxShape.circle,
                                                                  border: Border.all(color: Colors.black26, width: 1.1),
                                                                  color: Colors.white,
                                                                ),
                                                                child: Center(
                                                                  child: Text('$n', style: TextStyle(fontSize: bubble * 0.55, color: Colors.black54)),
                                                                ),
                                                              ),
                                                            ),
                                                        ],
                                                      )),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                    },
                                  ),
                                  const SizedBox(height: 18),
                                  // Questions Section
                                  ...List.generate(_numQuestions, (i) => Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 7),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        SizedBox(
                                          width: 36,
                                          child: Builder(
                                            builder: (context) {
                                              final loc = AppLocalizations.of(context)!;
                                              return Text('${loc.question} ${i + 1}', style: const TextStyle(fontWeight: FontWeight.w600));
                                            },
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        ..._choiceLabels.map((opt) => Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 4),
                                          child: Column(
                                            children: [
                                              Container(
                                                width: 18,
                                                height: 18,
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  border: Border.all(color: Colors.black38, width: 1.2),
                                                  color: Colors.white,
                                                ),
                                              ),
                                              Text(opt, style: const TextStyle(fontSize: 11)),
                                            ],
                                          ),
                                        )),
                                        const SizedBox(width: 10),
                                        Builder(
                                          builder: (context) {
                                            final loc = AppLocalizations.of(context)!;
                                            return Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                              decoration: BoxDecoration(
                                                color: const Color(0xFF007BFF).withOpacity(0.09),
                                                borderRadius: BorderRadius.circular(7),
                                              ),
                                              child: Text('${loc.mark}: ${_marksControllers.length > i ? _marksControllers[i].text : '1'}', style: const TextStyle(fontSize: 12, color: Color(0xFF007BFF))),
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                  )),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                // Footer
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.vertical(bottom: Radius.circular(28)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 2,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Wrap(
                    alignment: WrapAlignment.end,
                    spacing: 12,
                    runSpacing: 8,
                    children: [
                      Builder(
                        builder: (context) {
                          final loc = AppLocalizations.of(context)!;
                          return OutlinedButton.icon(
                            icon: const Icon(Icons.picture_as_pdf, color: Color(0xFF007BFF)),
                            label: Text(loc.exportPdf, style: const TextStyle(color: Color(0xFF007BFF))),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Color(0xFF007BFF)),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                            ),
                            onPressed: () async {
                              String fileName = '${_title ?? 'exam'}.pdf';
                              final pdfBytes = await printOmrExamPaper(
                                context: context,
                                examTitle: _title ?? '',
                                idDigits: _idDigits,
                                numQuestions: _numQuestions,
                                numChoices: _numChoices,
                              );
                              if (pdfBytes.isEmpty) return;
                              // Show dialog to let user edit filename before saving
                              String? editedFileName = await showDialog<String>(
                                context: context,
                                builder: (dialogContext) {
                                  final controller = TextEditingController(text: fileName);
                                  return AlertDialog(
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                                    title: Text(loc.exportPdf),
                                    content: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(loc.chooseSaveLocation),
                                        const SizedBox(height: 12),
                                        TextField(
                                          controller: controller,
                                          autofocus: true,
                                          decoration: InputDecoration(
                                            labelText: loc.fileName,
                                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        // if (Theme.of(context).platform == TargetPlatform.android)
                                        //   Text(
                                        //     loc.androidSaveHint,
                                        //     style: const TextStyle(fontSize: 12, color: Colors.grey),
                                        //     textAlign: TextAlign.center,
                                        //   ),
                                      ],
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.of(dialogContext).pop(),
                                        child: Text(loc.cancel),
                                      ),
                                      ElevatedButton(
                                        onPressed: () {
                                          String name = controller.text.trim();
                                          // Remove invalid filename characters (Windows, macOS, Linux)
                                          name = name.replaceAll(RegExp(r'[\\/:*?"<>|]'), '');
                                          if (!name.toLowerCase().endsWith('.pdf')) {
                                            name +='.pdf';
                                          }
                                          if (name.isEmpty || name == '.pdf') {
                                            // Show error (simple way: shake or ignore)
                                            Navigator.of(dialogContext).pop(fileName); // fallback
                                          } else {
                                            Navigator.of(dialogContext).pop(name);
                                          }
                                        },
                                        child: Text(loc.save),
                                      ),
                                    ],
                                  );
                                },
                              );
                              if (editedFileName == null) return;
                              fileName = editedFileName;
                              // Use DocumentFileSavePlus for Android, FilePicker for others
                              try {
                                if (Theme.of(context).platform == TargetPlatform.android) {
                                  await DocumentFileSavePlus().saveFile(
                                    Uint8List.fromList(pdfBytes),
                                    fileName,
                                    "application/pdf",
                                  );
                                  _scaffoldMessengerKey.currentState?.showSnackBar(
                                    SnackBar(
                                      content: Text(loc.pdfSaved),
                                    ),
                                  );
                                } else {
                                  String? outputPath = await FilePicker.platform.saveFile(
                                    dialogTitle: loc.chooseSaveLocation,
                                    fileName: fileName,
                                    type: FileType.custom,
                                    allowedExtensions: ['pdf'],
                                  );
                                  if (outputPath != null) {
                                    final file = File(outputPath);
                                    await file.writeAsBytes(pdfBytes);
                                    _scaffoldMessengerKey.currentState?.showSnackBar(
                                      SnackBar(content: Text('${loc.pdfSavedTo} $outputPath'), action: SnackBarAction(label: loc.view, onPressed: () => OpenFile.open(outputPath))),
                                    );
                                  }
                                }
                              } catch (e) {
                                _scaffoldMessengerKey.currentState?.showSnackBar(
                                  SnackBar(content: Text('Error: $e')),
                                );
                              }
                            },
                          );
                        },
                      ),
                      Builder(
                        builder: (context) {
                          final loc = AppLocalizations.of(context)!;
                          return TextButton.icon(
                            icon: const Icon(Icons.save_rounded, color: Color(0xFF007BFF)),
                            label: Text(loc.save, style: const TextStyle(color: Color(0xFF007BFF))),
                            style: TextButton.styleFrom(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                            ),
                            onPressed: () {
                              Navigator.of(context).pop();
                              showDialog(
                                context: context,
                                builder: (context) {
                                  final loc = AppLocalizations.of(context)!;
                                  return AlertDialog(
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                                    title: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.check_circle, color: Color(0xFF43A047), size: 48),
                                        const SizedBox(height: 8),
                                        Text(loc.examCreated),
                                      ],
                                    ),
                                    content: Text(loc.examSaved),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        child: Text(loc.ok),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _StepCircle extends StatelessWidget {
  final bool active;
  final String label;
  const _StepCircle({required this.active, required this.label});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!; // Access localization
    // Only use ARB keys that exist. Fallback to label if not found.
    String displayLabel;
    if (label == '1') {
      displayLabel = loc.examTitle; // Use examTitle as step 1 label
    } else if (label == '2') {
      displayLabel = loc.answerKey;
    } else {
      displayLabel = label;
    }
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: active ? const Color(0xFF007BFF) : Colors.grey[300],
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          displayLabel,
          style: TextStyle(
            color: active ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

bool _isDuplicateSubject(String subject) {
    final predefinedSubjects = ['Math', 'Science', 'History', 'English'];
    return predefinedSubjects.contains(subject);
  }
