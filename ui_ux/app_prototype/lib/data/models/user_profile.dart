/// Benutzerprofil (reines UI-Modell).
class UserProfile {
  final String name;
  final String email;
  final String goal;
  final String region; // Hauptregion
  final List<String> regions; // alle betroffenen Regionen
  final String mobility; // Niedrig | Mittel | Hoch
  final String gender;
  final String reminder; // "08:00"

  const UserProfile({
    required this.name,
    required this.email,
    required this.goal,
    required this.region,
    this.regions = const [],
    required this.mobility,
    required this.gender,
    required this.reminder,
  });

  /// Initialen für den Header-Avatar (StyleGuide §7.8).
  String get initials {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) {
      return parts.first.substring(0, 1).toUpperCase();
    }
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1))
        .toUpperCase();
  }

  UserProfile copyWith({
    String? name,
    String? email,
    String? goal,
    String? region,
    List<String>? regions,
    String? mobility,
    String? gender,
    String? reminder,
  }) {
    return UserProfile(
      name: name ?? this.name,
      email: email ?? this.email,
      goal: goal ?? this.goal,
      region: region ?? this.region,
      regions: regions ?? this.regions,
      mobility: mobility ?? this.mobility,
      gender: gender ?? this.gender,
      reminder: reminder ?? this.reminder,
    );
  }
}
