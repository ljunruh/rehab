# Modeling Requirements from Competency Questions

## Ziel

Dieses Dokument leitet aus den zuvor definierten Competency Questions konkrete Anforderungen an den Reha Knowledge Graph ab.

Ziel ist es zu prüfen:

* welche Klassen und Relationen bereits in der Ontologie vorhanden sind
* welche Informationen durch die aktuelle Import-Pipeline bereits genutzt werden
* welche Aspekte für die Beantwortung der Competency Questions noch fehlen oder weiter modelliert werden sollten

Die Analyse dient als Zwischenschritt zwischen den Competency Questions und der weiteren Ontologie- bzw. Knowledge-Graph-Modellierung.

---

## Ausgangspunkt

Die Competency Questions beschreiben, welche Fragen der Knowledge Graph später beantworten können soll, zum Beispiel:

* Welche Übungen eignen sich für eine bestimmte Körperregion?
* Welche Übungen passen zu einer bestimmten Beschwerde?
* Welche Übungen sind für Anfänger:innen geeignet?
* Welche Übungen unterstützen ein bestimmtes Reha-Ziel?
* Welche Übungen sollten bei bestimmten Kontraindikationen ausgeschlossen werden?
* Welche Übungen benötigen bestimmte Hilfsmittel?
* Welche Warnhinweise sollten bei Schmerzen oder Einschränkungen gegeben werden?

Damit diese Fragen beantwortet werden können, müssen die relevanten Konzepte im Knowledge Graph als Klassen, Relationen und Instanzen modelliert sein.

---

## Aktueller Stand der Ontologie

Nach aktuellem Stand enthält die Ontologie bereits mehrere relevante Konzepte für den Reha-Kontext.

### Relevante vorhandene Klassen

* `Exercise`
* `BodyPart`
* `Condition`
* `Injury`
* `Goal`
* `TrainingsEffect`
* `TrainingsLevel`
* `Contraindication`
* `Patient`
* `PhysiotherapyRecord`
* `CompetencyQuestion`
* `Answer`
* `PainLevelAnswer`
* `RecoveryGoalAnswer`

Diese Klassen zeigen, dass zentrale Konzepte wie Übungen, Körperteile, Beschwerden, Verletzungen, Ziele und Trainingslevel bereits grundsätzlich in der Ontologie vorgesehen sind.

Wichtig ist jedoch die Unterscheidung zwischen:

1. **in der Ontologie vorhanden**
2. **in der aktuellen Import-Pipeline genutzt**
3. **für konkrete Empfehlungen bereits ausreichend modelliert**

Nicht jede vorhandene Klasse wird aktuell schon aktiv für die automatische Übungsempfehlung genutzt.

---

## Aktuell genutzte Relationen in der Import-Pipeline

Die aktuelle Import-Pipeline nutzt vor allem folgende Relationen:

* `engagedBodyPart`
* `hasDifficultyLevel`
* `hasContraindication`

Damit können bereits einfache Fragen beantwortet werden, zum Beispiel:

* Welche Körperregion wird durch eine Übung angesprochen?
* Welches Schwierigkeitslevel hat eine Übung?
* Welche Kontraindikationen sind mit einer Übung verbunden?

Diese Relationen bilden eine wichtige Grundlage, reichen aber noch nicht für alle Competency Questions aus.

---

## Weitere vorhandene Relationen in der Ontologie

Neben den bereits in der Pipeline genutzten Relationen gibt es in der Ontologie weitere Relationen, die für die Modellierung relevant sein könnten:

* `affectsBodyPart`
* `forCondition`
* `hasFocusOn`
* `improves`
* `fulfillsPurpose`
* `rehabilitates`
* `hasRecoveryGoal`
* `hasCondition`
* `hasInjury`
* `answersQuestion`
* `isAnsweredBy`

Diese Relationen sollten geprüft werden, bevor neue Relationen eingeführt werden.
Besonders für Reha-Ziele, Beschwerden und Empfehlungen könnten vorhandene Relationen wie `forCondition`, `hasFocusOn`, `improves`, `fulfillsPurpose`, `rehabilitates` oder `hasRecoveryGoal` genutzt oder weiter konkretisiert werden.

---

## Gap Analysis

| Bereich                 | In Ontologie vorhanden? | In Import-Pipeline genutzt? | Bewertung / Gap                                                                                                                                                     |
| ----------------------- | ----------------------- | --------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Body Part               | Ja                      | Ja                          | Bereits gut abgedeckt durch `BodyPart` und `engagedBodyPart`.                                                                                                       |
| Difficulty Level        | Ja                      | Ja                          | Bereits gut abgedeckt durch `TrainingsLevel` und `hasDifficultyLevel`.                                                                                              |
| Contraindication        | Ja                      | Ja                          | Bereits abgedeckt durch `Contraindication` und `hasContraindication`.                                                                                               |
| Injury / Condition      | Ja                      | Teilweise                   | `Condition` und `Injury` sind vorhanden, werden aber aktuell noch nicht klar für positive Übungsempfehlungen genutzt.                                               |
| Goal / TrainingsEffect  | Ja                      | Unklar / kaum               | `Goal` und `TrainingsEffect` sind vorhanden, aber die direkte Verbindung zu Übungen muss genauer geprüft werden.                                                    |
| Equipment               | Unklar / kaum           | Nein                        | Hilfsmittel wie Theraband, Pezziball oder Balancepad werden in den Interviews genannt, sind aber in der Pipeline noch nicht sichtbar modelliert.                    |
| Pain / Warning          | Teilweise               | Nein                        | Schmerzangaben sind als Antwortkonzept teilweise vorhanden, aber noch nicht als Entscheidungslogik für Warnhinweise oder Übungsanpassung modelliert.                |
| Positive Recommendation | Teilweise               | Nein / unklar               | Der Graph kann aktuell eher Ausschlüsse über Kontraindikationen darstellen. Eine positive Empfehlung für Beschwerden oder Ziele muss noch klarer modelliert werden. |

---

## Analyse nach Competency Questions

### CQ1: Welche Übungen eignen sich für eine bestimmte Körperregion?

Diese Frage ist bereits weitgehend beantwortbar.

Benötigte Konzepte:

* `Exercise`
* `BodyPart`
* `engagedBodyPart`

Aktueller Stand:

```text
Exercise → engagedBodyPart → BodyPart
```

Bewertung:

Diese Modellierung ist bereits vorhanden und wird durch die aktuelle Import-Pipeline genutzt.

---

### CQ2: Welche Übungen passen zu einer bestimmten Verletzung oder Beschwerde?

Diese Frage ist nur teilweise beantwortbar.

Benötigte Konzepte:

* `Exercise`
* `Condition`
* `Injury`
* `BodyPart`

Mögliche vorhandene Relationen:

* `forCondition`
* `hasInjury`
* `hasCondition`
* `rehabilitates`

Aktueller Stand:

Die Ontologie enthält Konzepte für `Condition` und `Injury`.
Die aktuelle Import-Pipeline nutzt jedoch vor allem `hasContraindication`, also eher eine Ausschlusslogik.

Beispiel:

```text
Exercise → hasContraindication → Condition
```

Gap:

Für positive Empfehlungen sollte geprüft werden, ob vorhandene Relationen wie `forCondition` oder `rehabilitates` genutzt werden können.

Mögliche Zielmodellierung:

```text
Exercise → forCondition → Condition
```

oder:

```text
Exercise → rehabilitates → Injury
```

---

### CQ3: Welche Übungen sind für Anfänger:innen geeignet?

Diese Frage ist bereits beantwortbar.

Benötigte Konzepte:

* `Exercise`
* `TrainingsLevel`
* `hasDifficultyLevel`

Aktueller Stand:

```text
Exercise → hasDifficultyLevel → TrainingsLevel
```

Bewertung:

Diese Modellierung ist bereits vorhanden und wird durch die Import-Pipeline genutzt.

---

### CQ4: Welche Übungen unterstützen ein bestimmtes Reha-Ziel?

Diese Frage ist teilweise vorbereitet, aber noch nicht vollständig modelliert.

Benötigte Konzepte:

* `Exercise`
* `Goal`
* `TrainingsEffect`

Mögliche vorhandene Relationen:

* `hasRecoveryGoal`
* `fulfillsPurpose`
* `improves`
* `hasFocusOn`

Aktueller Stand:

Die Ontologie enthält bereits Ziel- und Effektkonzepte.
Unklar ist jedoch, welche Relation langfristig für die Verbindung zwischen Übung und Reha-Ziel genutzt werden soll.

Gap:

Es sollte entschieden werden, ob Reha-Ziele über `Goal`, `TrainingsEffect` oder eine Kombination aus beiden modelliert werden.

Mögliche Zielmodellierung:

```text
Exercise → fulfillsPurpose → Goal
```

oder:

```text
Exercise → improves → TrainingsEffect
```

---

### CQ5: Welche Übungen sollten bei bestimmten Kontraindikationen ausgeschlossen werden?

Diese Frage ist bereits teilweise beantwortbar.

Benötigte Konzepte:

* `Exercise`
* `Contraindication`
* `Condition`
* `hasContraindication`

Aktueller Stand:

```text
Exercise → hasContraindication → Condition
```

Bewertung:

Die aktuelle Modellierung eignet sich gut für Ausschlussregeln.
Wichtig wäre im nächsten Schritt, die medizinische Korrektheit der jeweiligen Kontraindikationen zu prüfen.

---

### CQ6: Welche Körperteile werden durch eine Übung angesprochen?

Diese Frage ist bereits beantwortbar.

Benötigte Konzepte:

* `Exercise`
* `BodyPart`
* `engagedBodyPart`

Aktueller Stand:

```text
Exercise → engagedBodyPart → BodyPart
```

Bewertung:

Diese Relation ist bereits in der aktuellen Pipeline vorhanden.

---

### CQ7: Welche Hilfsmittel werden für eine Übung benötigt?

Diese Frage ist aktuell noch nicht ausreichend abgedeckt.

Benötigte Konzepte:

* `Exercise`
* `Equipment`

Mögliche fehlende Relation:

```text
Exercise → requiresEquipment → Equipment
```

Aktueller Stand:

In den Physiotherapeut:innen-Interviews wurden Hilfsmittel wie Theraband, Pezziball, Balancepad, Stuhl oder Wand erwähnt.
Diese Informationen sind für Übungsempfehlungen relevant, scheinen aber in der aktuellen Import-Pipeline noch nicht explizit modelliert zu sein.

Gap:

Es sollte geprüft werden, ob eine Klasse `Equipment` bereits vorhanden ist oder ergänzt werden muss.

Mögliche Beispiele:

```text
Theraband Exercise → requiresEquipment → Theraband
Balance Exercise → requiresEquipment → Balancepad
Wall Pushup → requiresEquipment → Wall
```

---

### CQ8: Welche Übungen passen zu einer Kombination aus Körperregion, Beschwerde und Schwierigkeitsgrad?

Diese Frage ist teilweise beantwortbar.

Benötigte Konzepte:

* `Exercise`
* `BodyPart`
* `Condition`
* `Injury`
* `TrainingsLevel`

Aktuell gut abgedeckt:

```text
Exercise → engagedBodyPart → BodyPart
Exercise → hasDifficultyLevel → TrainingsLevel
```

Noch unklar:

```text
Exercise → forCondition → Condition
```

oder:

```text
Exercise → rehabilitates → Injury
```

Gap:

Die Kombination aus Body Part und Difficulty Level ist bereits möglich.
Die positive Verbindung zwischen Übung und Beschwerde oder Verletzung sollte noch klarer modelliert werden.

---

### CQ9: Welche Übungen passen zu einem bestimmten Reha-Ziel und einer bestimmten Körperregion?

Diese Frage ist teilweise vorbereitet.

Benötigte Konzepte:

* `Exercise`
* `BodyPart`
* `Goal`
* `TrainingsEffect`

Aktuell vorhanden:

```text
Exercise → engagedBodyPart → BodyPart
```

Noch zu prüfen:

```text
Exercise → fulfillsPurpose → Goal
```

oder:

```text
Exercise → improves → TrainingsEffect
```

Gap:

Die Verbindung zwischen Übung und Körperregion ist vorhanden.
Die Verbindung zwischen Übung und Ziel bzw. Trainingseffekt muss noch genauer definiert werden.

---

### CQ10: Welche Übungen sollten bei Schmerzen pausiert oder angepasst werden?

Diese Frage ist aktuell noch nicht vollständig modelliert.

Benötigte Konzepte:

* `PainLevelAnswer`
* `Condition`
* `Warning`
* `Recommendation`
* `Exercise`

Aktueller Stand:

Die Ontologie enthält Antwortkonzepte wie `PainLevelAnswer`.
Eine konkrete Entscheidungslogik für Warnhinweise oder Übungsanpassungen ist jedoch noch nicht klar in der Import-Pipeline sichtbar.

Mögliche Modellierung:

```text
UserInput → reportsPainLevel → PainLevelAnswer
Exercise → hasContraindication → Condition
Exercise → requiresWarning → Warning
```

Gap:

Schmerzlevel sollten wahrscheinlich eher mit Nutzer:innen-Eingaben und App-Logik verbunden werden, nicht nur mit statischen Übungsdaten.

---

## Wichtige Modellierungsentscheidungen

### 1. Ausschlusslogik vs. positive Empfehlung

Aktuell ist die Ausschlusslogik durch `hasContraindication` bereits gut vorbereitet.

Beispiel:

```text
Exercise → hasContraindication → Condition
```

Für Empfehlungen braucht der Graph jedoch zusätzlich eine positive Verbindung zwischen Übung und Beschwerde, Verletzung oder Reha-Ziel.

Mögliche vorhandene Relationen, die geprüft werden sollten:

* `forCondition`
* `rehabilitates`
* `fulfillsPurpose`
* `improves`
* `hasRecoveryGoal`

Neue Relationen sollten erst eingeführt werden, wenn vorhandene Relationen nicht ausreichen.

---

### 2. Goal oder TrainingsEffect?

Für Ziele wie Kraftaufbau, Mobilisation, Balance, Stabilität oder Entspannung sollte entschieden werden, ob diese als `Goal`, `TrainingsEffect` oder beides modelliert werden.

Mögliche Varianten:

```text
Exercise → fulfillsPurpose → Goal
```

```text
Exercise → improves → TrainingsEffect
```

Diese Entscheidung ist wichtig, damit Competency Questions zu Reha-Zielen konsistent beantwortet werden können.

---

### 3. Equipment als Erweiterung

Hilfsmittel wurden in den Interviews mehrfach genannt und können für Übungsempfehlungen relevant sein.

Beispiele:

* Theraband
* Balancepad
* Pezziball
* Chair
* Wall

Falls Equipment noch nicht modelliert ist, könnte eine eigene Klasse `Equipment` sinnvoll sein.

Mögliche Relation:

```text
Exercise → requiresEquipment → Equipment
```

---

### 4. Pain Level und Warnhinweise

Schmerzangaben sollten wahrscheinlich nicht nur als medizinische Information, sondern auch als Trigger für App-Verhalten betrachtet werden.

Mögliche App-Logik:

```text
Wenn Pain Level hoch ist, sollte die Übung pausiert oder angepasst werden.
```

Dafür könnten Warnhinweise oder Empfehlungen modelliert werden.

Mögliche Konzepte:

* `PainLevelAnswer`
* `Warning`
* `Recommendation`

---

## Priorisierung der nächsten Schritte

### Hohe Priorität

1. Prüfen, welche vorhandene Relation für positive Empfehlungen genutzt werden soll:

   * `forCondition`
   * `rehabilitates`
   * `fulfillsPurpose`
   * `improves`

2. Klären, ob Reha-Ziele als `Goal`, `TrainingsEffect` oder beides modelliert werden.

3. Erste Beispielinstanzen für typische Reha-Ziele ergänzen:

   * Balance
   * Stability
   * Mobility
   * Strength
   * Relaxation
   * Coordination

---

### Mittlere Priorität

4. Equipment modellieren oder prüfen, ob es bereits ein passendes Konzept gibt:

   * Theraband
   * Balancepad
   * Pezziball
   * Chair
   * Wall

5. Erste positive Empfehlungen zwischen Übungen und Conditions/Injuries modellieren.

---

### Niedrige Priorität / spätere Erweiterung

6. Schmerzlevel und Warnhinweise detaillierter modellieren.

7. Nutzer:innenprofile und individuelle Anpassungen stärker einbeziehen.

8. App-spezifische Recommendation-Logik ergänzen.

---

## Beispielhafte Zielmodellierung

### Beispiel 1: Einbeinstand

```text
Einbeinstand
  engagedBodyPart → Knees
  engagedBodyPart → Ankles
  hasDifficultyLevel → Beginner
  fulfillsPurpose → Balance
```

Optional, falls eine positive Empfehlung modelliert wird:

```text
Einbeinstand
  forCondition → BalanceIssue
```

---

### Beispiel 2: Kniebeuge mit Unterstützung

```text
Kniebeuge mit Unterstützung
  engagedBodyPart → Knees
  hasDifficultyLevel → Beginner
  fulfillsPurpose → Strength
```

Optional:

```text
Kniebeuge mit Unterstützung
  forCondition → KneeIssue
```

---

### Beispiel 3: Theraband-Übung

```text
Theraband-Übung
  hasDifficultyLevel → Beginner
  fulfillsPurpose → Strength
  requiresEquipment → Theraband
```

Falls `Equipment` noch nicht vorhanden ist, müsste dieses Konzept ergänzt oder anders modelliert werden.

---

## Fazit

Die Competency Questions zeigen, dass der Knowledge Graph bereits wichtige Grundlagen enthält.

Gut abgedeckt sind aktuell:

* Körperregionen
* Schwierigkeitsgrade
* Kontraindikationen

Teilweise vorhanden, aber noch nicht vollständig für Empfehlungen genutzt sind:

* Verletzungen und Beschwerden
* Reha-Ziele
* Trainingseffekte

Noch zu prüfen oder zu ergänzen sind vor allem:

* positive Empfehlungen für Conditions oder Injuries
* klare Verbindung zwischen Übungen und Goals bzw. TrainingsEffects
* Hilfsmittel / Equipment
* Schmerzlevel und Warnhinweise

Der nächste sinnvolle Modellierungsschritt ist daher nicht, sofort neue Klassen und Relationen einzuführen, sondern zuerst zu prüfen, welche vorhandenen Ontologie-Elemente für die offenen Competency Questions genutzt werden können.
