import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:studycards/utils/colors.dart';

class ProfilePerformance extends StatefulWidget {
  @override
  _ProfilePerformanceState createState() => _ProfilePerformanceState();
}

class _ProfilePerformanceState extends State<ProfilePerformance> {
  String _selectedTimeFrame = 'Day';
  String _selectedFlashcard = 'Flashcard 1';
  List<String> _flashcardOptions = ['Flashcard 1', 'Flashcard 2'];
  List<int> _flashcardScores = [85, 90, 75];
  int _flashcardsCreated = 10;
  int _testsTaken = 5;

  void _updateTimeFrame(String timeFrame) {
    setState(() {
      _selectedTimeFrame = timeFrame;
    });
  }

  Widget _buildStatisticCard(String label, String value) {
    return Card(
      color: AppColors.greyish,
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

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
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
                    children: ['Day', 'Week', 'Month'].map((timeFrame) {
                      return ElevatedButton(
                        onPressed: () => _updateTimeFrame(timeFrame),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _selectedTimeFrame == timeFrame
                              ? Colors.white
                              : AppColors.blueish,
                          foregroundColor: Colors.black,
                        ),
                        child: Text(timeFrame),
                      );
                    }).toList(),
                  ),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildStatisticCard(
                          'Flashcards Created', _flashcardsCreated.toString()),
                      _buildStatisticCard(
                          'Tests Taken', _testsTaken.toString()),
                    ],
                  ),
                ],
              ),
            ),
          ),
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
                    'Check scores of particular flashcard',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.white),
                  ),
                  SizedBox(height: 10),
                  DropdownButton<String>(
                    value: _selectedFlashcard,
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedFlashcard = newValue!;
                      });
                    },
                    items: _flashcardOptions
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child:
                            Text(value, style: TextStyle(color: Colors.black)),
                      );
                    }).toList(),
                  ),
                  SizedBox(height: 10),
                  SizedBox(
                    height: 50,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _flashcardScores.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: EdgeInsets.symmetric(horizontal: 4),
                          child: Card(
                            color: AppColors.blueish,
                            child: Padding(
                              padding: EdgeInsets.all(8),
                              child: Text(
                                'Score ${index + 1}: ${_flashcardScores[index]}%',
                                style: TextStyle(
                                    fontSize: 16, color: Colors.white),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
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
