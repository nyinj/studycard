class Flashcard {
  final int? id;
  final String question;
  final String answer;
  final String color;
  final int? deckId; // Add deckId property

  Flashcard({this.id, required this.question, required this.answer, required this.color, this.deckId});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'question': question,
      'answer': answer,
      'color': color,
      'deckId': deckId, // Include deckId in the map
    };
  }

  static Flashcard fromMap(Map<String, dynamic> map) {
    return Flashcard(
      id: map['id'],
      question: map['question'],
      answer: map['answer'],
      color: map['color'],
      deckId: map['deckId'], // Retrieve deckId from the map
    );
  }
}
