# Foliensatz ReVia Abschlusspräsentation

| Datei | Inhalt |
|---|---|
| `ReVia_Abschlusspraesentation.html` | Der Foliensatz (31 Folien). Eine einzige Datei, läuft offline im Browser. |
| `praesentation_server.py` | Kleiner lokaler Server, damit bearbeitete Sprechernotizen direkt in der HTML-Datei landen. |

## Präsentieren

Die HTML-Datei einfach im Browser öffnen.

| Taste | Funktion |
|---|---|
| `←` `→` / Leertaste | blättern |
| `P` | Präsentator-Fenster öffnen (aktuelle und nächste Folie, Stoppuhr, Sprechernotiz) |
| `N` | Notizen als Overlay (erscheint auch am Beamer) |
| `O` | Folienübersicht |
| `F` | Vollbild |
| Ziffern | direkt zu einer Folie springen |

Beide Fenster bleiben synchron, geblättert werden kann in jedem davon.

## Sprechernotizen bearbeiten

Im Präsentator-Fenster (`P`) in die Sprechernotiz klicken und schreiben. Formatierungen wie Fett und Listen bleiben erhalten. Solange der Cursor in der Notiz steht, blättern Pfeiltasten und Leertaste nicht; `Esc` verlässt das Feld.

Wo die Änderung landet, hängt davon ab, wie der Foliensatz geöffnet wurde:

### Mit Server: direkt in die Datei (empfohlen)

```bash
uv run präsentation/foliensatz/praesentation_server.py
```

Das Skript öffnet den Foliensatz unter `http://127.0.0.1:8765/ReVia_Abschlusspraesentation.html`. Jede Änderung an einer Notiz wird nach etwa einer halben Sekunde automatisch in `ReVia_Abschlusspraesentation.html` geschrieben. Über der Notiz steht dann „Änderungen landen direkt in …“. Beenden mit `Strg+C`.

- Der Server ist nur auf dem eigenen Rechner erreichbar (`127.0.0.1`) und braucht nur die Python-Standardbibliothek.
- Er ändert ausschließlich die `data-notes`-Attribute der Folien, der Rest der Datei bleibt unverändert. Git-Diffs zeigen also nur die bearbeiteten Notizen.
- Anderer Port: `PORT=9000 uv run …`

### Ohne Server (Datei per Doppelklick geöffnet)

Ein Browser darf eine per `file://` geöffnete Datei nicht selbst überschreiben. Änderungen werden deshalb nur im Browser gespeichert (`localStorage`) und überstehen ein Neuladen, sind aber nicht in der Datei. Die Statuszeile zeigt, wie viele Notizen noch nicht in der Datei stehen.

„In Datei speichern“ (oder `Cmd/Strg+S`) gibt den Foliensatz mit allen Notizen als neue HTML-Datei aus: in Chrome und Edge über einen Speichern-Dialog, in Brave, Firefox und Safari als Download. Diese Datei muss dann von Hand an die Stelle der alten kopiert werden. Achtung: Dabei schreibt der Browser die ganze Datei neu, der Git-Diff wird entsprechend groß.

### Gut zu wissen

- **Original** setzt die Notiz der aktuellen Folie auf den Stand beim Öffnen zurück.
- Im Browser gesicherte Änderungen gelten nur, solange die Notiz in der Datei noch dem Stand beim Bearbeiten entspricht. Steht die Änderung inzwischen in der Datei oder wurde die Notiz dort anders geändert, wird der Browser-Eintrag beim nächsten Laden verworfen.
- Der Browser-Speicher ist pro Browser und pro Adresse getrennt: Was per Doppelklick bearbeitet wurde, ist unter `http://127.0.0.1` nicht sichtbar und umgekehrt.
