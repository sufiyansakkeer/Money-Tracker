import 'dart:developer';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:money_track/domain/entities/category_entity.dart';
import 'package:money_track/domain/usecases/category/add_category_usecase.dart';
import 'package:money_track/domain/usecases/category/get_all_categories_usecase.dart';

part 'category_event.dart';
part 'category_state.dart';

class CategoryBloc extends Bloc<CategoryEvent, CategoryState> {
  final GetAllCategoriesUseCase getAllCategoriesUseCase;
  final AddCategoryUseCase addCategoryUseCase;

  CategoryBloc({
    required this.getAllCategoriesUseCase,
    required this.addCategoryUseCase,
  }) : super(CategoryInitial()) {
    on<GetAllCategoriesEvent>((event, emit) async {
      emit(CategoryLoading());
      try {
        final result = await getAllCategoriesUseCase();

        result.fold(
          (success) => emit(CategoryLoaded(categoryList: success)),
          (error) => emit(CategoryError(message: error.message)),
        );
      } catch (e) {
        log(e.toString(), name: "Get all category Model Exception");
        emit(CategoryError(message: e.toString()));
      }
    });

    on<AddCategoryEvent>((event, emit) async {
      final category = CategoryEntity(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        categoryName: event.name,
        type: TransactionType.expense,
      );

      final result = await addCategoryUseCase(params: category);

      result.fold(
        (success) => add(GetAllCategoriesEvent()),
        (error) => emit(CategoryError(message: error.message)),
      );
    });

    on<GetAllCategoryModels>((event, emit) async {
      add(GetAllCategoriesEvent());
    });

    on<SetConstantCategoryModels>((event, emit) async {
      // This is a placeholder for setting constant category models
      // You might want to implement this based on your requirements
      add(GetAllCategoriesEvent());
    });
  }
}
