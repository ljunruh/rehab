from rdflib import Literal
from rdflib.namespace import RDF, RDFS
from src.vocab import VOCAB, PT

# Entity Builders

def add_activity(graph, uri, label):
    graph.add((uri, RDF.type, VOCAB.Activity))
    graph.add((uri, RDFS.label, Literal(label, lang="de")))


def add_body_part(graph, uri, label):
    graph.add((uri, RDF.type, VOCAB.BodyPart))
    graph.add((uri, RDFS.label, Literal(label, lang="de")))


def add_injury(graph, uri, label):
    graph.add((uri, RDF.type, VOCAB.Injury))
    graph.add((uri, RDFS.label, Literal(label, lang="de")))


def add_media(graph, uri, url):
    graph.add((uri, RDF.type, VOCAB.Media))
    graph.add((uri, VOCAB.url, Literal(url)))

# Relation Builders

def link_activity_body_part(graph, activity_uri, body_part_uri):
    graph.add((activity_uri, VOCAB.involvesBodyPart, body_part_uri))


def link_injury_body_part(graph, injury_uri, body_part_uri):
    graph.add((injury_uri, VOCAB.affectsBodyPart, body_part_uri))


def link_activity_media(graph, activity_uri, media_uri):
    graph.add((activity_uri, VOCAB.hasMedia, media_uri))


# Difficulty Level Builder
DIFFICULTY_MAP = {
    "beginner":     PT["Beginner"],
    "intermediate": PT["Intermediate"],
    "advanced":     PT["Advanced"],
}

def link_difficulty(graph, activity_uri, level: str):
    """
    Verknüpft eine Aktivität mit einem Schwierigkeitsgrad.
    level: 'beginner' | 'intermediate' | 'advanced'
    """
    level_key = level.lower().strip()
    level_uri = DIFFICULTY_MAP.get(level_key)

    if level_uri:
        graph.add((activity_uri, PT.hasDifficultyLevel, level_uri))
        print(f"    [Difficulty] → {level_key}")
    else:
        print(f"    [Warnung] Unbekannter Schwierigkeitsgrad: '{level}'")


# Contraindication Builder
def link_contraindication(graph, activity_uri, condition_id: str):
    """
    Verknüpft eine Aktivität mit einer Kontraindikation aus der PT-Ontologie.
    condition_id: z.B. 'KneeIssue', 'ShoulderIssue', 'LowerBackIssue'
    """
    condition_uri = PT[condition_id]
    graph.add((activity_uri, PT.hasContraindication, condition_uri))
    print(f"    [Contraindication] → {condition_id}")