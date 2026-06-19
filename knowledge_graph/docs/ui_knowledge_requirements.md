# UI Knowledge Requirements

## Ziel

Dieses Dokument fasst zusammen, was das UI-Team vom Knowledge-Team benötigt, um den Prototypen zu vervollständigen, und stellt dem gegenüber, was im Knowledge Graph bereits vorhanden ist.

Grundlage sind:

* die Anforderungen des UI-Teams für Plan-Empfehlung, manuelle Übungssuche, Mobilitätstest und MVP-Übungen
* die bestehenden Competency Questions
* die Gap Analysis / Modeling Requirements
* die vorhandenen Übungsdaten aus `raw_data/deep_squad.json`
* die Ontologie `knowledge_graph/ontology/PhysicalTherapy.owx`

Ziel ist es, die Verbindung zwischen UI-Eingaben und Knowledge-Graph-Daten klarer zu machen.

---

## 1. Eingabefelder für die Plan-Empfehlung

Für die automatische Plan-Empfehlung benötigt das UI möglichst wenige, aber aussagekräftige Eingabefelder.

### Vorgeschlagene Eingabefelder

| Eingabefeld                 | Zweck                                                | Beispielwerte                                                             |
| --------------------------- | ---------------------------------------------------- | ------------------------------------------------------------------------- |
| Körperregion                | Auswahl der betroffenen oder zu trainierenden Region | Knie, Schulter, Rücken, Nacken, Hüfte, Sprunggelenk                       |
| Beschwerde / Injury         | Einschränkung oder Problem der Nutzer:innen          | KneeIssue, ShoulderIssue, LowerBackIssue, HipIssue, AnkleIssue, NeckIssue |
| Schmerzlevel                | Einschätzung der aktuellen Schmerzen                 | 0–10                                                                      |
| Ziel                        | Trainings- oder Reha-Ziel                            | Mobilität, Stabilität, Kraft, Entspannung, Balance                        |
| Schwierigkeit / Skill Level | Anpassung an Leistungsniveau                         | Beginner, Intermediate, Advanced                                          |
| Verfügbare Zeit             | Länge des Trainingsplans                             | 5 Minuten, 10 Minuten, 15 Minuten                                         |
| Verfügbare Hilfsmittel      | Filterung nach Equipment                             | kein Equipment, Stuhl, Wand, Theraband, Balancepad                        |
| Notiz                       | optionale zusätzliche Information                    | Freitext                                                                  |

---

## 2. Was der Knowledge Graph dafür bereits liefern kann

### Körperregion

Körperregionen sind über die Klasse `BodyPart` und die Relation `engagedBodyPart` bereits für die aktuellen Übungsdaten abgedeckt.

Mögliche Werte aus den aktuellen Daten sind zum Beispiel:

* `Knees`
* `Thighs`
* `Glutes`
* `LowerBack`
* `Hip`
* `Shoulders`
* `UpperBack`
* `Core`
* `Calves`
* `Ankles`
* `Spine`
* `Neck`

### Schwierigkeitsgrad

Der Schwierigkeitsgrad ist durch `hasDifficultyLevel` bereits in der aktuellen Import-Pipeline abgedeckt.

Aktuelle Werte:

* `Beginner`
* `Intermediate`
* `Advanced`

### Kontraindikationen

Kontraindikationen sind durch `hasContraindication` bereits in der aktuellen Import-Pipeline abgedeckt.

Beispiele:

* `KneeIssue`
* `ShoulderIssue`
* `LowerBackIssue`
* `HipIssue`
* `AnkleIssue`
* `BalanceIssue`
* `NeckIssue`
* `SpineIssue`

### Ziel / Goal

Ziele sind in der Ontologie als Klasse `Goal` sowie über Relationen wie `hasRecoveryGoal` und `fulfillsPurpose` konzeptionell vorgesehen.

Die aktuelle Import-Pipeline nutzt diese Zielinformationen jedoch noch nicht aktiv für Übungen.

Das bedeutet:

* Ziele sind konzeptionell vorhanden
* konkrete Goal-Instanzen wie Mobilität, Stabilität oder Kraft müssen noch definiert werden
* Übungen müssen noch mit diesen Zielen verknüpft werden

### Verfügbare Zeit

Verfügbare Zeit ist aktuell noch nicht in den Übungsdaten modelliert.

Für das UI wäre eine einfache Dauer-Angabe pro Übung sinnvoll, zum Beispiel:

```text
duration: "30 Sekunden"
```

oder:

```text
duration_minutes: 5
```

---

## 3. Eingabefelder für die manuelle Übungssuche

Für die manuelle Übungssuche sollte das UI Filter anbieten, damit Nutzer:innen gezielt passende Übungen finden können.

### Vorgeschlagene Filter

| Filter             | Zweck                                     | Beispielwerte                                                              |
| ------------------ | ----------------------------------------- | -------------------------------------------------------------------------- |
| Körperregion       | Übungen nach Körperteil filtern           | Knie, Schulter, Rücken, Hüfte, Nacken                                      |
| Kategorie          | Art der Übung auswählen                   | StrengthExercise, MobilisationStretching, CoordinationMobility, Relaxation |
| Schwierigkeit      | Belastungsniveau filtern                  | Beginner, Intermediate, Advanced                                           |
| Startposition      | Übung nach Position filtern               | Standing, Sitting, Laying, Floor                                           |
| Ziel               | Übungen nach Trainingsziel filtern        | Kraft, Mobilität, Stabilität, Balance, Entspannung                         |
| Equipment          | Übungen mit oder ohne Hilfsmittel filtern | kein Equipment, Stuhl, Wand, Theraband, Balancepad                         |
| Kontraindikationen | riskante Übungen ausschließen             | KneeIssue, ShoulderIssue, LowerBackIssue                                   |

---

## 4. Logik für die Plan-Empfehlung

Eine einfache Empfehlungslogik könnte für den Prototyp so aussehen:

```text
Body Part + Injury / Complaint + Pain Level + Goal + Skill Level → Exercise Recommendation
```

### Beispiel

```text
Input:
- Body Part: Knie
- Complaint: KneeIssue
- Pain Level: 4
- Goal: Stability
- Skill Level: Beginner

Output:
- nur Beginner-Übungen anzeigen
- Übungen mit KneeIssue als Kontraindikation vermeiden oder mit Warnhinweis anzeigen
- Fokus auf einfache und kontrollierte Übungen
```

---

## 5. Pain-Level-Regel

Eine einfache erste Regel für den Prototyp könnte sein:

```text
Pain Level > 3 → nur Beginner-Übungen anzeigen
```

Zusätzlich könnte gelten:

```text
Pain Level > 6 → Warnhinweis anzeigen und keine belastenden Übungen empfehlen
```

### Mögliche UI-Formulierung

```text
Da du ein erhöhtes Schmerzlevel angegeben hast, werden dir zunächst nur einfache Übungen angezeigt. Bitte führe die Übungen langsam aus und pausiere, wenn die Schmerzen stärker werden.
```

Diese Regel sollte später fachlich überprüft werden.

---

## 6. Mobilitätstest

Der Mobilitätstest sollte möglichst kurz sein, aber genug Informationen liefern, um einen ersten Plan vorzuschlagen.

### Ziel des Mobilitätstests

Der Test soll helfen, folgende Werte abzuleiten:

* betroffene Körperregion
* Schmerzlevel
* Aktivitätslevel
* ungefähres Skill Level
* Trainingsziel
* mögliche Einschränkungen

---

## 7. Vorgeschlagene Fragen für den Mobilitätstest

### Frage 1: Körperregion

```text
Welche Körperregion bereitet dir aktuell Beschwerden?
```

Mögliche Antworten:

* Knie
* Schulter
* Rücken
* Hüfte
* Nacken
* Sprunggelenk
* keine konkrete Beschwerde

---

### Frage 2: Schmerzlevel

```text
Wie stark sind deine Schmerzen bei Bewegung?
```

Antwortformat:

```text
0 = keine Schmerzen
10 = sehr starke Schmerzen
```

---

### Frage 3: Häufigkeit von Schmerzen

```text
Wie oft spürst du Schmerzen bei Bewegung?
```

Mögliche Antworten:

* nie
* selten
* manchmal
* häufig
* fast immer

---

### Frage 4: Alltagsbewegung

```text
Wie viele Minuten bewegst du dich ungefähr pro Tag aktiv?
```

Mögliche Antworten:

* weniger als 10 Minuten
* 10–30 Minuten
* 30–60 Minuten
* mehr als 60 Minuten

---

### Frage 5: Sportliche Aktivität

```text
Machst du regelmäßig Sport oder gezielte Übungen?
```

Mögliche Antworten:

* nein
* 1–2 mal pro Woche
* 3–4 mal pro Woche
* mehr als 4 mal pro Woche

---

### Frage 6: Beweglichkeit

```text
Wie würdest du deine aktuelle Beweglichkeit einschätzen?
```

Mögliche Antworten:

* stark eingeschränkt
* leicht eingeschränkt
* normal
* gut

---

### Frage 7: Ziel

```text
Was ist dein wichtigstes Ziel?
```

Mögliche Antworten:

* Schmerzen reduzieren
* Beweglichkeit verbessern
* Kraft aufbauen
* Stabilität verbessern
* Balance verbessern
* entspannen / lockern

---

## 8. Ableitung aus dem Mobilitätstest

### Pain Score

Der Pain Score kann direkt aus der Schmerzfrage abgeleitet werden.

```text
Pain Level 0–3 → normale Empfehlung möglich
Pain Level 4–6 → nur Beginner-Übungen / Warnhinweis
Pain Level 7–10 → Warnhinweis / therapeutische Abklärung empfehlen
```

### Skill Level

Das Skill Level kann aus mehreren Antworten abgeleitet werden.

| Antwortbereich                             | Mögliche Ableitung         |
| ------------------------------------------ | -------------------------- |
| wenig Bewegung + Schmerzen                 | Beginner                   |
| regelmäßige Bewegung + wenig Schmerzen     | Beginner oder Intermediate |
| regelmäßiger Sport + gute Beweglichkeit    | Intermediate               |
| starke Schmerzen oder starke Einschränkung | Beginner / Warnhinweis     |

Für den Prototyp reicht zunächst eine einfache Regel:

```text
Bei erhöhtem Schmerzlevel oder geringer Aktivität → Beginner
```

---

## 9. Erste Übungen für das MVP

Im Repository existiert bereits `raw_data/deep_squad.json` mit 23 Übungen.

Die Übungen sind in vier Kategorien aufgeteilt:

* `StrengthExercise`
* `MobilisationStretching`
* `CoordinationMobility`
* `Relaxation`

Jede Übung enthält aktuell:

* `activity_id`
* `activity_name`
* `category`
* `difficulty`
* `starting_position`
* `body_parts`
* `contraindications`

Diese Struktur ist bereits gut für den Knowledge Graph geeignet, da sie die aktuell genutzten Relationen unterstützt:

* `engagedBodyPart`
* `hasDifficultyLevel`
* `hasContraindication`

Für das UI fehlen jedoch noch weitere Felder wie Beschreibung, Anleitung, Korrekturhinweise, Dauer, Equipment und Ziel.

---

## 10. MVP-Übungen aus deep_squad.json

### StrengthExercise

| ID         | Übung                   | Schwierigkeit | Body Parts           | Contraindications |
| ---------- | ----------------------- | ------------- | -------------------- | ----------------- |
| `kraft_01` | Wandsitzen (Wall Sit)   | beginner      | Knees, Thighs        | KneeIssue         |
| `kraft_02` | Brücke (Bridging)       | beginner      | Glutes, LowerBack    | LowerBackIssue    |
| `kraft_03` | Muschel (Clamshell)     | beginner      | Hip, Glutes          | HipIssue          |
| `kraft_04` | Scapula-Retraktion      | beginner      | Shoulders, UpperBack | ShoulderIssue     |
| `kraft_05` | Theraband-Außenrotation | beginner      | Shoulders            | ShoulderIssue     |
| `kraft_06` | Dead Bug                | intermediate  | Core                 | LowerBackIssue    |

---

### MobilisationStretching

| ID         | Übung                      | Schwierigkeit | Body Parts       | Contraindications   |
| ---------- | -------------------------- | ------------- | ---------------- | ------------------- |
| `mobil_01` | Kniegelenk-Mobilisation    | beginner      | Knees            | KneeIssue           |
| `mobil_02` | Hüftbeuger-Dehnung         | beginner      | Hip              | KneeIssue, HipIssue |
| `mobil_03` | Wadendehnung               | beginner      | Calves           | AnkleIssue          |
| `mobil_04` | Brustwirbelsäulen-Rotation | beginner      | Spine, UpperBack | SpineIssue          |
| `mobil_05` | Nackendehnungen            | beginner      | Neck             | NeckIssue           |
| `mobil_06` | Pigeon Pose (vereinfacht)  | beginner      | Hip              | HipIssue, KneeIssue |

---

### CoordinationMobility

| ID         | Übung                                   | Schwierigkeit | Body Parts          | Contraindications        |
| ---------- | --------------------------------------- | ------------- | ------------------- | ------------------------ |
| `koord_01` | Einbeinstand                            | beginner      | Ankles, Knees       | BalanceIssue, AnkleIssue |
| `koord_02` | Gewichtsverlagerung seitlich            | beginner      | Hip, Core           | BalanceIssue             |
| `koord_03` | Gleichgewicht auf instabilem Untergrund | intermediate  | Ankles, Core        | BalanceIssue, AnkleIssue |
| `koord_04` | Ferse-Zehen-Gang                        | beginner      | Ankles, Calves      | BalanceIssue, AnkleIssue |
| `koord_05` | Armkreisen mit Gewichtsverlagerung      | beginner      | Shoulders, Core     | ShoulderIssue            |
| `koord_06` | Sitzen-Stehen-Übung                     | beginner      | Knees, Thighs, Core | KneeIssue                |

---

### Relaxation

| ID         | Übung                         | Schwierigkeit | Body Parts        | Contraindications        |
| ---------- | ----------------------------- | ------------- | ----------------- | ------------------------ |
| `entsp_01` | Progressive Muskelentspannung | beginner      | Core              | -                        |
| `entsp_02` | Atemübung (4-7-8 Technik)     | beginner      | -                 | -                        |
| `entsp_03` | Kindpose (Child's Pose)       | beginner      | LowerBack, Hip    | KneeIssue, HipIssue      |
| `entsp_04` | Faszienrolle Rücken/Wade      | beginner      | LowerBack, Calves | SpineIssue               |
| `entsp_05` | Schulter-Nacken-Entspannung   | beginner      | Shoulders, Neck   | ShoulderIssue, NeckIssue |

---

## 11. Vorschlag für eine erste MVP-Auswahl

Für das MVP sollten zunächst einfache, überwiegend beginner-freundliche Übungen verwendet werden.

### Vorgeschlagene MVP-Übungen

* Wandsitzen (Wall Sit)
* Brücke (Bridging)
* Muschel (Clamshell)
* Scapula-Retraktion
* Kniegelenk-Mobilisation
* Nackendehnungen
* Einbeinstand
* Gewichtsverlagerung seitlich
* Sitzen-Stehen-Übung
* Progressive Muskelentspannung
* Atemübung (4-7-8 Technik)
* Schulter-Nacken-Entspannung

Diese Auswahl deckt mehrere relevante Kategorien ab:

* Kraft
* Mobilisation
* Koordination / Balance
* Entspannung

Außerdem sind die meisten Übungen auf Beginner-Level und damit für einen ersten Prototyp gut geeignet.

---

## 12. Fehlende UI-relevante Felder pro Übung

Damit die Übungen im UI verständlich angezeigt werden können, sollten die vorhandenen Übungsdaten erweitert werden.

### Vorgeschlagene zusätzliche Felder

```json
{
  "description": "Kurze Beschreibung der Übung",
  "instructions": [
    "Schritt 1",
    "Schritt 2",
    "Schritt 3"
  ],
  "corrections": [
    "Häufiger Fehler und Korrekturhinweis"
  ],
  "repetitions": "z. B. 8–12 Wiederholungen",
  "duration": "z. B. 30 Sekunden",
  "equipment": [
    "z. B. Stuhl"
  ],
  "goal": [
    "z. B. Strength"
  ],
  "warning": "Hinweis bei Schmerzen oder Einschränkungen"
}
```

---

## 13. Beispiel für eine erweiterte Übung

```json
{
  "activity_id": "koord_01",
  "activity_name": "Einbeinstand",
  "category": "CoordinationMobility",
  "difficulty": "beginner",
  "starting_position": "Standing",
  "body_parts": [
    {
      "id": "Ankles",
      "name": "Sprunggelenk"
    },
    {
      "id": "Knees",
      "name": "Knie"
    }
  ],
  "contraindications": [
    "BalanceIssue",
    "AnkleIssue"
  ],
  "description": "Eine einfache Gleichgewichtsübung zur Verbesserung von Stabilität und Koordination.",
  "instructions": [
    "Stelle dich aufrecht hin und halte dich bei Bedarf an einer Wand oder einem Stuhl fest.",
    "Hebe ein Bein leicht vom Boden ab.",
    "Halte die Position für einige Sekunden und wechsle dann die Seite."
  ],
  "corrections": [
    "Achte darauf, dass das Standbein leicht gebeugt bleibt.",
    "Vermeide ruckartige Bewegungen.",
    "Halte dich fest, wenn du dich unsicher fühlst."
  ],
  "duration": "10–30 Sekunden pro Seite",
  "equipment": [
    "optional: Stuhl oder Wand"
  ],
  "goal": [
    "Balance",
    "Stability"
  ],
  "warning": "Bei Schwindel, starken Schmerzen oder Unsicherheit sollte die Übung pausiert werden."
}
```

---

## 14. Offene Punkte

Vor der finalen Umsetzung sollten folgende Fragen im Team geklärt werden:

1. Welche Übungen sollen tatsächlich im MVP angezeigt werden?
2. Sollen Kontraindikationen Übungen komplett ausschließen oder nur Warnhinweise erzeugen?
3. Welche Relation wird für positive Empfehlungen genutzt?

   * `forCondition`
   * `rehabilitates`
   * `fulfillsPurpose`
   * `improves`
4. Wie genau wird der Pain Score berechnet?
5. Welche Mobilitätstest-Fragen sollen final ins UI?
6. Soll Equipment bereits im MVP modelliert werden?
7. Welche Daten kommen direkt aus dem Knowledge Graph und welche bleiben zunächst UI-seitig?

---

## 15. Zusammenfassung der offenen Punkte

| Bereich                                        | Status                                                         |
| ---------------------------------------------- | -------------------------------------------------------------- |
| Körperregion                                   | Für die aktuellen Übungsdaten abgedeckt                        |
| Schwierigkeitsgrad                             | In der aktuellen Import-Pipeline abgedeckt                     |
| Kontraindikationen                             | In der aktuellen Import-Pipeline abgedeckt                     |
| Ziel / Goal                                    | Konzept vorhanden, noch nicht mit Übungen verknüpft            |
| Verfügbare Zeit                                | Noch nicht modelliert                                          |
| Übungsbeschreibung / Anweisungen / Korrekturen | Noch nicht in den Daten vorhanden                              |
| Equipment                                      | Noch nicht modelliert                                          |
| Mobilitätstest-Logik                           | Antwortkonzepte vorhanden, Verknüpfung zur Übungsauswahl fehlt |

---

## Fazit

Die vorhandenen Übungsdaten bilden bereits eine gute Grundlage für das MVP.

Für das UI fehlen vor allem:

* konkrete Eingabefelder
* Mobilitätstest-Struktur
* Übungsbeschreibungen
* Anweisungen und Korrekturen
* Dauer / Wiederholungen
* Equipment
* Ziele und Warnhinweise

Der nächste sinnvolle Schritt ist daher nicht, neue Übungen zu erfinden, sondern die vorhandenen Übungen aus `deep_squad.json` für das MVP auszuwählen und mit UI-relevanten Informationen anzureichern.

Dieses Dokument betrifft ausschließlich die Datenstruktur und greift nicht in die Ontologie oder die Import-Pipeline ein.
