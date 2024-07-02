import 'dart:developer';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:money_track/core/constants/db_constants.dart';
import 'package:money_track/models/categories_model/category_model.dart';
import 'package:money_track/repository/category_repository.dart';

part 'category_event.dart';
part 'category_state.dart';

class CategoryBloc extends Bloc<CategoryEvent, CategoryState> {
  CategoryBloc() : super(CategoryInitial()) {
    on<GetAllCategoryModels>((event, emit) async {
      emit(CategoryLoading());
      try {
        final categoryDB =
            await Hive.openBox<CategoryModel>(DBConstants.categoryDbName);
        emit(CategoryLoaded(
            categoryList: categoryDB.values.toList().reversed.toList()));
      } catch (e) {
        log(e.toString(), name: "Get all category Model Exception");
        emit(CategoryError());
      }
    });

    on<SetConstantCategoryModels>((event, emit) async {
      await CategoryRepository().setConstantCategoryModels();
      add(GetAllCategoryModels());
    });

    on<AddCategoryEvent>((event, emit) async {
      CategoryModel model = CategoryModel(
          id: DateTime.fromMicrosecondsSinceEpoch(
                  DateTime.now().microsecondsSinceEpoch)
              .toString(),
          categoryName: event.name,
          type: TransactionType.expense);
      String res = await CategoryRepository().addCategoryToDB(model);
      if (res == "success") {
        add(GetAllCategoryModels());
      }
    });
  }
}
