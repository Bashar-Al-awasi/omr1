class Student {
  final int? id;
  final String studentId;
  final String name;

  Student({this.id, required this.studentId, required this.name});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'student_id': studentId,
      'name': name,
    };
  }

  factory Student.fromMap(Map<String, dynamic> m) {
    return Student(id: m['id'] as int?, studentId: m['student_id'] as String? ?? '', name: m['name'] as String? ?? '');
  }
}
