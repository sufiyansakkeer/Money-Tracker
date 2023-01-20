import 'package:flutter/material.dart';
import 'package:money_track/onboarding_screens/onboarding_screen_1.dart';
import 'package:money_track/onboarding_screens/onboarding_screen_2.dart';
import 'package:money_track/onboarding_screens/onboarding_screen_3.dart';
import 'package:money_track/screens/root_page.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class OnBoardingScreens extends StatefulWidget {
  const OnBoardingScreens({super.key});

  @override
  State<OnBoardingScreens> createState() => _OnBoardingScreensState();
}

class _OnBoardingScreensState extends State<OnBoardingScreens> {
  final PageController _pageController = PageController();
  //here we declared a function to ensure the page is last
  bool isLastPage = false;
  bool isVisible = true;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView(
            onPageChanged: (index) {
              //using set state we are making the isLastPage true
              setState(() {
                isLastPage = (index == 2);
                isVisible = (index != 2);
              });
            },
            controller: _pageController,
            children: const [
              OnBoardingOne(),
              OnBoardingTwo(),
              OnBoardingScreenThree(),
            ],
          ),
          Container(
            alignment: const Alignment(0, 0.75),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Visibility(
                  visible: isVisible,
                  child: GestureDetector(
                    onTap: () {
                      _pageController.jumpToPage(2);
                    },
                    child: const Text(
                      'Skip',
                    ),
                  ),
                ),
                SmoothPageIndicator(
                  controller: _pageController,
                  count: 3,
                ),
                isLastPage
                    ? GestureDetector(
                        onTap: (() {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: ((context) {
                                return const RootPage();
                              }),
                            ),
                          );
                        }),
                        child: const Text(
                          'Done',
                        ),
                      )
                    : GestureDetector(
                        onTap: (() {
                          _pageController.nextPage(
                              duration: const Duration(milliseconds: 500),
                              curve: Curves.easeIn);
                        }),
                        child: const Text(
                          'Next',
                        ),
                      )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
