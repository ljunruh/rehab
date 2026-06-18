# Competency Questions für den Reha Knowledge Graph

## Ziel

Dieses Dokument sammelt zentrale Competency Questions für den Reha Knowledge Graph.
Die Fragen beschreiben, welche Informationen der Knowledge Graph später beantworten können soll und dienen als Grundlage für die Modellierung von Entitäten, Relationen und Beispielabfragen.

Die Fragen basieren auf den bisherigen Projektideen, den Physiotherapeut:innen-Interviews sowie den im Team diskutierten Reha- und Übungsquellen.

---

## Grundidee

Der Knowledge Graph soll Reha-Übungen nicht isoliert speichern, sondern in Beziehung zu wichtigen Kontextinformationen setzen.

Relevante Faktoren sind unter anderem:

* betroffene Körperregion
* Verletzung oder Beschwerde
* Reha-Ziel
* Schwierigkeitsgrad
* benötigte Hilfsmittel
* mögliche Kontraindikationen
* geeignete oder ungeeignete Übungen

Eine zentrale Empfehlungslogik könnte daher lauten:

**Body Part + Injury / Complaint + Skill Level + Goal → suitable Exercise**

---

## Competency Questions

### CQ1: Welche Übungen eignen sich für eine bestimmte Körperregion?

**Beispielfrage:**
Welche Übungen eignen sich für das Knie?

**Benötigte Informationen im Knowledge Graph:**

* Exercise
* BodyPart
* Relation: `targetsBodyPart` oder `engagedBodyPart`

**Beispielantwort:**
Für das Knie könnten z. B. Kniebeugen mit Unterstützung, Einbeinstand oder leichte Stabilisationsübungen relevant sein.

---

### CQ2: Welche Übungen passen zu einer bestimmten Verletzung oder Beschwerde?

**Beispielfrage:**
Welche Übungen eignen sich bei Kniebeschwerden?

**Benötigte Informationen im Knowledge Graph:**

* Exercise
* Injury / Complaint
* BodyPart
* Relation: `recommendedForInjury`
* Relation: `targetsBodyPart`

**Beispielantwort:**
Bei Kniebeschwerden könnten anfängerfreundliche und kontrollierte Übungen empfohlen werden, z. B. Kniebeugen mit Unterstützung oder Balanceübungen.

---

### CQ3: Welche Übungen sind für Anfänger:innen geeignet?

**Beispielfrage:**
Welche Übungen haben den Schwierigkeitsgrad Beginner?

**Benötigte Informationen im Knowledge Graph:**

* Exercise
* DifficultyLevel
* Relation: `hasDifficultyLevel`

**Beispielantwort:**
Übungen mit geringer Belastung und einfacher Ausführung, z. B. Einbeinstand mit Unterstützung, Brücke oder einfache Mobilisationsübungen.

---

### CQ4: Welche Übungen unterstützen ein bestimmtes Reha-Ziel?

**Beispielfrage:**
Welche Übungen helfen beim Ziel Balance?

**Benötigte Informationen im Knowledge Graph:**

* Exercise
* Goal
* Relation: `supportsGoal`

**Beispielantwort:**
Für das Ziel Balance könnten Einbeinstand, Gleichgewichtsübungen oder Übungen mit Balancepad relevant sein.

---

### CQ5: Welche Übungen sollten bei bestimmten Kontraindikationen ausgeschlossen werden?

**Beispielfrage:**
Welche Übungen sollten bei starken Schmerzen oder bestimmten medizinischen Einschränkungen nicht empfohlen werden?

**Benötigte Informationen im Knowledge Graph:**

* Exercise
* Contraindication
* Injury / Complaint
* Relation: `hasContraindication`

**Beispielantwort:**
Übungen mit hoher Belastung, Sprüngen oder komplexen Bewegungen sollten bei bestimmten Beschwerden oder starken Schmerzen ausgeschlossen oder nur unter therapeutischer Anleitung durchgeführt werden.

---

### CQ6: Welche Körperteile werden durch eine Übung angesprochen?

**Beispielfrage:**
Welche Körperregionen werden durch die Übung Brücke beansprucht?

**Benötigte Informationen im Knowledge Graph:**

* Exercise
* BodyPart
* Relation: `engagedBodyPart`

**Beispielantwort:**
Die Übung Brücke kann unter anderem Rumpf, Becken und Rücken ansprechen.

---

### CQ7: Welche Hilfsmittel werden für eine Übung benötigt?

**Beispielfrage:**
Welche Übungen benötigen ein Theraband?

**Benötigte Informationen im Knowledge Graph:**

* Exercise
* Equipment
* Relation: `requiresEquipment`

**Beispielantwort:**
Therabandübungen können für Kräftigung, Mobilisation oder leichte Widerstandsübungen eingesetzt werden.

---

### CQ8: Welche Übungen passen zu einer Kombination aus Körperregion, Beschwerde und Schwierigkeitsgrad?

**Beispielfrage:**
Welche Übungen eignen sich für Kniebeschwerden auf Beginner-Level?

**Benötigte Informationen im Knowledge Graph:**

* Exercise
* BodyPart
* Injury / Complaint
* DifficultyLevel
* Relation: `targetsBodyPart`
* Relation: `recommendedForInjury`
* Relation: `hasDifficultyLevel`

**Beispielantwort:**
Für Kniebeschwerden auf Beginner-Level könnten kontrollierte Übungen wie Einbeinstand mit Unterstützung oder Kniebeugen mit Unterstützung passend sein.

---

### CQ9: Welche Übungen passen zu einem bestimmten Reha-Ziel und einer bestimmten Körperregion?

**Beispielfrage:**
Welche Übungen unterstützen Stabilität im Kniebereich?

**Benötigte Informationen im Knowledge Graph:**

* Exercise
* Goal
* BodyPart
* Relation: `supportsGoal`
* Relation: `targetsBodyPart`

**Beispielantwort:**
Zur Stabilität im Kniebereich könnten Balanceübungen, Einbeinstand oder kontrollierte Kräftigungsübungen relevant sein.

---

### CQ10: Welche Übungen sollten bei Schmerzen pausiert oder angepasst werden?

**Beispielfrage:**
Was soll passieren, wenn Nutzer:innen während einer Übung starke Schmerzen angeben?

**Benötigte Informationen im Knowledge Graph:**

* Exercise
* PainLevel
* Contraindication
* Recommendation / Warning
* Relation: `hasContraindication`
* Relation: `requiresWarning`

**Beispielantwort:**
Bei starken Schmerzen sollte die Übung pausiert werden. Die App könnte einen Warnhinweis anzeigen und empfehlen, die Übung nicht weiterzuführen oder therapeutischen Rat einzuholen.

---

## Mögliche zentrale Klassen

* Exercise
* BodyPart
* Injury
* Complaint
* Goal
* DifficultyLevel
* Equipment
* Contraindication
* Warning

---

## Mögliche zentrale Relationen

* `targetsBodyPart`
* `engagedBodyPart`
* `recommendedForInjury`
* `supportsGoal`
* `hasDifficultyLevel`
* `requiresEquipment`
* `hasContraindication`
* `requiresWarning`

---

## Beispielhafte Empfehlungslogik

```text
User input:
- Body Part: Knee
- Complaint: Knee Pain
- Skill Level: Beginner
- Goal: Stability

Knowledge Graph query:
Find exercises that:
- target the knee
- are suitable for beginner level
- support stability
- are not contraindicated for knee pain
```

**Mögliche Antwort:**
Einbeinstand mit Unterstützung, Kniebeuge mit Unterstützung oder leichte Balanceübungen.

---

## Nutzen für die Modellierung

Die Competency Questions helfen dabei zu prüfen, ob die Ontologie und der Knowledge Graph die wichtigsten Projektanforderungen abdecken.

Wenn eine Frage nicht beantwortet werden kann, fehlen wahrscheinlich noch:

* eine Klasse
* eine Relation
* konkrete Instanzen
* oder Beispiel-Daten im Graphen

Dadurch können die nächsten Modellierungsschritte gezielter geplant werden.

