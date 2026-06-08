import os
import json
import argparse
import rdflib
import owlready2

from src.vocab import VOCAB, ID, PT
from src.builders import (
    add_activity,
    add_body_part,
    link_activity_body_part,
    link_difficulty,
    link_contraindication,
    link_category,
    link_starting_position,
)

OUTPUT_DIR = "raw_data"
OUTPUT_FILE = "reha_graph.ttl"
ONTOLOGY_PATH = "ontology/PhysicalTherapy.owx"


def load_ontology(graph: rdflib.Graph, ontology_path: str):
    """
    Lädt die PhysicalTherapy-Ontologie im OWL/XML-Format mit owlready2
    und fügt sie anschließend dem rdflib-Graphen hinzu.

    Hinweis:
    rdflib.parse(..., format="xml") erwartet RDF/XML.
    Die Datei PhysicalTherapy.owx liegt jedoch als OWL/XML vor.
    Deshalb wird owlready2 verwendet.
    """
    if not os.path.exists(ontology_path):
        print(f"Warnung: Ontologie nicht gefunden unter: {ontology_path}")
        return

    print(f"Lade Ontologie von {ontology_path}...")

    ontology_file_uri = f"file://{os.path.abspath(ontology_path)}"

    world = owlready2.World()
    world.get_ontology(ontology_file_uri).load()

    ontology_graph = world.as_rdflib_graph()

    for triple in ontology_graph:
        graph.add(triple)

    print(f"Ontologie geladen. Graph enthält aktuell {len(graph)} Triples.")


def process_item(graph: rdflib.Graph, item_data: dict):
    """
    Verarbeitet ein einzelnes Übungs-Dictionary und fügt es in den Graphen ein.

    Unterstützte JSON-Felder:
    - activity_id
    - activity_name
    - category
    - difficulty
    - starting_position
    - body_parts
    - contraindications
    """

    # ----------------------------
    # Pflichtfelder prüfen
    # ----------------------------
    if "activity_id" not in item_data:
        print("[WARNUNG] Eintrag ohne activity_id übersprungen.")
        return

    if "activity_name" not in item_data:
        print(f"[WARNUNG] Eintrag '{item_data['activity_id']}' ohne activity_name übersprungen.")
        return

    # ----------------------------
    # Activity anlegen
    # ----------------------------
    activity_uri = ID[item_data["activity_id"]]
    add_activity(graph, activity_uri, item_data["activity_name"])

    # ----------------------------
    # Kategorie
    # ----------------------------
    category = item_data.get("category")
    if category:
        link_category(graph, activity_uri, category)

    # ----------------------------
    # Ausgangsstellung
    # ----------------------------
    starting_position = item_data.get("starting_position")
    if starting_position:
        link_starting_position(graph, activity_uri, starting_position)

    # ----------------------------
    # Körperteile
    # ----------------------------
    for bp in item_data.get("body_parts", []):
        if "id" not in bp or "name" not in bp:
            print(f"    [WARNUNG] Ungültiger body_part in {item_data['activity_id']}: {bp}")
            continue

        bp_uri = ID[bp["id"]]
        add_body_part(graph, bp_uri, bp["name"])
        link_activity_body_part(graph, activity_uri, bp_uri)

    # ----------------------------
    # Schwierigkeitsgrad
    # ----------------------------
    difficulty = item_data.get("difficulty")
    if difficulty:
        link_difficulty(graph, activity_uri, difficulty)

    # ----------------------------
    # Kontraindikationen
    # ----------------------------
    for condition_id in item_data.get("contraindications", []):
        link_contraindication(graph, activity_uri, condition_id)

    category = item_data.get("category")      # ← neu
    if category:
        link_category(graph, activity_uri, category)

    position = item_data.get("starting_position")   # ← neu
    if position:
        link_starting_position(graph, activity_uri, position)

    print(f"[OK] '{item_data['activity_name']}' zum Graphen hinzugefügt.")


def load_json(import_file: str):
    """
    Lädt die JSON-Datei mit Übungsdaten.
    Erwartet entweder:
    - ein einzelnes JSON-Objekt {...}
    - oder eine Liste von Objekten [...]
    """
    try:
        with open(import_file, "r", encoding="utf-8") as f:
            return json.load(f)
    except FileNotFoundError:
        print(f"Fehler: Datei '{import_file}' nicht gefunden.")
        return None
    except json.JSONDecodeError as e:
        print(f"Fehler: Datei '{import_file}' ist kein gültiges JSON.")
        print(f"JSON-Fehler: {e}")
        return None


def build_graph(data):
    """
    Erstellt den RDF-Graphen:
    - Namespaces binden
    - Ontologie laden
    - JSON-Daten in RDF-Triples überführen
    """
    g = rdflib.Graph()

    # Namespaces
    g.bind("v", VOCAB)
    g.bind("id", ID)
    g.bind("pt", PT)

    # Ontologie laden
    load_ontology(g, ONTOLOGY_PATH)

    # Daten verarbeiten
    if isinstance(data, list):
        for item in data:
            process_item(g, item)

    elif isinstance(data, dict):
        process_item(g, data)

    else:
        print("Fehler: JSON muss ein Objekt ({...}) oder ein Array ([...]) sein.")
        return None

    return g


def save_graph(graph: rdflib.Graph):
    """
    Speichert den Graphen als Turtle-Datei.
    """
    os.makedirs(OUTPUT_DIR, exist_ok=True)

    output_path = os.path.join(OUTPUT_DIR, OUTPUT_FILE)
    graph.serialize(destination=output_path, format="turtle")

    print(f"\n[Fertig] Graph enthält {len(graph)} Triples.")
    print(f"Gespeichert unter: {output_path}")


def main():
    parser = argparse.ArgumentParser(
        description="Importiert JSON-Daten in den Reha Knowledge Graph."
    )

    parser.add_argument(
        "--import",
        dest="import_file",
        required=True,
        help="Pfad zur JSON-Datei mit den Übungsdaten."
    )

    args = parser.parse_args()

    print("Starte Import in den Reha Knowledge Graph...\n")

    # JSON laden
    data = load_json(args.import_file)
    if data is None:
        return

    print(f"Verarbeite Daten aus: {args.import_file}\n")

    # Graph bauen
    graph = build_graph(data)
    if graph is None:
        return

    # Graph speichern
    save_graph(graph)


if __name__ == "__main__":
    main()