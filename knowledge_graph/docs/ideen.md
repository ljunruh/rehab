# Aufbau Graph: 

Geteilt in 3 Über-Klassen: Muskeln/Organe, Übungen und User (haben wir schon)

## Muskeln/Organe
+ referenzontologie nutzen (zb Foundational model of anatomy) FMA
+ hierarchie/ taxonomie aufbauen. Körper -> Gewebe -> Organe -> Gelenke
+ relation ontology zwischen den klassen (muskel ist teil von einem gelenk)
+ fma hat auch nerven und blutversorgung daten (wichtig?)
+ einteilung in kraft, mobilisation/dehnung, koodrination/beweglichkeit, entspannung

## Übungen
+ beschreibung
+ sets
+ löst welches Problem
+ wann sollte man die übung nicht machen
+ wiederholungen
+ utensilien
+ welche fehler kann man machen
+ beteiligte Körperteile
+ ausgangshaltung
+ endhaltung
+ bewegungsumfang (range of motion)
+ bewegungspfad
+ intensitätslevel
+ volumen
+ anleitung
+ worauf muss man achten
+ wo werden oft fehler gemacht
+ pause zwischen wiederholungen
+ schmerzlevel
+ müdigkeitslevel
+ progression
+ schwierigkeitsgrad

## User
vielleicht müssen wir die userdaten von dem rest koppeln wegen performance
+ verletzung
+ tag der verletzung
+ was wurde verschrieben (vllt noch granularer), weil wie werden sonst übungen für den user ausgegeben? vllt sagt der physio das??
+ demografische daten
+ körperdaten wie bmi zb 
+ lebensstil
+ krankengeschichte
+ motivation
+ fortschrittswerte
+ schmerzwerte
+ psychologische Faktoren
+ persönliche vorlieben

### Ideen Berechnung Skill level:
+ Verletzung und Krankheit schließt sofort Übungen aus (zB Schulterprobleme und Übungen mit zu großer Dehnung). Dazu wird das Behandlungsprotokoll mit einbezogen.
+ Fortschrittswerte wie Range of Motion oder Progressscore 
+ Schmerzwerte
+ Tag der Verletzung ggf auch OP
+ BMI, Demografie und Lebensstil gewichten Übungen anders
+ Skill Score von Gemini
+ MET Score



### Nach der Stunde
+ Kompetenzfragen aufstellen
+ DOLCE oder BFO Ontology benutzen
+ Aufteilung in Module 
+ OntOlogy Pitfall Scanner
+ Werden alle Competency Questions beantwortet

### Design nach best Practices
+ Übungen werden eingeteilt in Unterklassen (kraft, mobilisation/dehnung, koodrination/beweglichkeit, entspannung)
+ Übungen können auch mehreren Unterklassen angehören
+ Ein User hat bezüglich einer Übung einen VAS Schmerz Wert
+ 