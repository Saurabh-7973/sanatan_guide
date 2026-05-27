import 'package:flutter/material.dart';
import 'package:sanatan_guide/presentation/theme/app_colors.dart';
import 'package:sanatan_guide/presentation/theme/app_typography.dart';

/// ThemeData for light and dark modes. Use AppTheme.light / AppTheme.dark in MaterialApp.
abstract final class AppTheme {
  static const Color _onSaffronLight = AppColors.onSaffron;
  static const Color _onSaffronDark = Color(0xFF1A1210);

  static ThemeData get light => ThemeData(
        brightness: Brightness.light,
        useMaterial3: true,
        colorScheme: const ColorScheme.light(
          primary: AppColors.saffron,
          onPrimary: _onSaffronLight,
          secondary: AppColors.deepRed,
          onSecondary: _onSaffronLight,
          surface: AppColors.surface,
          onSurface: AppColors.textPrimary,
          onSurfaceVariant: AppColors.textSecondary,
          surfaceContainerLowest: AppColors.cream,
          surfaceContainer: AppColors.surface,
          surfaceContainerHigh: AppColors.surfaceVariant,
          surfaceTint: AppColors.saffron,
          error: AppColors.error,
          onError: _onSaffronLight,
          outline: AppColors.border,
          outlineVariant: AppColors.divider,
        ),
        textTheme: const TextTheme(
          displayLarge: AppTypography.displayLarge,
          displayMedium: AppTypography.displayMedium,
          bodyLarge: AppTypography.bodyLarge,
          bodyMedium: AppTypography.bodyMedium,
          labelLarge: AppTypography.labelLarge,
          labelMedium: AppTypography.labelMedium,
          bodySmall: AppTypography.caption,
        ),
        scaffoldBackgroundColor: AppColors.cream,
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.cream,
          foregroundColor: AppColors.textPrimary,
          elevation: 0,
          centerTitle: false,
          titleTextStyle: AppTypography.displayMedium,
        ),
        cardTheme: CardThemeData(
          color: AppColors.surface,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: AppColors.border, width: 1),
          ),
          margin: EdgeInsets.zero,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.saffron,
            foregroundColor: _onSaffronLight,
            textStyle: AppTypography.labelLarge,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            elevation: 0,
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: AppColors.deepRed,
            textStyle: AppTypography.labelMedium,
          ),
        ),
        dividerTheme: const DividerThemeData(
          color: AppColors.divider,
          thickness: 1,
          space: 1,
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: AppColors.surface,
          selectedItemColor: AppColors.saffron,
          unselectedItemColor: AppColors.textSecondary,
          elevation: 8,
          type: BottomNavigationBarType.fixed,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.surface,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AppColors.saffron, width: 2),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          hintStyle:
              AppTypography.bodyMedium.copyWith(color: AppColors.textHint),
        ),
      );

  static ThemeData get dark => ThemeData(
        brightness: Brightness.dark,
        useMaterial3: true,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.saffron,
          onPrimary: _onSaffronDark,
          secondary: Color(0xFFFF6B6B),
          onSecondary: _onSaffronDark,
          surface: AppColors.surfaceDark,
          onSurface: Color(0xFFF0EBE5),
          onSurfaceVariant: Color(0xFF9B9390),
          surfaceContainerLowest: Color(0xFF0F0F0F),
          surfaceContainer: AppColors.surfaceDark,
          surfaceContainerHigh: AppColors.surfaceElevated,
          surfaceTint: Color(0xFFE8820C),
          error: AppColors.error,
          onError: _onSaffronLight,
          outline: AppColors.borderDark,
          outlineVariant: AppColors.dividerDark,
        ),
        textTheme: TextTheme(
          displayLarge:
              AppTypography.displayLarge.copyWith(color: AppColors.textOnDark),
          displayMedium:
              AppTypography.displayMedium.copyWith(color: AppColors.textOnDark),
          bodyLarge:
              AppTypography.bodyLarge.copyWith(color: AppColors.textOnDark),
          bodyMedium:
              AppTypography.bodyMedium.copyWith(color: AppColors.textOnDark),
          labelLarge:
              AppTypography.labelLarge.copyWith(color: AppColors.textOnDark),
          labelMedium:
              AppTypography.labelMedium.copyWith(color: AppColors.textOnDark),
          bodySmall:
              AppTypography.caption.copyWith(color: const Color(0xFF9B9390)),
        ),
        scaffoldBackgroundColor: const Color(0xFF0F0F0F),
        appBarTheme: AppBarTheme(
          backgroundColor: const Color(0xFF0F0F0F),
          foregroundColor: AppColors.textOnDark,
          elevation: 0,
          centerTitle: false,
          titleTextStyle:
              AppTypography.displayMedium.copyWith(color: AppColors.textOnDark),
        ),
        cardTheme: CardThemeData(
          color: AppColors.surfaceDark,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: AppColors.borderDark, width: 1),
          ),
          margin: EdgeInsets.zero,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.saffron,
            foregroundColor: _onSaffronLight,
            textStyle: AppTypography.labelLarge,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            elevation: 0,
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: const Color(0xFFFF6B6B),
            textStyle: AppTypography.labelMedium,
          ),
        ),
        dividerTheme: const DividerThemeData(
          color: AppColors.dividerDark,
          thickness: 1,
          space: 1,
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: AppColors.surfaceDark,
          selectedItemColor: AppColors.saffron,
          unselectedItemColor: AppColors.textSecondary,
          elevation: 8,
          type: BottomNavigationBarType.fixed,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.surfaceDark,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AppColors.borderDark),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AppColors.borderDark),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AppColors.saffron, width: 2),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          hintStyle:
              AppTypography.bodyMedium.copyWith(color: AppColors.textHint),
        ),
      );
}
