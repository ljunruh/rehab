# SPARQL Abfragen

Diese Sammlung enthält SPARQL-Queries zur Abfrage von Daten für die Rehab-App.

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


## Allgemeine SPARQL-Hilfen

### URI → lokaler Name (Label-Extraktion)

Diese Technik extrahiert den letzten Teil einer URI (z. B. Deadlift aus einer vollständigen URL), um ihn in der UI lesbar zu machen.
Bspw: http://purl.org/PhysicalTherapy#Deadlift -> Deadlift 

```sparql
BIND(REPLACE(STR(?exercise), "^.*[#/]", "") AS ?localName)
```