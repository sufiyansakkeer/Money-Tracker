import 'package:flutter/material.dart';

import 'package:money_track/screens/onboarding_screens/onboarding_screen_1.dart';
import 'package:money_track/screens/onboarding_screens/onboarding_screen_2.dart';
import 'package:money_track/screens/onboarding_screens/onboarding_screen_3.dart';
import 'package:money_track/screens/root_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class OnBoardingScreens extends StatefulWidget {
  const OnBoardingScreens({super.key});

  @override
  State<OnBoardingScreens> createState() => _OnBoardingScreensState();
}

class _OnBoardingScreensState extends State<OnBoardingScreens> {
  //here we declared a function to ensure the page is last
  bool isLastPage = false;

  bool isVisible = true;

  final PageController _pageController = PageController();

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
          Padding(
            padding:
                const EdgeInsets.only(left: 30, right: 30, top: 40, bottom: 40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Visibility(
                      visible: isVisible,
                      child: GestureDetector(
                        onTap: () {
                          _pageController.jumpToPage(2);
                        },
                        child: Container(
                          height: 30,
                          width: 70,
                          decoration: const BoxDecoration(
                            borderRadius: BorderRadius.all(
                              Radius.circular(15),
                            ),
                            color: Color(0x992E49FB),
                          ),
                          child: Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Text(
                                  'Skip',
                                  style: TextStyle(color: Colors.white),
                                ),
                                Icon(
                                  Icons.skip_next_rounded,
                                  color: Colors.white,
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SmoothPageIndicator(
                      onDotClicked: (index) => _pageController.animateToPage(
                        index,
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeIn,
                      ),
                      effect: const ExpandingDotsEffect(),
                      controller: _pageController,
                      count: 3,
                    ),
                    isLastPage
                        ? GestureDetector(
                            onTap: (() async {
                              final pref =
                                  await SharedPreferences.getInstance();
                              pref.setBool('seen', true);
                              rootPageNavigation();
                            }),
                            // child: Container(
                            //   decoration: BoxDecoration(

                            //   ),
                            //   height: 50,

                            //   child:
                            //       Lottie.asset('assets/images/getStarted.json'),
                            // ),
                            child: Container(
                              height: 50,
                              width: 140,
                              decoration: const BoxDecoration(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(15)),
                                color: Colors.transparent,
                                image: DecorationImage(
                                  image: AssetImage(
                                    "assets/images/gradienta-background.jpg",
                                  ),
                                  fit: BoxFit.cover,
                                ),
                              ),
                              child: Center(
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    const Text(
                                      'Get Started',
                                      style: TextStyle(
                                        color: Colors.white,
                                      ),
                                    ),
                                    Icon(
                                      Icons.adaptive.arrow_forward,
                                      color: Colors.white,
                                    )
                                  ],
                                ),
                              ),
                            ),
                          )
                        : GestureDetector(
                            onTap: (() {
                              _pageController.nextPage(
                                  duration: const Duration(milliseconds: 500),
                                  curve: Curves.easeIn);
                            }),
                            child: Container(
                              height: 50,
                              width: 140,
                              decoration: const BoxDecoration(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(15)),
                                color: Colors.transparent,
                                image: DecorationImage(
                                    image: AssetImage(
                                        "assets/images/gradienta-background.jpg"),
                                    fit: BoxFit.cover),
                              ),
                              child: Center(
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    const Text(
                                      'Next',
                                      style: TextStyle(
                                        color: Colors.white,
                                      ),
                                    ),
                                    Icon(
                                      Icons.adaptive.arrow_forward,
                                      color: Colors.white,
                                    )
                                  ],
                                ),
                              ),
                            ),
                          )
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  rootPageNavigation() {
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: ((context) => const RootPage())),
        (route) => false);
  }
}
