# Aktuelle Verfahren

## Übungen finden am Bsp. ACL-Tear (ist aktuell nur am bsp KneeJoint):

ACLTear -> requiresImprovementOf -> KneeJoint -> isRehabilitatedBy -> Übung -> hasDifficultyLevel -> Beginner  
    |   										  					   ^ ^
	|																   | |
	--------------------------- excludesExercise ----------------------- -- ist Patient auf mind. Beginner TrainingsLevel?

alternativ, wenn man nicht auf Basis von der Injury agieren möchte, könnte man auch einfach anfangs den Bereich z.B. KneeJoint nehmen und dann Übungen allein durch PainScore ausschließen
(schwieriger, weil aktuell painScore nicht mit Übung verknüpft ist, und wenn wie?)
			
## Für UI:
blau:
hat der alltagszustand nicht etwas mit dem fitnesszustand zutun? - unter pinkes Aktivitätslevel?
verfügbare zeit: man bekommt, wie oben erklärt ein set an übungen, man könnte hier für jede Übung eine Zeit hinzufügen

grün:
man kann für jedes Set an übungen dann abfragen für jede Übung [Übung] improves [Trainingseffekt]
Rubriken stehen im Graphen unter Exercise/Trainingseffekt
empfohlen oder nicht kann der graph nicht wissen ??

pink:
entweder:
fitness- / mobilitätszustand muss intern in der app ermittelt werden, aktuell hat patient Trainingslevel: advanced, intermediate, beginner. 

oder:
antworten von fragen werden mit daten per query an den Graphen geschickt, welcher jeweiliges trainingslevel "zusammenfügt".

wir müssten uns darauf einigen, bei Eingabe -> Zuweisung eines Traningslevels und dann abfrage an den Graphen