import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:money_track/core/constants/colors.dart';
import 'package:money_track/helper/sized_box_extension.dart';
import 'package:money_track/presentation/bloc/category/category_bloc.dart';
import 'widget/category_bottom_sheet.dart';
import 'widget/category_card.dart';

class CategoryPage extends StatefulWidget {
  const CategoryPage({super.key});

  @override
  State<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  @override
  void initState() {
    context.read<CategoryBloc>().add(GetAllCategoryModels());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
          ),
          child: SingleChildScrollView(
            child: Column(
              children: [
                20.height(),
                const Text(
                  "Category",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                20.height(),
                BlocBuilder<CategoryBloc, CategoryState>(
                  builder: (context, state) {
                    if (state is CategoryLoading) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    } else if (state is CategoryLoaded) {
                      return GridView.builder(
                        shrinkWrap: true,
                        primary: false,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3),
                        itemBuilder: (context, index) {
                          var categoryModel = state.categoryList[index];
                          return CategoryCard(
                            categoryType: categoryModel.categoryType,
                            categoryName: categoryModel.categoryName,
                          );
                        },
                        itemCount: state.categoryList.length,
                      );
                    } else {
                      return const Center(
                        child: Text("Something went wrong"),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ),
        floatingActionButton: Padding(
          padding: const EdgeInsets.only(
            bottom: 100,
            right: 20,
          ),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: ColorConstants.secondaryColor,
                padding: const EdgeInsets.all(20)),
            onPressed: () {
              showModalBottomSheet(
                showDragHandle: true,
                context: context,
                builder: (context) => const CategoryBottomSheetWidget(),
              );
            },
            child: Icon(
              Icons.add,
              color: ColorConstants.themeColor,
            ),
          ),
        ),
      ),
    );
  }
}
