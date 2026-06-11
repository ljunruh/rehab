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
from rdflib.namespace import RDF, RDFS

import owlready2

from src.vocab import ID, PT
from src.builders import (
    add_activity,
    add_body_part,
    add_injury,
    add_patient,
    link_activity_body_part,
    link_difficulty,
    link_contraindication,
    link_injury_body_part,
    link_patient_injury,
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

    world = owlready2.World()
    world.get_ontology(str(ontology_path.resolve())).load()

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
# JSON -> RDF : Injuries and Users
# ---------------------------------------------------------------------------

def body_part_id_and_name(bp):
    if isinstance(bp, dict):
        return bp.get("id"), bp.get("name")
    return bp, None 

def process_injury(graph: rdflib.Graph, injury_data: dict) -> None:
    """
    Verarbeitet eine konkrete Verletzung.

    Erwartete Injury-Felder:
      - injury_id oder id
      - injury_name oder name
      - affected_body_parts[] mit Strings oder {"id", "name"}
      - condition optional: pt:Condition-Instanz; wird zusätzlich als pt:hasCondition gespeichert
    """
    injury_id = injury_data.get("injury_id") or injury_data.get("id")
    injury_name = injury_data.get("injury_name") or injury_data.get("name")
    if not injury_id:
        print(f"[WARNUNG] Injury ohne injury_id/id übersprungen: {injury_data}")
        return

    injury_uri = ID[injury_id]
    add_injury(graph, injury_uri, injury_name)

    affected_body_parts = injury_data.get("affected_body_parts") or injury_data.get("body_parts") or []
    for bp in affected_body_parts:
        bp_id, bp_name = body_part_id_and_name(bp)
        if not bp_id:
            print(f"    [WARNUNG] Ungültiger affected_body_part in {injury_id}: {bp}")
            continue
        bp_uri = PT[bp_id]
        if bp_name:
            add_body_part(graph, bp_uri, bp_name)
        link_injury_body_part(graph, injury_uri, bp_uri)

    condition = injury_data.get("condition")
    if condition:
        graph.add((injury_uri, PT.hasCondition, PT[condition]))

    print(f"[OK] Verletzung '{injury_id}' zum Graphen hinzugefügt.")

def process_user(graph: rdflib.Graph, user_data: dict) -> None:
    """Verarbeitet optional User/Patient-Daten und verknüpft vorhandene Injuries."""
    user_id = user_data.get("user_id") or user_data.get("id")
    user_name = user_data.get("name")
    if not user_id:
        print(f"[WARNUNG] User ohne user_id/id übersprungen: {user_data}")
        return

    user_uri = ID[user_id]
    add_patient(graph, user_uri, user_name)

    for injury_ref in user_data.get("injuries", []) or []:
        injury_id = injury_ref.get("id") if isinstance(injury_ref, dict) else injury_ref
        if injury_id:
            link_patient_injury(graph, user_uri, ID[injury_id])

    print(f"[OK] User '{user_id}' zum Graphen hinzugefügt.")

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

def _activity_items(data):
    if isinstance(data, dict) and "activities" in data:
        return data.get("activities") or []
    if isinstance(data, list):
        return data
    if isinstance(data, dict) and "activity_id" in data:
        return [data]
    return []

def _injury_items(data):
    if isinstance(data, dict) and "injuries" in data:
        return data.get("injuries") or []
    injuries = []
    for item in _activity_items(data):
        injuries.extend(item.get("injuries", []) or [])
    return injuries

def _user_items(data):
    if isinstance(data, dict) and "users" in data:
        return data.get("users") or []
    return []
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
    g.bind("rdfs",RDFS)

    # Ontologie laden
    world = load_ontology(g, ontology_path)

    # Validierung VOR dem Schreiben – strict fail
    try:
        validate_dataset(data, world)
    except ValidationError as e:
        print(f"\n{e}", file=sys.stderr)
        return None

    activity_items = _activity_items(data)
    injury_items = _injury_items(data)
    user_items = _user_items(data)

    if not activity_items and not injury_items and not user_items:
        print("Fehler: JSON enthält keine importierbaren activities/injuries/users.", file=sys.stderr)
        return None

    for item in activity_items:
        process_item(g, item)
    for injury in injury_items:
        process_injury(g, injury)
    for user in user_items:
        process_user(g, user)

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
