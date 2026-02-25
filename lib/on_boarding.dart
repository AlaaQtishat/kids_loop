import 'package:flutter/material.dart';
import 'package:kids_loop/managers/theme_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'auth_screens/create_account_screen.dart';
import 'utilities/device.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  final Color subtitleColor = Colors.grey.shade600;
  final List<Map<String, String>> _onboardingData = [
    {
      "title": "They Grow Up Fast!",
      "subtitle":
          "Buy and sell gently used clothes, toys, and gear for kids up to 12 years old.",
      "image": "images/onboarding1.png",
    },
    {
      "title": "Declutter & Earn",
      "subtitle":
          "Give outgrown items a second life. Snap a photo, post it in seconds, and make extra cash.",
      "image": "images/onboarding2.png",
    },
    {
      "title": "Shop Smart, Save the Planet",
      "subtitle":
          "Find amazing deals from local parents. Good for your wallet, great for the environment!",
      "image": "images/onboarding3.png",
    },
  ];

  void _completeOnboarding(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    await prefs.setBool('seenOnboarding', true);
    if (context.mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const CreateAccountScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: ThemeManager.backgroundGrey,
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: Device.screenHeight(context) * 0.62,
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              itemCount: _onboardingData.length,
              itemBuilder: (context, index) {
                return Container(
                  decoration: BoxDecoration(
                    color: ThemeManager.primaryTeal.withOpacity(0.1),
                  ),
                  padding: const EdgeInsets.all(50.0),
                  child: Image.asset(
                    _onboardingData[index]["image"]!,
                    fit: BoxFit.contain,
                  ),
                );
              },
            ),
          ),

          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: screenHeight * 0.46,
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, -5),
                  ),
                ],
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(40),
                  topRight: Radius.circular(40),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(32, 40, 32, 30),
                child: Column(
                  children: [
                    Text(
                      _onboardingData[_currentPage]["title"]!,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: ThemeManager.primaryTeal,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 16),

                    Text(
                      _onboardingData[_currentPage]["subtitle"]!,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15,
                        color: subtitleColor,
                        height: 1.5,
                      ),
                    ),

                    const Spacer(),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        _onboardingData.length,
                        (index) => _buildDot(
                          index: index,
                          activeColor: ThemeManager.primaryTeal,
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    Row(
                      children: [
                        if (_currentPage > 0) ...[
                          Expanded(
                            flex: 1,
                            child: SizedBox(
                              height: 56,
                              child: OutlinedButton(
                                onPressed: () {
                                  _pageController.previousPage(
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeInOut,
                                  );
                                },
                                style: OutlinedButton.styleFrom(
                                  side: BorderSide(
                                    color: ThemeManager.primaryTeal,
                                    width: 1.5,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                ),
                                child: Text(
                                  "Back",
                                  style: TextStyle(
                                    color: ThemeManager.primaryTeal,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                        ],

                        Expanded(
                          flex: 2,
                          child: Container(
                            height: 56,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: ThemeManager.primaryYellow.withOpacity(
                                    0.4,
                                  ),
                                  blurRadius: 15,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: ElevatedButton(
                              onPressed: () {
                                if (_currentPage ==
                                    _onboardingData.length - 1) {
                                  _completeOnboarding(context);
                                } else {
                                  _pageController.nextPage(
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeInOut,
                                  );
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: ThemeManager.primaryYellow,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                elevation: 0,
                              ),
                              child: Text(
                                _currentPage == _onboardingData.length - 1
                                    ? "Get Started"
                                    : "Continue",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: InkWell(
                  onTap: () {
                    _completeOnboarding(context);
                  },
                  borderRadius: BorderRadius.circular(30),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 8.0,
                    ),
                    decoration: BoxDecoration(
                      color: ThemeManager.primaryTeal.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(
                        color: ThemeManager.primaryTeal,
                        width: 1.5,
                      ),
                    ),
                    child: Text(
                      "Skip",
                      style: TextStyle(
                        color: ThemeManager.primaryTeal,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDot({required int index, required Color activeColor}) {
    bool isActive = _currentPage == index;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 5),
      height: 8,
      width: isActive ? 24 : 8,
      decoration: BoxDecoration(
        color: isActive ? activeColor : Colors.grey[300],
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}
