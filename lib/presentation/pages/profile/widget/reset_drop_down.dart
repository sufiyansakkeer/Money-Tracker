import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:money_track/core/constants/colors.dart';
import 'package:money_track/core/constants/style_constants.dart';
import 'package:money_track/helper/navigation_extension.dart';
import 'package:money_track/helper/sized_box_extension.dart';
import 'package:money_track/presentation/bloc/bottom_navigation/bottom_navigation_bloc.dart';
import 'package:money_track/repository/profile_repository.dart';

class ResetDropDown extends StatelessWidget {
  const ResetDropDown({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      width: 800,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            "Do you want to Reset?.",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          30.height(),
          ElevatedButton(
            style: StyleConstants.elevatedButtonStyle(
                backgroundColor: ColorConstants.secondaryColor),
            onPressed: () {
              ProfileRepository().clearDB(context: context);
              context
                  .read<BottomNavigationBloc>()
                  .add(ChangeBottomNavigation(index: 0));
            },
            child: Text(
              "Yes",
              style: TextStyle(
                color: ColorConstants.themeColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          10.height(),
          ElevatedButton(
            style: StyleConstants.elevatedButtonStyle(),
            onPressed: () => context.pop(),
            child: const Text(
              "No",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
