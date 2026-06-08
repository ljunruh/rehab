from rdflib import Namespace

BASE_URI = "http://reha-app.org/"

# Instanz-URIs (z.B. http://reha-app.org/id/kraft_01)
ID = Namespace(BASE_URI + "id/")

# Ontologie-Namespace (PhysicalTherapy.owx)
PT = Namespace("http://purl.org/PhysicalTherapy#")
