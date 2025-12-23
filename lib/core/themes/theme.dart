import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'design_tokens.dart';

// ThemeExtension để định nghĩa màu success
@immutable
class SuccessColor extends ThemeExtension<SuccessColor> {
  final Color success;

  const SuccessColor({required this.success});

  @override
  SuccessColor copyWith({Color? success}) {
    return SuccessColor(
      success: success ?? this.success,
    );
  }

  @override
  SuccessColor lerp(ThemeExtension<SuccessColor>? other, double t) {
    if (other is! SuccessColor) {
      return this;
    }
    return SuccessColor(
      success: Color.lerp(success, other.success, t)!,
    );
  }
}

class AppTheme {
  static final ThemeData lightTheme = ThemeData(
    primaryColor: FigmaColors.primary,
    scaffoldBackgroundColor: FigmaColors.background,
    textTheme: TextTheme(
      displayLarge: FigmaTextStyles.h1,
      displayMedium: FigmaTextStyles.h2,
      displaySmall: FigmaTextStyles.h3,
      headlineMedium: FigmaTextStyles.h4,
      bodyLarge: FigmaTextStyles.bodyLarge,
      bodyMedium: FigmaTextStyles.bodyMedium,
      bodySmall: FigmaTextStyles.bodySmall,
      labelLarge: FigmaTextStyles.labelLarge,
      labelMedium: FigmaTextStyles.labelMedium,
      labelSmall: FigmaTextStyles.labelSmall,
      titleLarge: FigmaTextStyles.h3,
      titleMedium: FigmaTextStyles.h4,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      titleTextStyle: FigmaTextStyles.h4,
      iconTheme: const IconThemeData(color: FigmaColors.textSecondary),
    ),
    cardTheme: CardThemeData(
      color: FigmaColors.white,
      elevation: FigmaElevation.sm,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(FigmaSpacing.radiusMd),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: FigmaColors.primary,
        foregroundColor: FigmaColors.textOnPrimary,
        minimumSize: const Size(double.infinity, FigmaSpacing.buttonHeight),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(FigmaSpacing.radiusMd),
        ),
        elevation: FigmaElevation.sm,
        textStyle: FigmaTextStyles.labelLarge,
        padding: FigmaSpacing.buttonPadding,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: FigmaColors.textPrimary,
        minimumSize: const Size(double.infinity, FigmaSpacing.buttonHeight),
        side: const BorderSide(
          color: FigmaColors.surface,
          width: 1.5,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(FigmaSpacing.radiusMd),
        ),
        textStyle: FigmaTextStyles.labelMedium,
        padding: FigmaSpacing.buttonPadding,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: FigmaColors.surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(FigmaSpacing.radiusMd),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(FigmaSpacing.radiusMd),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(FigmaSpacing.radiusMd),
        borderSide: const BorderSide(
          color: FigmaColors.primary,
          width: 2,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(FigmaSpacing.radiusMd),
        borderSide: const BorderSide(
          color: FigmaColors.error,
          width: 1.5,
        ),
      ),
      contentPadding: FigmaSpacing.inputPadding,
      hintStyle: FigmaTextStyles.hint,
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: FigmaColors.primary,
      foregroundColor: FigmaColors.textOnPrimary,
    ),
    colorScheme: ColorScheme.light(
      primary: FigmaColors.primary,
      secondary: FigmaColors.primaryDark,
      surface: FigmaColors.white,
      background: FigmaColors.background,
      error: FigmaColors.error,
      onPrimary: FigmaColors.textOnPrimary,
      onSecondary: FigmaColors.textOnPrimary,
      onSurface: FigmaColors.textPrimary,
      onBackground: FigmaColors.textPrimary,
      onError: FigmaColors.textOnPrimary,
      primaryContainer: FigmaColors.background,
      errorContainer: const Color(0xFFFFEBEE),
      brightness: Brightness.light,
    ),
    extensions: const <ThemeExtension<dynamic>>[
      SuccessColor(success: FigmaColors.success),
    ],
  );

  static final ThemeData darkTheme = ThemeData(
    primaryColor: FigmaColors.primary,
    scaffoldBackgroundColor: FigmaColors.darkBackground,
    textTheme: TextTheme(
      displayLarge: FigmaTextStyles.h1.copyWith(color: FigmaColors.white),
      displayMedium: FigmaTextStyles.h2.copyWith(color: FigmaColors.white),
      displaySmall: FigmaTextStyles.h3.copyWith(color: FigmaColors.white),
      headlineMedium: FigmaTextStyles.h4.copyWith(color: FigmaColors.white),
      bodyLarge: FigmaTextStyles.bodyLarge.copyWith(color: FigmaColors.white),
      bodyMedium: FigmaTextStyles.bodyMedium.copyWith(color: FigmaColors.textDisabled),
      bodySmall: FigmaTextStyles.bodySmall.copyWith(color: FigmaColors.textDisabled),
      labelLarge: FigmaTextStyles.labelLarge,
      labelMedium: FigmaTextStyles.labelMedium.copyWith(color: FigmaColors.white),
      labelSmall: FigmaTextStyles.labelSmall.copyWith(color: FigmaColors.textDisabled),
      titleLarge: FigmaTextStyles.h3.copyWith(color: FigmaColors.white),
      titleMedium: FigmaTextStyles.h4.copyWith(color: FigmaColors.white),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      titleTextStyle: FigmaTextStyles.h4.copyWith(color: FigmaColors.white),
      iconTheme: const IconThemeData(color: FigmaColors.textDisabled),
    ),
    cardTheme: CardThemeData(
      color: FigmaColors.darkSurface,
      elevation: FigmaElevation.sm,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(FigmaSpacing.radiusMd),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: FigmaColors.primary,
        foregroundColor: FigmaColors.textOnPrimary,
        minimumSize: const Size(double.infinity, FigmaSpacing.buttonHeight),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(FigmaSpacing.radiusMd),
        ),
        elevation: FigmaElevation.sm,
        textStyle: FigmaTextStyles.labelLarge,
        padding: FigmaSpacing.buttonPadding,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: FigmaColors.white,
        minimumSize: const Size(double.infinity, FigmaSpacing.buttonHeight),
        side: const BorderSide(
          color: FigmaColors.darkSurface,
          width: 1.5,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(FigmaSpacing.radiusMd),
        ),
        textStyle: FigmaTextStyles.labelMedium.copyWith(color: FigmaColors.white),
        padding: FigmaSpacing.buttonPadding,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: FigmaColors.darkSurface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(FigmaSpacing.radiusMd),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(FigmaSpacing.radiusMd),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(FigmaSpacing.radiusMd),
        borderSide: const BorderSide(
          color: FigmaColors.primary,
          width: 2,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(FigmaSpacing.radiusMd),
        borderSide: const BorderSide(
          color: FigmaColors.error,
          width: 1.5,
        ),
      ),
      contentPadding: FigmaSpacing.inputPadding,
      hintStyle: FigmaTextStyles.hint.copyWith(color: FigmaColors.textTertiary),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: FigmaColors.primary,
      foregroundColor: FigmaColors.textOnPrimary,
    ),
    colorScheme: ColorScheme.dark(
      primary: FigmaColors.primary,
      secondary: FigmaColors.primaryDark,
      surface: FigmaColors.darkSurface,
      background: FigmaColors.darkBackground,
      error: FigmaColors.error,
      onPrimary: FigmaColors.textOnPrimary,
      onSecondary: FigmaColors.textOnPrimary,
      onSurface: FigmaColors.white,
      onBackground: FigmaColors.white,
      onError: FigmaColors.textOnPrimary,
      primaryContainer: FigmaColors.darkSurface,
      errorContainer: const Color(0xFF4A2A2A),
      brightness: Brightness.dark,
    ),
    extensions: const <ThemeExtension<dynamic>>[
      SuccessColor(success: FigmaColors.success),
    ],
  );
}