class Exercise {
  final String id;
  final String label;
  final String bodyPartLabel;

  Exercise({
    required this.id,
    required this.label,
    required this.bodyPartLabel,
  });

  // Fabrikmethode, um ein einzelnes Resultat aus dem SPARQL-JSON zu konvertieren
  factory Exercise.fromSparqlJson(Map<String, dynamic> json) {
    return Exercise(
      id: json['uebung']['value'] ?? '',
      label: json['uebungLabel']['value'] ?? '',
      bodyPartLabel: json['bodyPartLabel']['value'] ?? '',
    );
  }
}