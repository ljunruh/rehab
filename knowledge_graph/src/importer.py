import os
import json
import argparse
import rdflib

from src.vocab import VOCAB, ID
from src.builders import (
    add_activity,
    add_body_part,
    link_activity_body_part
)

# ausgabedateien deklarieren
OUTPUT_DIR = "../raw_data"
OUTPUT_FILE = "reha_graph.ttl"


def process_scraped_item(graph: rdflib.Graph, item_data: dict):
    """
    Nimmt ein Dictionary vom Scraper entgegen und wandelt es in Triples um.
    Der Importer erwartet eine .json Datei als Eingabe und es ist geplant das mit einem
    Scraper-Modul zu betreiben. Man kann aber auch manuell eine .json Datei einpflegen.
    """
    # eine übung anlegen
    activity_uri = ID[item_data["activity_id"]]
    add_activity(graph, activity_uri, item_data["activity_name"])
    
    # körperteile anlegen und verlinken
    for bp in item_data.get("body_parts", []):
        bp_uri = ID[bp["id"]]
        add_body_part(graph, bp_uri, bp["name"])
        link_activity_body_part(graph, activity_uri, bp_uri)
        
    print(f"[OK] '{item_data['activity_name']}' zum Graphen hinzugefügt.")


def main():
    # Kommandozeilen-Argumente definieren
    parser = argparse.ArgumentParser(description="Importiert JSON-Daten in den Reha Knowledge-Graph.")
    parser.add_argument(
        "--import", 
        dest="import_file", 
        required=True, 
        help="Pfad zur JSON-Datei mit den zu importierenden Daten."
    )
    args = parser.parse_args()

    # JSON-Datei einlesen
    try:
        with open(args.import_file, 'r', encoding='utf-8') as f:
            scraped_data = json.load(f)
    except FileNotFoundError:
        print(f"Fehler: Die Datei '{args.import_file}' wurde nicht gefunden.")
        return
    except json.JSONDecodeError:
        print(f"Fehler: Die Datei '{args.import_file}' ist kein gültiges JSON.")
        return
    
    # Graphen definieren
    g = rdflib.Graph()
    
    """
    Namespaces an den Graphen binden. hierbei ist es nicht erforderlich diese aus der
    Ontologie zu nutzen, weil das durch g.parse schon erledigt wird.
    """
    g.bind("v", VOCAB)
    g.bind("id", ID)

    # Ontologie laden
    ontology_path = "../ontology/PhysicalTherapy.owx"
    if os.path.exists(ontology_path):
        print(f"Lade Ontologie von {ontology_path}...")
        g.parse(ontology_path, format="xml") # import in xml
        for prefix, ns in list(g.namespaces()):
            g.bind(prefix, ns)
    else:
        print(f"Warnung: Ontologie unter {ontology_path} nicht gefunden. Starte leer.")

    # JSON-Daten in den Graphen einfügen
    print(f"Verarbeite Daten aus '{args.import_file}'...")
    if isinstance(scraped_data, list):
        for item in scraped_data:
            process_scraped_item(g, item)
    elif isinstance(scraped_data, dict):
        process_scraped_item(g, scraped_data)
    else:
        print("Fehler: Das JSON muss ein Objekt ({...}) oder ein Array ([...]) sein.")
        return

    # Den kombinierten Graphen speichern
    os.makedirs(OUTPUT_DIR, exist_ok=True)
    output_path = os.path.join(OUTPUT_DIR, OUTPUT_FILE)
    g.serialize(destination=output_path, format="turtle")

    print(f"\n[Fertig] Der Graph enthält nun insgesamt {len(g)} Triples.")
    print(f"Gespeichert unter: {output_path}")

if __name__ == "__main__":
    main()