import 'package:flutter/material.dart';
import 'package:flip_card/flip_card.dart';

class FlashcardWidget extends StatelessWidget {
  final String question;
  final String answer;
  final String color;

  const FlashcardWidget({
    super.key,
    required this.question,
    required this.answer,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    // The size of the card (square)
    double cardSize = 300.0; // Adjust this value to change the size of the card

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: FlipCard(
        direction: FlipDirection.HORIZONTAL, // Set flip direction
        flipOnTouch: true, // The card flips when tapped
        front: SizedBox(
          width: cardSize,  // Set the width of the square
          height: cardSize, // Set the height of the square
          child: Card(
            color: Color(int.parse(color)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
            elevation: 5,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Label for the question
                Text(
                  "Question",
                  style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.white70,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 10),
                
                // The actual question
                Text(
                  question,
                  style: TextStyle(
                    fontSize: 24.0, // Adjust font size as needed
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
        back: SizedBox(
          width: cardSize,  // Set the width of the square
          height: cardSize, // Set the height of the square
          child: Card(
            color: Color(int.parse(color)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
            elevation: 5,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Label for the answer
                Text(
                  "Answer",
                  style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.white70,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 10),

                // The actual answer
                Text(
                  answer,
                  style: TextStyle(
                    fontSize: 24.0, // Adjust font size as needed
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
