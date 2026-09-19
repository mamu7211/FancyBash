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

### FancyBash laden

In einem Bash-Terminal:

```bash
source /home/martin/Workspace/FancyBash/fancybash.bash
```

Dieselbe Zeile lädt auch Änderungen in einem bereits geöffneten Terminal neu.

Für eine dauerhafte Aktivierung dieselbe Zeile ans Ende von `~/.bashrc` setzen.
Eine bisherige Source-Zeile für `prompt.bash` durch diese Zeile ersetzen.
Den Pfad bei einem anderen Speicherort anpassen. Zum Entfernen die Source-Zeile
löschen und ein neues Terminal öffnen. Wer nur den Prompt möchte, kann weiterhin
`prompt.bash` direkt laden.

## Gemeinsame History

FancyBash behält bis zu 50.000 Befehle im Speicher und 100.000 Zeilen in der
History-Datei. Direkt aufeinanderfolgende Duplikate und Befehle mit führendem
Leerzeichen werden nicht gespeichert. `history` zeigt Datum und Uhrzeit an.

Vor jedem neuen Prompt werden eigene Befehle angehängt (`history -a`) und neue
Einträge anderer Terminals eingelesen (`history -n`). Alle beteiligten Terminals
müssen FancyBash laden und dieselbe `HISTFILE` verwenden (normalerweise
`~/.bash_history`). In einem wartenden Terminal einmal Enter drücken, um neue
Einträge einzulesen. Auch die Pfeiltasten durchsuchen den gemeinsamen Verlauf.

## History-Suche mit fzf

Unter Ubuntu/Debian zuerst installieren:

```bash
sudo apt install fzf
```

Danach FancyBash erneut laden. `Ctrl+R` öffnet die Suche im Verlauf:
Suchbegriffe eingeben, mit den Pfeiltasten auswählen und mit Enter in die
Eingabezeile übernehmen. Erst ein weiteres Enter führt den Befehl aus.
Escape bricht die Suche ab. Die Suche belegt 40 % der Terminalhöhe.

Die Integration verwendet die [offiziellen fzf-Bash-Bindings](https://github.com/junegunn/fzf#setting-up-shell-integration).
`Ctrl+T` und `Alt+C` werden nicht zusätzlich aktiviert. Eigene
`FZF_CTRL_R_OPTS` haben Vorrang. Ohne installiertes fzf bleiben Prompt und History
nutzbar; `Ctrl+R` verwendet dann die normale Bash-Suche.

## Besuchte Verzeichnisse mit c

FancyBash merkt sich ab dem Laden die Verzeichnisse, in denen ein Prompt
angezeigt wird. Das erfasst auch Wechsel mit `cd`, `pushd` und `popd`.
Zwischenstationen innerhalb eines Befehls wie `cd /tmp; cd /var` werden nicht
einzeln erfasst. Der erste Prompt erfasst auch das Startverzeichnis.

| Aufruf | Verhalten |
| --- | --- |
| `c` | Öffnet die fzf-Auswahl, auch bei nur einem Eintrag |
| `c fancy` | Ein Treffer: direkt wechseln; mehrere: gefilterte Auswahl |
| `c workspace fancy` | Suche mit mehreren Begriffen nach den fzf-Suchregeln |

Enter wechselt zum gewählten Verzeichnis. Escape oder Ctrl+C bricht ab, ohne
zu wechseln. Bei null Treffern erscheint ein Hinweis. Nicht mehr vorhandene
Verzeichnisse werden ausgeblendet, aber bleiben gespeichert (etwa für momentan
nicht eingehängte Laufwerke). Zuletzt besuchte Verzeichnisse stehen oben.

Die Liste liegt in `${XDG_DATA_HOME:-$HOME/.local/share}/fancybash/directories`.
Sie wird zwischen Terminals geteilt, bleibt über Neustarts erhalten und enthält
jeden Pfad nur einmal. Nullbytes trennen die Einträge, damit auch Leerzeichen
und Zeilenumbrüche in Namen funktionieren. `flock` schützt parallele Schreibzugriffe;
die Datei wird atomar ersetzt. Benötigt Bash, fzf und `flock` (unter Ubuntu aus
`util-linux`). Die Besuchsliste wird nicht ins Git-Repository geschrieben.

Nach einem Update in bereits geöffneten Terminals `fancybash.bash` erneut laden.
Die normale Bash-History wird nicht als Verzeichnisliste importiert.

Zusätzliche Aliase sind noch nicht eingerichtet.
