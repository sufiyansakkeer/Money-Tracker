import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:money_track/helper/sized_box_extension.dart';
import 'package:money_track/models/categories_model/category_model.dart';
import 'package:money_track/presentation/bloc/category/category_bloc.dart';
import 'package:money_track/presentation/widgets/category_icon_widget.dart';

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
          child: FloatingActionButton(
            onPressed: () {},
            child: const Icon(
              Icons.abc,
            ),
          ),
        ),
      ),
    );
  }
}

class CategoryCard extends StatelessWidget {
  const CategoryCard({
    super.key,
    required this.categoryType,
    required this.categoryName,
  });
  final CategoryType categoryType;
  final String categoryName;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CategoryIconWidget(categoryType: categoryType),
        10.height(),
        Text(
          categoryName,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
