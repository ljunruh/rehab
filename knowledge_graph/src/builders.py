from rdflib import Literal
from rdflib.namespace import RDF, RDFS
from src.vocab import PT


# ---------------------------------------------------------------------------
# Entity Builders
# ---------------------------------------------------------------------------

def add_activity(graph, uri, label: str, category_local_name: str):
    """
    Erzeugt eine Aktivität mit zwei rdf:type-Tripeln:
      - pt:Exercise       (Wurzelklasse)
      - pt:<Kategorie>    (Subklasse, z.B. pt:StrengthExercise)
    plus ein deutsches rdfs:label.

    category_local_name muss eine Subklasse von pt:Exercise sein
    (Aufrufer hat das via validate_dataset sichergestellt).
    """
    graph.add((uri, RDF.type, PT.Exercise))
    graph.add((uri, RDF.type, PT[category_local_name]))
    graph.add((uri, RDFS.label, Literal(label, lang="de")))


def add_body_part(graph, uri, label: str):
    """Setzt rdf:type pt:BodyPart und ein deutsches rdfs:label."""
    graph.add((uri, RDF.type, PT.BodyPart))
    graph.add((uri, RDFS.label, Literal(label, lang="de")))


# ---------------------------------------------------------------------------
# Relation Builders
# ---------------------------------------------------------------------------

def link_activity_body_part(graph, activity_uri, body_part_uri):
    """pt:engagedBodyPart (Ontologie-konform)."""
    graph.add((activity_uri, PT.engagedBodyPart, body_part_uri))


# ---------------------------------------------------------------------------
# Difficulty Builder
# ---------------------------------------------------------------------------

DIFFICULTY_MAP = {
    "beginner":     PT.Beginner,
    "intermediate": PT.Intermediate,
    "advanced":     PT.Advanced,
}


def link_difficulty(graph, activity_uri, level: str):
    """
    Verknüpft eine Aktivität mit einem Schwierigkeitsgrad
    (pt:Beginner / pt:Intermediate / pt:Advanced).
    """
    level_key = level.lower().strip()
    level_uri = DIFFICULTY_MAP.get(level_key)
    if level_uri is None:
        raise ValueError(
            f"Unknown difficulty '{level}'. "
            f"Expected one of: {sorted(DIFFICULTY_MAP)}"
        )
    graph.add((activity_uri, PT.hasDifficultyLevel, level_uri))


# ---------------------------------------------------------------------------
# Contraindication Builder
# ---------------------------------------------------------------------------

def link_contraindication(graph, activity_uri, condition_id: str):
    """
    Verknüpft eine Aktivität mit einer Kontraindikation
    (pt:hasContraindication pt:<condition_id>).
    condition_id muss eine pt:Condition-Instanz sein.
    """
    graph.add((activity_uri, PT.hasContraindication, PT[condition_id]))
