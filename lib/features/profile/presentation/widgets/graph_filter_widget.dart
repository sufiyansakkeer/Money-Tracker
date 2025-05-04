import 'package:flutter/material.dart';
import 'package:money_track/core/constants/colors.dart';
import 'package:money_track/core/constants/style_constants.dart';
import 'package:money_track/core/utils/sized_box_extension.dart';
import 'package:money_track/core/utils/string_extensions.dart';
import 'package:money_track/domain/entities/category_entity.dart';
import 'package:money_track/features/profile/domain/entities/graph_filter_data.dart';
import 'package:money_track/features/transactions/presentation/pages/transaction_list/widgets/custom_choice_chip.dart';

class GraphFilterWidget extends StatefulWidget {
  const GraphFilterWidget({
    super.key,
    required this.filterData,
    required this.onFilterChanged,
  });

  final GraphFilterData filterData;
  final Function(GraphFilterData) onFilterChanged;

  @override
  State<GraphFilterWidget> createState() => _GraphFilterWidgetState();
}

class _GraphFilterWidgetState extends State<GraphFilterWidget> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.7,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Filter Graph",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColorConstants.secondaryColor,
                    elevation: 0,
                  ),
                  onPressed: () {
                    setState(() {
                      widget.filterData.reset();
                      widget.onFilterChanged(widget.filterData);
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
              "Transaction Type",
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
                  selected: widget.filterData.transactionType ==
                      TransactionType.income,
                  onSelected: (value) {
                    setState(() {
                      widget.filterData.transactionType =
                          TransactionType.income;
                      widget.onFilterChanged(widget.filterData);
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
                      widget.filterData.transactionType =
                          TransactionType.expense;
                      widget.onFilterChanged(widget.filterData);
                    });
                  },
                ),
                10.width(),
                CustomChoiceChip(
                  name: "All",
                  selected: widget.filterData.transactionType == null,
                  onSelected: (value) {
                    setState(() {
                      widget.filterData.transactionType = null;
                      widget.onFilterChanged(widget.filterData);
                    });
                  },
                ),
              ],
            ),
            10.height(),
            const Text(
              "Time Period",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            10.height(),
            SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  ...List.generate(
                    GraphTimePeriod.values.length,
                    (index) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: CustomChoiceChip(
                          name: GraphTimePeriod.values[index].name.capitalize(),
                          selected: widget.filterData.timePeriod ==
                              GraphTimePeriod.values[index],
                          onSelected: (value) {
                            setState(() {
                              widget.filterData.timePeriod =
                                  GraphTimePeriod.values[index];
                              widget.onFilterChanged(widget.filterData);
                            });
                          },
                        ),
                      );
                    },
                  )
                ],
              ),
            ),
            10.height(),
            const Text(
              "Chart Type",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            10.height(),
            Row(
              children: [
                CustomChoiceChip(
                  name: "Pie Chart",
                  selected: widget.filterData.chartType == ChartType.pie,
                  onSelected: (value) {
                    setState(() {
                      widget.filterData.chartType = ChartType.pie;
                      widget.onFilterChanged(widget.filterData);
                    });
                  },
                ),
                10.width(),
                CustomChoiceChip(
                  name: "Line Chart",
                  selected: widget.filterData.chartType == ChartType.line,
                  onSelected: (value) {
                    setState(() {
                      widget.filterData.chartType = ChartType.line;
                      widget.onFilterChanged(widget.filterData);
                    });
                  },
                ),
              ],
            ),
            20.height(),
            ElevatedButton(
              style: StyleConstants.elevatedButtonStyle(),
              onPressed: () {
                Navigator.pop(context);
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
      ),
    );
  }
}
