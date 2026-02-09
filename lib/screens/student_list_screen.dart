import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import '../providers/student_provider.dart';
import '../models/student.dart';
import 'student_group_screen.dart';

class StudentListScreen extends StatelessWidget {
  const StudentListScreen({super.key});

  Future<void> _pickAndImport(BuildContext context) async {
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
    if (title == null || title!.isEmpty || subject == null || subject!.isEmpty) return;

    final result = await FilePicker.platform.pickFiles(allowMultiple: false, type: FileType.custom, allowedExtensions: ['csv', 'txt', 'xls', 'xlsx']);
    if (result == null) return;
    final path = result.files.single.path;
    if (path == null) return;
    final file = File(path);
    final provider = Provider.of<StudentProvider>(context, listen: false);
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );
    try {
      await provider.importFromFileWithMeta(file, subject!, title!);
      messenger.showSnackBar(const SnackBar(content: Text('Import complete')));
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('Import failed: $e')));
    } finally {
      navigator.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Students')),
      body: Consumer<StudentProvider>(builder: (context, prov, _) {
        final list = prov.students;
        if (list.isEmpty) return const Center(child: Text('No students imported'));

        // Group students by subject and title
        final Map<String, Map<String, List<Student>>> grouped = {};
        for (final s in list) {
          final subject = s.subject ?? 'Unknown Subject';
          final title = s.title ?? 'Unknown Title';
          grouped.putIfAbsent(subject, () => {});
          grouped[subject]!.putIfAbsent(title, () => []);
          grouped[subject]![title]!.add(s);
        }

        return ListView(
          children: grouped.entries.expand((subjectEntry) {
            final subject = subjectEntry.key;
            final titles = subjectEntry.value;
            return [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: Text(subject, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              ...titles.entries.map((titleEntry) {
                final title = titleEntry.key;
                final students = titleEntry.value;
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: ListTile(
                    title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('${students.length} students'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) => StudentGroupScreen(
                          subject: subject,
                          title: title,
                          students: students,
                        ),
                      ));
                    },
                  ),
                );
              })
            ];
          }).toList(),
        );
      }),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.upload_file),
        label: const Text('Import'),
        onPressed: () => _pickAndImport(context),
      ),
    );
  }
}

