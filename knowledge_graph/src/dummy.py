import rdflib
from rdflib import Namespace, URIRef, Literal
from rdflib.namespace import RDF, RDFS
import os

def main():
    g = rdflib.Graph()
    
    # dummies
    DUMMY_VOCAB = Namespace("http://reha-app.org/dummy-vocab#")
    DUMMY_ID = Namespace("http://reha-app.org/dummy-id/")
    
    g.bind("dv", DUMMY_VOCAB)
    g.bind("di", DUMMY_ID)

    print("dummy daten erstellen...")

    #test übung
    uebung = DUMMY_ID["dummy_uebung_1"]
    g.add((uebung, RDF.type, DUMMY_VOCAB.Activity))
    g.add((uebung, RDFS.label, Literal("dummy uebung a", lang="de")))

    #test körperteil
    rechter_arm = DUMMY_ID["dummy_rechter_arm"]
    g.add((rechter_arm, RDF.type, DUMMY_VOCAB.BodyPart))
    g.add((rechter_arm, RDFS.label, Literal("rechter arm", lang="de")))

    #zusammenfügen
    g.add((uebung, DUMMY_VOCAB.involvesBodyPart, rechter_arm))

    #dummieverletzung
    verletzung = DUMMY_ID["dummy_verletzung_schulter"]
    g.add((verletzung, RDF.type, DUMMY_VOCAB.Injury))
    g.add((verletzung, RDFS.label, Literal("schulter-einschränkung", lang="de")))
    g.add((verletzung, DUMMY_VOCAB.affectsBodyPart, rechter_arm))

    #als datei speichern, aktuell ohne server
    ausgabe_ordner = "raw_data"
    os.makedirs(ausgabe_ordner, exist_ok=True) 
    
    datei_pfad = os.path.join(ausgabe_ordner, "dummy_graph.ttl")
    
    g.serialize(destination=datei_pfad, format="turtle")
    
    print(f"es hat geklappt. graph mit {len(g)} triples wurde gespeichert unter:")
    print(f"-> {datei_pfad}")

if __name__ == "__main__":
    main()