import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:money_track/core/constants/colors.dart';
import 'package:money_track/presentation/bloc/on_boarding/on_boarding_cubit.dart';
import 'package:money_track/presentation/pages/bottom_navigation/bottom_navigation.dart';
import 'package:money_track/presentation/pages/onboarding_screens/widgets/lottie_onboarding_widget.dart';
import 'package:money_track/presentation/pages/onboarding_screens/widgets/onboarding_button_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class OnBoardingScreens extends StatefulWidget {
  const OnBoardingScreens({super.key});

  @override
  State<OnBoardingScreens> createState() => _OnBoardingScreensState();
}

class _OnBoardingScreensState extends State<OnBoardingScreens> {
  //here we declared a function to ensure the page is last
  late final PageController _pageController;

  @override
  void initState() {
    _pageController = PageController();
    super.initState();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: PageView.builder(
                itemBuilder: (context, index) => LottieOnBoardWidget(
                  lottie: lottieList[index],
                  lottieTitle: lottieTitleList[index],
                ),
                itemCount: lottieList.length,
                onPageChanged: (index) {
                  //using set state we are making the isLastPage true
                  context.read<OnBoardingCubit>().changeIndex(index: index);
                },
                controller: _pageController,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 30,
                vertical: 40,
              ),
              child: BlocBuilder<OnBoardingCubit, OnBoardingState>(
                builder: (context, state) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Visibility(
                            visible: state.index != 2,
                            child: GestureDetector(
                              onTap: () {
                                _pageController.jumpToPage(2);
                              },
                              child: Container(
                                height: 30,
                                width: 70,
                                decoration: BoxDecoration(
                                  borderRadius: const BorderRadius.all(
                                    Radius.circular(15),
                                  ),
                                  color: ColorConstants.secondaryColor,
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
                            onDotClicked: (index) =>
                                _pageController.animateToPage(
                              index,
                              duration: const Duration(milliseconds: 500),
                              curve: Curves.easeIn,
                            ),
                            effect: ExpandingDotsEffect(
                              activeDotColor: ColorConstants.themeColor,
                              dotColor: ColorConstants.secondaryColor,
                            ),
                            controller: _pageController,
                            count: 3,
                          ),
                          OnBoardingButtonWidget(
                            isLastPage: state.index == 2,
                            onTap: () async {
                              if (state.index == 2) {
                                final pref =
                                    await SharedPreferences.getInstance();
                                pref.setBool('seen', true);
                                if (context.mounted) {
                                  rootPageNavigation(context);
                                }
                              } else {
                                _pageController.nextPage(
                                    duration: const Duration(milliseconds: 500),
                                    curve: Curves.easeIn);
                              }
                            },
                          )
                        ],
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  rootPageNavigation(context) {
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: ((context) => const BottomNavigationPage())),
        (route) => false);
  }
}
