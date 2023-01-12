import 'package:hive_flutter/adapters.dart';

import '../../models/categories_model/category_model.dart';

const categoryDBName = 'category-name';

abstract class CategoryDBFunction {
  Future<List<CategoryName>> getAllCategory();
  Future<void> insertCategory(CategoryName value);
}

class CategoryDB extends CategoryDBFunction {
  @override
  Future<void> insertCategory(CategoryName value) async {
    final _categoryDB = await Hive.openBox<CategoryName>(categoryDBName);
    await _categoryDB.add(value);
  }

  @override
  Future<List<CategoryName>> getAllCategory() async {
    final _categoryDB = await Hive.openBox<CategoryName>(categoryDBName);
    //here we need to get all the data's ,it is in a list form thats why we convert it into list.
    return _categoryDB.values.toList();
  }
}
