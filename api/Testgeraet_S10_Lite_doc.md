# Setup Guide & Dokumentation: S10 Lite Testgerät (Rehab App)

Dieses Dokument dient als Einrichtungs- und Bedienungsanleitung für das Samsung Galaxy S10 Lite Testgerät, auf dem die Rehab App sowie die benötigten Backend- und Entwicklungs-Services laufen.

---

## Einleitung & Übersicht

Auf dem S10 Lite Testgerät werden folgende Tools und Komponenten genutzt:
* **Rehab App:** Die zu testende Flutter-Anwendung.
* **Termux:** Terminal-Emulation mit Linux-Tools und Paketmanager (hält den Fuseki-Server und SSH).
* **F-Droid:** Open-Source App-Store (genutzt, da kein Samsung- oder Google-Account auf dem Testgerät eingerichtet ist).
* **Simple Text Editor:** Aus F-Droid installierte App zur Bearbeitung lokaler Projektnotizen.
* **Java:** OpenJDK 21 (über Termux `pkg` installiert) als Laufzeitumgebung für Fuseki.
* **Apache Jena Fuseki:** SPARQL-Server / Graph-Datenbank für die Ontologie der App.
* **Isar Database & Inspector:** Lokale App-Datenbank und Web-Tool zur Inspectierung.

<b>Passwort des Testgeräts nur auf Anfrage.</b>

---

## 1. Termux Umgebung & Dateistruktur

Termux ist das zentrale Terminal auf dem Testgerät. Über Termux wird der Fuseki-Server gestartet und die SSH-Verbindung für den PC-Zugriff bereitgestellt.

* **Termux-Home-Verzeichnis (`~`):** `/data/data/com.termux/files/home`
* **Installiertes Java:** Java 21 (OpenJDK 21)

### Dateistruktur in Termux (`~`)

* **Fuseki 6.1.0:** `~/fuseki`
* **Notizen:** `~/notes.txt`
* **Ontologie & SPARQL:**
  * Ontologie für Fuseki: `~/ontologie/PhysicalTherapy.ttl`
  * Queries für die Fuseki Webanwendung (zum Debuggen): `~/ontologie/fuseki_query.sparql`
* **SSH-Server:**
  * Installiert, um vom PC auf das Termux-Terminal zuzugreifen.
  * SSH-Keys befinden sich im Ordner `~/.ssh/`.
  * **Nutzer-Name:** `u0_a245`
  * **Passwort:** `k4r4` (Passwort setzen/ändern mit Kommando: `passwd`)
  * **SSH-Daemon-Kommando:** `sshd`

---

## 2. PC-Zugriff auf das Termux-Terminal (SSH)

Über diese Verbindung kann vom PC direkt auf das Termux-Verzeichnis zugegriffen werden, um den Fuseki-Server zu starten oder eine aktualisierte Ontologie-Datei (`PhysicalTherapy.ttl`) vom PC auf das Testgerät zu kopieren.

### Schritt-für-Schritt Verbindung aufbauen:

1. **Hardware-Verbindung:** Testgerät und PC über USB-Kabel verbinden und die Datenverbindung auf dem Testgerät freigeben. *(Hinweis: Je nach Betriebssystem müssen evtl. weitere Treiber/Schritte unternommen werden, falls keine Verbindung aufgebaut werden kann).*
2. **SSH auf Testgerät starten:**
   * Termux auf dem S10 Lite öffnen.
   * SSH-Daemon starten mit Kommando:
     ```bash
     sshd
     ```
3. **Port weiterleiten & SSH-Verbindung auf dem PC herstellen:**
   * Port-Forwarding über ADB einrichten:
     ```bash
     adb forward tcp:8022 tcp:8022
     ```
   * SSH-Verbindung aufbauen:
     ```bash
     ssh u0_a245@localhost -p 8022
     ```
   * Passwort eingeben: `k4r4`
4. **SSH-Dienst auf dem Testgerät beenden:**
   * Prozess-ID anzeigen lassen und Prozess beenden:
     ```bash
     pgrep sshd
     kill <PID>
     ```
     *(Alternativ: `pkill sshd`)*

---

## 3. PC App bauen und ausliefern

* **Voraussetzung:** USB-Kabelverbindung zum Testgerät steht.
* **Ausliefern im Debug-Mode:** revia-debug
  - App über PC-Verbindung debugbar
  - Isar Inspector kann auf dem PC geöffnet werden und Daten zu manipulieren
  - Isar Inspector URL wird in der App als footer in einem Widget angezeigt. URL ist kopierbar
  ```bash
  flutter run
  ```

* **Ausliefern im Prod-Mode:** revia
  - Optimierte Performance und Sicherheit durch buildprozess der für Release-Versionen ausgerichtet ist
  - Debuggen nicht möglich
  ```bash
  flutter run --release
  ```

## 4. Apache Fuseki Server

Kopieren des Knowledge-Graph auf das Testgerät:
* **Voraussetzung:** USB-Kabelverbindung zum Testgerät steht und Terminalverbindung über SSH steht.
* **Ausliefern des Knowledge-Graph:** Kommando muss auf dem PC ausgeführt werden.
  ```bash
  scp -P 8022 ./PhysicalTherapy.ttl u0_a245@localhost:~/ontologie/PhysicalTherapy.ttl
  ```


Starten mit Ontologie:

In das Fuseki-Verzeichnis wechseln:
```bash
cd ~/fuseki
```

Server starten mit Kommando:
```bash
./fuseki-server --file=../ontologie/PhysicalTherapy.ttl /rehab
```

<b>Alternativ</b> Bash-Skript unter dem home Verzeichnis ~ nutzen:
```bash
./host-revia-graph.sh
```

Webanwendung aufrufen: Browser öffnen unter `http://localhost:3030`

### Debug-Queries ausführen

In `~/ontologie/fuseki_query.sparql` befinden sich vordefinierte Queries, die alle Übungen ausgeben, welche die Ontologie-Kriterien für die App erfüllen.

Query-Datei im Terminal ausgeben lassen:
```bash
cat ~/ontologie/fuseki_query.sparql
```

Text kopieren und in das Query-Eingabefeld der Fuseki-Weboberfläche einfügen.

## 5. Isar Database & Isar Inspector

Lokale Datenspeicherung für die App (Lese- und Schreibzugriff auf Schemas/Daten):

* Voraussetzung: USB-Verbindung vom PC zum Testgerät.
* App auf dem Testgerät im Debug-Mode öffnen.
* Isar Inspector Link aus den Consolen-Logs / der UI kopieren und auf dem PC im Browser aufrufen.
* Der Isar Inspector öffnet sich, woraufhin die Nutzerdaten gelesen und bearbeitet werden können.
* Hinweis: Port und Hash werden bei jedem App-Start neu vergeben.

BaseURL-Schema:
`https://inspect.isar.dev/3.1.0+1/#/PORT/HASH`

## 6. Notizen zum Projekt & F-Droid

Projektnotizen auf dem Gerät:

* Pfad auf dem Testgerät: `Eigene Dateien > Dokumente > RehabNotes.txt`
* Kann über die App Simple Text Editor geöffnet und bearbeitet werden (installiert via F-Droid).
* Eine Kopie liegt in Termux unter `~/notes.txt`.

### F-Droid Store

Wird genutzt, um Open-Source-Apps ohne Google-/Samsung-Account auf dem Testgerät zu installieren.


## ⚠️Known Issue: Isar Inspector

**Problembeschreibung:**

Der Isar Inspector kann aktuell nicht direkt im Browser des Testgeräts aufgerufen werden. Er lässt sich nur auf dem Rechner öffnen und bearbeiten, wenn dieser über SSH/ADB mit dem Testgerät verbunden ist.

**Ursache:**

Android unterbindet das Öffnen des Isar Inspectors direkt auf dem Testgerät. Die Webanwendung des Inspectors wird über HTTPS geladen (`https://inspect.isar.dev`), versucht jedoch auf den lokalen HTTP/WebSocket-Server (`http://localhost`) zuzugreifen. Dies wird von den Security-Richtlinien als Mixed-Content blockiert.

**Bereits versuchte Maßnahmen zur Behebung (bisher ohne Erfolg):**

### Android Chrome Traffic-Konfigurationen anpassen

URL aufgerufen:
```text
chrome://flags
```

Suche nach: Insecure origins treated as secure

Pfad eingetragen: `http://localhost` (für Isar WebSocket-Server)

Status auf Enabled gesetzt (Wichtig: Nach Tests nicht vergessen wieder zu entfernen/löschen!).

### DevTools auf dem PC für Android Chrome Browser-Tab nutzen

Auf PC-Browser aufgerufen:
```text
chrome://inspect/#devices
```

Unter Devices > Remote Target das Testgerät ausgewählt.

Aktiven Browser-Tab des Smartphones über Inspect analysiert.