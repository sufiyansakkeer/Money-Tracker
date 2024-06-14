import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:money_track/core/constants/colors.dart';
import 'package:money_track/helper/sized_box_extension.dart';
import 'package:money_track/helper/widget_extension.dart';
import 'package:money_track/presentation/bloc/bottom_navigation/bottom_navigation_bloc.dart';
import 'package:money_track/presentation/bloc/category/category_bloc.dart';
import 'package:money_track/presentation/pages/bottom_navigation/widgets/bottom_navigation_list.dart'; // Custom widget or list for bottom navigation items
import 'package:money_track/presentation/widgets/custom_inkwell.dart';
import 'package:rive/rive.dart'; // Rive package for animations

// List to store state machine boolean inputs for Rive animations
List<SMIBool> riveIconInputs = [];
List<StateMachineController?> controllers =
    []; // List to store state machine controllers
// int selectedNavIndex = 0; // Index to keep track of selected navigation item

class BottomNavigationPage extends StatefulWidget {
  const BottomNavigationPage({super.key});

  @override
  State<BottomNavigationPage> createState() => _BottomNavigationPageState();
}

class _BottomNavigationPageState extends State<BottomNavigationPage> {
  @override
  void initState() {
    context.read<CategoryBloc>().add(SetConstantCategoryModels());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          BlocBuilder<BottomNavigationBloc, BottomNavigationState>(
            builder: (context, state) {
              return state.pages[state.index];
            },
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: SafeArea(
              child: Container(
                height: 76, // Height of the bottom navigation bar
                padding:
                    const EdgeInsets.all(0), // Padding inside the container
                margin: const EdgeInsets.fromLTRB(
                    18, 0, 18, 10), // Horizontal margin outside the container
                decoration: BoxDecoration(
                  color: ColorConstants.themeColor
                      .withOpacity(0.8), // Background color with opacity
                  borderRadius: const BorderRadius.all(
                      Radius.circular(24)), // Rounded corners
                  boxShadow: [
                    BoxShadow(
                      color: ColorConstants.themeColor
                          .withOpacity(0.2), // Shadow color with opacity
                      offset: const Offset(0, 20), // Shadow offset
                      blurRadius: 10, // Blur radius for the shadow
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
                      (index) => BlocBuilder<BottomNavigationBloc,
                          BottomNavigationState>(
                        builder: (context, state) {
                          return CustomInkWell(
                            onTap: () {
                              riveIconInputs[index]
                                  .change(true); // Activate animation on tap
                              Future.delayed(
                                const Duration(
                                    milliseconds:
                                        200), // Delay to reset the animation
                                () {
                                  riveIconInputs[index].change(
                                      false); // Deactivate animation after delay
                                },
                              );

                              context
                                  .read<BottomNavigationBloc>()
                                  .add(ChangeBottomNavigation(index: index));
                            },
                            child: Column(
                              children: [
                                10.height(),
                                RiveAnimation.asset(
                                  bottomNavItems[index]
                                      .rive
                                      .src, // Rive animation source
                                  artboard: bottomNavItems[index]
                                      .rive
                                      .artBoard, // Artboard for the Rive animation
                                  onInit: (artboard) {
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
                                    color: state.index == index
                                        ? Colors.white
                                        : Colors.grey[100],
                                    fontWeight: state.index == index
                                        ? FontWeight.w700
                                        : null,
                                    fontSize: state.index == index ? 15 : null,
                                  ),
                                ),
                                10.height(),
                              ],
                            ),
                          );
                        },
                      ).expand(),
                    ),
                  ),
                ),
              ),
            ),
          )
        ],
      ),
      // bottomNavigationBar:,
    );
  }
}

void riveOnInIt(Artboard artboard, {required String stateMachineName}) {
  try {
    StateMachineController? controller = StateMachineController.fromArtboard(
        artboard,
        stateMachineName); // Get the state machine controller from the artboard

    bool added = artboard
        .addController(controller!); // Add the controller to the artboard
    log(added.toString(), name: "artboard adding bool");
    controllers.add(controller); // Add the controller to the controllers list

    riveIconInputs.add(controller.findInput<bool>('active')
        as SMIBool); // Find and add the boolean input for animation state
  } catch (e) {
    log(e.toString(), name: "on catch rive on init");
  }
}
