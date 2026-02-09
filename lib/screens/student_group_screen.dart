import 'package:flutter/material.dart';
import '../models/student.dart';

class StudentGroupScreen extends StatelessWidget {
  final String subject;
  final String title;
  final List<Student> students;

  const StudentGroupScreen({
    super.key,
    required this.subject,
    required this.title,
    required this.students,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('$subject - $title')),
      body: ListView.builder(
        itemCount: students.length,
        itemBuilder: (_, i) {
          final s = students[i];
          return ListTile(
            leading: CircleAvatar(child: Text((i + 1).toString())),
            title: Text(s.name.isEmpty ? '—' : s.name),
            subtitle: Text(s.studentId),
          );
        },
      ),
    );
  }
}
