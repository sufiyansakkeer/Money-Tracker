import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

/// Base state for theme
abstract class ThemeState extends Equatable {
  const ThemeState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class ThemeInitial extends ThemeState {}

/// Loading state
class ThemeLoading extends ThemeState {}

/// State when theme is loaded
class ThemeLoaded extends ThemeState {
  final String themeName;
  final String themeMode;
  final ThemeData lightThemeData;
  final ThemeData darkThemeData;
  final ThemeMode appThemeMode;
  final Color primaryColor;
  final Color darkPrimaryColor;

  const ThemeLoaded({
    required this.themeName,
    required this.themeMode,
    required this.lightThemeData,
    required this.darkThemeData,
    required this.appThemeMode,
    required this.primaryColor,
    required this.darkPrimaryColor,
  });

  @override
  List<Object?> get props => [
        themeName,
        themeMode,
        lightThemeData,
        darkThemeData,
        appThemeMode,
        primaryColor,
        darkPrimaryColor,
      ];
}

/// Error state
class ThemeError extends ThemeState {
  final String message;

  const ThemeError({required this.message});

  @override
  List<Object?> get props => [message];
}
