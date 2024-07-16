<h1>Home Assistant // BEM - Behälter-Entnahme-Messung</h1>

<b>BEM</b> ist eine einfache Automatisierung für Home Assistant zur Erfassung von Entnahmemengen aus beliebigen Behältern wie beispielsweise Wassertanks. Dabei wird vorausgesetzt, dass der Behälter bereits über einen Sensor verfügt, welcher den aktuellen Füllstand des Behälters misst, und dieser in Home Assistant bereits als entsprechende Sensor-Entität eingerichtet ist.<br />
<b>BEM</b> speichert dann fortwährend bei jeder Entnahme die letzte entnommene sowie die über einen beliebigen Zeitraum hinweg insgesamt entnommene Menge, und stellt beide Werte in Home Assistant zur Verfügung.<br />
Dazu verwendet <b>BEM</b> nur die Standard-Funktionen von Home Assistant und ggf. NodeRED, es werden keine zusätzlichen Integrationen, Add-Ons, HACS-Module oder NodeRED-Paletten (und auch kein Funktions-Node mit JavaScript ;) benötigt. Darüber hinaus sind in dem NodeRED-Flow-Paket auch Einzel-Flows zur Anzeige und zum Zurücksetzen der jeweiligen Werte enthalten.
<hr>
<h2>Vorbereitung</h2>
Zur Ausführung benötigt <b>BEM</b> neben einem beliebigen Füllstandsensor die folgenden Helfer, welche zunächst in Home Assistant angelegt werden müssen.<br /><br />
1. Als Erstes den Helfer "BEM Stand aktuell" (<b>sensor.bem_stand_aktuell</b>) als Typ <b>Template für einen Sensor</b> anlegen. Dieser Helfer enthält den Stand des tatsächlichen Sensors, dessen Entitäts-ID wie folgt in das Feld "Zustandstemplate" einzutragen ist (die Entität 'sensor.behaelter_fuellstand_aktuell' gegen die des eigenen Sensors ersetzen). Dies vereinfacht die Einrichtung von <b>BEM</b>, da so nur an dieser einen Stelle die ID des realen Sensors eingetragen werden muss und dann sämtliche Funktionen von <b>BEM</b> mit dem Template-Sensor arbeiten.<br />
<img src="./img/bem_img_helper_1.png"><br />
<img src="./img/bem_img_helper_stand_aktuell.png"><br />
2. Damit die Werte
<img src="./img/bem_img_helper_2.png">
<ul>
<li> "BEM Entnahme gesamt" (<b>input_number.bem_entnahme_gesamt</b>)</li>
<li> "BEM Entnahme letzte" (<b>input_number.bem_entnahme_letzte</b>)</li>
<li> "BEM Stand bei Beginn letzter Entnahme" (<b>input_number.bem_stand_bei_beginn_letzter_entnahme</b>)</li>
</ul>
<img src="./img/bem_img_helper_entnahme_gesamt.png">
<b>Wichtig</b>: Für alle diese Helfer sind folgende Punkte zu beachten:<br />
<ul>
<li>In Home Assistant als Typ <b>Nummer</b> (<i>input_number</i>) anlegen.</li>
<li>Bei <b>1</b> den maximalen Wert gemäß des eigenen Umfeldes eintragen. Dieser Wert sollte höher sein als die Summe aller Entnahmen erreichen kann.</li>
<li>Bei <b>2</b> ist die Schrittgröße entsprechend der gewünschten Genauigkeit einzustellen (in diesem Beispiel 1/1000 = Milliliter).</li>
<li>Bei <b>3</b> die Entitäts-ID exakt so benennen wie zu dem jeweiligen Helfer oben angegeben (der Entitäts-Name hingegen ist egal), oder statt dessen die Entitäts-IDs in den NodeRED-Flows entsprechend ändern (mehr Aufwand).</li>
</ul>
3. Darüber hinaus ist noch ein Helfer "BEM Entnahme Status" (<b>input_boolean.bem_entnahme_status</b>) als Typ <b>Schalter</b> (<i>input_boolean</i>) anzulegen, welcher den aktuellen Status der Entnahme speichert, so dass darüber eine Absicherung des Entnahmeablaufs erfolgen kann.<br /><br />
<img src="./img/bem_img_helper_3.png">

<h3>Tipp</h3>
<b>BEM</b> verwendet für den aktuellen Füllstand des Behälters sowohl in den NodeRED-Flows als auch in den Komponenten von Home Assistant (Dashboard-Karte, Skripte, Templates) die Entitäts-ID <b>sensor.behaelter_fuellstand_aktuell</b>, welche bei der Einrichtung überall (derzeit insgesamt rund 10 Vorkommen) durch die Entitäts-ID des eigenen, tatsächlichen bereits eingerichteten Sensors zu ersetzen ist. Sofern Letzterer noch nicht anderweitig (bspw. in anderen Automatisierungen) in Verwendung ist, ist es eventuell einfacher und schneller, die Entitäts-ID des bestehenden Sensors in <b>sensor.behaelter_fuellstand_aktuell</b> zu ändern und die diesbezüglich nachstehend zahlreich aufgeführten Änderungen zu ignorieren ;).

<hr>
<h2>BEM (Varianten)</h2><ul>
<li>Eine Automatisierung von <b>BEM</b> steht aktuell nur als <a href="#nodered_flow">NodeRED-Flow</a> zur Verfügung.</li>
<li>Allerdings kann die Steuerung auch manuell mit der <a href="#dashboard_card">interaktiven Dashboard-Karte</a> erfolgen.</li>
</ul>

<a id="nodered_flow"></a>
<hr>
<h3>NodeRED-Flow</h3>
<img src="./img/bem_img_nodered_flow.png">
<b>Download</b> NodeRED-Flow&nbsp;&raquo;&nbsp;<a href="https://github.com/migacode/home-assistant/blob/main/bem/code/bem_nodered_flow_1.30.json"><strong>bem_nodered_flow_1.30.json</strong></a><br />
<br />
Den Quelltext/Flow in NodeRED importieren und wie folgt anpassen.<br />
<br />
In allen Nodes namens "<b>Aktuellen Füllstand einlesen</b>" die Entität <b>sensor.behaelter_fuellstand_aktuell</b> durch die Entität des eigenen tatsächlichen Sensor ersetzen, welcher den Füllstand des realen Behälters enthält.<br />
<b>Achtung:</b> Einen geänderten Node nicht einfach über einen anderen gleichlautenden Node kopieren, da die einzelnen Nodes trotz gleicher Bezeichnung unterschiedliche Ausgänge haben!<br /><br />
<img src="./img/bem_img_change_nodes.png">

<hr>
<h3>Handhabung und Funktionsweise</h3>
Ein Messvorgang besteht <b>immer aus zwei Schritten</b> - einer Messung des Füllstandes zu Beginn und einer Messung zum Ende jeder Entnahme.<br />
Die beiden Schritte werden entsprechend durch die Automatisierungs-Flows 1. (Entnahme Beginn) und 2. (Entnahme Ende) abgebildet.<br />
In <b>Flow 1</b> wird der zum Zeitpunkt dessen Aufrufs gemessene Füllstand des Behälters in dem Helfer <b>bem_stand_bei_beginn_letzter_entnahme</b> gespeichert.
In <b>Flow 2</b> wird der aktuelle Füllstand des Behälters erneut eingelesen und die Differenz zu dem in Flow 1 gemessenen und gespeicherten Stand ermittelt. Die ermittelte Differenz (letzte Entnahmemenge) dann in dem Helfer <b>bem_entnahme_letzte</b> gespeichert, sowie der Gesamtentnahmemenge hinzu addiert. Die neue Gesamtentnahmemenge wird wiederrum in dem Helfer <b>bem_entnahme_gesamt</b> gespeichert. Insofern muss vor Beginn <b>jeder</b> Entnahme der Flow 1, sowie nach dem Ende der Entnahme Flow 2 getriggert werden - beispielsweise parallel zum Ein- bzw. Ausschalten einer Pumpe.<br />
<b>Hinweis:</b> Ein Aufruf von Flow 2 ohne vorherigen Aufruf von Flow 1 führt natürlich dazu, dass Flow 2 den gespeicherten Füllstand noch von vor der/n vorletzten Entnahme/n als Basiswert verwendet, die Messung insofern auch die vorletzte/n Entnahmemenge/n mehrfach beinhaltet und somit auch die Werte der entnommenen Einzel- und Gesamtmenge verfälscht! Daher wird bei Start jedes Flows der Status der Entnahme überprüft und die weitere Verarbeitung entsprechend des Status abgebrochen oder fortgeführt.<br />

<a id="dashboard_card"></a>
<hr>
<h3>Interaktive Dashboard-Karte</h3>
Die nachstehende Dashboard-Karte enthält diverse Funktionen zur Anzeige und Steuerung von <b>BEM</b>:
<ul>
<li>Anzeige des Behälterfüllstandes in absoluter und prozentualer Wertigkeit</li>
<li>Anzeige der Einzel- und Gesamt-Entnahmemengen in verschiedenen Einheiten</li>
<li>Visuelle Anzeige zur Überwachung des aktuellen Entnahmestatus</li>
<li>Buttons zur manuellen Steuerung des Entnahmestatus (mit Sicherheitsabfrage)</li>
<li>Button zum Zurücksetzen des Gesamtentnahmezählers (mit Sicherheitsabfrage)</li>
</ul>
Für die Berechnung der Entnahmemengen spielt es übrigens keine Rolle, ob der Entnahmestatus automatisiert aus den NodeRED-Flows oder manuell über diese Karte gesteuert wird - sogar eine gemischte Verwendung ist möglich.<br /><br />
<img src="./img/bem_img_card.png">
<b>Download</b> Dashboard-Karte&nbsp;&raquo;&nbsp;<a href="https://github.com/migacode/home-assistant/blob/main/bem/code/bem_dashboard_card_1.30.yaml"><strong>bem_dashboard_card_1.30.yaml</strong></a><br />
<br />
Den Quelltext als neue Karte (manuell über YAML-Code einfügen) im Dashboard anlegen, darin die maximale Inhaltsmenge des Behälters (der Wert max: 5000) durch die maximale Füllmenge des realen Behälters ersetzen und die Werte für die Gewichtung der Gauge-Anzeigen (severity) gemäß den eigenen Wünschen an die realen Gegebenheiten anpassen.<br />
Zudem sind nachstehende Erweiterungen in Home Assistant hinzufügen.<br />
<br />
<b>Erforderliche Erweiterung 1 für interaktive Dashboard-Karte:</b><br />
Zur besseren Darstellung der Messwerte (Rundung etc.) verwendet die Karte zusätzliche Sensoren. Um diese anzulegen sind die folgenden Zeilen in der <b>configuration.yaml</b> unter dem Bereich <b>template:</b> hinzuzufügen.<br />
<b>Achtung:</b> Die Entitäts-ID <b>sensor.behaelter_fuellstand_aktuell</b> muss wie zuvor natürlich auch wieder überall durch die Entitäts-ID des eigenen tatsächlichen Sensors ersetzt werden, sowie die Kapazität in der Formel für die prozentuale Angabe des Füllstandes (der Wert <i>5000</i>) an die Größe (Fassungsvermögen/maximaler Füllstand) des eigenen Behälters angepasst werden.<br />
Nachstehenden Code kopieren oder downloaden&nbsp;&raquo;&nbsp;<a href="https://github.com/migacode/home-assistant/blob/main/bem/code/bem_templates_1.30.yaml"><strong>bem_templates_1.30.yaml</strong></a>.<br />

```yaml
```

<br />
<b>Erforderliche Erweiterung 2 für interaktive Dashboard-Karte:</b><br />
Da die "action"-Sequenzen von Dashboard-Buttons leider (noch?) keine Templates unterstützen, müssen wir uns diesbezüglich mit zusätzlichen Skripten behelfen. Dazu sind die folgenden Zeilen in der <b>configuration.yaml</b> unter dem Bereich <b>script:</b> hinzuzufügen.<br />
<b>Nochmal Achtung:</b> Die Entitäts-ID <b>sensor.behaelter_fuellstand_aktuell</b> muss wie zuvor natürlich auch wieder überall durch die Entitäts-ID des eigenen tatsächlichen Sensors ersetzt werden.<br />
Nachstehenden Code kopieren oder downloaden&nbsp;&raquo;&nbsp;<a href="https://github.com/migacode/home-assistant/blob/main/bem/code/bem_scripts_1.30.yaml"><strong>bem_scripts_1.30.yaml</strong></a>.<br />

```yaml
```

<br />
