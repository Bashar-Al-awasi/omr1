import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../models/student.dart';

class StudentGroupScreen extends StatefulWidget {
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
  State<StudentGroupScreen> createState() => _StudentGroupScreenState();
}

class _StudentGroupScreenState extends State<StudentGroupScreen> {
  late List<Student> _filteredStudents;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _filteredStudents = widget.students;
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredStudents = widget.students.where((s) {
        return s.name.toLowerCase().contains(query) || s.studentId.contains(query);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black)),
            Text(widget.subject, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Column(
        children: [
          // Header Stats & Search
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: Column(
              children: [
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F3F4),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: loc.search,
                      border: InputBorder.none,
                      prefixIcon: const Icon(Icons.search, color: Colors.grey, size: 20),
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      loc.studentsCount(_filteredStudents.length),
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blueGrey),
                    ),
                    const Icon(Icons.sort, color: Colors.grey, size: 20),
                  ],
                ),
              ],
            ),
          ),
          
          // Student List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _filteredStudents.length,
              itemBuilder: (context, i) {
                final s = _filteredStudents[i];
                final initial = s.name.isNotEmpty ? s.name[0].toUpperCase() : '?';
                
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8, offset: const Offset(0, 4))],
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    leading: CircleAvatar(
                      backgroundColor: theme.primaryColor.withOpacity(0.1),
                      child: Text(initial, style: TextStyle(color: theme.primaryColor, fontWeight: FontWeight.bold)),
                    ),
                    title: Text(
                      s.name.isEmpty ? '—' : s.name,
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                    ),
                    subtitle: Text(
                      'ID: ${s.studentId}',
                      style: TextStyle(color: Colors.grey[600], fontSize: 13),
                    ),
                    trailing: Text(
                      '#${i + 1}',
                      style: TextStyle(color: Colors.grey[300], fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
