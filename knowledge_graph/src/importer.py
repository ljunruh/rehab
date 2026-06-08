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
    link_contraindication
)

OUTPUT_DIR = "raw_data"
OUTPUT_FILE = "reha_graph.ttl"


def load_ontology(graph: rdflib.Graph, ontology_path: str):
    """
    Lädt die PhysicalTherapy-Ontologie im OWL/XML-Format mit owlready2
    und fügt sie anschließend dem rdflib-Graph hinzu.

    Hintergrund:
    rdflib.parse(..., format="xml") erwartet RDF/XML.
    Die Datei PhysicalTherapy.owx liegt jedoch in OWL/XML vor.
    """
    if not os.path.exists(ontology_path):
        print(f"Warnung: Ontologie nicht gefunden unter {ontology_path}")
        return

    print(f"Lade Ontologie von {ontology_path}...")

    ontology_file_uri = f"file://{os.path.abspath(ontology_path)}"

    world = owlready2.World()
    world.get_ontology(ontology_file_uri).load()

    ontology_graph = world.as_rdflib_graph()

    for triple in ontology_graph:
        graph.add(triple)

    print(f"Ontologie geladen. Graph enthält aktuell {len(graph)} Triples.")


def process_scraped_item(graph: rdflib.Graph, item_data: dict):
    """
    Verarbeitet ein einzelnes Übungs-Dictionary und fügt es in den Graphen ein.
    Unterstützt aktuell:
    - body_parts
    - difficulty
    - contraindications
    """
    activity_uri = ID[item_data["activity_id"]]
    add_activity(graph, activity_uri, item_data["activity_name"])

    # ----------------------------
    # Körperteile
    # ----------------------------
    for bp in item_data.get("body_parts", []):
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

    print(f"[OK] '{item_data['activity_name']}' zum Graphen hinzugefügt.")


def main():
    parser = argparse.ArgumentParser(
        description="Importiert JSON-Daten in den Reha Knowledge-Graph."
    )
    parser.add_argument(
        "--import",
        dest="import_file",
        required=True,
        help="Pfad zur JSON-Datei mit den Übungsdaten."
    )
    args = parser.parse_args()

    # ----------------------------
    # JSON laden
    # ----------------------------
    try:
        with open(args.import_file, "r", encoding="utf-8") as f:
            scraped_data = json.load(f)
    except FileNotFoundError:
        print(f"Fehler: Datei '{args.import_file}' nicht gefunden.")
        return
    except json.JSONDecodeError:
        print(f"Fehler: Datei '{args.import_file}' ist kein gültiges JSON.")
        return

    # ----------------------------
    # Graph initialisieren
    # ----------------------------
    g = rdflib.Graph()
    g.bind("v", VOCAB)
    g.bind("id", ID)
    g.bind("pt", PT)

    # ----------------------------
    # Ontologie laden
    # ----------------------------
    ontology_path = "ontology/PhysicalTherapy.owx"
    load_ontology(g, ontology_path)

    # ----------------------------
    # JSON-Daten verarbeiten
    # ----------------------------
    print(f"Verarbeite '{args.import_file}'...")

    if isinstance(scraped_data, list):
        for item in scraped_data:
            process_scraped_item(g, item)
    elif isinstance(scraped_data, dict):
        process_scraped_item(g, scraped_data)
    else:
        print("Fehler: JSON muss ein Objekt ({...}) oder Array ([...]) sein.")
        return

    # ----------------------------
    # Graph speichern
    # ----------------------------
    os.makedirs(OUTPUT_DIR, exist_ok=True)
    output_path = os.path.join(OUTPUT_DIR, OUTPUT_FILE)

    g.serialize(destination=output_path, format="turtle")

    print(f"\n[Fertig] Graph enthält {len(g)} Triples.")
    print(f"Gespeichert unter: {output_path}")


if __name__ == "__main__":
    main()