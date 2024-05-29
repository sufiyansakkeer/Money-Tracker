import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:money_track/core/constants/colors.dart';
import 'package:money_track/helper/sized_box_extension.dart';
import 'package:money_track/helper/widget_extension.dart';
import 'package:money_track/presentation/widgets/bottom_navigation_list.dart'; // Custom widget or list for bottom navigation items
import 'package:money_track/presentation/widgets/custom_inkwell.dart';
import 'package:rive/rive.dart'; // Rive package for animations

// List to store state machine boolean inputs for Rive animations
List<SMIBool> riveIconInputs = [];
List<StateMachineController?> controllers =
    []; // List to store state machine controllers
int selectedNavIndex = 0; // Index to keep track of selected navigation item

class BottomNavigationPage extends StatefulWidget {
  const BottomNavigationPage({super.key});

  @override
  State<BottomNavigationPage> createState() => _BottomNavigationPageState();
}

class _BottomNavigationPageState extends State<BottomNavigationPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: const SafeArea(
        child: Center(
          child: Text(
            "Bottom navigation",
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          height: 76, // Height of the bottom navigation bar
          padding: const EdgeInsets.all(0), // Padding inside the container
          margin: const EdgeInsets.symmetric(
              horizontal: 18), // Horizontal margin outside the container
          decoration: BoxDecoration(
            color: ColorConstants.bottomNaColor
                .withOpacity(0.8), // Background color with opacity
            borderRadius:
                const BorderRadius.all(Radius.circular(24)), // Rounded corners
            boxShadow: [
              BoxShadow(
                color: ColorConstants.bottomNaColor
                    .withOpacity(0.3), // Shadow color with opacity
                offset: const Offset(0, 20), // Shadow offset
                blurRadius: 20, // Blur radius for the shadow
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 0),
            child: Row(
              mainAxisAlignment:
                  MainAxisAlignment.spaceBetween, // Space items evenly
              children: List.generate(
                bottomNavItems
                    .length, // Generate widgets based on number of bottom navigation items
                (index) => CustomInkWell(
                  onTap: () {
                    riveIconInputs[index]
                        .change(true); // Activate animation on tap
                    Future.delayed(
                      const Duration(
                          milliseconds: 200), // Delay to reset the animation
                      () {
                        riveIconInputs[index]
                            .change(false); // Deactivate animation after delay
                      },
                    );
                    setState(() {
                      selectedNavIndex =
                          index; // Update the selected navigation index
                    });
                  },
                  child: Column(
                    children: [
                      10.height(),
                      RiveAnimation.asset(
                        bottomNavItems[index].rive.src, // Rive animation source
                        artboard: bottomNavItems[index]
                            .rive
                            .artBoard, // Artboard for the Rive animation
                        onInit: (artboard) {
                          log(index.toString(), name: "index");
                          riveOnInIt(artboard,
                              stateMachineName: bottomNavItems[index]
                                  .rive
                                  .stateMachineName); // Initialize the Rive animation state machine
                        },
                      ).expand(),
                      Text(
                        bottomNavItems[index].text,
                        style: TextStyle(
                          fontFamily: GoogleFonts.mulish().fontFamily,
                          color: selectedNavIndex == index
                              ? Colors.white
                              : Colors.grey[100],
                          fontWeight: selectedNavIndex == index
                              ? FontWeight.w700
                              : null,
                        ),
                      ),
                      10.height(),
                    ],
                  ),
                ).expand(),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

void riveOnInIt(Artboard artboard, {required String stateMachineName}) {
  StateMachineController? controller = StateMachineController.fromArtboard(
      artboard,
      stateMachineName); // Get the state machine controller from the artboard

  bool added =
      artboard.addController(controller!); // Add the controller to the artboard
  log(added.toString(), name: "artboard adding bool");
  controllers.add(controller); // Add the controller to the controllers list

  riveIconInputs.add(controller.findInput<bool>('active')
      as SMIBool); // Find and add the boolean input for animation state
}
