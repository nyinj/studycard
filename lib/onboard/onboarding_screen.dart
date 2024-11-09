import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:studycards/main.dart';
import 'package:studycards/onboard/size_config.dart';
import 'package:studycards/onboard/onboarding_contents.dart';
import 'package:studycards/onboard/username_screen.dart';
import 'package:studycards/utils/colors.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  late PageController _controller;

  @override
  void initState() {
    _controller = PageController();
    super.initState();
  }

  int _currentPage = 0;

  List<Color> titleColors = [
    AppColors.red,
    AppColors.blue,
    AppColors.yellow,
  ];

  AnimatedContainer _buildDots({int? index}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(50)),
        color: Color(0xFF000000),
      ),
      margin: const EdgeInsets.only(right: 5),
      height: 10,
      curve: Curves.easeIn,
      width: _currentPage == index ? 20 : 10,
    );
  }

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_completed', true);

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => UsernameScreen(
          onSave: (username, profilePicture) {
            // Optional: Handle updated username or profile picture if needed
            print(
                'Updated username: $username, profile picture: $profilePicture');
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    double width = SizeConfig.screenW!;
    double height = SizeConfig.screenH!;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: GestureDetector(
            onTap: () {
              // Dismiss the keyboard when tapping outside the focused widget
              FocusScope.of(context).requestFocus(FocusNode());
            },
            child: Column(
              children: [
                // Wrap this in a SizedBox to set a height that's suitable for the screen.
                SizedBox(
                  height: height * 0.7, // Adjust the size based on your screen
                  child: PageView.builder(
                    physics: const BouncingScrollPhysics(),
                    controller: _controller,
                    onPageChanged: (value) =>
                        setState(() => _currentPage = value),
                    itemCount: contents.length,
                    itemBuilder: (context, i) {
                      return Padding(
                        padding: const EdgeInsets.all(40.0),
                        child: Column(
                          children: [
                            Expanded(
                              child: Image.asset(contents[i].image),
                            ),
                            SizedBox(height: height >= 840 ? 60 : 30),
                            Text(
                              contents[i].title,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: "Mulish",
                                fontWeight: FontWeight.w600,
                                fontSize: width <= 550 ? 30 : 35,
                                color: titleColors[i],
                              ),
                            ),
                            const SizedBox(height: 15),
                            Text(
                              contents[i].desc,
                              style: TextStyle(
                                fontFamily: "Mulish",
                                fontWeight: FontWeight.w300,
                                fontSize: width <= 550 ? 17 : 25,
                                color: Colors.black,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          contents.length,
                          (index) => _buildDots(index: index),
                        ),
                      ),
                      SizedBox(height: 20),
                      _currentPage + 1 == contents.length
                          ? ElevatedButton(
                              onPressed: _completeOnboarding,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: titleColors[_currentPage],
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(50),
                                ),
                                padding: EdgeInsets.symmetric(
                                  horizontal: width <= 550 ? 100 : width * 0.2,
                                  vertical: width <= 550 ? 15 : 20,
                                ),
                                textStyle:
                                    TextStyle(fontSize: width <= 550 ? 13 : 17),
                              ),
                              child: const Text("START"),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                TextButton(
                                  onPressed: () {
                                    _controller.jumpToPage(contents.length - 1);
                                  },
                                  style: TextButton.styleFrom(
                                    textStyle: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: width <= 550 ? 13 : 17,
                                    ),
                                  ),
                                  child: const Text(
                                    "SKIP",
                                    style: TextStyle(color: Colors.black),
                                  ),
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    _controller.nextPage(
                                      duration:
                                          const Duration(milliseconds: 200),
                                      curve: Curves.easeIn,
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: titleColors[_currentPage],
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(50),
                                    ),
                                    padding: EdgeInsets.symmetric(
                                      horizontal: width <= 550 ? 30 : 50,
                                      vertical: width <= 550 ? 15 : 20,
                                    ),
                                    textStyle: TextStyle(
                                        fontSize: width <= 550 ? 13 : 17),
                                  ),
                                  child: const Text("NEXT"),
                                ),
                              ],
                            ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
