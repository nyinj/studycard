class Flashcard {
  final int? id;
  final int? deckId;
  final String question;
  final String answer;
  final DateTime createdAt;
  final String color;

  Flashcard({
    this.id,
    required this.deckId,
    required this.question,
    required this.answer,
    required this.createdAt,
    required this.color,
  });

  // Convert a Map into a Flashcard
  factory Flashcard.fromMap(Map<String, dynamic> map) {
    return Flashcard(
      id: map['id'],
      deckId: map['deckId'],
      question: map['question'],
      answer: map['answer'],
      createdAt: DateTime.parse(map['createdAt']),
      color: map['color'],
    );
  }

  // Convert a Flashcard into a Map
  Map<String, dynamic> toMap() {
    return {
      'deckId': deckId,
      'question': question,
      'answer': answer,
      'color': color,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
