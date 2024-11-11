// ignore_for_file: use_build_context_synchronously, library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:studycards/main.dart';
import 'package:studycards/utils/colors.dart';
import 'package:studycards/tabs/custom_title.dart';  // Import your CustomTitle widget

class UsernameScreen extends StatefulWidget {
  final bool isEditMode;
  final Function(String, String) onSave;

  const UsernameScreen({super.key, this.isEditMode = false, required this.onSave});

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
    if (widget.isEditMode) {
      _loadProfileData();
    }
  }

  // Load profile data from SharedPreferences
  Future<void> _loadProfileData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _usernameController.text = prefs.getString('username') ?? '';
      _selectedPfp = prefs.getString('profile_picture') ?? _pfpList.first;
    });
  }

  void _saveData() async {
    if (_usernameController.text.isNotEmpty && _selectedPfp != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('username', _usernameController.text);
      await prefs.setString('profile_picture', _selectedPfp!);

      widget.onSave(_usernameController.text, _selectedPfp!);

      if (widget.isEditMode) {
        Navigator.pop(context, {
          'username': _usernameController.text,
          'profile_picture': _selectedPfp,
        });
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a username and select a picture')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Replace Text widget with CustomTitle in the AppBar
        title: CustomTitle(
          title: widget.isEditMode ? 'Edit Profile' : 'Set Your Profile',
        ),
        backgroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.isEditMode ? 'Edit your profile' : 'Create your profile',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.red,
                ),
              ),
              const SizedBox(height: 20),

              // Username TextField with styling
              TextField(
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: 'Username',
                  labelStyle: const TextStyle(
                    color: AppColors.blue, // Label color when the field is active
                    fontSize: 16,
                  ),
                  hintText: 'Enter your username',
                  hintStyle: TextStyle(
                    color: Colors.grey[500], // Lighter text for hint
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12), // Rounded corners for the border
                    borderSide: BorderSide(color: Colors.grey[300]!), // Subtle border color
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.blueish, width: 2), // Focused border color
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[300]!, width: 1), // Default border color
                  ),
                  filled: true,
                  fillColor: Colors.white, // Background color of the TextField
                  contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16), // Padding inside the TextField
                  suffixIcon: _usernameController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            setState(() {
                              _usernameController.clear();
                            });
                          },
                        )
                      : null, // Clear icon appears when there is text inside
                ),
              ),

              const SizedBox(height: 30), // Increased space between username and profile picture selection

              // Profile Picture selection
              Text(
                'Select Profile Picture',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 10),
              GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 16.0,
                  mainAxisSpacing: 16.0,
                ),
                itemCount: _pfpList.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  final isSelected = _selectedPfp == _pfpList[index];
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedPfp = _pfpList[index];
                      });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected ? AppColors.orange : Colors.transparent,
                          width: 2.0,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.2),
                            spreadRadius: 2,
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.asset(
                          _pfpList[index],
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 30), // Space before the save button

              // Save Button
              Center(
                child: ElevatedButton(
                  onPressed: _saveData,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.blue,
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Text(
                    widget.isEditMode ? 'Update' : 'Save',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
