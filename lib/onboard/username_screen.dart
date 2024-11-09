import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:studycards/main.dart';

class UsernameScreen extends StatefulWidget {
  final bool isEditMode;
  final Function(String, String) onSave;

  // Constructor to accept edit mode flag and callback
  UsernameScreen({this.isEditMode = false, required this.onSave});

  @override
  _UsernameScreenState createState() => _UsernameScreenState();
}

class _UsernameScreenState extends State<UsernameScreen> {
  final TextEditingController _usernameController = TextEditingController();
  String? _selectedPfp;
  final List<String> _pfpList = [
    'assets/profiles/pfp1.png',
    'assets/profiles/pfp2.png',
    'assets/profiles/pfp3.png',
    'assets/profiles/pfp4.png',
    'assets/profiles/pfp5.png',
    'assets/profiles/pfp6.png',
  ];

  @override
  void initState() {
    super.initState();
    print("UsernameScreen initialized with edit mode: ${widget.isEditMode}");
    if (widget.isEditMode) {
      _loadProfileData();
    }
  }

  // Load profile data from SharedPreferences
  Future<void> _loadProfileData() async {
    print("Loading profile data...");
    try {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        _usernameController.text = prefs.getString('username') ?? '';
        _selectedPfp = prefs.getString('profile_picture') ?? _pfpList.first;
      });
      print("Profile data loaded: Username - ${_usernameController.text}, "
          "Profile Picture - $_selectedPfp");
    } catch (e) {
      print("Error loading profile data: $e");
    }
  }

  // Save the updated profile data
  // Inside _saveData method in UsernameScreen
  void _saveData() async {
    print("Saving profile data...");
    if (_usernameController.text.isNotEmpty && _selectedPfp != null) {
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('username', _usernameController.text);
        await prefs.setString('profile_picture', _selectedPfp!);
        print("Profile data saved successfully.");

        widget.onSave(_usernameController.text, _selectedPfp!);

        if (widget.isEditMode) {
          Navigator.pop(context, {
            'username': _usernameController.text,
            'profile_picture': _selectedPfp,
          });
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    HomeScreen()), // Update HomeScreen to your main screen widget
          );
        }
      } catch (e) {
        print("Error saving profile data: $e");
      }
    } else {
      print("Profile data incomplete: Username or Profile Picture is missing.");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter a username and select a picture')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    print("Building UsernameScreen UI...");
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditMode
            ? 'Edit Profile'
            : 'Set Username & Profile Picture'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(labelText: 'Username'),
            ),
            SizedBox(height: 20),
            GridView.builder(
              gridDelegate:
                  SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
              itemCount: _pfpList.length,
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedPfp = _pfpList[index];
                      print("Selected profile picture: $_selectedPfp");
                    });
                  },
                  child: Container(
                    margin: EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: _selectedPfp == _pfpList[index]
                            ? Colors.blue
                            : Colors.grey,
                      ),
                    ),
                    child: Image.asset(_pfpList[index]),
                  ),
                );
              },
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveData,
              child: Text(widget.isEditMode ? 'Update' : 'Save'),
            ),
          ],
        ),
      ),
    );
  }
}
