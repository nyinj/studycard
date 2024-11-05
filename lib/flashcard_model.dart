class Flashcard {
  final int? id;
  final int deckId;
  final String question;
  final String answer;
  final DateTime createdAt;  // Keep it as a DateTime
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
      createdAt: map['createdAt'] != null 
          ? DateTime.parse(map['createdAt']) 
          : DateTime.now(),  // Handle null safely
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
      'createdAt': createdAt.toIso8601String(),  // Ensure DateTime is formatted correctly
    };
  }
}
