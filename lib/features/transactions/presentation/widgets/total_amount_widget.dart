import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:money_track/core/constants/colors.dart';
import 'package:money_track/core/utils/currency_formatter.dart';
import 'package:money_track/core/utils/sized_box_extension.dart';
import 'package:money_track/features/transactions/presentation/bloc/total_transaction/total_transaction_cubit.dart';
import 'package:money_track/features/transactions/presentation/widgets/source_tile.dart';

/// Optimized TotalAmountWidget with performance improvements
class TotalAmountWidget extends StatefulWidget {
  const TotalAmountWidget({super.key});

  @override
  State<TotalAmountWidget> createState() => _TotalAmountWidgetState();
}

class _TotalAmountWidgetState extends State<TotalAmountWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _countAnimation;

  double _previousAmount = 0;
  double _currentAmount = 0;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    // Removed: Do not trigger calculateTotalAmounts here
  }

  void _initializeAnimations() {
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

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _updateAmount(double newAmount) {
    if (!mounted || _previousAmount == newAmount) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() {
        _previousAmount = _currentAmount;
        _currentAmount = newAmount;
      });
      _animationController.reset();
      _animationController.forward();
    });
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
          // Account Balance Label
          const _AccountBalanceLabel(),
          10.height(),

          // Balance Amount with optimized BlocSelector
          BlocSelector<TotalTransactionCubit, TotalTransactionState, double?>(
            selector: (state) {
              if (state is TotalTransactionSuccess) {
                return state.balance;
              }
              return null;
            },
            builder: (context, balance) {
              if (balance != null) {
                _updateAmount(balance);
                return _AnimatedBalanceText(
                  animation: _countAnimation,
                  previousAmount: _previousAmount,
                  currentAmount: _currentAmount,
                );
              }
              return _AnimatedBalanceText(
                animation: _countAnimation,
                previousAmount: 0,
                currentAmount: 0,
              );
            },
          ),

          20.height(),

          // Income and Expense Tiles
          const _IncomeExpenseRow(),
        ],
      ),
    );
  }
}

/// Separated widget for account balance label to prevent unnecessary rebuilds
class _AccountBalanceLabel extends StatelessWidget {
  const _AccountBalanceLabel();

  @override
  Widget build(BuildContext context) {
    return Text(
      'Account Balance',
      style: TextStyle(
        color: ColorConstants.getTextColor(context).withValues(alpha: 0.6),
      ),
    );
  }
}

/// Optimized animated balance text widget
class _AnimatedBalanceText extends StatelessWidget {
  const _AnimatedBalanceText({
    required this.animation,
    required this.previousAmount,
    required this.currentAmount,
  });

  final Animation<double> animation;
  final double previousAmount;
  final double currentAmount;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) {
        final value =
            previousAmount + (currentAmount - previousAmount) * animation.value;
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
  }
}

/// Optimized income and expense row
class _IncomeExpenseRow extends StatelessWidget {
  const _IncomeExpenseRow();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TotalTransactionCubit, TotalTransactionState>(
      buildWhen: (previous, current) =>
          previous.runtimeType != current.runtimeType,
      builder: (context, state) {
        if (state is! TotalTransactionSuccess) {
          // Show loading or placeholder until data is available
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _SourceTilePlaceholder(label: 'Income'),
              20.width(),
              _SourceTilePlaceholder(label: 'Expense'),
            ],
          );
        } else {
          // Only build when data is available
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: AnimatedSourceTile(
                  color: ColorConstants.getIncomeColor(context),
                  sourceName: 'Income',
                  sourceData: state.totalIncome,
                  sourceIcon: 'assets/svg/home/income_icon.svg',
                  padding: const EdgeInsets.fromLTRB(8, 16, 8, 8),
                  delay: const Duration(milliseconds: 100),
                ),
              ),
              10.width(),
              Expanded(
                child: AnimatedSourceTile(
                  color: ColorConstants.getExpenseColor(context),
                  sourceName: 'Expense',
                  sourceData: state.totalExpense,
                  sourceIcon: 'assets/svg/home/expense_icon.svg',
                  delay: const Duration(milliseconds: 200),
                ),
              ),
            ],
          );
        }
      },
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
  double _currentAmount = 0;

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

    _currentAmount = widget.sourceData;

    // Delay the animation start based on the provided delay
    Future.delayed(widget.delay, () {
      if (mounted) {
        _animationController.forward();
      }
    });
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
        sourceData: _currentAmount,
        sourceIcon: widget.sourceIcon,
        padding: widget.padding,
      ),
    );
  }
}

class _SourceTilePlaceholder extends StatelessWidget {
  final String label;

  const _SourceTilePlaceholder({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ColorConstants.getCardColor(context),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min, // Fix: shrink-wrap row
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Placeholder for icon
          Container(
            width: 24,
            height: 24,
            color: Colors.grey.shade300,
          ),
          const SizedBox(width: 16),
          // Placeholder for label
          Flexible(
            fit: FlexFit.loose,
            child: Container(
              height: 16,
              color: Colors.grey.shade300,
            ),
          ),
          const SizedBox(width: 16),
          // Placeholder for value
          Container(
            width: 64,
            height: 16,
            color: Colors.grey.shade300,
          ),
        ],
      ),
    );
  }
}
