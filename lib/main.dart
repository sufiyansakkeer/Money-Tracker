import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:money_track/my_app.dart';
import 'package:money_track/models/categories_model/category_model.dart';
import 'models/transaction_model/transaction_model.dart';

//here main function became future because the init flutter function is a future method
Future<void> main() async {
  //Setting SystemUIOverlay
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      systemStatusBarContrastEnforced: true,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarDividerColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.dark,
      statusBarIconBrightness: Brightness.dark));
  //here it will ensure that the app will connect with platform channels or not,
  // all plugins are connected with platform channels or not before app starting
  WidgetsFlutterBinding.ensureInitialized();

  //here it will initialize the hive database
  await Hive.initFlutter();
  Hive.openBox<CategoryModel>('categoryDBName');
  //here it will register the category type adapter if it is not registered ,
  //without adapter we can't read or write to data base,
  // it act as a bridge between database and app
//category type adapter registration

  if (!Hive.isAdapterRegistered(CategoryTypeAdapter().typeId)) {
    Hive.registerAdapter(CategoryTypeAdapter());
  }

  //here we register the category name adapter if it is not registered
//category model adapter registration
//transaction model adapter registration

  Hive.registerAdapter(TransactionModelAdapter());
  if (!Hive.isAdapterRegistered(CategoryModelAdapter().typeId)) {
    Hive.registerAdapter(CategoryModelAdapter());
  }
  if (!Hive.isAdapterRegistered(TransactionTypeAdapter().typeId)) {
    Hive.registerAdapter(TransactionTypeAdapter());
  }
  runApp(
    const MyApp(),
  );
}
