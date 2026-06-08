"""
Importiert JSON-Übungsdaten in den Reha Knowledge Graph.

Ablauf:
  1. JSON laden
  2. Ontologie (PhysicalTherapy.owx) via owlready2 laden
  3. Validierung: alle JSON-Werte müssen Termen der Ontologie entsprechen
  4. Items in den RDF-Graphen überführen
  5. Als Turtle-Datei serialisieren

Pfade (Ontologie, Output) sind CWD-unabhängig via __file__ aufgelöst.
"""
import argparse
import json
import sys
from pathlib import Path

import rdflib
from rdflib.namespace import RDF

import owlready2

from src.vocab import ID, PT
from src.builders import (
    add_activity,
    add_body_part,
    link_activity_body_part,
    link_difficulty,
    link_contraindication,
)
from src.validators import ValidationError, validate_dataset


# ---------------------------------------------------------------------------
# Pfade (CWD-unabhängig)
# ---------------------------------------------------------------------------

BASE_DIR = Path(__file__).resolve().parent.parent  # knowledge_graph/
ONTOLOGY_PATH = BASE_DIR / "ontology" / "PhysicalTherapy.owx"
OUTPUT_DIR = BASE_DIR / "raw_data"
OUTPUT_FILE = OUTPUT_DIR / "reha_graph.ttl"


# ---------------------------------------------------------------------------
# Ontologie-Lader
# ---------------------------------------------------------------------------

def load_ontology(graph: rdflib.Graph, ontology_path: Path) -> owlready2.World:
    """
    Lädt die PhysicalTherapy-Ontologie im OWL/XML-Format mit owlready2
    und fügt ihre Triples dem rdflib-Graphen hinzu.

    Gibt die geladene World zurück, damit der Validator sie nutzen kann.
    """
    if not ontology_path.exists():
        raise FileNotFoundError(f"Ontologie nicht gefunden: {ontology_path}")

    print(f"Lade Ontologie von {ontology_path}…")

    ontology_file_uri = ontology_path.resolve().as_uri()
    world = owlready2.World()
    world.get_ontology(ontology_file_uri).load()

    for triple in world.as_rdflib_graph():
        graph.add(triple)

    print(f"Ontologie geladen. Graph enthält aktuell {len(graph)} Triples.")
    return world


# ---------------------------------------------------------------------------
# JSON → RDF
# ---------------------------------------------------------------------------

def process_item(graph: rdflib.Graph, item_data: dict) -> None:
    """
    Verarbeitet ein einzelnes Übungs-Dictionary und fügt es in den Graphen ein.

    Erwartete JSON-Felder (alle ontology-konform):
      - activity_id
      - activity_name
      - category      (pt:Exercise-Subklasse, z.B. "StrengthExercise")
      - difficulty    ("beginner" | "intermediate" | "advanced")
      - starting_position (pt:Position-Subklasse, z.B. "Standing")
      - body_parts[]  (Liste von {"id": "<pt:BodyPart-Instanz>", "name": "..."})
      - contraindications[] (Liste von pt:Condition-Instanzen, z.B. "KneeIssue")
    """
    activity_id = item_data.get("activity_id")
    activity_name = item_data.get("activity_name")
    if not activity_id or not activity_name:
        print(f"[WARNUNG] Eintrag ohne activity_id/activity_name übersprungen: {item_data}")
        return

    # ----- Aktivität (rdf:type pt:Exercise + Klassen-Subklasse) -----
    activity_uri = ID[activity_id]
    add_activity(
        graph,
        activity_uri,
        activity_name,
        item_data["category"],
    )

    # ----- Ausgangsstellung (rdf:type pt:<Position>) -----
    position = item_data.get("starting_position")
    if position:
        graph.add((activity_uri, RDF.type, PT[position]))

    # ----- Körperteile -----
    for bp in item_data.get("body_parts", []):
        bp_id = bp.get("id")
        bp_name = bp.get("name")
        if not bp_id or not bp_name:
            print(f"    [WARNUNG] Ungültiger body_part in {activity_id}: {bp}")
            continue
        bp_uri = PT[bp_id]
        add_body_part(graph, bp_uri, bp_name)
        link_activity_body_part(graph, activity_uri, bp_uri)

    # ----- Schwierigkeitsgrad -----
    difficulty = item_data.get("difficulty")
    if difficulty:
        link_difficulty(graph, activity_uri, difficulty)

    # ----- Kontraindikationen -----
    for condition_id in item_data.get("contraindications", []):
        link_contraindication(graph, activity_uri, condition_id)

    print(f"[OK] '{activity_name}' zum Graphen hinzugefügt.")


# ---------------------------------------------------------------------------
# JSON-Loader
# ---------------------------------------------------------------------------

def load_json(import_file: str):
    """
    Lädt die JSON-Datei mit Übungsdaten.
    Erwartet entweder ein einzelnes Objekt {...} oder eine Liste von Objekten [...].
    """
    try:
        with open(import_file, "r", encoding="utf-8") as f:
            return json.load(f)
    except FileNotFoundError:
        print(f"Fehler: Datei '{import_file}' nicht gefunden.", file=sys.stderr)
        return None
    except json.JSONDecodeError as e:
        print(f"Fehler: Datei '{import_file}' ist kein gültiges JSON: {e}", file=sys.stderr)
        return None


# ---------------------------------------------------------------------------
# Graph-Orchestrierung
# ---------------------------------------------------------------------------

def build_graph(data, ontology_path: Path) -> rdflib.Graph | None:
    """
    Erstellt den RDF-Graphen:
      - Namespaces binden
      - Ontologie laden
      - Validierung gegen die Ontologie
      - JSON-Daten in RDF-Triples überführen
    """
    g = rdflib.Graph()
    g.bind("id", ID)
    g.bind("pt", PT)

    # Ontologie laden
    world = load_ontology(g, ontology_path)

    # Validierung VOR dem Schreiben – strict fail
    try:
        validate_dataset(data, world)
    except ValidationError as e:
        print(f"\n{e}", file=sys.stderr)
        return None

    # Daten verarbeiten
    if isinstance(data, list):
        for item in data:
            process_item(g, item)
    elif isinstance(data, dict):
        process_item(g, data)
    else:
        print("Fehler: JSON muss ein Objekt ({...}) oder ein Array ([...]) sein.", file=sys.stderr)
        return None

    return g


def save_graph(graph: rdflib.Graph) -> None:
    """Speichert den Graphen als Turtle-Datei (CWD-unabhängig)."""
    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)
    graph.serialize(destination=str(OUTPUT_FILE), format="turtle")
    print(f"\n[Fertig] Graph enthält {len(graph)} Triples.")
    print(f"Gespeichert unter: {OUTPUT_FILE}")


# ---------------------------------------------------------------------------
# CLI
# ---------------------------------------------------------------------------

def main() -> int:
    parser = argparse.ArgumentParser(
        description="Importiert JSON-Daten in den Reha Knowledge Graph."
    )
    parser.add_argument(
        "--import",
        dest="import_file",
        required=True,
        help="Pfad zur JSON-Datei mit den Übungsdaten.",
    )
    args = parser.parse_args()

    print("Starte Import in den Reha Knowledge Graph…\n")

    data = load_json(args.import_file)
    if data is None:
        return 1

    print(f"Verarbeite Daten aus: {args.import_file}\n")

    graph = build_graph(data, ONTOLOGY_PATH)
    if graph is None:
        return 1

    save_graph(graph)
    return 0


if __name__ == "__main__":
    sys.exit(main())
