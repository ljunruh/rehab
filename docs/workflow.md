# GitLab Workflow & Zusammenarbeit

Um bei drei verschiedenen Arbeitsgruppen nicht den Überblick zu verlieren, sind folgende Leitlinien empfehlenswert. 

Bitte lest euch diesen Leitfaden durch, bevor ihr mit der Arbeit beginnt.

---

## 1. Die Label-Struktur

Mit Labels kann man Issues und Merge Requests auf einen Blick kategorisieren. Bitte verseht jedes neue Issue mit mindestens einem Gruppen-Label und einem Typ-Label.

**Arbeitsgruppen (Zuständigkeit):**
*   `Group::Graph`
*   `Group::UI` 
*   `Group::API`
*   `Group::Alle`

**Art der Aufgabe (Typ):**
*   `Type::Feature` (Neuer Code, neue Scripte, neue Funktionalität)
*   `Type::Bug` (Fehlerbehebung an bestehendem Code)
*   `Type::Design` (Figma, Mockups, UI-Entwürfe)
*   `Type::Docs` (Architektur, READMEs, Dokumentationen)

---

## 2. Das Issue Board (Kanban)

Unter **Planen > Ticketübersichten** in GitLab steht das Kanban Board. Dieses ist in folgende Spalten unterteilt:

1.  **Open**: Das Backlog. Hier landen alle neuen Ideen, Bugs oder zukünftigen Tasks.
2.  **Status::To Do**: Aufgaben, die für die nächste Woche/den nächsten Meilenstein aktiv eingeplant sind.
3.  **Status::In Progress**: Hieran wird *aktuell* gearbeitet. (Zieht die Karte hierher, wenn ihr anfangt)
4.  **Status::Review**: Die Aufgabe ist fertig, aber ein anderes Gruppenmitglied muss noch einen kurzen Blick auf den Code (den Merge Request) werfen.
5.  **Closed**: Erledigt und im `main`-Branch gemerged.

---

## 3. Der Entwicklungs-Workflow (Wie Code in den main-Branch kommt)

**Wichtig:** Niemand pusht direkt in den `main`-Branch! Der `main`-Branch spiegelt immer die lauffähige Version des Projekts wider.

Wir arbeiten mit **Merge Requests (MRs)**. Der Lebenszyklus einer Aufgabe sieht so aus:

1.  **Issue erstellen:** Jemand erstellt ein Issue (z.B. "API Endpunkt für Patientenliste") und vergibt die passenden Labels (`Group::API`, `Type::Feature`).
2.  **Zuweisen:** Bearbeitest du die Aufgabe, weise das Issue dir selbst zu ("Assignee") und ziehe es auf dem Board in `Status::In Progress`.
3.  **Branch erstellen:** Klicke direkt im GitLab-Issue auf den Button **"Create Merge Request"**. GitLab erstellt daraufhin automatisch einen neuen Entwicklungs-Branch (z.B. `14-api-endpunkt-patientenliste`) und verknüpft ihn mit dem Issue.
4.  **Arbeiten & Committen:**
    *   Ziehe dir den neuen Branch lokal: `git fetch && git checkout 14-api-endpunkt-patientenliste`
    *   Arbeite lokal und mache deine Commits.
5.  **Review anfordern:**
    *   Pushe deine Änderungen.
    *   Ziehe das Issue auf dem Board in `Status::Review`.
    *   Bitte jemanden aus deiner Gruppe, sich den Merge Request in GitLab anzusehen.
6.  **Merge & Close:**
    *   Wenn alles passt, klickt der Reviewer im Merge Request auf "Merge".
    *   Der Code wandert sauber in den `main`-Branch.
    *   Da der Branch aus dem Issue heraus erstellt wurde, schließt sich das Issue nun vollautomatisch und wandert auf dem Board auf "Closed".
