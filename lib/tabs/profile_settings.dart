import 'package:flutter/material.dart';
import 'package:studycards/onboard/username_screen.dart';
import 'package:studycards/utils/colors.dart';

class ProfileSettings extends StatelessWidget {
  final Function(String, String) onProfileUpdated;

  ProfileSettings({required this.onProfileUpdated});

  Future<void> _navigateToUsernameScreen(BuildContext context) async {
    print('Navigating to UsernameScreen...');
    final updatedData = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UsernameScreen(
          isEditMode: true,
          onSave: onProfileUpdated, // Pass onProfileUpdated as onSave
        ),
      ),
    );

    if (updatedData != null) {
      print('Profile updated: $updatedData');
      onProfileUpdated(
        updatedData['username'],
        updatedData['profile_picture'],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ElevatedButton(
        onPressed: () => _navigateToUsernameScreen(context),
        child: Text('Edit Username and Profile Picture'),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.blueish,
          padding: EdgeInsets.symmetric(vertical: 14),
          textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
