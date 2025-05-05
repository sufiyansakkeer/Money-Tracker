import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:money_track/config/theme/app_themes.dart';
import 'package:money_track/core/constants/colors.dart';
import 'package:money_track/core/utils/sized_box_extension.dart';
import 'package:money_track/features/profile/presentation/bloc/theme/theme_cubit.dart';
import 'package:money_track/features/profile/presentation/bloc/theme/theme_state.dart';
import 'package:money_track/features/profile/presentation/widgets/custom_app_bar.dart';

class ThemePage extends StatefulWidget {
  const ThemePage({super.key});

  @override
  State<ThemePage> createState() => _ThemePageState();
}

class _ThemePageState extends State<ThemePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: customAppBar(context, title: "Theme"),
        body: BlocBuilder<ThemeCubit, ThemeState>(
          builder: (context, state) {
            if (state is ThemeLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is ThemeError) {
              return Center(child: Text("Error: ${state.message}"));
            }

            String selectedTheme = "";
            String selectedMode = "";
            if (state is ThemeLoaded) {
              selectedTheme = state.themeName;
              selectedMode = state.themeMode;
            }

            final themeOptions = AppThemes.getAllThemes();
            final themeModes = AppThemes.getThemeModes();

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TabBar(
                    controller: _tabController,
                    tabs: const [
                      Tab(text: "Colors"),
                      Tab(text: "Mode"),
                    ],
                    labelColor: ColorConstants.getThemeColor(context),
                    indicatorColor: ColorConstants.getThemeColor(context),
                    unselectedLabelColor: Colors.grey,
                  ),
                  20.height(),
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        // Colors Tab
                        ColorThemeTab(
                          themeOptions: themeOptions,
                          selectedTheme: selectedTheme,
                        ),

                        // Mode Tab
                        ModeThemeTab(
                          themeModes: themeModes,
                          selectedMode: selectedMode,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class ColorThemeTab extends StatelessWidget {
  final List<ThemeOption> themeOptions;
  final String selectedTheme;

  const ColorThemeTab({
    super.key,
    required this.themeOptions,
    required this.selectedTheme,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Select Color Theme",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        10.height(),
        const Text(
          "Choose a color theme for the app",
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey,
          ),
        ),
        20.height(),
        Expanded(
          child: ListView.builder(
            itemCount: themeOptions.length,
            itemBuilder: (context, index) {
              final theme = themeOptions[index];
              final isSelected = theme.name == selectedTheme;

              return ThemeOptionTile(
                theme: theme,
                isSelected: isSelected,
                onTap: () {
                  context.read<ThemeCubit>().setTheme(theme.name);
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

class ModeThemeTab extends StatelessWidget {
  final List<ThemeModeOption> themeModes;
  final String selectedMode;

  const ModeThemeTab({
    super.key,
    required this.themeModes,
    required this.selectedMode,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Select Theme Mode",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        10.height(),
        const Text(
          "Choose light, dark, or system mode",
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey,
          ),
        ),
        20.height(),
        Expanded(
          child: ListView.builder(
            itemCount: themeModes.length,
            itemBuilder: (context, index) {
              final mode = themeModes[index];
              final isSelected = mode.name == selectedMode;

              return ThemeModeOptionTile(
                mode: mode,
                isSelected: isSelected,
                onTap: () {
                  context.read<ThemeCubit>().setThemeMode(mode.name);
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

class ThemeOptionTile extends StatelessWidget {
  final ThemeOption theme;
  final bool isSelected;
  final VoidCallback onTap;

  const ThemeOptionTile({
    super.key,
    required this.theme,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final displayColor = isDarkMode ? theme.darkColor : theme.color;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 0),
      leading: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: displayColor,
          shape: BoxShape.circle,
        ),
      ),
      title: Text(
        theme.name,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          fontSize: 16,
        ),
      ),
      subtitle: Text(
        theme.description,
        style: TextStyle(
          fontSize: 14,
          color: ColorConstants.getTextColor(context).withValues(alpha: 0.6),
        ),
      ),
      trailing:
          isSelected ? Icon(Icons.check_circle, color: displayColor) : null,
      onTap: onTap,
    );
  }
}

class ThemeModeOptionTile extends StatelessWidget {
  final ThemeModeOption mode;
  final bool isSelected;
  final VoidCallback onTap;

  const ThemeModeOptionTile({
    super.key,
    required this.mode,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final themeColor = ColorConstants.getThemeColor(context);

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 0),
      leading: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: themeColor.withValues(alpha: 0.2),
          shape: BoxShape.circle,
        ),
        child: Icon(
          mode.icon,
          color: themeColor,
        ),
      ),
      title: Text(
        mode.name,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          fontSize: 16,
        ),
      ),
      subtitle: Text(
        mode.description,
        style: TextStyle(
          fontSize: 14,
          color: ColorConstants.getTextColor(context).withValues(alpha: 0.6),
        ),
      ),
      trailing: isSelected ? Icon(Icons.check_circle, color: themeColor) : null,
      onTap: onTap,
    );
  }
}
