import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:money_track/core/constants/colors.dart';
import 'package:money_track/core/utils/navigation_extension.dart';
import 'package:money_track/core/utils/sized_box_extension.dart';
import 'package:money_track/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:money_track/features/auth/presentation/pages/login_page.dart';
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
import 'package:money_track/core/presentation/pages/sync_settings_page.dart';

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

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                context.read<AuthBloc>().add(SignOutEvent());
                // Navigate to login page
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                  (route) => false,
                );
              },
              child: Text(
                'Logout',
                style: TextStyle(
                  color: ColorConstants.getThemeColor(context),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
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
        title: "Sync Settings",
        subtitle: "Manage data synchronization",
        navigationScreen: const SyncSettingsPage(),
        tag: "Sync",
        icon: Icons.sync,
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
      ProfileModel(
        title: "Logout",
        subtitle: "",
        navigationScreen: null,
        tag: "Logout",
        icon: Icons.logout,
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
            20.height(),

            // User profile section
            BlocBuilder<AuthBloc, AuthState>(
              builder: (context, state) {
                if (state is AuthAuthenticated) {
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: ColorConstants.getThemeColor(context)
                          .withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: ColorConstants.getThemeColor(context)
                            .withValues(alpha: 0.2),
                      ),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundColor:
                              ColorConstants.getThemeColor(context),
                          child: state.user.photoUrl != null
                              ? ClipOval(
                                  child: Image.network(
                                    state.user.photoUrl!,
                                    width: 60,
                                    height: 60,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Icon(
                                        Icons.person,
                                        size: 30,
                                        color: Colors.white,
                                      );
                                    },
                                  ),
                                )
                              : const Icon(
                                  Icons.person,
                                  size: 30,
                                  color: Colors.white,
                                ),
                        ),
                        16.width(),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                state.user.displayName ?? 'User',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              4.height(),
                              Text(
                                state.user.email,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: ColorConstants.getTextColor(context)
                                      .withValues(alpha: 0.7),
                                ),
                              ),
                              if (!state.user.isEmailVerified) ...[
                                4.height(),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.orange.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Text(
                                    'Email not verified',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.orange,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
            20.height(),
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
                child: Scrollbar(
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
                      padding: const EdgeInsets.only(
                          bottom:
                              120), // Increased padding to account for bottom navigation bar (80px height + 16px bottom padding + extra space)
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
                            if (_profileItems[index].title == "Logout") {
                              _showLogoutDialog(context);
                            }
                          },
                        );
                      },
                      itemCount: _profileItems.length,
                    );
                  }),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
