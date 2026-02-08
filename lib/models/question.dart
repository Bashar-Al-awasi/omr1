class Question {
  final int? id;
  final int examId;
  final int questionNumber;
  final int correctChoice;
  final int mark;

  Question({
    this.id,
    required this.examId,
    required this.questionNumber,
    required this.correctChoice,
    required this.mark,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'exam_id': examId,
      'question_number': questionNumber,
      'correct_choice': correctChoice,
      'mark': mark,
    };
  }

  factory Question.fromMap(Map<String, dynamic> map) {
    return Question(
      id: map['id'] as int?,
      examId: map['exam_id'] as int,
      questionNumber: map['question_number'] as int,
      correctChoice: map['correct_choice'] as int,
      mark: map['mark'] as int,
    );
  }
}
