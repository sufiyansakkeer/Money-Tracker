import 'dart:developer';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:money_track/models/categories_model/category_model.dart';
import 'package:money_track/repository/category_repository.dart';

part 'category_event.dart';
part 'category_state.dart';

class CategoryBloc extends Bloc<CategoryEvent, CategoryState> {
  CategoryBloc() : super(CategoryInitial()) {
    const categoryDbName = 'category-database';
    on<GetAllCategoryModels>((event, emit) async {
      emit(CategoryLoading());
      try {
        final categoryDB = await Hive.openBox<CategoryModel>(categoryDbName);
        emit(CategoryLoaded(
            categoryList: categoryDB.values.toList().reversed.toList()));
      } catch (e) {
        log(e.toString(), name: "Get all category Model Exception");
        emit(CategoryError());
      }
    });
    on<SetConstantCategoryModels>((event, emit) async {
      await CategoryRepository()
          .setConstantCategoryModels(categoryDbName: categoryDbName);
    });
  }
}
