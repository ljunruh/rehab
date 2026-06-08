import os
import json
import argparse
import rdflib

from src.vocab import VOCAB, ID, PT
from src.builders import (
    add_activity,
    add_body_part,
    link_activity_body_part,
    link_difficulty,
    link_contraindication,
    link_category,           # ← neu
    link_starting_position   # ← neu
)

OUTPUT_DIR = "../raw_data"
OUTPUT_FILE = "reha_graph.ttl"


def process_scraped_item(graph: rdflib.Graph, item_data: dict):
    activity_uri = ID[item_data["activity_id"]]
    add_activity(graph, activity_uri, item_data["activity_name"])

    for bp in item_data.get("body_parts", []):
        bp_uri = ID[bp["id"]]
        add_body_part(graph, bp_uri, bp["name"])
        link_activity_body_part(graph, activity_uri, bp_uri)

    difficulty = item_data.get("difficulty")
    if difficulty:
        link_difficulty(graph, activity_uri, difficulty)

    for condition_id in item_data.get("contraindications", []):
        link_contraindication(graph, activity_uri, condition_id)

    category = item_data.get("category")      # ← neu
    if category:
        link_category(graph, activity_uri, category)

    position = item_data.get("starting_position")   # ← neu
    if position:
        link_starting_position(graph, activity_uri, position)

    print(f"[OK] '{item_data['activity_name']}' zum Graphen hinzugefügt.")

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--import",
        dest="import_file",
        required=True,
        help="Pfad zur JSON-Datei"
    )
    args = parser.parse_args()

    try:
        with open(args.import_file, 'r', encoding='utf-8') as f:
            scraped_data = json.load(f)
    except FileNotFoundError:
        print(f"Fehler: Datei '{args.import_file}' nicht gefunden.")
        return
    except json.JSONDecodeError:
        print(f"Fehler: '{args.import_file}' ist kein gültiges JSON.")
        return

    g = rdflib.Graph()
    g.bind("v",  VOCAB)
    g.bind("id", ID)
    g.bind("pt", PT)

    ontology_path = "../ontology/PhysicalTherapy.owx"
    if os.path.exists(ontology_path):
        print(f"Lade Ontologie von {ontology_path}...")
        g.parse(ontology_path, format="xml")
    else:
        print(f"Warnung: Ontologie nicht gefunden unter {ontology_path}")

    print(f"Verarbeite '{args.import_file}'...")

    if isinstance(scraped_data, list):
        for item in scraped_data:
            process_scraped_item(g, item)
    elif isinstance(scraped_data, dict):
        process_scraped_item(g, scraped_data)
    else:
        print("Fehler: JSON muss ein Objekt oder Array sein.")
        return

    os.makedirs(OUTPUT_DIR, exist_ok=True)
    output_path = os.path.join(OUTPUT_DIR, OUTPUT_FILE)
    g.serialize(destination=output_path, format="turtle")

    print(f"\n[Fertig] Graph enthält {len(g)} Triples.")
    print(f"Gespeichert unter: {output_path}")


if __name__ == "__main__":
    main()