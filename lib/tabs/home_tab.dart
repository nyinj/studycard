import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:studycards/tabs/custom_title.dart'; // Adjust the import path
import 'dart:async';

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  _HomeTabState createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  int _streakCount = 0;

  @override
  void initState() {
    super.initState();
    _checkStreak();
  }

  Future<void> _checkStreak() async {
    final prefs = await SharedPreferences.getInstance();
    final lastOpened = prefs.getString('lastOpened');
    final today = DateTime.now();

    // If the app was opened on a different day, check for streak update
    if (lastOpened != null) {
      final lastOpenedDate = DateTime.parse(lastOpened);
      final difference = today.difference(lastOpenedDate).inDays;

      if (difference == 1) {
        // Continue the streak
        _streakCount = prefs.getInt('streakCount') ?? 0;
        _streakCount++;
      } else if (difference > 1) {
        // Streak broken
        _streakCount = 1;
      }
    } else {
      // First time opening the app
      _streakCount = 1;
    }

    // Save the current date and streak count
    await prefs.setString('lastOpened', today.toIso8601String());
    await prefs.setInt('streakCount', _streakCount);

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;

    return Container(
      color: Colors.white, // Set the background color to white
      padding: EdgeInsets.only(
          top: topPadding + 16.0, left: 16.0, right: 16.0), // Add top padding
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start, // Align content to the start
        children: [
          CustomTitle(title: 'Home'), // Use the CustomTitle widget here
          SizedBox(height: 20), // Space after the title

          // Display the current streak
          Row(
            children: [
              Icon(Icons.local_fire_department, color: Colors.orange),
              SizedBox(width: 8),
              Text(
                'Current Streak: $_streakCount days',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ],
          ),

          const SizedBox(height: 20), // Space after the streak display
        ],
      ),
    );
  }
}
