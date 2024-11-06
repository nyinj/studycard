import 'package:flutter/material.dart';
import 'package:flip_card/flip_card.dart';
import 'package:studycards/utils/colors.dart';

class FlashcardWidget extends StatelessWidget {
  final String question;
  final String answer;
  final String color;
  final bool isQuestionSide; // Pass the side as a boolean

  const FlashcardWidget({
    super.key,
    required this.question,
    required this.answer,
    required this.color,
    required this.isQuestionSide, // Adding the isQuestionSide parameter
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
          width: cardSize, // Set the width of the square
          height: cardSize, // Set the height of the square
          child: Card(
            color: isQuestionSide
                ? Color(int.parse(color))
                : AppColors.skin, // Conditional color based on side
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
          width: cardSize, // Set the width of the square
          height: cardSize, // Set the height of the square
          child: Card(
            color: isQuestionSide
                ? AppColors.skin
                : Color(int.parse(color)), // Conditional color based on side
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
                    color: Colors.black45,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 10),

                // The actual answer with black text when it's the answer side
                Text(
                  answer,
                  style: TextStyle(
                    fontSize: 24.0, // Adjust font size as needed
                    color: isQuestionSide
                        ? Colors.black
                        : Colors.black, // Set black for answer side
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
