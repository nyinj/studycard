import 'package:flutter/material.dart';
import 'package:studycards/tabs/custom_title.dart'; // Adjust the import path

class TestTab extends StatelessWidget {
  const TestTab({super.key});

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    return Container(
      color: Colors.white, // Set the background color to white
      padding: EdgeInsets.only(top: topPadding + 16.0, left: 16.0, right: 16.0), // Add top padding
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, // Align content to the start
        children: [
          CustomTitle(title: 'Test'), // Use the CustomTitle widget here
          SizedBox(height: 20), // Space after the title

          // Additional content can be added below
          const Center(child: Text("This is test tab")),
        ],
      ),
    );
  }
}