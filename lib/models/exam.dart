class Exam {
  final int? id;
  final String title;
  final String subject;
  final String date;
  final int numQuestions;
  final int numChoices;
  final String answerKey; // Store as JSON string
  final String? userId;

  Exam({
    this.id,
    required this.title,
    required this.subject,
    required this.date,
    required this.numQuestions,
    required this.numChoices,
    required this.answerKey,
    this.userId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'subject': subject,
      'date': date,
      'num_questions': numQuestions,
      'num_choices': numChoices,
      'answer_key': answerKey,
      'user_id': userId,
    };
  }

  factory Exam.fromMap(Map<String, dynamic> map) {
    return Exam(
      id: map['id'] as int?,
      title: map['title'] as String,
      subject: map['subject'] as String,
      date: map['date'] as String,
      numQuestions: map['num_questions'] as int,
      numChoices: map['num_choices'] as int,
      answerKey: map['answer_key'] as String,
      userId: map['user_id'] as String?,
    );
  }
}
