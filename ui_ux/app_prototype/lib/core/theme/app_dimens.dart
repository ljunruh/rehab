import 'package:flutter/animation.dart';

/// Abstände & Layout — StyleGuide Abschnitt 4.
///
/// Basis-Einheit 8 dp, alle Werte Vielfache von 4 dp.
class AppSpacing {
  AppSpacing._();

  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double base = 16;
  static const double lg = 20;
  static const double xl = 24;

  /// Horizontales Bildschirm-Padding (links + rechts)
  static const double screenH = 20;

  /// Card-Innenabstand (16–22, Standardwert)
  static const double cardPadding = 18;

  /// Abstand zwischen Cards (Section-Gap 18–22)
  static const double sectionGap = 20;

  /// Item-Abstand innerhalb von Cards (8–14)
  static const double itemGap = 12;

  /// Icon-zu-Label-Abstand (6–8)
  static const double iconLabelGap = 8;

  /// Bottom-Nav-Höhe (+ Safe Area)
  static const double bottomNavHeight = 64;

  /// Top-Header-Höhe (+ Statusleiste)
  static const double topHeaderHeight = 56;

  /// Padding unter dem letzten scrollbaren Element
  static const double scrollBottom = 24;
}

/// Border-Radius — StyleGuide Abschnitt 5.
class AppRadius {
  AppRadius._();

  /// Cards (Standard)
  static const double card = 22;

  /// Primär-Buttons (voll gerundet)
  static const double buttonPrimary = 24;

  /// Sekundär-Buttons
  static const double buttonSecondary = 22;

  /// Chips / Tags / Badges (Pill)
  static const double pill = 999;

  /// Icon-Container (klein)
  static const double iconSmall = 12;

  /// Icon-Container (groß)
  static const double iconLarge = 16;

  /// Eingabefelder
  static const double input = 14;

  /// Modal / Bottom-Sheet (obere Ecken)
  static const double sheet = 24;

  /// Toast
  static const double toast = 16;
}

/// Icon-Größen — StyleGuide Abschnitt 8.
class AppIconSize {
  AppIconSize._();

  static const double defaultSize = 20;
  static const double nav = 22;
  static const double button = 16;
  static const double cardIllustration = 24;
  static const double info = 14;

  static const double strokeDefault = 1.5;
  static const double strokeActive = 2.0;
  static const double strokeAction = 2.5;
}

/// Bewegung & Animation — StyleGuide Abschnitt 9.
class AppMotion {
  AppMotion._();

  /// Standard-Transition 150–200 ms
  static const Duration standard = Duration(milliseconds: 180);

  /// Screen-Entry / Drawer 320 ms
  static const Duration screenEntry = Duration(milliseconds: 320);

  /// Chevron-Rotation 250 ms
  static const Duration chevron = Duration(milliseconds: 250);

  /// Toggle / Switch 200 ms
  static const Duration toggle = Duration(milliseconds: 200);

  /// Toast-Auto-Dismiss
  static const Duration toastDuration = Duration(milliseconds: 2400);

  // ── Kurven ──────────────────────────────────────────────────
  /// Standard ease-out
  static const Curve easeOut = Curves.easeOut;

  /// Screen-Entry: custom cubic (0.16, 1, 0.3, 1) — "expo out"
  static const Curve expoOut = Cubic(0.16, 1, 0.3, 1);

  /// Spring/Bounce (Chips): cubic (0.34, 1.56, 0.64, 1)
  static const Curve spring = Cubic(0.34, 1.56, 0.64, 1);
}
