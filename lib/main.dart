// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:money_track/provider/add_transaction_provider.dart';
import 'package:money_track/provider/category_provider.dart';
import 'package:money_track/provider/onboarding_screen.dart';
// import 'package:money_track/provider/transaction_provider.dart';

import 'package:money_track/transaction/add_transaction.dart/add_transaction.dart';
import 'package:money_track/models/categories_model/category_model.dart';

import 'package:money_track/screens/splash_screen.dart';
import 'package:money_track/core/colors.dart';
import 'package:provider/provider.dart';

import 'models/transaction_model/transaction_model.dart';
import 'provider/category_type_provider.dart';

//here main function became future because the init flutter function is a future method
Future<void> main() async {
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.black,
    ),
  );
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

  // //here we register the category name adapter if it is not registered
//category model adapter registration
//transaction model adapter registration

  Hive.registerAdapter(TransactionModelAdapter());
  if (!Hive.isAdapterRegistered(CategoryModelAdapter().typeId)) {
    Hive.registerAdapter(CategoryModelAdapter());
  }
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
  const MoneyTrack({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // ChangeNotifierProvider(
        //   create: (BuildContext context) => ProviderTransaction(),
        // ),
        ChangeNotifierProvider(
          create: (BuildContext context) => OnBoardingProvider(),
        ),
        ChangeNotifierProvider(
          create: (BuildContext context) => CategoryProvider(),
        ),
        ChangeNotifierProvider(
          create: (BuildContext context) => AddScreenProvider(),
        ),
        ChangeNotifierProvider(
          create: (BuildContext context) => CategoryTypeProvider(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          // useMaterial3: true,
          primarySwatch: createMaterialColor(
            themeDarkBlue,
          ),
        ),
        home: const SplashScreen(),
        routes: const {
          // AddTransaction.routeName: (context) => const AddTransaction(),
        },
      ),
    );
  }
}
