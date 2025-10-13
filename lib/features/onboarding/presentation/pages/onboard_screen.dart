import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:money_track/core/constants/colors.dart';
import 'package:money_track/features/auth/presentation/pages/login_page.dart';
import 'package:money_track/features/onboarding/presentation/bloc/on_boarding_cubit.dart';
import 'package:money_track/features/onboarding/presentation/widgets/lottie_onboarding_widget.dart';
import 'package:money_track/features/onboarding/presentation/widgets/onboarding_button_widget.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardScreen extends StatefulWidget {
  const OnboardScreen({super.key});

  @override
  State<OnboardScreen> createState() => _OnboardScreenState();
}

class _OnboardScreenState extends State<OnboardScreen> {
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView(
            controller: _pageController,
            onPageChanged: (index) {
              context.read<OnBoardingCubit>().changePage(index);
            },
            children: const [
              LottieOnboardingWidget(
                title: "Track Your Money",
                description:
                    "Easily track your income and expenses to manage your finances better.",
                lottieAsset: "assets/lottie/onboarding_1.json",
              ),
              LottieOnboardingWidget(
                title: "Categorize Transactions",
                description:
                    "Organize your transactions into categories for better insights.",
                lottieAsset: "assets/lottie/onboarding_2.json",
              ),
              LottieOnboardingWidget(
                title: "Analyze Your Spending",
                description:
                    "Get insights into your spending habits and make informed decisions.",
                lottieAsset: "assets/lottie/onboarding_3.json",
              ),
            ],
          ),
          Align(
            alignment: const Alignment(0, 0.7),
            child: BlocBuilder<OnBoardingCubit, OnBoardingState>(
              builder: (context, state) {
                return SmoothPageIndicator(
                  controller: _pageController,
                  count: 3,
                  effect: ExpandingDotsEffect(
                    activeDotColor: ColorConstants.themeColor,
                    dotColor: Colors.grey.shade300,
                    dotHeight: 8,
                    dotWidth: 8,
                    spacing: 5,
                  ),
                );
              },
            ),
          ),
          Align(
            alignment: const Alignment(0, 0.9),
            child: BlocBuilder<OnBoardingCubit, OnBoardingState>(
              builder: (context, state) {
                return OnboardingButtonWidget(
                  onPressed: () async {
                    if (state.currentPage == 2) {
                      // Mark onboarding as seen
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.setBool('seen', true);

                      if (mounted) {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (_) => const LoginPage(),
                          ),
                        );
                      }
                    } else {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.ease,
                      );
                    }
                  },
                  text: state.currentPage == 2 ? "Get Started" : "Next",
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
