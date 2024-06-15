import 'package:flutter/material.dart';
import 'package:money_track/helper/navigation_extension.dart';
import 'package:svg_flutter/svg_flutter.dart';

PreferredSize customAppBar(BuildContext context, {required String title}) {
  return PreferredSize(
      preferredSize: const Size(double.infinity, 50),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              InkWell(
                onTap: () => context.pop(),
                child: SvgPicture.asset(
                  "assets/svg/common/arrow_left.svg",
                  height: 20,
                  // width: 20,
                ),
              ),
              const Spacer(),
              Center(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const Spacer()
            ],
          ),
        ),
      ));
}
