import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:money_track/core/utils/navigation_extension.dart';
import 'package:money_track/core/utils/sized_box_extension.dart';
import 'package:money_track/features/profile/domain/models/profile_model.dart';
import 'package:money_track/features/profile/domain/repositories/profile_repository.dart';
import 'package:money_track/features/profile/presentation/bloc/currency/currency_cubit.dart';
import 'package:money_track/features/profile/presentation/bloc/currency/currency_state.dart';
import 'package:money_track/features/profile/presentation/bloc/theme/theme_cubit.dart';
import 'package:money_track/features/profile/presentation/bloc/theme/theme_state.dart';
import 'package:money_track/features/budget/presentation/pages/budget_page.dart';
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

    // Load currencies and theme when the page is opened
    context.read<CurrencyCubit>().loadCurrencies();
    context.read<ThemeCubit>().loadTheme();
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
        title: "Budget Planning",
        subtitle: "Track your spending limits",
        navigationScreen: const BudgetPage(),
        tag: "Budget",
        icon: Icons.account_balance_wallet,
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
        subtitle: "Purple",
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
      // Divider - using a special tag
      ProfileModel(
        title: "Divider",
        subtitle: "",
        navigationScreen: null,
        tag: "divider",
        icon: null,
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
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
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
            Expanded(
              child: MultiBlocListener(
                listeners: [
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
                  ),
                  BlocListener<ThemeCubit, ThemeState>(
                    listener: (context, state) {
                      if (state is ThemeLoaded) {
                        // Update the theme subtitle with the selected theme
                        setState(() {
                          final themeIndex = _profileItems.indexWhere(
                            (item) => item.tag == "Theme",
                          );
                          if (themeIndex != -1) {
                            _profileItems[themeIndex] = ProfileModel(
                              title: "Theme",
                              subtitle: state.themeName,
                              navigationScreen: const ThemePage(),
                              tag: "Theme",
                              icon: Icons.color_lens_outlined,
                            );
                          }
                        });
                      }
                    },
                  ),
                ],
                child: LayoutBuilder(builder: (context, constraints) {
                  return ListView.separated(
                    separatorBuilder: (context, index) {
                      // Don't add separator before or after divider
                      if (index > 0 &&
                          (_profileItems[index].tag == "divider" ||
                              _profileItems[index - 1].tag == "divider")) {
                        return const SizedBox.shrink();
                      }
                      return 20.height();
                    },
                    primary: false,
                    padding: const EdgeInsets.only(bottom: 20),
                    itemBuilder: (context, index) {
                      // Handle divider item
                      if (_profileItems[index].tag == "divider") {
                        return Container(
                          margin: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 20),
                          height: 1,
                          width: constraints.maxWidth,
                          color: Colors.grey.withValues(alpha: 0.3),
                        );
                      }

                      // Regular profile tile
                      return ProfileTile(
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
                      );
                    },
                    itemCount: _profileItems.length,
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
