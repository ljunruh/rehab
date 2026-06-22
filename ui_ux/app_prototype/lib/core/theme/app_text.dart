import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Typografie — StyleGuide Abschnitt 3.
///
/// Eine einzige Schrift: Inter. Größen in logischen Pixeln (dp).
///
/// Hinweis zur Schrift: Inter wird app-weit über `google_fonts` registriert
/// (siehe AppTheme.fontFamily / main). Dadurch können diese TextStyles wieder
/// `const` sein (sie referenzieren nur den Familiennamen 'Inter'), was an
/// vielen Stellen `const`-Konstruktoren ermöglicht und Performance spart.
class AppText {
  AppText._();

  static const String fontFamily = 'Inter';

  /// Screen-Titel — 26 dp · Medium (500) · text
  static const TextStyle screenTitle = TextStyle(
    fontSize: 26,
    fontWeight: FontWeight.w500,
    color: AppColors.text,
    height: 1.25,
  );

  /// Begrüßung im Header — 22–24 dp · SemiBold · text (§10.2)
  static const TextStyle greeting = TextStyle(
    fontSize: 23,
    fontWeight: FontWeight.w600,
    color: AppColors.text,
    height: 1.25,
  );

  /// Section-Header — 15 dp · SemiBold (600) · text
  static const TextStyle sectionHeader = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    color: AppColors.text,
    height: 1.2,
  );

  /// Card-Titel — 14 dp · SemiBold (600) · text
  static const TextStyle cardTitle = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.text,
    height: 1.3,
  );

  /// Body — 13 dp · Regular (400) · text
  static const TextStyle body = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: AppColors.text,
    height: 1.5,
  );

  /// Caption — 12 dp · Regular (400) · textSecondary
  static const TextStyle caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    height: 1.4,
  );

  /// Label / Tag — 12 dp · Medium (500) · variiert (Farbe beim Einsatz setzen)
  static const TextStyle label = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 1.2,
  );

  /// Micro / Eyebrow — 10–11 dp · SemiBold (600) · textMuted, uppercase + 0.4 tracking
  static const TextStyle micro = TextStyle(
    fontSize: 10.5,
    fontWeight: FontWeight.w600,
    color: AppColors.textMuted,
    letterSpacing: 0.4,
    height: 1.2,
  );

  /// Button-Text — 14 dp · Medium (500) · white oder sageDeep
  static const TextStyle button = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.0,
  );

  /// Sub-Text im Header — 13 dp · Regular · textSecondary (§10.2)
  static const TextStyle headerSub = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    height: 1.4,
  );
}
