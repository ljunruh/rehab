from rdflib import Namespace

BASE_URI = "http://reha-app.org/"

VOCAB = Namespace(BASE_URI + "vocab#")
ID = Namespace(BASE_URI + "id/")

# Ontologie-Namespace (PhysicalTherapy.owx)
PT = Namespace("http://purl.org/PhysicalTherapy#")