part of 'category_bloc.dart';

sealed class CategoryEvent extends Equatable {
  const CategoryEvent();

  @override
  List<Object> get props => [];
}

class GetAllCategoryModels extends CategoryEvent {}

class SetConstantCategoryModels extends CategoryEvent {}

class AddCategoryEvent extends CategoryEvent {}
