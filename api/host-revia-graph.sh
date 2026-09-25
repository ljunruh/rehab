cat << 'EOF' > ~/host-revia-graph.sh
#!/bin/bash

# In das Fuseki-Verzeichnis wechseln
cd ~/fuseki || { echo "Fehler: Verzeichnis ~/fuseki nicht gefunden!"; exit 1; }

echo "Starte Fuseki Server mit PhysicalTherapy.ttl..."

# Fuseki Server starten
./fuseki-server --file=../ontologie/PhysicalTherapy.ttl /rehab
EOF
