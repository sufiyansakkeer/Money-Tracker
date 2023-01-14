import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:money_track/models/categories_model/category_model.dart';

import 'package:money_track/screens/splash_screen.dart';

//here main function became future because the init flutter function is a future method
Future<void> main() async {
  //here it will ensure that the app will connect with platform channels or not,
  // all plugins are connected with platform channels or not before app starting
  WidgetsFlutterBinding.ensureInitialized();
  //here it will initialize the hive database
  await Hive.initFlutter();
  Hive.openBox<CategoryModel>('categoryDBName');
  //here it will register the category type adapter if it is not registered ,
  //without adapter we can't read or write to data base,
  // it act as a bridge between database and app
  Hive.registerAdapter(CategoryTypeAdapter());
  // if (!Hive.isAdapterRegistered(CategoryTypeAdapter().typeId)) {
  // }

  // //here we register the category name adapter if it is not registered

  Hive.registerAdapter(CategoryModelAdapter());
  // if (!Hive.isAdapterRegistered(CategoryModelAdapter().typeId)) {
  // }
  runApp(
    const MoneyTrack(),
  );
}

MaterialColor createMaterialColor(Color color) {
  List strengths = <double>[.05];
  Map<int, Color> swatch = {};
  final int r = color.red, g = color.green, b = color.blue;

  for (int i = 1; i < 10; i++) {
    strengths.add(0.1 * i);
  }
  for (var strength in strengths) {
    final double ds = 0.5 - strength;
    swatch[(strength * 1000).round()] = Color.fromRGBO(
      r + ((ds < 0 ? r : (255 - r)) * ds).round(),
      g + ((ds < 0 ? g : (255 - g)) * ds).round(),
      b + ((ds < 0 ? b : (255 - b)) * ds).round(),
      1,
    );
  }
  return MaterialColor(color.value, swatch);
}

class MoneyTrack extends StatelessWidget {
  const MoneyTrack({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: createMaterialColor(
          const Color(0xFF2E49FB),
        ),
      ),
      home: const SplashScreen(),
    );
  }
}