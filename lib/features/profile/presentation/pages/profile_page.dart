import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:money_track/core/utils/navigation_extension.dart';
import 'package:money_track/core/utils/sized_box_extension.dart';
import 'package:money_track/features/profile/domain/models/profile_model.dart';
import 'package:money_track/features/profile/domain/repositories/profile_repository.dart';
import 'package:money_track/features/profile/presentation/bloc/currency/currency_cubit.dart';
import 'package:money_track/features/profile/presentation/bloc/currency/currency_state.dart';
import 'package:money_track/features/profile/presentation/pages/about_page.dart';
import 'package:money_track/features/profile/presentation/pages/analyze_page.dart';
import 'package:money_track/features/profile/presentation/pages/currency_page.dart';
import 'package:money_track/features/profile/presentation/pages/theme_page.dart';
import 'package:money_track/features/profile/presentation/widgets/reset_drop_down.dart';
import 'package:money_track/features/profile/presentation/widgets/profile_tile.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late List<ProfileModel> _profileItems;

  @override
  void initState() {
    super.initState();
    _profileItems = _getProfileItems();

    // Load currencies when the page is opened
    context.read<CurrencyCubit>().loadCurrencies();
  }

  List<ProfileModel> _getProfileItems() {
    return [
      ProfileModel(
        title: "Analyze",
        subtitle: "",
        navigationScreen: const AnalyzePage(),
        tag: "Analyze",
        icon: Icons.analytics_outlined,
      ),
      ProfileModel(
        title: "Currency",
        subtitle: "Select Currency",
        navigationScreen: const CurrencyPage(),
        tag: "Currency",
        icon: Icons.currency_exchange,
      ),
      ProfileModel(
        title: "Theme",
        subtitle: "Light",
        navigationScreen: const ThemePage(),
        tag: "Theme",
        icon: Icons.color_lens_outlined,
      ),
      ProfileModel(
        title: "Reset",
        subtitle: "",
        navigationScreen: null,
        icon: Icons.restart_alt_outlined,
      ),
      ProfileModel(
        title: "",
        subtitle: "",
        navigationScreen: null,
      ),
      ProfileModel(
        title: "About",
        subtitle: "",
        navigationScreen: const AboutPage(),
        tag: "About",
        icon: Icons.info_outline,
      ),
      ProfileModel(
        title: "Help",
        subtitle: "",
        navigationScreen: null,
        onPressed: () => ProfileRepository().navigateToMail(),
        icon: Icons.help_outline,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Column(
          children: [
            20.height(),
            const Text(
              "Profile",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            30.height(),
            BlocListener<CurrencyCubit, CurrencyState>(
              listener: (context, state) {
                if (state is CurrenciesLoaded) {
                  // Update the currency subtitle with the selected currency
                  setState(() {
                    final currencyIndex = _profileItems.indexWhere(
                      (item) => item.tag == "Currency",
                    );
                    if (currencyIndex != -1) {
                      _profileItems[currencyIndex] = ProfileModel(
                        title: "Currency",
                        subtitle:
                            "${state.selectedCurrency.code} (${state.selectedCurrency.symbol})",
                        navigationScreen: const CurrencyPage(),
                        tag: "Currency",
                        icon: Icons.currency_exchange,
                      );
                    }
                  });
                }
              },
              child: ListView.separated(
                separatorBuilder: (context, index) => 20.height(),
                primary: false,
                shrinkWrap: true,
                itemBuilder: (context, index) => ProfileTile(
                  title: _profileItems[index].title,
                  subtitle: _profileItems[index].subtitle,
                  icon: _profileItems[index].icon,
                  onPressed: () {
                    if (_profileItems[index].navigationScreen != null) {
                      context.pushWithRightToLeftTransition(
                          _profileItems[index].navigationScreen!);
                    } else if (_profileItems[index].onPressed != null) {
                      _profileItems[index].onPressed!();
                    }
                    if (_profileItems[index].title == "Reset") {
                      showModalBottomSheet(
                        context: context,
                        builder: (context) => const ResetDropDown(),
                      );
                    }
                  },
                ),
                itemCount: _profileItems.length,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
