import 'package:flutter/material.dart';
import 'package:money_track/core/constants/colors.dart';
import 'package:money_track/helper/sized_box_extension.dart';
import 'package:money_track/helper/widget_extension.dart';
import 'package:money_track/models/categories_model/category_model.dart';
import 'package:money_track/presentation/pages/home/widgets/source_tile.dart';
import 'package:money_track/presentation/widgets/category_icon_widget.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Container(
          height: MediaQuery.sizeOf(context).height,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment(0.9, 0.1),
              colors: [
                Color(0xFFFFF6E5),
                Colors.white,
              ],
            ),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                20.height(),
                const Text(
                  "Account Balance",
                  style: TextStyle(
                    color: Colors.grey,
                  ),
                ),
                10.height(),
                const Text(
                  "₹2222222",
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 28,
                  ),
                ),
                20.height(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SourceTile(
                      color: ColorConstants.incomeColor,
                      sourceName: "Income",
                      sourceData: 2344444,
                      sourceIcon: "assets/svg/home/income_icon.svg",
                      padding: const EdgeInsets.fromLTRB(8, 16, 8, 8),
                    ).expand(),
                    10.width(),
                    SourceTile(
                      color: ColorConstants.expenseColor,
                      sourceName: "Expense",
                      sourceData: 23222222,
                      sourceIcon: "assets/svg/home/expense_icon.svg",
                    ).expand(),
                  ],
                ),
                20.height(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Recent transaction",
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 20,
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ColorConstants.secondaryColor,
                        elevation: 0,
                      ),
                      child: Text(
                        "See All",
                        style: TextStyle(
                          color: ColorConstants.themeColor,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    )
                  ],
                ),
                20.height(),
                ListView.separated(
                  separatorBuilder: (context, index) => 10.height(),
                  primary: false,
                  shrinkWrap: true,
                  itemBuilder: (context, index) => Row(
                    children: [
                      const CategoryIconWidget(
                        categoryType: CategoryType.other,
                      ),
                      10.width(),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "index $index",
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              // 10.width(),
                              Text(
                                "₹$index",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: ColorConstants.expenseColor,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                          10.height(),
                          Row(
                            children: [
                              Text(
                                "index $index ",
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontWeight: FontWeight.w400,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ).expand(),
                              10.width(),
                              const Text(
                                "3:33 PM",
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ).expand(),
                    ],
                  ),
                  itemCount: 10,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
