import 'package:flutter/material.dart';

class OnBoardingProvider extends ChangeNotifier {
  bool isLastPage = false;

  bool isVisible = true;

  void pageChanging(index) {
    isLastPage = (index == 2);
    // notifyListeners();
    isVisible = (index != 2);
    notifyListeners();
  }
}
