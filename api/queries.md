# SPARQL Abfragen

Diese Sammlung enthält SPARQL-Queries zur Abfrage von Daten für die Rehab-App.
<b>Queries die aktiv in der App genutzt werden durch "🟢 PROD QUERY" gekennzeichnet.</b>

---

## Übungen

### Alle Übungen

Diese Abfrage liefert alle Instanzen von `rehab:Exercise` sowie rekursive aller Subklassen davon. Zusätzlich werden optionale Metadaten wie `rdfs:label` und `rdfs:comment` ausgegeben, sofern vorhanden.

```sparql
SELECT DISTINCT ?exercise ?label ?comment WHERE {
    ?exercise a/rdfs:subClassOf* rehab:Exercise .
    OPTIONAL { ?exercise rdfs:label ?label . }
    OPTIONAL { ?exercise rdfs:comment ?comment . }
}
```


### Planempfehlung – Übersichtsquery (vollständige Exercise-Details)

Diese Abfrage liefert alle Übungen mit ihren zentralen Eigenschaften für die Planempfehlung. Dazu gehören Schwierigkeit, Kontraindikationen, Trainingseffekte sowie beanspruchte Körperbereiche. Zusätzlich werden Labels für eine bessere Darstellung in der App geladen.

```sparql
SELECT DISTINCT ?exercise ?difficulty ?label ?clabel ?tlabel ?blabel
WHERE {
    ?exercise a/rdfs:subClassOf* rehab:Exercise ;
              rehab:hasDifficultyLevel ?difficulty ;
              rehab:hasContraindication ?contra ;
              rehab:improves ?trainingsEffect ;
              rehab:engagedBodyPart ?bodyPart .

    ?contra a rehab:Injury .
    ?contra rdfs:label ?clabel .

    ?trainingsEffect a rehab:TrainingsEffect .
    ?trainingsEffect rdfs:label ?tlabel .

    ?bodyPart a rehab:BodyPart .
    ?bodyPart rdfs:label ?blabel .

    OPTIONAL { ?exercise rdfs:label ?label }
    OPTIONAL { ?exercise rdfs:comment ?comment }
}
```

### Planempfehlung – Gefilterte Exercises (Input-basiert)

Diese Abfrage filtert Übungen basierend auf vorgegebenen Kriterien wie Schwierigkeit, Trainingseffekt und Körperregion. Zusätzlich werden bestimmte Kontraindikationen ausgeschlossen (z. B. Schulter- oder Wirbelsäulenprobleme).

```sparql
SELECT DISTINCT
    ?exercise 
    ?exerciseLabel 
    ?difficultyLabel
    ?contraindicationLabel 
    ?trainingsEffectLabel 
    ?bodyPartLabel
WHERE {
    VALUES ?difficulty { rehab:Beginner rehab:Intermediate }

    VALUES ?trainingsEffect {
        rehab:Balance rehab:Coordination rehab:Flexibility rehab:Focus
        rehab:Mobility rehab:Posture rehab:Relaxation rehab:Stability
    }

    VALUES ?bodyPart {
        rehab:Ankles rehab:Arms rehab:Back rehab:Biceps rehab:Calves
        rehab:Chest rehab:Core rehab:Elbows rehab:Glutes rehab:Hamstrings
        rehab:Hip rehab:Knees rehab:Legs rehab:LowerBack rehab:Neck
        rehab:Obliques rehab:Pelvic rehab:Psoas rehab:Quadriceps
        rehab:Shoulders rehab:Spine rehab:Thighs rehab:Triceps rehab:Wrists
    }

    ?exercise a/rdfs:subClassOf* rehab:Exercise ;
              rehab:hasDifficultyLevel ?difficulty ;
              rehab:hasContraindication ?contraindication ;
              rehab:improves ?trainingsEffect ;
              rehab:engagedBodyPart ?bodyPart .

    ?contraindication a rehab:Injury .
    ?contraindication rdfs:label ?contraindicationLabel .

    ?trainingsEffect a rehab:TrainingsEffect .
    ?trainingsEffect rdfs:label ?trainingsEffectLabel .

    ?bodyPart a rehab:BodyPart .
    ?bodyPart rdfs:label ?bodyPartLabel .

    FILTER NOT EXISTS {
        VALUES ?selectedInjury { rehab:ShoulderIssue rehab:SpineIssue }
        ?exercise rehab:hasContraindication ?selectedInjury
    }

    OPTIONAL { ?exercise rdfs:label ?exerciseLabel }

    BIND(REPLACE(STR(?difficulty), "^.*[#/]", "") AS ?difficultyLabel)
}
```


### Planempfehlung – Aggregierte JSON-freundliche Ausgabe

Diese Variante gruppiert Mehrfachwerte (Kontraindikationen, Trainingseffekte, Körperbereiche) in kommagetrennte Strings, um sie einfacher in der App als strukturierte JSON-Felder weiterzuverarbeiten.

```sparql
SELECT
    ?exercise 
    ?exerciseLabel
    ?difficultyLabel
    (GROUP_CONCAT(DISTINCT ?contraindicationLabel; separator=", ") AS ?contraindications)
    (GROUP_CONCAT(DISTINCT ?trainingsEffectLabel; separator=", ") AS ?trainingsEffects)
    (GROUP_CONCAT(DISTINCT ?bodyPartLabel; separator=", ") AS ?bodyParts)
WHERE {
    VALUES ?difficulty { rehab:Beginner rehab:Intermediate }

    VALUES ?trainingsEffect {
        rehab:Balance rehab:Coordination rehab:Flexibility rehab:Focus
        rehab:Mobility rehab:Posture rehab:Relaxation rehab:Stability
    }

    VALUES ?bodyPart {
        rehab:Ankles rehab:Arms rehab:Back rehab:Biceps rehab:Calves
        rehab:Chest rehab:Core rehab:Elbows rehab:Glutes rehab:Hamstrings
        rehab:Hip rehab:Knees rehab:Legs rehab:LowerBack rehab:Neck
        rehab:Obliques rehab:Pelvic rehab:Psoas rehab:Quadriceps
        rehab:Shoulders rehab:Spine rehab:Thighs rehab:Triceps rehab:Wrists
    }

    ?exercise a/rdfs:subClassOf* rehab:Exercise ;
              rehab:hasDifficultyLevel ?difficulty ;
              rehab:hasContraindication ?contraindication ;
              rehab:improves ?trainingsEffect ;
              rehab:engagedBodyPart ?bodyPart .

    ?contraindication a rehab:Injury .
    ?contraindication rdfs:label ?contraindicationLabel .

    ?trainingsEffect a rehab:TrainingsEffect .
    ?trainingsEffect rdfs:label ?trainingsEffectLabel .

    ?bodyPart a rehab:BodyPart .
    ?bodyPart rdfs:label ?bodyPartLabel .

    FILTER NOT EXISTS {
        VALUES ?selectedInjury { rehab:ShoulderIssue rehab:SpineIssue }
        ?exercise rehab:hasContraindication ?selectedInjury
    }

    OPTIONAL { ?exercise rdfs:label ?exerciseLabel }

    BIND(REPLACE(STR(?difficulty), "^.*[#/]", "") AS ?difficultyLabel)
}
GROUP BY ?exercise ?exerciseLabel ?difficultyLabel
```


### Gefilterte Planempfehlung mit vollständigen Exercise-Details

Diese Abfrage liefert gefilterte Übungen basierend auf Schwierigkeit, Trainingszielen und Körperbereichen. Zusätzlich werden sowohl Objekt-Properties (z. B. Contraindications, BodyParts) als auch Data-Properties (z. B. Beschreibung, Dauer, Instruktionen) für die Darstellung in der App geladen und teilweise aggregiert.

```sparql
SELECT
	?exercise 
	?exerciseLabel
	?difficultyLabel
	# Verpack alle Values der Property in einem Value
	(GROUP_CONCAT(DISTINCT ?contraindicationLabel; separator=" | ") AS ?contraindications)
	(GROUP_CONCAT(DISTINCT ?trainingsEffectLabel; separator=" | ") AS ?trainingsEffects)
	(GROUP_CONCAT(DISTINCT ?bodyPartLabel; separator=" | ") AS ?bodyParts)
	?description
	?duration
	?instruction
	(GROUP_CONCAT(DISTINCT ?correction; separator=" | ") AS ?corrections)
	(GROUP_CONCAT(DISTINCT ?mistake; separator=" | ") AS ?mistakes)
WHERE {
  	#rehab:Advanced -> keine Profi Übungen
    VALUES ?difficulty { rehab:Beginner rehab:Intermediate rehab:Advanced }
  	#rehab:Strength -> Übungen die kein Strength Ziel haben
  	VALUES ?trainingsEffect { rehab:Balance rehab:Coordination rehab:Flexibility rehab:Focus rehab:Mobility rehab:Posture rehab:Relaxation rehab:Stability }
  	#rehab:UpperBack -> Übungen die den UpperBack nicht beanspruchen
  	VALUES ?bodyPart { rehab:Ankles rehab:Arms rehab:Back rehab:Biceps rehab:Calves rehab:Chest rehab:Core rehab:Elbows rehab:Glutes rehab:Hamstrings rehab:Hip rehab:Knees rehab:Legs rehab:LowerBack rehab:Neck rehab:Obliques rehab:Pelvic rehab:Psoas rehab:Quadriceps rehab:Shoulders rehab:Spine rehab:Thighs rehab:Triceps rehab:Wrists }
  
  	# Filter auf Übungen anhand übergebener VALUES Parameter
    ?exercise a/rdfs:subClassOf* rehab:Exercise ;
              rehab:hasDifficultyLevel ?difficulty ;
  			  rehab:hasContraindication ?contraindication;
       		  rehab:improves ?trainingsEffect ;
  			  rehab:engagedBodyPart ?bodyPart .
	?contraindication a rehab:Contraindication .
	?contraindication rdfs:label ?contraindicationLabel .
  	?trainingsEffect a rehab:TrainingsEffect .
  	?trainingsEffect rdfs:label ?trainingsEffectLabel .
  	?bodyPart a rehab:BodyPart .
  	?bodyPart rdfs:label ?bodyPartLabel .

  	FILTER NOT EXISTS {
    	VALUES ?selectedContraindication { rehab:ShoulderIssue } # -> Übungen rausnehmen die diese Problemzonen beanspruchen würden
    	?exercise rehab:hasContraindication ?selectedContraindication
  	}
  
  	# Text Properties zur Übungsbeschreibung
  	OPTIONAL { ?exercise rdfs:label ?exerciseLabel }
  	OPTIONAL { ?exercise rehab:hasDescription ?description }
  	OPTIONAL { ?exercise rehab:duration ?duration }
  	OPTIONAL { ?exercise rehab:hasInstruction ?instruction }
  	OPTIONAL { ?exercise rehab:hasCorrectionGuidance ?correction }
  	OPTIONAL { ?exercise rehab:hasCommonMistake ?mistake }
    
  	#Erstelle aus einer URI ein Labelersatz: http://purl.org/PhysicalTherapy#Deadlift -> Deadlift 
  	BIND(REPLACE(STR(?difficulty), "^.*[#/]", "") AS ?difficultyLabel)
} GROUP BY
    ?exercise
    ?exerciseLabel
    ?difficultyLabel
    ?description
    ?duration
    ?instruction
    ?corrections
    ?mistakes
```


## Planerstellung

### 🟢 PROD QUERY – Planerstellung – Filter nach Contraindications

Diese Abfrage liefert alle Übungen im Datenformat der App und filtert dabei Übungen heraus, die aufgrund der übergebenen Kontraindikationen nicht geeignet sind.

Die Abfrage stellt sicher, dass nur Übungen mit den für die App erforderlichen Objekt-Properties zurückgegeben werden. Zusätzlich werden Mehrfachwerte wie Kontraindikationen, Trainingseffekte, beanspruchte Körperbereiche, Korrekturhinweise und typische Fehler zu einem einzelnen String zusammengefasst, sodass sie einfach als JSON verarbeitet werden können.

```sparql
SELECT
    ?exercise
    ?exerciseLabel
    ?difficultyLabel
    ?duration
    ?instruction
    # Verpackt alle Values der Property in einem Value
    (GROUP_CONCAT(DISTINCT ?contraindicationLabel; separator=" | ") AS ?contraindications)
    (GROUP_CONCAT(DISTINCT ?trainingsEffectLabel; separator=" | ") AS ?trainingsEffects)
    (GROUP_CONCAT(DISTINCT ?bodyPartLabel; separator=" | ") AS ?bodyParts)
    (GROUP_CONCAT(DISTINCT ?correction; separator=" | ") AS ?corrections)
    (GROUP_CONCAT(DISTINCT ?mistake; separator=" | ") AS ?mistakes)
WHERE {

    # Filter für alle Übungen, die diese Object Properties besitzen müssen.
    # Übungen ohne diese Properties führen in der App zu unvollständigen Daten.
    ?exercise a/rdfs:subClassOf* rehab:Exercise ;
              rehab:hasDifficultyLevel ?difficulty ;
              rehab:hasContraindication ?contraindication ;
              rehab:improves ?trainingsEffect ;
              rehab:engagedBodyPart ?bodyPart .

    ?contraindication a rehab:Contraindication .
    ?trainingsEffect a rehab:TrainingsEffect .
    ?bodyPart a rehab:BodyPart .

    # Entfernt Übungen, deren Kontraindikationen mit den
    # vom Benutzer angegebenen Einschränkungen kollidieren.
    FILTER NOT EXISTS {
        VALUES ?selectedContraindication {
            rehab:AnkleIssue
            rehab:NeckIssue
        }
        ?exercise rehab:hasContraindication ?selectedContraindication
    }

    # Pflichtfelder
    ?contraindication rdfs:label ?contraindicationLabel .
    ?trainingsEffect rdfs:label ?trainingsEffectLabel .
    ?bodyPart rdfs:label ?bodyPartLabel .
    ?exercise rehab:hasInstruction ?instruction .

    # Aktuell optionale Felder (sollen später Pflichtfelder werden)
    OPTIONAL { ?exercise rehab:duration ?duration }
    OPTIONAL { ?exercise rdfs:label ?exerciseLabel }

    # Optionale Zusatzinformationen
    OPTIONAL { ?exercise rehab:hasCorrectionGuidance ?correction }
    OPTIONAL { ?exercise rehab:hasCommonMistake ?mistake }

    # Extrahiert den lokalen Namen der Difficulty-URI
    BIND(REPLACE(STR(?difficulty), "^.*[#/]", "") AS ?difficultyLabel)
}
GROUP BY
    ?exercise
    ?exerciseLabel
    ?difficultyLabel
    ?contraindications
    ?trainingsEffects
    ?bodyParts
    ?duration
    ?instruction
    ?corrections
    ?mistakes
```


## Planempfehlung

### 🟢 PROD QUERY – Planempfehlung – Filter nach Trainingslevel, Trainingseffekt, Körperbereich und Contraindications

Diese Abfrage liefert alle Übungen im Datenformat der App und filtert sie anhand der vom Benutzer ausgewählten Trainingsparameter. Berücksichtigt werden das Trainingslevel, gewünschte Trainingseffekte, beanspruchte Körperbereiche sowie vorhandene Kontraindikationen.

Nur Übungen, die alle erforderlichen Objekt-Properties besitzen und mit den angegebenen Einschränkungen kompatibel sind, werden zurückgegeben. Mehrfachwerte werden für eine einfache Weiterverarbeitung in der App zu einem String zusammengefasst.

```sparql
SELECT
    ?exercise
    ?exerciseLabel
    ?difficultyLabel
    ?duration
    ?instruction

    # Verpackt alle Values der Property in einem Value
    (GROUP_CONCAT(DISTINCT ?contraindicationLabel; separator=" | ") AS ?contraindications)
    (GROUP_CONCAT(DISTINCT ?trainingsEffectLabel; separator=" | ") AS ?trainingsEffects)
    (GROUP_CONCAT(DISTINCT ?bodyPartLabel; separator=" | ") AS ?bodyParts)
    (GROUP_CONCAT(DISTINCT ?correction; separator=" | ") AS ?corrections)
    (GROUP_CONCAT(DISTINCT ?mistake; separator=" | ") AS ?mistakes)

WHERE {

    # Filterparameter (werden zur Laufzeit übergeben)

    # Trainingslevel
    VALUES ?difficulty {
        rehab:Beginner
        rehab:Intermediate
    }

    # Gewünschte Trainingseffekte
    VALUES ?trainingsEffect {
        rehab:Balance
        rehab:Coordination
        rehab:Flexibility
        rehab:Focus
        rehab:Mobility
        rehab:Posture
        rehab:Relaxation
        rehab:Stability
        rehab:Strength
    }

    # Gewünschte Körperbereiche
    VALUES ?bodyPart {
        rehab:Ankles rehab:Arms rehab:Back rehab:Biceps rehab:Calves
        rehab:Chest rehab:Core rehab:Elbows rehab:Glutes rehab:Hamstrings
        rehab:Hip rehab:Knees rehab:Legs rehab:LowerBack rehab:Neck
        rehab:Obliques rehab:Pelvic rehab:Psoas rehab:Quadriceps
        rehab:Shoulders rehab:Spine rehab:Thighs rehab:Triceps rehab:Wrists
        rehab:UpperBack
    }

    # Übungen müssen alle benötigten Object Properties besitzen
    ?exercise a/rdfs:subClassOf* rehab:Exercise ;
              rehab:hasDifficultyLevel ?difficulty ;
              rehab:hasContraindication ?contraindication ;
              rehab:improves ?trainingsEffect ;
              rehab:engagedBodyPart ?bodyPart .

    ?contraindication a rehab:Contraindication .
    ?trainingsEffect a rehab:TrainingsEffect .
    ?bodyPart a rehab:BodyPart .

    # Entfernt Übungen, die mit den angegebenen Contraindications kollidieren
    FILTER NOT EXISTS {
        VALUES ?selectedContraindication {
            rehab:AnkleIssue
            rehab:NeckIssue
        }
        ?exercise rehab:hasContraindication ?selectedContraindication
    }

    # Pflichtfelder
    ?contraindication rdfs:label ?contraindicationLabel .
    ?trainingsEffect rdfs:label ?trainingsEffectLabel .
    ?bodyPart rdfs:label ?bodyPartLabel .
    ?exercise rehab:hasInstruction ?instruction .

    # Aktuell optionale Felder (sollen später Pflichtfelder werden)
    OPTIONAL { ?exercise rehab:duration ?duration }
    OPTIONAL { ?exercise rdfs:label ?exerciseLabel }

    # Optionale Zusatzinformationen
    OPTIONAL { ?exercise rehab:hasCorrectionGuidance ?correction }
    OPTIONAL { ?exercise rehab:hasCommonMistake ?mistake }

    # Extrahiert den lokalen Namen der Difficulty-URI
    BIND(REPLACE(STR(?difficulty), "^.*[#/]", "") AS ?difficultyLabel)
}

GROUP BY
    ?exercise
    ?exerciseLabel
    ?difficultyLabel
    ?contraindications
    ?trainingsEffects
    ?bodyParts
    ?duration
    ?instruction
    ?corrections
    ?mistakes
```


## Allgemeine SPARQL-Hilfen

### URI → lokaler Name (Label-Extraktion)

Diese Technik extrahiert den letzten Teil einer URI (z. B. Deadlift aus einer vollständigen URL), um ihn in der UI lesbar zu machen.
Bspw: http://purl.org/PhysicalTherapy#Deadlift -> Deadlift 

```sparql
BIND(REPLACE(STR(?exercise), "^.*[#/]", "") AS ?localName)
```