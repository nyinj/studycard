import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:studycards/utils/colors.dart';
import 'package:studycards/tabs/custom_title.dart';
import 'package:studycards/tabs/profile_performance.dart';
import 'package:studycards/tabs/profile_settings.dart';
import 'package:studycards/database_helper.dart';

class ProfileTab extends StatefulWidget {
  const ProfileTab({super.key});

  @override
  _ProfileTabState createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _username = 'User'; // Default value
  String? _profilePicture = 'assets/profiles/pfp1.png'; // Default value

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadProfileData(); // Load saved data on initialization
  }

  Future<void> _loadProfileData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _username = prefs.getString('username') ?? 'User';
      _profilePicture =
          prefs.getString('profile_picture') ?? 'assets/profiles/pfp1.png';
    });
  }

  void _updateProfileData(String newUsername, String newPfp) async {
    setState(() {
      _username = newUsername;
      _profilePicture = newPfp;
    });

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('username', newUsername);
    await prefs.setString('profile_picture', newPfp);
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;

    return Scaffold(
      body: Container(
        color: Colors.white,
        padding: EdgeInsets.only(top: topPadding + 16.0, left: 16.0, right: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CustomTitle(title: 'You'),
                  SizedBox(height: 20),
                  Center(
                    child: Text(
                      'Hello, $_username!',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  if (_profilePicture != null)
                    Center(
                      child: CircleAvatar(
                        radius: 50,
                        backgroundImage: AssetImage(_profilePicture!),
                      ),
                    ),
                  Divider(thickness: 2, color: Colors.grey[400]),
                ],
              ),
            ),
            Expanded(
              child: Column(
                children: [
                  TabBar(
                    controller: _tabController,
                    tabs: [
                      Tab(
                        text: 'Performance',
                        icon: Icon(Icons.assessment, color: AppColors.blue),
                      ),
                      Tab(
                        text: 'Settings',
                        icon: Icon(Icons.settings, color: AppColors.blue),
                      ),
                    ],
                    labelColor: AppColors.blue,
                    unselectedLabelColor: Colors.grey,
                    indicatorColor: AppColors.blue,
                  ),
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        ProfilePerformance(),  // This widget now includes the average score
                        ProfileSettings(
                          onProfileUpdated: (newUsername, newPfp) {
                            _updateProfileData(newUsername, newPfp);
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
