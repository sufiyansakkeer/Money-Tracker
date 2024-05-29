import 'package:flutter/material.dart';
import 'package:money_track/provider/onboarding_screen.dart';
import 'package:money_track/view/screens/onboarding_screens/widgets/onboarding_screen_1.dart';
import 'package:money_track/view/screens/onboarding_screens/widgets/onboarding_screen_2.dart';
import 'package:money_track/view/screens/onboarding_screens/widgets/onboarding_screen_3.dart';
import 'package:money_track/view/screens/root_page.dart';

import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class OnBoardingScreens extends StatelessWidget {
  OnBoardingScreens({super.key});

  //here we declared a function to ensure the page is last
  final PageController _pageController = PageController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView(
            onPageChanged: (index) {
              //using set state we are making the isLastPage true
              context.read<OnBoardingProvider>().pageChanging(index);
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
            child:
                Consumer<OnBoardingProvider>(builder: (context, value, child) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Visibility(
                        visible: value.isVisible,
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
                            child: const Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
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
                      value.isLastPage
                          ? InkWell(
                              onTap: (() async {
                                final pref =
                                    await SharedPreferences.getInstance();
                                pref.setBool('seen', true);
                                rootPageNavigation(context);
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
              );
            }),
          ),
        ],
      ),
    );
  }

  rootPageNavigation(context) {
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: ((context) => const RootPage())),
        (route) => false);
  }
}
