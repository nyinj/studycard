// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:studycards/onboard/onboarding_screen.dart';
import 'package:studycards/utils/colors.dart';
import 'tabs/flashcards_tab.dart';
import 'tabs/create_tab.dart';
import 'tabs/test_tab.dart';
import 'tabs/profile_tab.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Persistent Bottom Navigation',
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
      ),
      home: FutureBuilder<bool>(
        future: _checkIfOnboardingCompleted(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else {
            return snapshot.data == true
                ? const HomeScreen(initialIndex: 0) // Change initial index if needed
                : const OnboardingScreen();
          }
        },
      ),
    );
  }

  Future<bool> _checkIfOnboardingCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('onboarding_completed') ?? false;
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, this.initialIndex = 0});

  final int initialIndex;

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late PersistentTabController _controller;

  @override
  void initState() {
    super.initState();
    _controller = PersistentTabController(
        initialIndex: widget.initialIndex); // Set the initial index
  }

  List<Widget> _buildScreens() {
    return [
      FlashcardsTab(controller: _controller, onDeckCreated: () {  },),  // Removed HomeTab
      CreateTab(
        onDeckCreated: () {},
        controller: _controller,
      ),
      const TestTab(),
      const ProfileTab(),
    ];
  }

  List<PersistentBottomNavBarItem> _navBarsItems() {
    return [
      PersistentBottomNavBarItem(
        icon: const Icon(Icons.book),
        title: ("Flashcards"),
        activeColorPrimary: AppColors.orange,
        inactiveColorPrimary: Colors.grey,
      ),
      PersistentBottomNavBarItem(
        icon: const Icon(Icons.add),
        title: ("Create"),
        activeColorPrimary: AppColors.yellow,
        inactiveColorPrimary: Colors.grey,
      ),
      PersistentBottomNavBarItem(
        icon: const Icon(Icons.quiz),
        title: ("Test"),
        activeColorPrimary: AppColors.blue,
        inactiveColorPrimary: Colors.grey,
      ),
      PersistentBottomNavBarItem(
        icon: const Icon(Icons.person),
        title: ("Profile"),
        activeColorPrimary: AppColors.blueish,
        inactiveColorPrimary: Colors.grey,
      ),
    ];
  }

  @override
Widget build(BuildContext context) {
  return Scaffold(
    body: SafeArea(
      child: PersistentTabView(
        context,
        controller: _controller,
        screens: _buildScreens(),
        items: _navBarsItems(),
        navBarStyle: NavBarStyle.style12,
        backgroundColor: Colors.white,
        handleAndroidBackButtonPress: true,
        resizeToAvoidBottomInset: true,
      ),
    ),
  );
}

}
