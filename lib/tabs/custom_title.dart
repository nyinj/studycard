// lib/custom_title.dart
import 'package:flutter/material.dart';
import 'package:studycards/utils/colors.dart';

class CustomTitle extends StatelessWidget {
  final String title;

  const CustomTitle({
    super.key,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft, // Align title to the left
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center, // Center the logo with text
        children: [
          // Logo
          Image.asset(
            'assets/title_logo.png', // Path to the logo image
            height: 40, // Adjust height as needed
          ),
          const SizedBox(width: 8), // Space between logo and title
          Column(
            crossAxisAlignment: CrossAxisAlignment.start, // Align title and underline to the left
            children: [
              Text(
                title,
                style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8), // Space between title and underline
              Container(
                height: 4, // Thickness of the underline
                width: 80, // Width of the underline
                decoration: BoxDecoration(
                  color: AppColors.skin, // Use your skin color here
                  borderRadius: BorderRadius.circular(2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2), // Shadow color
                      offset: const Offset(2, 2), // Shadow offset
                      blurRadius: 4, // Shadow blur radius
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
