import 'package:flutter/material.dart';
import 'package:money_track/core/constants/colors.dart';
import 'package:money_track/core/constants/style_constants.dart';
import 'package:money_track/helper/sized_box_extension.dart';
import 'package:money_track/helper/string_extensions.dart';
import 'package:money_track/models/categories_model/category_model.dart';
import 'package:money_track/models/transaction_model/filter_model/filter_data.dart';
import 'package:money_track/presentation/pages/home/transaction_list/widget/custom_choice_chip.dart';

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
      // width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Filter Transaction",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: ColorConstants.secondaryColor,
                  elevation: 0,
                  // textStyle: TextStyle(
                  //   fontWeight: FontWeight.bold,
                  //   color: ColorConstants.themeColor,
                  // ),
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
                    color: ColorConstants.themeColor,
                  ),
                ),
              ),
            ],
          ),
          10.height(),
          const Text(
            "Filter By",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
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
          const Text(
            "Sort By",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
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
            style: StyleConstants.elevatedButtonStyle(),
            onPressed: () {},
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
