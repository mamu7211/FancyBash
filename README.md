# FancyBash

Ein kleiner Bash-Prompt im Agnoster-Stil ohne Framework. Benötigt eine
Powerline-/Nerd-Font wie Hurmit und ein Terminal mit 256 Farben.

Farbige Segmente: Benutzer/Host in Dunkelgrau, Ordner in Blau und Git-Branch
in Grün. Die Übergänge sind rund (`U+E0B4`) statt dreieckig; das letzte
Segment endet mit einer runden Kappe vor der Eingabe.

Zeigt den Ordner, optional den Git-Branch (bei detached HEAD den kurzen Commit)
und bei Fehlern den Exit-Code des letzten Befehls in einem roten Segment.
Für root erscheint zusätzlich `#` im Benutzersegment.
Das Git-Segment zeigt nur Zähler größer null:

| Anzeige | Bedeutung |
| --- | --- |
| `+N` | Dateien mit gestagten Änderungen |
| `~N` | Dateien mit ungestagten Änderungen |
| `?N` | Unversionierte Dateien |
| `\uf01b` + Zahl | Commits vor dem Upstream (ausgehend) |
| `\uf01a` + Zahl | Commits hinter dem Upstream (eingehend) |
| `\uef5b` + Zahl | Dateien mit ungelösten Konflikten |

Eine Datei kann sowohl gestagte als auch ungestagte Änderungen haben und
in beiden Zählern stehen. Konflikte werden separat gezählt. Grün bedeutet
sauber, Gelb lokale Änderungen, Rot Konflikte. Ohne konfigurierten Upstream
bleiben die Commit-Zähler aus. Der Vergleich nutzt den lokal bekannten Stand;
`git fetch` aktualisiert ihn, der Prompt greift nicht auf das Netzwerk zu.

Pro Prompt wird einmal `git status --porcelain=v2` aufgerufen. Das scannt auch
unversionierte Dateien und kann in sehr großen Repositories Zeit kosten.
Vorhandene `PROMPT_COMMAND`-Hooks bleiben erhalten.

## Ausprobieren

### Schriftart und Symbole

Für die runden Trenner und Git-Symbole eine [Nerd Font](https://www.nerdfonts.com/font-downloads)
installieren und in den Terminal-Einstellungen als Schriftart auswählen.
Dieser Prompt verwendet **Hurmit Nerd Font**, die um Icons erweiterte Variante
von **Hermit**. Auf der Download-Seite nach **Hurmit** suchen;
eine [Vorschau von Hermit](https://www.programmingfonts.org/#hermit) gibt es
auf Programming Fonts.

Im [Nerd Fonts Cheat Sheet](https://www.nerdfonts.com/cheat-sheet) lassen sich
Icons suchen und ihre Zeichen bzw. Unicode-Codes zum Anpassen des Prompts
nachschlagen, beispielsweise `e0b4`, `f01b`, `f01a` und `ef5b`.

### Prompt laden

In einem Bash-Terminal:

```bash
source /home/martin/Workspace/FancyBash/prompt.bash
```

Dieselbe Zeile lädt auch Änderungen in einem bereits geöffneten Terminal neu.

Für eine dauerhafte Aktivierung dieselbe Zeile ans Ende von `~/.bashrc` setzen.
Die Einrichtung verändert diese Datei nicht automatisch. Zum Entfernen die
Source-Zeile löschen und ein neues Terminal öffnen.

Aliase und fzf sind bewusst noch nicht eingerichtet.
