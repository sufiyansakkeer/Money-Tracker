import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:money_track/core/constants/colors.dart';
import 'package:money_track/features/budget/presentation/bloc/budget_bloc.dart';
import 'package:money_track/features/categories/presentation/bloc/category_bloc.dart';
import 'package:money_track/features/navigation/presentation/bloc/bottom_navigation_bloc.dart';
import 'package:money_track/features/navigation/presentation/widgets/bottom_navigation_list.dart';
import 'package:money_track/features/transactions/presentation/bloc/total_transaction/total_transaction_cubit.dart';
import 'package:money_track/features/transactions/presentation/bloc/transaction_bloc.dart';
import 'package:money_track/core/widgets/custom_inkwell.dart';
import 'package:rive/rive.dart';

// List to store state machine boolean inputs for Rive animations
List<SMIBool> riveIconInputs = [];
List<StateMachineController?> controllers =
    []; // List to store state machine controllers

class BottomNavigationPage extends StatefulWidget {
  const BottomNavigationPage({super.key});

  @override
  State<BottomNavigationPage> createState() => _BottomNavigationPageState();
}

class _BottomNavigationPageState extends State<BottomNavigationPage>
    with TickerProviderStateMixin {
  // Animation controllers for tab transitions
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  // Current tab index
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();

    // Initialize animations
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.fastOutSlowIn,
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.fastOutSlowIn,
      ),
    );

    // Start with the animation completed
    _animationController.value = 1.0;

    // Initialize data
    context.read<TransactionBloc>().add(GetAllTransactionsEvent());
    context.read<CategoryBloc>().add(SetDefaultCategoriesEvent());
    context.read<TotalTransactionCubit>().calculateTotalAmounts();
  }

  @override
  void dispose() {
    _animationController.dispose();
    controllers.clear();
    riveIconInputs.clear(); // Clear the Rive inputs list
    super.dispose();
  }

  // Method to handle tab changes with animations
  void _onTabChanged(int index) {
    if (_currentIndex == index) return;

    setState(() {
      _currentIndex = index;
    });

    // Page transition animation
    _animationController.reset();
    _animationController.forward();

    // Trigger Rive animation
    if (riveIconInputs.isNotEmpty && index < riveIconInputs.length) {
      riveIconInputs[index].change(true);
      Future.delayed(
        const Duration(milliseconds: 150),
        () {
          riveIconInputs[index].change(false);
        },
      );
    }

    // Update navigation state
    context.read<BottomNavigationBloc>().add(
          ChangeBottomNavigationEvent(index: index),
        );
  }

  @override
  Widget build(BuildContext context) {
    final themeColor = ColorConstants.getThemeColor(context);

    return Scaffold(
      body: Stack(
        children: [
          // Listen for transaction changes and update budgets
          BlocListener<TransactionBloc, TransactionState>(
            listener: (context, state) {
              if (state is TransactionLoaded) {
                // When transactions are loaded, refresh budgets
                context
                    .read<BudgetBloc>()
                    .add(const RefreshBudgetsOnTransactionChange());
              }
            },
            child: AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return FadeTransition(
                  opacity: _fadeAnimation,
                  child: ScaleTransition(
                    scale: _scaleAnimation,
                    child: BlocBuilder<BottomNavigationBloc,
                        BottomNavigationState>(
                      builder: (context, state) {
                        return state.pages[state.index];
                      },
                    ),
                  ),
                );
              },
            ),
          ),

          // Modern bottom navigation bar
          Align(
            alignment: Alignment.bottomCenter,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 16, left: 16, right: 16),
                child: Container(
                  height: 80,
                  decoration: BoxDecoration(
                    color: themeColor,
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(
                      bottomNavItems.length,
                      (index) => BlocBuilder<BottomNavigationBloc,
                          BottomNavigationState>(
                        builder: (context, state) {
                          final isSelected = state.index == index;

                          return CustomInkWell(
                            onTap: () => _onTabChanged(index),
                            child: Container(
                              width: (MediaQuery.of(context).size.width - 32) /
                                  bottomNavItems.length,
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    height: 36,
                                    child: RiveAnimation.asset(
                                      bottomNavItems[index].rive.src,
                                      artboard:
                                          bottomNavItems[index].rive.artBoard,
                                      onInit: (artboard) {
                                        riveOnInIt(
                                          artboard,
                                          stateMachineName:
                                              bottomNavItems[index]
                                                  .rive
                                                  .stateMachineName,
                                        );
                                      },
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  AnimatedDefaultTextStyle(
                                    duration: const Duration(milliseconds: 200),
                                    curve: Curves.easeOutCubic,
                                    style: TextStyle(
                                      fontFamily:
                                          GoogleFonts.poppins().fontFamily,
                                      color: Colors.white,
                                      fontWeight: isSelected
                                          ? FontWeight.w600
                                          : FontWeight.w400,
                                      fontSize: isSelected ? 14 : 12,
                                    ),
                                    child: Text(
                                      bottomNavItems[index].text,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

void riveOnInIt(Artboard artboard, {required String stateMachineName}) {
  try {
    StateMachineController? controller = StateMachineController.fromArtboard(
        artboard,
        stateMachineName); // Get the state machine controller from the artboard

    if (controller != null) {
      bool added = artboard
          .addController(controller); // Add the controller to the artboard
      log(added.toString(), name: "artboard adding bool");
      controllers.add(controller); // Add the controller to the controllers list

      riveIconInputs.add(controller.findInput<bool>('active')
          as SMIBool); // Find and add the boolean input for animation state
    }
  } catch (e) {
    log(e.toString(), name: "on catch rive on init");
  }
}
