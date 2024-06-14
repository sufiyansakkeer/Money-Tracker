import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:money_track/core/constants/colors.dart';
import 'package:money_track/helper/navigation_extension.dart';
import 'package:money_track/helper/sized_box_extension.dart';
import 'package:money_track/presentation/bloc/category/category_bloc.dart';
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

class CategoryBottomSheetWidget extends StatefulWidget {
  const CategoryBottomSheetWidget({
    super.key,
  });

  @override
  State<CategoryBottomSheetWidget> createState() =>
      _CategoryBottomSheetWidgetState();
}

class _CategoryBottomSheetWidgetState extends State<CategoryBottomSheetWidget> {
  late GlobalKey<FormState> _formKey;

  late TextEditingController controller;
  @override
  void initState() {
    _formKey = GlobalKey<FormState>();
    controller = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      // height: 500,
      width: 800,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Category",
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
            20.height(),
            Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Form(
                key: _formKey,
                child: TextFormField(
                  controller: controller,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(
                          16,
                        ),
                      ),
                    ),
                    hintText: "Category Name",
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty || value.trim() == "") {
                      return "Required";
                    }
                    return null;
                  },
                ),
              ),
            ),
            20.height(),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: ColorConstants.themeColor,
                  minimumSize: const Size(double.infinity, 55),
                  enableFeedback: true,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16))),
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  context
                      .read<CategoryBloc>()
                      .add(AddCategoryEvent(name: controller.text.trim()));
                  controller.clear();
                  context.pop();
                }
              },
              child: const Text(
                "Add Category",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            30.height(),
          ],
        ),
      ),
    );
  }
}
