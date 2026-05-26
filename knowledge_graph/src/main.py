import os
import rdflib

from src.vocab import VOCAB, ID
from src.builders import (
    add_activity,
    add_body_part,
    add_injury,
    link_activity_body_part,
    link_injury_body_part
)

OUTPUT_DIR = "../raw_data"
OUTPUT_FILE = "dummy_graph.ttl"


def main():
    g = rdflib.Graph()
    g.bind("v", VOCAB)
    g.bind("id", ID)

    print("dummy in graphen erzeugen")

    # Dummy Activity

    activity_uri = ID["dummy_uebung_1"]
    add_activity(g, activity_uri, "Dummy Übung A")


    # Dummy Body Part

    body_part_uri = ID["rechter_arm"]
    add_body_part(g, body_part_uri, "Rechter Arm")

    link_activity_body_part(g, activity_uri, body_part_uri)


    # Dummy Injury

    injury_uri = ID["schulter_einschraenkung"]
    add_injury(g, injury_uri, "Schulter‑Einschränkung")

    link_injury_body_part(g, injury_uri, body_part_uri)


    # Serialize Graph

    os.makedirs(OUTPUT_DIR, exist_ok=True)
    output_path = os.path.join(OUTPUT_DIR, OUTPUT_FILE)

    g.serialize(destination=output_path, format="turtle")

    print(f" graph mit {len(g)} triples erstellt")
    print(f" gespeichert unter: {output_path}")


if __name__ == "__main__":
    main()