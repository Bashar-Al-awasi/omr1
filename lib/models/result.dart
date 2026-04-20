class Result {
  final int? id;
  final int examId;
  final String studentId;
  final String studentName; // Added studentName
  final int score;
  final String answers; // Store as JSON string
  final String date;

  Result({
    this.id,
    required this.examId,
    required this.studentId,
    required this.studentName,
    required this.score,
    required this.answers,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'exam_id': examId,
      'student_id': studentId,
      'student_name': studentName,
      'score': score,
      'answers': answers,
      'date': date,
    };
  }

  factory Result.fromMap(Map<String, dynamic> map) {
    return Result(
      id: map['id'] as int?,
      examId: map['exam_id'] as int,
      studentId: map['student_id'] as String,
      studentName: map['student_name'] as String? ?? 'Unknown Student',
      score: map['score'] as int,
      answers: map['answers'] as String,
      date: map['date'] as String,
    );
  }
}
