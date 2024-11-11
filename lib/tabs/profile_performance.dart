// ignore_for_file: unnecessary_const, library_private_types_in_public_api, use_key_in_widget_constructors, unused_local_variable

import 'package:flutter/material.dart';
import 'package:studycards/database_helper.dart';
import 'package:studycards/utils/colors.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<int> _getLastResetMonth() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getInt('last_reset_month') ?? -1; // Default to -1 if not set
}

Future<void> _setLastResetMonth(int month) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setInt('last_reset_month', month);
}

class ProfilePerformance extends StatefulWidget {
  @override
  _ProfilePerformanceState createState() => _ProfilePerformanceState();
}

class _ProfilePerformanceState extends State<ProfilePerformance> {
  int _flashcardsCreated = 0;
  int _totalDecksCount = 0;
  int _testsTaken = 0;
  double _averageTestScore = 0.0;

  final DatabaseHelper _databaseHelper = DatabaseHelper();

  Future<void> _fetchPerformanceData() async {
    // Fetch the current month
    int currentMonth = DateTime.now().month;

    // Get the last reset month from SharedPreferences
    int lastResetMonth = await _getLastResetMonth();

    // If the month has changed, reset the data
    if (currentMonth != lastResetMonth) {
      await _resetPerformanceData();
      await _setLastResetMonth(currentMonth); // Update the reset month
    }

    // Continue fetching performance data
    Map<String, int> performanceData =
        await _databaseHelper.getPerformanceData('');
    int testsTaken = await _databaseHelper.getTotalTestResultsCount();
    double averageScore = await _getAverageTestScore();
    int highScoreCount = await _getHighScoreFlashcardsCount();

    setState(() {
      _flashcardsCreated = performanceData['flashcards_created'] ?? 0;
      _testsTaken = testsTaken;
      _averageTestScore = averageScore;
    });
  }

  Future<void> _resetPerformanceData() async {
    final db = await _databaseHelper.database;

    // Reset flashcards count or any data you need to reset
    await db.update(
      'flashcards',
      {'score': 0}, // Reset specific columns
      where: 'score >= ?',
      whereArgs: [0],
    );

    // Optionally, reset test results
    await db.delete('test_results');
  }

  Future<void> _loadDecks() async {
    final decks = await _databaseHelper.getDecks();
    setState(() {
      _totalDecksCount = decks.length;
    });
  }

  Future<double> _getAverageTestScore() async {
    final db = await _databaseHelper.database;
    List<Map<String, dynamic>> results = await db.query('test_results');
    if (results.isEmpty) return 0.0;

    double totalScore =
        results.fold(0, (sum, row) => sum + row['percentage_score']);
    return totalScore / results.length;
  }

  Future<int> _getHighScoreFlashcardsCount() async {
    final db = await _databaseHelper.database;
    List<Map<String, dynamic>> results = await db.query(
      'flashcards',
      where: 'score >= ?',
      whereArgs: [80], // Change 80 to any threshold you prefer
    );
    return results.length;
  }

  @override
  void initState() {
    super.initState();
    _fetchPerformanceData();
    _loadDecks();
  }

  Widget _buildStatisticCard(String label, String value, {Color? color}) {
    return Card(
      elevation: 4,
      color: color ?? Colors.grey[200],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            Text(value, style: const TextStyle(fontSize: 20, color: Colors.black)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header Card
          Card(
            elevation: 4,
            color: AppColors.red,
            margin: const EdgeInsets.all(16),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: const Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  Center(
                    child: Text(
                      'Performance Analysis',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  SizedBox(height: 8), // Space between title and subtitle
                  Center(
                    child: Text(
                      'Resets every month',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white70, // Lighter color for subtitle
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Individual Statistic Cards
          _buildStatisticCard(
              'Flashcards Created', _flashcardsCreated.toString()),
          _buildStatisticCard('Total Decks', _totalDecksCount.toString()),
          _buildStatisticCard('Tests Taken', _testsTaken.toString()),
          _buildStatisticCard(
              'Average Test Score', '${_averageTestScore.toStringAsFixed(1)}%'),
        ],
      ),
    );
  }
}
