import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:money_track/core/constants/colors.dart';
import 'package:money_track/core/constants/style_constants.dart';
import 'package:money_track/core/utils/navigation_extension.dart';
import 'package:money_track/core/utils/sized_box_extension.dart';
import 'package:money_track/features/navigation/presentation/bloc/bottom_navigation_bloc.dart';
import 'package:money_track/features/profile/domain/repositories/profile_repository.dart';

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
                backgroundColor: ColorConstants.getSecondaryColor(context),
                context: context),
            onPressed: () {
              ProfileRepository().clearDB(context: context);
              context
                  .read<BottomNavigationBloc>()
                  .add(ChangeBottomNavigationEvent(index: 0));
            },
            child: Text(
              "Yes",
              style: TextStyle(
                color: ColorConstants.getThemeColor(context),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          10.height(),
          ElevatedButton(
            style: StyleConstants.elevatedButtonStyle(context: context),
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
