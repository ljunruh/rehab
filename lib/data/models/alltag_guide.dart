import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// Ein Abschnitt innerhalb eines Schonungs-Leitfadens (z.B. "Sitzen").
class GuideSection {
  final String title;
  final IconData icon;
  final String intro;
  final List<String> items;
  const GuideSection({
    required this.title,
    this.icon = Icons.watch_later_outlined,
    required this.intro,
    required this.items,
  });
}

/// Schonungs-Karte / Alltagsleitfaden ("Knie im Alltag schonen",
/// "Sanft in den Morgen"). Reine UI-Demo-Daten, kein Backend.
class AlltagGuide {
  final String id;
  final String title;
  final String tag;
  final String subtitle;
  final String region; // für Schonung-Situationskarten (Priorisierung)
  final IconData icon;
  final Color bg;
  final Color fg;
  final bool isGuide; // true = Leitfaden (hell), false = Schonungs-Karte (dunkel)
  final String? readTime;
  final List<GuideSection> sections;

  const AlltagGuide({
    required this.id,
    required this.title,
    required this.tag,
    this.subtitle = '',
    this.region = '',
    this.icon = Icons.gps_fixed,
    this.bg = AppColors.sage,
    this.fg = AppColors.white,
    this.isGuide = false,
    this.readTime,
    this.sections = const [],
  });
}
