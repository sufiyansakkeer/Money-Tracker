import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:money_track/core/constants/colors.dart';
import 'package:money_track/core/utils/currency_formatter.dart';
import 'package:money_track/core/utils/sized_box_extension.dart';
import 'package:money_track/core/utils/widget_extension.dart';
import 'package:money_track/features/transactions/presentation/bloc/total_transaction/total_transaction_cubit.dart';
import 'package:money_track/features/transactions/presentation/widgets/source_tile.dart';

class TotalAmountWidget extends StatefulWidget {
  const TotalAmountWidget({
    super.key,
  });

  @override
  State<TotalAmountWidget> createState() => _TotalAmountWidgetState();
}

class _TotalAmountWidgetState extends State<TotalAmountWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  double _previousAmount = 0;
  double _currentAmount = 0;
  late Animation<double> _countAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );

    _countAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.2, 0.8, curve: Curves.easeOutCubic),
      ),
    );

    // Start the animation when the widget is first built
    _animationController.forward();

    // Ensure total amounts are loaded when the widget is shown
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TotalTransactionCubit>().getTotalAmount();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _updateAmount(double newAmount) {
    if (!mounted) return;
    if (_previousAmount != newAmount) {
      _previousAmount = _currentAmount;
      _currentAmount = newAmount;
      // Reset and restart the animation when the amount changes
      // Use addPostFrameCallback to avoid calling setState during build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _animationController.reset();
          _animationController.forward();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: child,
          ),
        );
      },
      child: Column(
        children: [
          Text(
            "Account Balance",
            style: TextStyle(
              color:
                  ColorConstants.getTextColor(context).withValues(alpha: 0.6),
            ),
          ),
          10.height(),
          BlocBuilder<TotalTransactionCubit, TotalTransactionState>(
            builder: (context, state) {
              if (state is TotalTransactionSuccess) {
                final balance = state.totalIncome - state.totalExpense;
                _updateAmount(balance);

                return AnimatedBuilder(
                  animation: _countAnimation,
                  builder: (context, _) {
                    final value = _previousAmount +
                        (_currentAmount - _previousAmount) *
                            _countAnimation.value;
                    return Text(
                      CurrencyFormatter.format(context, value),
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 28,
                        color: ColorConstants.getTextColor(context),
                      ),
                    );
                  },
                );
              } else {
                return Text(
                  CurrencyFormatter.format(context, 0),
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 28,
                    color: ColorConstants.getTextColor(context),
                  ),
                );
              }
            },
          ),
          20.height(),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              BlocBuilder<TotalTransactionCubit, TotalTransactionState>(
                builder: (context, state) {
                  if (state is TotalTransactionSuccess) {
                    return AnimatedSourceTile(
                      color: ColorConstants.getIncomeColor(context),
                      sourceName: "Income",
                      sourceData: state.totalIncome,
                      sourceIcon: "assets/svg/home/income_icon.svg",
                      padding: const EdgeInsets.fromLTRB(8, 16, 8, 8),
                      delay: const Duration(milliseconds: 100),
                    );
                  } else {
                    return AnimatedSourceTile(
                      color: ColorConstants.getIncomeColor(context),
                      sourceName: "Income",
                      sourceData: 0,
                      sourceIcon: "assets/svg/home/income_icon.svg",
                      padding: const EdgeInsets.fromLTRB(8, 16, 8, 8),
                      delay: const Duration(milliseconds: 100),
                    );
                  }
                },
              ).expand(),
              10.width(),
              BlocBuilder<TotalTransactionCubit, TotalTransactionState>(
                builder: (context, state) {
                  if (state is TotalTransactionSuccess) {
                    return AnimatedSourceTile(
                      color: ColorConstants.getExpenseColor(context),
                      sourceName: "Expense",
                      sourceData: state.totalExpense,
                      sourceIcon: "assets/svg/home/expense_icon.svg",
                      delay: const Duration(milliseconds: 200),
                    );
                  } else {
                    return AnimatedSourceTile(
                      color: ColorConstants.getExpenseColor(context),
                      sourceName: "Expense",
                      sourceData: 0,
                      sourceIcon: "assets/svg/home/expense_icon.svg",
                      delay: const Duration(milliseconds: 200),
                    );
                  }
                },
              ).expand(),
            ],
          ),
        ],
      ),
    );
  }
}

class AnimatedSourceTile extends StatefulWidget {
  final Color color;
  final String sourceName;
  final double sourceData;
  final String sourceIcon;
  final EdgeInsetsGeometry? padding;
  final Duration delay;

  const AnimatedSourceTile({
    super.key,
    required this.color,
    required this.sourceName,
    required this.sourceData,
    required this.sourceIcon,
    this.padding,
    this.delay = Duration.zero,
  });

  @override
  State<AnimatedSourceTile> createState() => _AnimatedSourceTileState();
}

class _AnimatedSourceTileState extends State<AnimatedSourceTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;
  double _previousAmount = 0;
  double _currentAmount = 0;
  late Animation<double> _countAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOutCubic),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.2, 0.8, curve: Curves.easeOutBack),
      ),
    );

    _countAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.3, 0.9, curve: Curves.easeOutCubic),
      ),
    );

    _currentAmount = widget.sourceData;

    // Delay the animation start based on the provided delay
    Future.delayed(widget.delay, () {
      if (mounted) {
        _animationController.forward();
      }
    });
  }

  @override
  void didUpdateWidget(AnimatedSourceTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.sourceData != widget.sourceData) {
      _previousAmount = _currentAmount;
      _currentAmount = widget.sourceData;
      // Reset and restart the animation when the amount changes
      // Use addPostFrameCallback to avoid calling setState during build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _animationController.reset();
          _animationController.forward();
        }
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: Transform.scale(
              scale: _scaleAnimation.value,
              child: child,
            ),
          ),
        );
      },
      child: SourceTile(
        color: widget.color,
        sourceName: widget.sourceName,
        sourceData: _previousAmount +
            (_currentAmount - _previousAmount) * _countAnimation.value,
        sourceIcon: widget.sourceIcon,
        padding: widget.padding,
      ),
    );
  }
}
