"""Diagnose: warum scheitert rdflib am Parsen der .owx?"""
from pathlib import Path
import sys

OWX = Path(__file__).resolve().parents[1] / "ontology" / "PhysicalTherapy.owx"

# 1. owlready2 (das bisher ging)
try:
    from owlready2 import get_ontology
    onto = get_ontology(f"file://{OWX}").load()
    print(f"[owlready2] OK  classes={len(list(onto.classes()))}  ind={len(list(onto.individuals()))}")
except Exception as e:
    print(f"[owlready2] FAIL: {e}")

# 2. rdflib strict
try:
    import rdflib
    g = rdflib.Graph()
    g.parse(str(OWX), format="xml")
    print(f"[rdflib]     OK  triples={len(g)}")
except Exception as e:
    print(f"[rdflib]     FAIL: {type(e).__name__}: {e}")

# 3. ElementTree (nur XML well-formedness)
try:
    import xml.etree.ElementTree as ET
    ET.parse(str(OWX))
    print(f"[ET]         OK  well-formed XML")
except Exception as e:
    print(f"[ET]         FAIL: {type(e).__name__}: {e}")