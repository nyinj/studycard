class Flashcard {
  final int? id;
  final int deckId;
  final String question;
  final String answer;
  final DateTime createdAt;
  final String color;
  String note; // This will hold the note for each flashcard
  final int score; // Add score field

  Flashcard({
    this.id,
    required this.deckId,
    required this.question,
    required this.answer,
    required this.createdAt,
    required this.color,
    this.note = '', // Default empty note
    this.score = 0, // Default score of 0
  });

  // Convert a Map into a Flashcard
  factory Flashcard.fromMap(Map<String, dynamic> map) {
    return Flashcard(
      id: map['id'],
      deckId: map['deckId'],
      question: map['question'],
      answer: map['answer'],
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'])
          : DateTime.now(),
      color: map['color'],
      note: map['note'] ?? '', // Default empty note if no note is available
      score: map['score'] ??
          0, // Get score from map (default to 0 if not available)
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
      'note': note, // Include the note when converting to Map
      'score': score, // Include the score when converting to Map
    };
  }
}
