import 'package:flutter/material.dart';

/// Farb-Tokens der Reha App.
///
/// Quelle: StyleGuide Abschnitt 2 (Colour Tokens) und Abschnitt 11
/// (Plan Calendar Colours).
///
/// WICHTIG (StyleGuide §14 "Do & Don't"):
/// Niemals Hex-Werte direkt in Widgets schreiben — immer diese Tokens
/// per Namen referenzieren.
class AppColors {
  AppColors._();

  // ── 2.1 Core Palette ─────────────────────────────────────────
  /// App-Hintergrund / Seitenfüllung
  static const Color cream = Color(0xFFEFF4F2);

  /// Erhöhte Fläche (Cards auf cream)
  static const Color offwhite = Color(0xFFF7FAF9);

  /// Höchste Fläche (Inputs, Modals)
  static const Color white = Color(0xFFFFFFFF);

  /// Trenner, Rahmen, inaktive Zustände
  static const Color beige = Color(0xFFDFEAE6);

  /// Akzentfüllungen, Icon-Hintergründe
  static const Color mint = Color(0xFFC2DED7);

  /// Chip-Hintergründe, aktive Pill-Tönung
  static const Color sageLight = Color(0xFFD2E7E1);

  /// Primäre Aktionsfarbe (Buttons, Toggles)
  static const Color sage = Color(0xFF2F7E72);

  /// Pressed-Zustand für primäre Aktionen
  static const Color sageMid = Color(0xFF27665D);

  /// Dunkle Fläche (Tipp-Card, Nav-Bar, Toasts)
  static const Color sageDeep = Color(0xFF1F4E47);

  /// Primärer Text
  static const Color text = Color(0xFF17241F);

  /// Labels, Captions, sekundäre Info
  static const Color textSecondary = Color(0xFF5C6B65);

  /// Placeholder, disabled, dezente Hinweise
  static const Color textMuted = Color(0xFF93A39D);

  /// Warn-/Achtung-Akzent
  static const Color alertSoft = Color(0xFFE9C2B0);

  // ── 12. Dark Surface (sageDeep) Hilfsfarben ──────────────────
  /// Sekundärtext auf dunkler Fläche
  static const Color onDarkSecondary = Color(0xA6FFFFFF); // rgba(255,255,255,0.65)
  /// Trenner auf dunkler Fläche
  static const Color onDarkDivider = Color(0x26FFFFFF); // rgba(255,255,255,0.15)
  /// Icon-Tint-Hintergrund auf dunkler Fläche
  static const Color onDarkIconBg = Color(0x26FFFFFF); // rgba(255,255,255,0.15)

  // ── 6. Elevation (einzige erlaubte Schatten) ─────────────────
  static const Color navShadow = Color(0x14000000); // rgba(0,0,0,0.08)
  static const Color avatarShadow = Color(0x1F3F5E48); // rgba(63,94,72,0.12)
  static const Color toastShadow = Color(0x2E1F2421); // rgba(31,36,33,0.18)
}

/// 11. Plan Calendar Colours.
///
/// Diese 9 Farben sind fix — NICHT aus den Core-Tokens ableiten.
/// Als Tag dargestellt: Hintergrund = Plan-Farbe, Text = weiß.
class PlanColors {
  PlanColors._();

  static const Color terrakotta = Color(0xFFCC7E63);
  static const Color sand = Color(0xFFC49A5A);
  static const Color gold = Color(0xFFE8B84B);
  static const Color olive = Color(0xFF9CA86B);
  static const Color marine = Color(0xFF3A5A8C);
  static const Color tuerkis = Color(0xFF2F7E72);
  static const Color petrol = Color(0xFF3E8DA6);
  static const Color lila = Color(0xFFA67BB5);
  static const Color koralle = Color(0xFFD95F5F);

  /// Reihenfolge wie im StyleGuide — für Farbauswahl-Picker.
  static const List<Color> all = [
    terrakotta,
    sand,
    gold,
    olive,
    marine,
    tuerkis,
    petrol,
    lila,
    koralle,
  ];

  static const Map<String, Color> byName = {
    'Terrakotta': terrakotta,
    'Sand': sand,
    'Gold': gold,
    'Olive': olive,
    'Marine': marine,
    'Türkis': tuerkis,
    'Petrol': petrol,
    'Lila': lila,
    'Koralle': koralle,
  };
}
