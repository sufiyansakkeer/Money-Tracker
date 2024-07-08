import 'package:flutter/material.dart';

class OnBoardingButtonWidget extends StatelessWidget {
  const OnBoardingButtonWidget({
    super.key,
    required this.isLastPage,
    this.onTap,
  });
  final bool isLastPage;
  final void Function()? onTap;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 50,
        width: 140,
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(15)),
          color: Colors.transparent,
          image: DecorationImage(
              image: AssetImage("assets/images/gradienta-background.jpg"),
              fit: BoxFit.cover),
        ),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text(
                isLastPage ? "Get Started" : 'Next',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
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
    );
  }
}
