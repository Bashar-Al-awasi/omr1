import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../db/database_helper.dart';
import '../models/exam.dart';
import '../models/question.dart';
import '../providers/auth_provider.dart';
import '../providers/sync_provider.dart';

class EditExamScreen extends StatefulWidget {
  final Exam exam;
  const EditExamScreen({super.key, required this.exam});

  @override
  State<EditExamScreen> createState() => _EditExamScreenState();
}

class _EditExamScreenState extends State<EditExamScreen> {
  late TextEditingController _titleController;
  late TextEditingController _subjectController;
  List<Question> _questions = [];
  bool _isLoading = true;
  bool _isSaving = false;

  // Editable copies
  late List<int> _correctChoices;
  late List<int> _marks;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.exam.title);
    _subjectController = TextEditingController(text: widget.exam.subject);
    _loadQuestions();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _subjectController.dispose();
    super.dispose();
  }

  Future<void> _loadQuestions() async {
    final questions =
        await DatabaseHelper().getQuestionsByExamId(widget.exam.id!);
    setState(() {
      _questions = questions;
      _correctChoices = questions.map((q) => q.correctChoice).toList();
      _marks = questions.map((q) => q.mark).toList();
      _isLoading = false;
    });
  }

  Future<void> _saveChanges() async {
    if (_isSaving) return;
    setState(() => _isSaving = true);

    final db = DatabaseHelper();
    final auth = Provider.of<AuthProvider>(context, listen: false);

    // Update exam title/subject
    final updatedExam = Exam(
      id: widget.exam.id,
      title: _titleController.text.trim(),
      subject: _subjectController.text.trim(),
      date: widget.exam.date,
      numQuestions: widget.exam.numQuestions,
      numChoices: widget.exam.numChoices,
      answerKey: widget.exam.answerKey,
      userId: widget.exam.userId,
    );
    await db.updateExam(updatedExam);

    // Update each question
    for (int i = 0; i < _questions.length; i++) {
      final q = _questions[i];
      final updated = Question(
        id: q.id,
        examId: q.examId,
        questionNumber: q.questionNumber,
        correctChoice: _correctChoices[i],
        mark: _marks[i],
      );
      await db.updateQuestion(updated);
    }

    // Sync
    Provider.of<SyncProvider>(context, listen: false).autoSync(auth.userId);

    setState(() => _isSaving = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Exam updated successfully'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.of(context).pop(true); // true = changed
    }
  }

  String _choiceLabel(int index) {
    if (index < 0) return '—';
    return String.fromCharCode(65 + index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        title: const Text('Edit Exam',
            style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          TextButton.icon(
            onPressed: _isSaving ? null : _saveChanges,
            icon: _isSaving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.save, color: Colors.blue),
            label: Text(
              _isSaving ? 'Saving...' : 'Save',
              style: const TextStyle(
                  color: Colors.blue, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // ── Exam Info Card ──
                Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Exam Details',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _titleController,
                          decoration: InputDecoration(
                            labelText: 'Exam Title',
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12)),
                            prefixIcon: const Icon(Icons.edit),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _subjectController,
                          decoration: InputDecoration(
                            labelText: 'Subject',
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12)),
                            prefixIcon: const Icon(Icons.subject),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${widget.exam.numQuestions} questions  •  ${widget.exam.numChoices} choices  •  ${widget.exam.date}',
                          style:
                              const TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // ── Questions Header ──
                Row(
                  children: [
                    const Text('Answer Key',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    const Spacer(),
                    Text('${_questions.length} questions',
                        style: const TextStyle(color: Colors.grey)),
                  ],
                ),
                const SizedBox(height: 8),

                // ── Questions List ──
                ...List.generate(_questions.length, (i) {
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 10),
                      child: Row(
                        children: [
                          // Question number
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Center(
                              child: Text(
                                'Q${_questions[i].questionNumber}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),

                          // Correct answer dropdown
                          Expanded(
                            flex: 3,
                            child: DropdownButtonFormField<int>(
                              value: _correctChoices[i],
                              decoration: InputDecoration(
                                labelText: 'Answer',
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10)),
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 8),
                                isDense: true,
                              ),
                              items: List.generate(
                                widget.exam.numChoices,
                                (c) => DropdownMenuItem(
                                  value: c,
                                  child: Text(
                                    _choiceLabel(c),
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w600),
                                  ),
                                ),
                              ),
                              onChanged: (val) {
                                if (val != null) {
                                  setState(() => _correctChoices[i] = val);
                                }
                              },
                            ),
                          ),
                          const SizedBox(width: 12),

                          // Mark input
                          Expanded(
                            flex: 2,
                            child: TextFormField(
                              initialValue: _marks[i].toString(),
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: 'Mark',
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10)),
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 8),
                                isDense: true,
                              ),
                              onChanged: (val) {
                                final parsed = int.tryParse(val);
                                if (parsed != null && parsed >= 0) {
                                  _marks[i] = parsed;
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),

                const SizedBox(height: 80), // space for FAB
              ],
            ),
    );
  }
}
