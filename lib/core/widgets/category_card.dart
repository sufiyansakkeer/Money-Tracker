import 'package:flutter/material.dart';
import 'package:money_track/core/constants/colors.dart';
import 'package:money_track/core/widgets/category_icon_widget.dart';
import 'package:money_track/domain/entities/category_entity.dart';

class CategoryCard extends StatefulWidget {
  const CategoryCard({
    super.key,
    required this.categoryType,
    required this.categoryName,
    this.onTap,
  });

  final CategoryType categoryType;
  final String categoryName;
  final VoidCallback? onTap;

  @override
  State<CategoryCard> createState() => _CategoryCardState();
}

class _CategoryCardState extends State<CategoryCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onHover(bool isHovered) {
    if (isHovered) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
    setState(() {
      _isHovered = isHovered;
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeColor = ColorConstants.getThemeColor(context);

    return MouseRegion(
      onEnter: (_) => _onHover(true),
      onExit: (_) => _onHover(false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: child,
            );
          },
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: themeColor.withValues(alpha: _isHovered ? 0.15 : 0.05),
                  blurRadius: _isHovered ? 8 : 4,
                  offset: Offset(0, _isHovered ? 4 : 2),
                ),
              ],
              border: Border.all(
                color: _isHovered
                    ? themeColor.withValues(alpha: 0.3)
                    : Colors.grey.withValues(alpha: 0.1),
                width: 1,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CategoryIconWidget(categoryType: widget.categoryType),
                const SizedBox(height: 12),
                Text(
                  widget.categoryName,
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: _isHovered
                        ? themeColor
                        : Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
