part of 'category_bloc.dart';

abstract class CategoryEvent extends Equatable {
  const CategoryEvent();

  @override
  List<Object?> get props => [];
}

class GetAllCategoriesEvent extends CategoryEvent {}

class AddCategoryEvent extends CategoryEvent {
  final String name;

  const AddCategoryEvent({required this.name});

  @override
  List<Object?> get props => [name];
}

class DeleteCategoryEvent extends CategoryEvent {
  final String categoryId;

  const DeleteCategoryEvent({required this.categoryId});

  @override
  List<Object?> get props => [categoryId];
}

class SetDefaultCategoriesEvent extends CategoryEvent {}
