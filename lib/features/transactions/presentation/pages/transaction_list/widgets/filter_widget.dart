import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:money_track/core/constants/colors.dart';
import 'package:money_track/core/constants/style_constants.dart';
import 'package:money_track/core/utils/navigation_extension.dart';
import 'package:money_track/core/utils/sized_box_extension.dart';
import 'package:money_track/core/utils/string_extensions.dart';
import 'package:money_track/domain/entities/category_entity.dart';
import 'package:money_track/features/transactions/domain/entities/filter_data.dart';
import 'package:money_track/features/transactions/presentation/bloc/transaction_bloc.dart';
import 'package:money_track/features/transactions/presentation/pages/transaction_list/widgets/custom_choice_chip.dart';

class FilterWidget extends StatefulWidget {
  const FilterWidget({
    super.key,
    required this.filterData,
  });
  final FilterData filterData;

  @override
  State<FilterWidget> createState() => _FilterWidgetState();
}

class _FilterWidgetState extends State<FilterWidget> {
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
                "Filter Transaction",
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
                    widget.filterData.reset();
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
          10.height(),
          Text(
            "Filter By",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: ColorConstants.getTextColor(context),
            ),
          ),
          10.height(),
          Row(
            children: [
              CustomChoiceChip(
                name: "Income",
                selected:
                    widget.filterData.transactionType == TransactionType.income,
                onSelected: (value) {
                  setState(() {
                    widget.filterData.transactionType = TransactionType.income;
                  });
                },
              ),
              10.width(),
              CustomChoiceChip(
                name: "Expense",
                selected: widget.filterData.transactionType ==
                    TransactionType.expense,
                onSelected: (value) {
                  setState(() {
                    widget.filterData.transactionType = TransactionType.expense;
                  });
                },
              ),
            ],
          ),
          10.height(),
          Text(
            "Sort By",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: ColorConstants.getTextColor(context),
            ),
          ),
          10.height(),
          Wrap(
            runSpacing: 5,
            spacing: 15,
            children: [
              ...List.generate(
                TransactionSortEnum.values.length,
                (index) {
                  return CustomChoiceChip(
                    name: TransactionSortEnum.values[index].name.capitalize(),
                    selected: widget.filterData.transactionSortEnum ==
                        TransactionSortEnum.values[index],
                    onSelected: (value) {
                      setState(() {
                        widget.filterData.transactionSortEnum =
                            TransactionSortEnum.values[index];
                      });
                    },
                  );
                },
              )
            ],
          ),
          10.height(),
          ElevatedButton(
            style: StyleConstants.elevatedButtonStyle(context: context),
            onPressed: () {
              context
                  .read<TransactionBloc>()
                  .add(FilterTransactionEvent(filterData: widget.filterData));
              context.pop();
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
}
