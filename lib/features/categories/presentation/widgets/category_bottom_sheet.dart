import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:money_track/core/constants/colors.dart';
import 'package:money_track/core/utils/navigation_extension.dart';
import 'package:money_track/core/utils/sized_box_extension.dart';
import 'package:money_track/features/categories/presentation/bloc/category_bloc.dart';

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
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
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
