/// Runde Region-Badge-Icons (Sophias Grafiken) je Körperregion.
///
/// Werden z. B. im Home-Starter-Karussell im runden Badge angezeigt.
/// Sophia liefert die Icons nach und nach — fehlt eins, greift der
/// neutrale Fallback (siehe Nutzungsstelle). Die deutschen Region-Namen
/// entsprechen den Demo-/Plan-Regionen (`Knie`, `Schulter`, `Rücken`, …).
class RegionIcons {
  RegionIcons._();

  static const Map<String, String> _byRegion = {
    'Schulter': 'assets/icons/regions/schulter.svg',
    'Rücken': 'assets/icons/regions/ruecken.svg',
  };

  /// Asset-Pfad des Region-Icons oder `null`, wenn (noch) keins vorliegt.
  static String? of(String region) => _byRegion[region];
}
