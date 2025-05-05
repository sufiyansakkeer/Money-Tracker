import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:money_track/core/constants/colors.dart';
import 'package:money_track/core/utils/sized_box_extension.dart';
import 'package:money_track/features/transactions/domain/entities/filter_data.dart';
import 'package:money_track/features/transactions/presentation/pages/transaction_list/widgets/date_filter_bottom_sheet.dart';
import 'package:svg_flutter/svg.dart';

class DateFilterIcon extends StatelessWidget {
  const DateFilterIcon({
    super.key,
    required this.dateType,
    required this.filterData,
    this.onFilterChanged,
  });
  final String dateType;
  final FilterData filterData;
  final VoidCallback? onFilterChanged;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        showModalBottomSheet(
          showDragHandle: true,
          isScrollControlled: true,
          context: context,
          builder: (context) => Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: DateFilterBottomSheet(
              filterData: filterData,
            ),
          ),
        ).then((result) {
          // Only trigger callback if filter was applied (not dismissed)
          if (result == true && onFilterChanged != null) {
            onFilterChanged!();
          }
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          border: Border.all(
            color: ColorConstants.getBorderColor(context),
          ),
          borderRadius: BorderRadius.circular(
            30,
          ),
        ),
        child: Row(
          children: [
            SvgPicture.asset(
              "assets/svg/common/arrow_down_rounded.svg",
              colorFilter: ColorFilter.mode(
                ColorConstants.getThemeColor(context),
                BlendMode.srcIn,
              ),
            ),
            5.width(),
            Text(
              _getDisplayText(),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: ColorConstants.getTextColor(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getDisplayText() {
    if (filterData.dateFilterType == null) {
      return dateType;
    }

    final filterType = filterData.dateFilterType!;

    if (filterType == DateFilterType.today) {
      return "Today";
    } else if (filterType == DateFilterType.yesterday) {
      return "Yesterday";
    } else if (filterType == DateFilterType.thisWeek) {
      return "This Week";
    } else if (filterType == DateFilterType.thisMonth) {
      return "This Month";
    } else if (filterType == DateFilterType.thisYear) {
      return "This Year";
    } else if (filterType == DateFilterType.custom) {
      if (filterData.startDate != null && filterData.endDate != null) {
        final DateFormat formatter = DateFormat('dd MMM');
        if (filterData.startDate!.year == filterData.endDate!.year) {
          // Same year
          if (filterData.startDate!.month == filterData.endDate!.month &&
              filterData.startDate!.day == filterData.endDate!.day) {
            // Same day
            return formatter.format(filterData.startDate!);
          } else {
            // Different days
            return "${formatter.format(filterData.startDate!)} - ${formatter.format(filterData.endDate!)}";
          }
        } else {
          // Different years
          final DateFormat yearFormatter = DateFormat('dd MMM yyyy');
          return "${yearFormatter.format(filterData.startDate!)} - ${yearFormatter.format(filterData.endDate!)}";
        }
      }
      return "Custom Range";
    } else {
      return "All Time";
    }
  }
}

class SortIconWidget extends StatelessWidget {
  const SortIconWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        border: Border.all(
          color: ColorConstants.getBorderColor(context),
        ),
        borderRadius: BorderRadius.circular(
          30,
        ),
      ),
      child: SvgPicture.asset(
        "assets/svg/common/sort.svg",
        colorFilter: ColorFilter.mode(
          ColorConstants.getThemeColor(context),
          BlendMode.srcIn,
        ),
      ),
    );
  }
}
