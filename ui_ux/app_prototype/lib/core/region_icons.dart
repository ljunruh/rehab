import 'package:app_prototype/data/enum/body_part.dart';

/// Runde Region-Badge-Icons je Körperregion.
///
/// Werden z. B. im Home-Starter-Karussell im runden Badge angezeigt.
/// Schlüssel ist der englische Enum-Name (`BodyPart.name`, z. B. `shoulders`,
/// `lowerBack`), damit `RegionIcons.of(region.name)` direkt passt.
class RegionIcons {
  RegionIcons._();

  static const Map<String, String> _byRegion = {
    'ankles': 'assets/icons/regions/ankles.svg',
    'arms': 'assets/icons/regions/arms.svg',
    'back': 'assets/icons/regions/back.svg',
    'biceps': 'assets/icons/regions/biceps.svg',
    'calves': 'assets/icons/regions/calves.svg',
    'chest': 'assets/icons/regions/chest.svg',
    'core': 'assets/icons/regions/core.svg',
    'elbows': 'assets/icons/regions/elbows.svg',
    'glutes': 'assets/icons/regions/glutes.svg',
    'hamstrings': 'assets/icons/regions/hamstrings.svg',
    'hip': 'assets/icons/regions/hip.svg',
    'knees': 'assets/icons/regions/knees.svg',
    'legs': 'assets/icons/regions/legs.svg',
    'lowerBack': 'assets/icons/regions/lowerback.svg',
    'neck': 'assets/icons/regions/neck.svg',
    'obliques': 'assets/icons/regions/obliques.svg',
    'pelvic': 'assets/icons/regions/pelvic.svg',
    'psoas': 'assets/icons/regions/psoas.svg',
    'quadriceps': 'assets/icons/regions/quadriceps.svg',
    'shoulders': 'assets/icons/regions/shoulders.svg',
    'spine': 'assets/icons/regions/spine.svg',
    'thighs': 'assets/icons/regions/thighs.svg',
    'triceps': 'assets/icons/regions/triceps.svg',
    'upperBack': 'assets/icons/regions/upperback.svg',
    'wrists': 'assets/icons/regions/wrists.svg',
  };

  /// Asset-Pfad des Region-Icons oder `null`, wenn (noch) keins vorliegt
  /// (z. B. für `BodyPart.none`).
  static String? of(String region) => _byRegion[region];

  /// Bequemer Zugriff direkt über den BodyPart-Enum-Wert.
  static String? forBodyPart(BodyPart part) => of(part.name);
}
