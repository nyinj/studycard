import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:studycards/utils/colors.dart';
import 'tabs/home_tab.dart';
import 'tabs/flashcards_tab.dart';
import 'tabs/create_tab.dart';
import 'tabs/test_tab.dart';
import 'tabs/profile_tab.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Persistent Bottom Navigation',
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late PersistentTabController _controller;

  @override
  void initState() {
    super.initState();
    _controller = PersistentTabController(initialIndex: 0);
  }

  List<Widget> _buildScreens() {
    return [
      HomeTab(),
      FlashcardsTab(),
      CreateTab(),
      TestTab(),
      ProfileTab(),
    ];
  }

  List<PersistentBottomNavBarItem> _navBarsItems() {
  return [
    PersistentBottomNavBarItem(
      icon: Icon(Icons.home),
      title: ("Home"),
      activeColorPrimary: AppColors.red, 
      inactiveColorPrimary: Colors.grey, 
      activeColorSecondary: Colors.white, 
    ),
    PersistentBottomNavBarItem(
      icon: Icon(Icons.book),
      title: ("Flashcards"),
      activeColorPrimary: AppColors.orange, 
      inactiveColorPrimary: Colors.grey,
      activeColorSecondary: Colors.white,
    ),
    PersistentBottomNavBarItem(
      icon: Icon(Icons.add),
      title: ("Create"),
      activeColorPrimary: AppColors.yellow, 
      inactiveColorPrimary: Colors.grey,
      activeColorSecondary: Colors.white,
    ),
    PersistentBottomNavBarItem(
      icon: Icon(Icons.quiz),
      title: ("Test"),
      activeColorPrimary: AppColors.blue, 
      inactiveColorPrimary: Colors.grey,
      activeColorSecondary: Colors.white,
    ),
    PersistentBottomNavBarItem(
      icon: Icon(Icons.person),
      title: ("Profile"),
      activeColorPrimary: AppColors.blueish, 
      inactiveColorPrimary: Colors.grey,
      activeColorSecondary: Colors.white,
    ),
  ];
}


  @override
  Widget build(BuildContext context) {
    return PersistentTabView(
      context,
      controller: _controller,
      screens: _buildScreens(),
      items: _navBarsItems(),
      navBarStyle: NavBarStyle.style7, // Set to Style 7
      backgroundColor: Colors.white, 
      handleAndroidBackButtonPress: true,
      resizeToAvoidBottomInset: true,
    );
  }
}


