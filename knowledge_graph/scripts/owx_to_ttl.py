"""Convert PhysicalTherapy.owx -> PhysicalTherapy.ttl via owlready2.

The .owx has RDF/XML constructs (e.g. <SubClassOf> with two <Class>
children) that rdflib's strict parser rejects. owlready2 handles OWL/XML
correctly and can serialize the loaded ontology to Turtle.
"""
from pathlib import Path

import owlready2

BASE = Path(__file__).resolve().parents[1]
OWX = BASE / "ontology" / "PhysicalTherapy.owx"
OUT = BASE / "ontology" / "PhysicalTherapy.ttl"


def main() -> int:
    print(f"loading {OWX}...")
    world = owlready2.World()
    onto = world.get_ontology(OWX.resolve().as_uri()).load()
    print(f"  classes={len(list(onto.classes()))}  individuals={len(list(onto.individuals()))}")

    print(f"serializing to {OUT}...")
    onto.save(file=str(OUT), format="ntriples")
    # owlready2 only writes ntriples/plain; convert via rdflib to Turtle for
    # readability.
    import rdflib
    g = rdflib.Graph()
    g.parse(str(OUT), format="ntriples")
    g.serialize(destination=str(OUT), format="turtle")
    print(f"  triples={len(g)}  bytes={OUT.stat().st_size}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())