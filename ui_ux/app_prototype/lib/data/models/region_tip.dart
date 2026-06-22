/// Ein Alltags-/Regenerationstipp, passend zu einer Körperregion.
///
/// Reines UI-Modell (kein Backend). Entspricht TIPS_BY_REGION im Prototyp.
class RegionTip {
  final String title;
  final String teaser;
  final String body;
  final String duration; // z.B. "1 Min lesen"

  const RegionTip({
    required this.title,
    required this.teaser,
    required this.body,
    required this.duration,
  });
}
