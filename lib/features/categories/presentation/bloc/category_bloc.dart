import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:money_track/core/logging/app_logger.dart';
import 'package:money_track/core/use_cases/use_case.dart';
import 'package:money_track/domain/entities/category_entity.dart';
import 'package:money_track/domain/usecases/category/add_category_usecase.dart';
import 'package:money_track/domain/usecases/category/get_all_categories_usecase.dart';
import 'package:money_track/domain/usecases/category/set_default_categories_usecase.dart';

part 'category_event.dart';
part 'category_state.dart';

class CategoryBloc extends Bloc<CategoryEvent, CategoryState> {
  final GetAllCategoriesUseCase getAllCategoriesUseCase;
  final AddCategoryUseCase addCategoryUseCase;
  final SetDefaultCategoriesUseCase setDefaultCategoriesUseCase;

  CategoryBloc({
    required this.getAllCategoriesUseCase,
    required this.addCategoryUseCase,
    required this.setDefaultCategoriesUseCase,
  }) : super(CategoryInitial()) {
    AppLogger().info('CategoryBloc initialized', tag: 'CATEGORY_BLOC');
    
    on<GetAllCategoriesEvent>((event, emit) async {
      AppLogger().blocEvent('CategoryBloc', 'GetAllCategoriesEvent');
      emit(CategoryLoading());
      
      try {
        final result = await getAllCategoriesUseCase();

        result.fold(
          (success) {
            AppLogger().blocState('CategoryBloc', 'CategoryLoaded', 
              data: {'categoryCount': success.length});
            emit(CategoryLoaded(categoryList: success));
          },
          (error) {
            AppLogger().error('Failed to get all categories: ${error.message}', 
              tag: 'CATEGORY_BLOC');
            emit(CategoryError(message: error.message));
          },
        );
      } catch (e) {
        AppLogger().error('Exception in GetAllCategoriesEvent: $e', 
          tag: 'CATEGORY_BLOC', error: e);
        emit(CategoryError(message: e.toString()));
      }
    });

    on<AddCategoryEvent>((event, emit) async {
      AppLogger().blocEvent('CategoryBloc', 'AddCategoryEvent', 
        data: {'categoryName': event.name});
      
      final category = CategoryEntity(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        categoryName: event.name,
        type: TransactionType.expense,
      );

      AppLogger().debug('Creating category with ID: ${category.id}', 
        tag: 'CATEGORY_BLOC');

      final result = await addCategoryUseCase(params: category);

      result.fold(
        (success) {
          AppLogger().info('Category added successfully', tag: 'CATEGORY_BLOC');
          add(GetAllCategoriesEvent());
        },
        (error) {
          AppLogger().error('Failed to add category: ${error.message}', 
            tag: 'CATEGORY_BLOC');
          emit(CategoryError(message: error.message));
        },
      );
    });

    on<SetDefaultCategoriesEvent>((event, emit) async {
      AppLogger().blocEvent('CategoryBloc', 'SetDefaultCategoriesEvent');
      
      try {
        final result = await setDefaultCategoriesUseCase(params: NoParams());

        result.fold(
          (success) {
            AppLogger().info('Default categories set successfully', tag: 'CATEGORY_BLOC');
            add(GetAllCategoriesEvent());
          },
          (error) {
            AppLogger().error('Failed to set default categories: ${error.message}', 
              tag: 'CATEGORY_BLOC');
            emit(CategoryError(message: error.message));
          },
        );
      } catch (e) {
        AppLogger().error('Exception in SetDefaultCategoriesEvent: $e', 
          tag: 'CATEGORY_BLOC', error: e);
        emit(CategoryError(message: e.toString()));
      }
    });
  }
}