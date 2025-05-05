import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:money_track/core/constants/colors.dart';
import 'package:money_track/core/constants/style_constants.dart';
import 'package:money_track/core/utils/navigation_extension.dart';
import 'package:money_track/core/utils/sized_box_extension.dart';
import 'package:money_track/features/transactions/domain/entities/filter_data.dart';
import 'package:money_track/features/transactions/presentation/bloc/transaction_bloc.dart';
import 'package:money_track/features/transactions/presentation/pages/transaction_list/widgets/custom_choice_chip.dart';

class DateFilterBottomSheet extends StatefulWidget {
  final FilterData filterData;

  const DateFilterBottomSheet({
    super.key,
    required this.filterData,
  });

  @override
  State<DateFilterBottomSheet> createState() => _DateFilterBottomSheetState();
}

class _DateFilterBottomSheetState extends State<DateFilterBottomSheet> {
  late DateFilterType? selectedDateFilter;
  DateTime? startDate;
  DateTime? endDate;
  final DateFormat dateFormat = DateFormat('dd MMM yyyy');

  @override
  void initState() {
    super.initState();
    selectedDateFilter = widget.filterData.dateFilterType;
    startDate = widget.filterData.startDate;
    endDate = widget.filterData.endDate;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 800,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Filter by Date",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: ColorConstants.getTextColor(context),
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: ColorConstants.getSecondaryColor(context),
                  elevation: 0,
                ),
                onPressed: () {
                  setState(() {
                    selectedDateFilter = null;
                    startDate = null;
                    endDate = null;
                  });
                },
                child: Text(
                  "Reset",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: ColorConstants.getThemeColor(context),
                  ),
                ),
              ),
            ],
          ),
          20.height(),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              CustomChoiceChip(
                name: "Today",
                selected: selectedDateFilter == DateFilterType.today,
                onSelected: (selected) {
                  setState(() {
                    selectedDateFilter = DateFilterType.today;
                  });
                },
              ),
              CustomChoiceChip(
                name: "Yesterday",
                selected: selectedDateFilter == DateFilterType.yesterday,
                onSelected: (selected) {
                  setState(() {
                    selectedDateFilter = DateFilterType.yesterday;
                  });
                },
              ),
              CustomChoiceChip(
                name: "This Week",
                selected: selectedDateFilter == DateFilterType.thisWeek,
                onSelected: (selected) {
                  setState(() {
                    selectedDateFilter = DateFilterType.thisWeek;
                  });
                },
              ),
              CustomChoiceChip(
                name: "This Month",
                selected: selectedDateFilter == DateFilterType.thisMonth,
                onSelected: (selected) {
                  setState(() {
                    selectedDateFilter = DateFilterType.thisMonth;
                  });
                },
              ),
              CustomChoiceChip(
                name: "This Year",
                selected: selectedDateFilter == DateFilterType.thisYear,
                onSelected: (selected) {
                  setState(() {
                    selectedDateFilter = DateFilterType.thisYear;
                  });
                },
              ),
              CustomChoiceChip(
                name: "All Time",
                selected: selectedDateFilter == DateFilterType.all,
                onSelected: (selected) {
                  setState(() {
                    selectedDateFilter = DateFilterType.all;
                  });
                },
              ),
              CustomChoiceChip(
                name: "Custom Range",
                selected: selectedDateFilter == DateFilterType.custom,
                onSelected: (selected) {
                  setState(() {
                    selectedDateFilter = DateFilterType.custom;

                    // Always initialize with today's date for better UX
                    final now = DateTime.now();

                    // Set start date to beginning of today
                    startDate = DateTime(now.year, now.month, now.day);

                    // Set end date to end of today
                    endDate =
                        DateTime(now.year, now.month, now.day, 23, 59, 59);
                  });
                },
              ),
            ],
          ),
          20.height(),
          if (selectedDateFilter == DateFilterType.custom) ...[
            Text(
              "Custom Date Range",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: ColorConstants.getTextColor(context),
              ),
            ),
            10.height(),
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => _selectStartDate(context),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: ColorConstants.getBorderColor(context),
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Start Date",
                            style: TextStyle(
                              fontSize: 12,
                              color: ColorConstants.getTextColor(context)
                                  .withValues(alpha: 0.6),
                            ),
                          ),
                          5.height(),
                          Text(
                            startDate != null
                                ? dateFormat.format(startDate!)
                                : "Select Date",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: ColorConstants.getTextColor(context),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                10.width(),
                Expanded(
                  child: InkWell(
                    onTap: () => _selectEndDate(context),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: ColorConstants.getBorderColor(context),
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "End Date",
                            style: TextStyle(
                              fontSize: 12,
                              color: ColorConstants.getTextColor(context)
                                  .withValues(alpha: 0.6),
                            ),
                          ),
                          5.height(),
                          Text(
                            endDate != null
                                ? dateFormat.format(endDate!)
                                : "Select Date",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: ColorConstants.getTextColor(context),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            10.height(),
          ],
          20.height(),
          ElevatedButton(
            style: StyleConstants.elevatedButtonStyle(context: context),
            onPressed: () {
              // Set appropriate date ranges based on filter type
              if (selectedDateFilter != null &&
                  selectedDateFilter != DateFilterType.custom) {
                final now = DateTime.now();

                switch (selectedDateFilter!) {
                  case DateFilterType.today:
                    startDate = DateTime(now.year, now.month, now.day);
                    endDate =
                        DateTime(now.year, now.month, now.day, 23, 59, 59);
                    break;
                  case DateFilterType.yesterday:
                    startDate = DateTime(now.year, now.month, now.day - 1);
                    endDate =
                        DateTime(now.year, now.month, now.day - 1, 23, 59, 59);
                    break;
                  case DateFilterType.thisWeek:
                    // Calculate the start of the week (assuming Sunday is the first day)
                    final daysToSubtract = now.weekday % 7;
                    startDate =
                        DateTime(now.year, now.month, now.day - daysToSubtract);
                    endDate =
                        DateTime(now.year, now.month, now.day, 23, 59, 59);
                    break;
                  case DateFilterType.thisMonth:
                    startDate = DateTime(now.year, now.month, 1);
                    endDate = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
                    break;
                  case DateFilterType.thisYear:
                    startDate = DateTime(now.year, 1, 1);
                    endDate = DateTime(now.year, 12, 31, 23, 59, 59);
                    break;
                  case DateFilterType.all:
                    startDate = null;
                    endDate = null;
                    break;
                  default:
                    break;
                }
              }

              // Update the filter data with selected values
              widget.filterData.dateFilterType = selectedDateFilter;
              widget.filterData.startDate = startDate;
              widget.filterData.endDate = endDate;

              // Debug print
              print(
                  'Applied filter: ${widget.filterData.dateFilterType}, Start: ${widget.filterData.startDate}, End: ${widget.filterData.endDate}');

              // Apply the filter
              context.read<TransactionBloc>().add(
                    FilterTransactionEvent(filterData: widget.filterData),
                  );

              // Close the bottom sheet and notify parent
              context.pop(true);
            },
            child: const Text(
              "Apply",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          20.height(),
        ],
      ),
    );
  }

  Future<void> _selectStartDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: startDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: ColorConstants.getThemeColor(context),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        // Set to beginning of the day (00:00:00)
        startDate = DateTime(picked.year, picked.month, picked.day);

        // Ensure end date is not before start date
        if (endDate != null && endDate!.isBefore(startDate!)) {
          endDate = DateTime(
              startDate!.year, startDate!.month, startDate!.day, 23, 59, 59);
        }

        print('Selected start date: $startDate');
      });
    }
  }

  Future<void> _selectEndDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: endDate ?? DateTime.now(),
      firstDate: startDate ?? DateTime(2000),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: ColorConstants.getThemeColor(context),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        // Set to end of the day (23:59:59)
        endDate = DateTime(picked.year, picked.month, picked.day, 23, 59, 59);
        print('Selected end date: $endDate');
      });
    }
  }
}
