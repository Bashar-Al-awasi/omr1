import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../providers/student_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/sync_provider.dart';
import '../models/student.dart';
import 'student_group_screen.dart';

class StudentListScreen extends StatefulWidget {
  const StudentListScreen({super.key});

  @override
  State<StudentListScreen> createState() => _StudentListScreenState();
}

class _StudentListScreenState extends State<StudentListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<StudentProvider>(context, listen: false).load();
    });
  }

  Future<void> _pickAndImport(BuildContext context) async {
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    final result = await showModalBottomSheet<Map<String, String>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final titleController = TextEditingController();
        final subjectController = TextEditingController();
        return Padding(
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
            ),
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
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
                const SizedBox(height: 24),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: theme.primaryColor.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.drive_folder_upload,
                          color: theme.primaryColor, size: 28),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(loc.newListInfo,
                              style: const TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.w900)),
                          Text(loc.importDetailsSubtitle,
                              style: TextStyle(
                                  color: Colors.grey[500], fontSize: 13)),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(
                    labelText: loc.title,
                    prefixIcon: const Icon(Icons.title),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: subjectController,
                  decoration: InputDecoration(
                    labelText: loc.subject,
                    prefixIcon: const Icon(Icons.book_outlined),
                  ),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      final t = titleController.text.trim();
                      final s = subjectController.text.trim();
                      if (t.isNotEmpty && s.isNotEmpty) {
                        Navigator.of(ctx).pop({'title': t, 'subject': s});
                      }
                    },
                    child: Text(loc.next),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (result == null) return;
    final title = result['title']!;
    final subject = result['subject']!;

    final fileResult = await FilePicker.platform.pickFiles(
        allowMultiple: false,
        type: FileType.custom,
        allowedExtensions: ['csv', 'txt', 'xls', 'xlsx', 'pdf']);
    if (fileResult == null) return;
    final path = fileResult.files.single.path;
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
      final int count = await provider.importFromFileWithMeta(file, subject, title);
      // Trigger auto-sync
      final auth = Provider.of<AuthProvider>(context, listen: false);
      Provider.of<SyncProvider>(context, listen: false).autoSync(auth.userId);

      if (context.mounted) Navigator.of(context).pop(); // Close loading dialog
      
      messenger.showSnackBar(SnackBar(
        content: Text(count > 0 ? loc.studentsLoaded(count) : "No students found in the file structure."),
        backgroundColor: count > 0 ? Colors.green : Colors.orange[800],
      ));
    } catch (e) {
      if (context.mounted) Navigator.of(context).pop(); // Close loading dialog
      messenger.showSnackBar(SnackBar(
          content: Text(loc.importFailed(e.toString())),
          backgroundColor: Colors.red[700]));
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      appBar: AppBar(
        title: Text(loc.students,
            style: const TextStyle(
                fontWeight: FontWeight.w900, color: Colors.black)),
        centerTitle: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline, color: Colors.grey),
            onPressed: () {},
          ),
        ],
      ),
      body: Consumer<StudentProvider>(builder: (context, prov, _) {
        final list = prov.students;

        if (list.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: theme.primaryColor.withOpacity(0.05),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.group_add_outlined,
                      size: 80, color: theme.primaryColor.withOpacity(0.4)),
                ),
                const SizedBox(height: 24),
                Text(loc.noStudentsImported,
                    style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black54)),
                const SizedBox(height: 8),
                Text('Tap the "+" button to import your students',
                    style: TextStyle(color: Colors.grey[400])),
              ],
            ),
          );
        }

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
          padding: const EdgeInsets.all(20),
          children: [
            // Decorative Search Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 4))
                ],
              ),
              child: TextField(
                decoration: InputDecoration(
                  hintText: loc.search,
                  border: InputBorder.none,
                  prefixIcon: const Icon(Icons.search, color: Colors.grey),
                ),
              ),
            ),
            const SizedBox(height: 28),

            ...grouped.entries.expand((subjectEntry) {
              final subject = subjectEntry.key;
              final titles = subjectEntry.value;
              return [
                Padding(
                  padding: const EdgeInsets.only(bottom: 12, top: 4),
                  child: Row(
                    children: [
                      Container(
                          width: 4,
                          height: 16,
                          decoration: BoxDecoration(
                              color: theme.primaryColor,
                              borderRadius: BorderRadius.circular(2))),
                      const SizedBox(width: 8),
                      Text(subject.toUpperCase(),
                          style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                              letterSpacing: 1.2)),
                    ],
                  ),
                ),
                ...titles.entries.map((titleEntry) {
                  final title = titleEntry.key;
                  final students = titleEntry.value;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 12,
                            offset: const Offset(0, 6))
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Material(
                        color: Colors.transparent,
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16),
                          leading: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: theme.primaryColor.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Icon(Icons.folder_shared,
                                color: theme.primaryColor),
                          ),
                          title: Text(title,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16)),
                          subtitle: Text(loc.studentsCount(students.length),
                              style: TextStyle(
                                  color: Colors.grey[600], fontSize: 13)),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                                onPressed: () async {
                                  final confirm = await showDialog<bool>(
                                    context: context,
                                    builder: (ctx) => AlertDialog(
                                      title: const Text('Delete List?'),
                                      content: Text('Are you sure you want to delete "$title"? This removes all students in this list.'),
                                      actions: [
                                        TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancel')),
                                        TextButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('Delete', style: TextStyle(color: Colors.red))),
                                      ],
                                    ),
                                  );
                                  if (confirm == true) {
                                    final provider = Provider.of<StudentProvider>(context, listen: false);
                                    await provider.deleteGroup(title, subject);
                                    final auth = Provider.of<AuthProvider>(context, listen: false);
                                    Provider.of<SyncProvider>(context, listen: false).autoSync(auth.userId);
                                    if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('List deleted')));
                                  }
                                },
                              ),
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                    color: Colors.grey[50], shape: BoxShape.circle),
                                child: const Icon(Icons.chevron_right,
                                    size: 20, color: Colors.grey),
                              ),
                            ],
                          ),
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
                      ),
                    ),
                  );
                }),
              ];
            }).toList(),
          ],
        );
      }),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: Text(loc.importLabel),
        onPressed: () => _pickAndImport(context),
      ),
    );
  }
}
