import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:studycards/database_helper.dart';
import 'package:studycards/flashcard_model.dart';
import 'package:studycards/utils/colors.dart';

class ProfilePerformance extends StatefulWidget {
  @override
  _ProfilePerformanceState createState() => _ProfilePerformanceState();
}

class _ProfilePerformanceState extends State<ProfilePerformance> {
  int _flashcardsCreated = 0;
  int _testsTaken = 0;
  int _totalDecksCount = 0; // Track total number of decks
  List<String> _flashcardNames = []; // List to store flashcard names
  Map<String, int> _flashcardScores = {}; // Store flashcard scores

  final DatabaseHelper _databaseHelper = DatabaseHelper();

  // Method to fetch performance data from the database
  Future<void> _fetchPerformanceData() async {
    Map<String, int> performanceData = await _databaseHelper
        .getPerformanceData(''); // Fetch data without time frame

    // Get the total test results count
    int totalTestResults = await _databaseHelper.getTotalTestResultsCount();

    // Log the total test results count
    print('Total Test Results: $totalTestResults');

    setState(() {
      _flashcardsCreated = performanceData['flashcards_created'] ?? 0;
      _testsTaken =
          totalTestResults; // Set the fetched total test results count
    });
  }

  // Method to load decks and count the total number of decks
  Future<void> _loadDecks() async {
    final decks = await _databaseHelper.getDecks();
    setState(() {
      _totalDecksCount = decks.length; // Count the total number of decks
    });
  }

  // Method to load flashcards and their scores
  Future<void> _loadFlashcards() async {
    // Fetch flashcards from the database
    List<Map<String, dynamic>> flashcards =
        await _databaseHelper.getFlashcardsWithScores();

    // Log the fetched data for debugging
    print("Fetched Flashcards: $flashcards");

    setState(() {
      // Collect the names and scores of flashcards
      _flashcardNames =
          flashcards.map((flashcard) => flashcard['title'].toString()).toList();
      _flashcardScores = {
        for (var flashcard in flashcards) flashcard['title']: flashcard['score']
      };
    });
  }

  @override
  void initState() {
    super.initState();
    _fetchPerformanceData(); // Initial fetch when the widget is created
    _loadDecks(); // Load decks and get the total count
    _loadFlashcards(); // Load flashcards and their scores
  }

  // Method to build statistic cards
  Widget _buildStatisticCard(String label, String value) {
    return Card(
      color: Colors.grey[200],
      child: Padding(
        padding: EdgeInsets.all(8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(label, style: TextStyle(fontWeight: FontWeight.bold)),
            Text(value, style: TextStyle(fontSize: 20)),
          ],
        ),
      ),
    );
  }

  // Method to build flashcard score display
  Widget _buildFlashcardScores() {
    return Column(
      children: [
        if (_flashcardNames.isEmpty)
          Center(
            child: Text(
              'No flashcards available',
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
          )
        else
          // Show flashcards and their scores
          ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: _flashcardNames.length,
            itemBuilder: (context, index) {
              String flashcardTitle = _flashcardNames[index];
              int flashcardScore = _flashcardScores[flashcardTitle] ?? 0;

              return Card(
                color: AppColors.blueish,
                margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                child: ListTile(
                  title: Text(
                    flashcardTitle,
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                  subtitle: Text(
                    'Score: $flashcardScore%',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              );
            },
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Performance analysis card with flashcards created and tests taken
          Card(
            elevation: 4,
            color: AppColors.red,
            margin: EdgeInsets.symmetric(vertical: 8),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  Text(
                    'Performance Analysis',
                    style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildStatisticCard(
                          'Flashcards Created', _totalDecksCount.toString()),
                      _buildStatisticCard('Tests Taken', _testsTaken.toString())
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Flashcard scores list
          Card(
            elevation: 4,
            color: AppColors.orange,
            margin: EdgeInsets.symmetric(vertical: 8),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Flashcard Scores',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.white),
                  ),
                  SizedBox(height: 10),
                  _buildFlashcardScores(), // Display all flashcard scores
                ],
              ),
            ),
          ),

          // Weekly performance chart
          Card(
            elevation: 4,
            color: AppColors.blue,
            margin: EdgeInsets.symmetric(vertical: 8),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  Text(
                    'Weekly Performance Chart',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                  SizedBox(
                    height: 200,
                    child: LineChart(
                      LineChartData(
                        gridData: FlGridData(show: true),
                        titlesData: FlTitlesData(
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, _) {
                                return Text(
                                  'Week ${value.toInt()}',
                                  style: TextStyle(
                                      fontSize: 10, color: Colors.white),
                                );
                              },
                            ),
                          ),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, _) {
                                return Text(
                                  '${value.toInt()}',
                                  style: TextStyle(
                                      fontSize: 10, color: Colors.white),
                                );
                              },
                            ),
                          ),
                        ),
                        borderData: FlBorderData(show: false),
                        lineBarsData: [
                          LineChartBarData(
                            spots: [
                              FlSpot(0, 50),
                              FlSpot(1, 70),
                              FlSpot(2, 80),
                              FlSpot(3, 60),
                              FlSpot(4, 90),
                              FlSpot(5, 85),
                            ],
                            isCurved: true,
                            barWidth: 4,
                            color: Colors.white,
                            dotData: FlDotData(show: false),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
