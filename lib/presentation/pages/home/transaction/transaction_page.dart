import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:money_track/core/constants/colors.dart';
import 'package:money_track/core/constants/style_constants.dart';
import 'package:money_track/helper/sized_box_extension.dart';
import 'package:money_track/helper/widget_extension.dart';
import 'package:money_track/presentation/bloc/category/category_bloc.dart';
import 'package:money_track/presentation/pages/settings/widget/custom_app_bar.dart';
import 'package:svg_flutter/svg.dart';

class TransactionPage extends StatefulWidget {
  const TransactionPage({super.key, required this.isExpense});
  final bool isExpense;

  @override
  State<TransactionPage> createState() => _TransactionPageState();
}

class _TransactionPageState extends State<TransactionPage> {
  late TextEditingController amountEditingController;
  late TextEditingController categoryController;
  late TextEditingController descriptionController;

  @override
  void initState() {
    amountEditingController = TextEditingController();
    categoryController = TextEditingController();
    descriptionController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    amountEditingController.dispose();
    categoryController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: widget.isExpense
          ? ColorConstants.expenseColor
          : ColorConstants.incomeColor,
      appBar: customAppBar(
        context,
        title: widget.isExpense ? "Expense" : "Income",
        color: widget.isExpense
            ? ColorConstants.expenseColor
            : ColorConstants.incomeColor,
      ),
      body: CustomScrollView(
        slivers: [
          SliverFillRemaining(
            hasScrollBody: false,
            child: Column(
              children: [
                AmountWidget(controller: amountEditingController),
                Container(
                  // height: constraints.maxHeight,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(
                        20,
                      ),
                      topRight: Radius.circular(
                        20,
                      ),
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 30,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // 10.height(),
                      Column(
                        children: [
                          TextFormField(
                            controller: categoryController,
                            readOnly: true,
                            onTap: () {
                              showModalBottomSheet(
                                context: context,
                                builder: (context) => Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                  ),
                                  width: 800,
                                  child: Column(
                                    children: [
                                      const Text("Category"),
                                      BlocBuilder<CategoryBloc, CategoryState>(
                                        builder: (context, state) {
                                          if (state is CategoryLoading) {
                                            return const Center(
                                              child:
                                                  CircularProgressIndicator(),
                                            );
                                          } else if (state is CategoryLoaded) {
                                            return ListView.builder(
                                              itemBuilder: (context, index) =>
                                                  Text(state.categoryList[index]
                                                      .categoryName),
                                              itemCount:
                                                  state.categoryList.length,
                                            );
                                          } else {
                                            return const Center(
                                              child: Text("No category found"),
                                            );
                                          }
                                        },
                                      ).expand()
                                    ],
                                  ),
                                ),
                              );
                            },
                            decoration: InputDecoration(
                              disabledBorder:
                                  StyleConstants.textFormFieldBorder(),
                              enabledBorder:
                                  StyleConstants.textFormFieldBorder(),
                              border: StyleConstants.textFormFieldBorder(),
                              hintText: "Category",
                              suffixIcon: const DropDownIcon(),
                            ),
                          ),
                          20.height(),
                          TextFormField(
                            controller: descriptionController,
                            decoration: InputDecoration(
                              disabledBorder:
                                  StyleConstants.textFormFieldBorder(),
                              enabledBorder:
                                  StyleConstants.textFormFieldBorder(),
                              border: StyleConstants.textFormFieldBorder(),
                              hintText: "Description",
                            ),
                            maxLines: 2,
                          ),
                          20.height(),
                        ],
                      ),
                      ElevatedButton(
                        onPressed: () {},
                        style: StyleConstants.elevatedButtonStyle(),
                        child: const Text(
                          "Continue",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ).expand(),
              ],
            ),
          )
        ],
      ),
    );
  }
}

class DropDownIcon extends StatelessWidget {
  const DropDownIcon({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      height: 20,
      width: 20,
      child: SvgPicture.asset(
        "assets/svg/common/arrow_down_rounded.svg",
        colorFilter: ColorFilter.mode(
          ColorConstants.borderColor,
          BlendMode.srcIn,
        ),
      ),
    );
  }
}

class AmountWidget extends StatelessWidget {
  const AmountWidget({
    super.key,
    required this.controller,
  });

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          80.height(),
          const Text(
            "How much?",
            style: TextStyle(
              color: Color(0xFFDAD9D9),
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          TextFormField(
            controller: controller,
            decoration: const InputDecoration(
              border: InputBorder.none,
              hintText: "0",
              hintStyle: TextStyle(
                color: Color(0xFFE3E2E2),
                fontSize: 70,
                fontWeight: FontWeight.bold,
              ),
              prefix: Text(
                "₹",
                style: TextStyle(
                  fontSize: 70,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 70,
              fontWeight: FontWeight.bold,
            ),
            keyboardType: TextInputType.number,
            inputFormatters: const [],
          ),
        ],
      ),
    );
  }
}
