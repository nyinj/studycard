// ignore_for_file: avoid_print

import 'package:flutter/material.dart';

class TestScreen extends StatelessWidget {
  final int flashcardId;
  final Duration timerDuration;

  const TestScreen({super.key, required this.flashcardId, required this.timerDuration});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Test for Flashcard #$flashcardId'), // Display flashcard ID
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Test Started for Flashcard ID: $flashcardId',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20),
            Text(
              'Time Remaining: ${timerDuration.inHours}:${timerDuration.inMinutes % 60}:${timerDuration.inSeconds % 60}',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                // Handle test logic here (e.g., show question, timer countdown, etc.)
                print('Test started for flashcard $flashcardId with timer $timerDuration');
              },
              child: const Text('Start Test'),
            ),
          ],
        ),
      ),
    );
  }
}