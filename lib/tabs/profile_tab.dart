import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:studycards/utils/colors.dart';
import 'package:studycards/tabs/custom_title.dart'; 

class ProfileTab extends StatefulWidget {
  const ProfileTab({super.key});

  @override
  _ProfileTabState createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  String _username = '';
  String? _profilePicture;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _username = prefs.getString('username') ?? 'No Username';
      _profilePicture = prefs.getString('profile_picture');
    });
  }

  @override
  Widget build(BuildContext context) {
    // Get the top padding from the safe area
    final topPadding = MediaQuery.of(context).padding.top;

    return Container(
      color: Colors.white, // Set the background color to white
      padding: EdgeInsets.only(top: topPadding + 16.0, left: 16.0, right: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center, // Center the main content
        children: [
          // Use the CustomTitle widget
          CustomTitle(
            title: 'You',
          ),
          SizedBox(height: 20), // Space after title section
          
          // Greeting message
          Text(
            'Hello, $_username!',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16), // Space between greeting and profile picture
          
          // Profile Picture
          if (_profilePicture != null) ...[
            CircleAvatar(
              radius: 50,
              backgroundImage: AssetImage(_profilePicture!),
            ),
            SizedBox(height: 16),
          ],
          
          // Divider
          Divider(thickness: 2, color: Colors.grey[400]), // Customize thickness and color
          SizedBox(height: 20), // Space after the divider
          
          // Additional content can be added below
          Text(
            'More content can go here...',
            style: TextStyle(fontSize: 18),
          ),
        ],
      ),
    );
  }
}
