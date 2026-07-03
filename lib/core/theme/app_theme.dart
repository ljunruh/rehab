import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

export 'app_colors.dart';
export 'app_dimens.dart';
export 'app_text.dart';

/// Zentrales App-Theme.
///
/// Setzt Inter (über google_fonts) als app-weite Standardschrift. Die
/// TextStyles in AppText bleiben const und erben Inter automatisch über
/// das textTheme.
class AppTheme {
  AppTheme._();

  static ThemeData get light {
    final base = ThemeData.light(useMaterial3: true);

    final interTextTheme = GoogleFonts.interTextTheme(base.textTheme).apply(
      bodyColor: AppColors.text,
      displayColor: AppColors.text,
    );

    return base.copyWith(
      scaffoldBackgroundColor: AppColors.cream,
      colorScheme: const ColorScheme.light(
        primary: AppColors.sage,
        onPrimary: AppColors.white,
        secondary: AppColors.sageLight,
        onSecondary: AppColors.sageDeep,
        surface: AppColors.white,
        onSurface: AppColors.text,
        error: AppColors.alertSoft,
      ),
      textTheme: interTextTheme,
      splashFactory: NoSplash.splashFactory,
      highlightColor: Colors.transparent,
    );
  }
}
