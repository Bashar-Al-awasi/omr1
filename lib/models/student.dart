class Student {
  final int? id;
  final String studentId;
  final String name;
  final String? subject;
  final String? notes;
  final String? title;

  Student({
    this.id,
    required this.studentId,
    required this.name,
    this.subject,
    this.notes,
    this.title,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'student_id': studentId,
      'name': name,
      'subject': subject,
      'notes': notes,
      'title': title,
    };
  }

  factory Student.fromMap(Map<String, dynamic> m) {
    return Student(
      id: m['id'] as int?,
      studentId: m['student_id'] as String? ?? '',
      name: m['name'] as String? ?? '',
      subject: m['subject'] as String?,
      notes: m['notes'] as String?,
      title: m['title'] as String?,
    );
  }
}
