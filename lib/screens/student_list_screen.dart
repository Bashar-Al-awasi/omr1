import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import '../providers/student_provider.dart';
import '../models/student.dart';

class StudentListScreen extends StatelessWidget {
  const StudentListScreen({super.key});

  Future<void> _pickAndImport(BuildContext context) async {
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
      await provider.importFromFile(file);
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
        return ListView.builder(
          itemCount: list.length,
          itemBuilder: (_, i) {
            final Student s = list[i];
            return ListTile(
              leading: CircleAvatar(child: Text((i + 1).toString())),
              title: Text(s.name.isEmpty ? '—' : s.name),
              subtitle: Text(s.studentId),
            );
          },
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
