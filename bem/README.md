<h1>Home Assistant // BEM - Behälter-Entnahme-Messung</h1>

<b>BEM</b> ist eine einfache Automatisierung für Home Assistant zur Erfassung von Entnahmemengen aus beliebigen Behältern wie beispielsweise Wassertanks. Dabei wird vorausgesetzt, dass der Behälter bereits über einen Sensor verfügt, welcher den aktuellen Füllstand des Behälters misst, und dieser in Home Assistant bereits als entsprechender Sensor eingerichtet ist.<br />
<b>BEM</b> speichert dann fortwährend bei jeder Entnahme die letzte entnommene sowie die insgesamt entnommene Menge und stellt beide Werte in Home Assistant zur Verfügung.<br />
Dazu verwendet <b>BEM</b> nur die Standard-Funktionen von Home Assistant und NodeRED, es werden keine zusätzlichen Integrationen, Add-Ons, HACS-Module oder NodeRED-Paletten benötigt.
<hr>
<h2>Vorbereitung</h2>
Zur Ausführung benötigt <b>BEM</b> neben einem beliebigen Füllstandssensor die folgenden Helfer, welche zunächst in Home Assistant angelegt werden müssen.<br />
<img src="./img/bem_img_helper.png">
Helfer<ul>
<li> Behälter Entnahme gesamt (<b>input_number.bem_entnahme_gesamt</b>)</li>
<li> Behälter Entnahme letzte (<b>input_number.bem_entnahme_letzte</b>)</li>
<li> Behälter Stand bei Beginn letzter Entnahme (<b>input_number.bem_stand_bei_beginn_letzter_entnahme</b>)</li>
</ul>
<b>Wichtig</b>: Diese Helfer sind in Home Assistant als Typ <b>Nummer</b> (<i>input_number</i>) anzulegen. Für alle Helfer sind folgende Punkte zu beachten:<br /><br />
<img src="./img/bem_img_helper_entnahme_gesamt.png">
<ul>
<li>1 Maximalen Wert gemäß dem eigenen Umfeld eintragen. Dieser Wert sollte höher sein als die Summe aller Entnahmen erreichen kann.</li>
<li>2 Die Schrittgröße ist entsprechend der gewünschten Genauigkeit einzustellen (in diesem Beispiel 1/1000 = Milliliter).</li>
<li>3 Die Entität-IDs exakt so umbenennen wie oben angegeben (Umlaute wurden umgewandelt), oder statt dessen die Entität-IDs in den NodeRED-Flows entsprechend ändern (mehr Aufwand).</li>
</ul>

<hr>
<h2>BEM (Varianten)</h2><ul>
<li><b>BEM</b> steht aktuell nur als <a href="#nodered_flow">NodeRED-Flow</a> zur Verfügung.</li>
</ul>

<a id="nodered_flow"></a>
<hr>
<h3>NodeRED-Flow</h3>
<img src="./img/bem_img_nodered_flow.png">
<b>Download</b> NodeRED-Flow&nbsp;&raquo;&nbsp;<a href="https://github.com/migacode/home-assistant/blob/main/bem/code/bem_nodered_flow_1.00.json"><strong>bem_nodered_flow_1.00.json</strong></a><br />
<br />
Den Quelltext/Flow in NodeRED importieren und wie folgt anpassen.<br />
<br />
In allen Nodes namens "<b>Aktuellen Füllstand einlesen</b>" die Entität <i>sensor.behaelter_fuellstand_aktuell</i> durch die Entität des eigenen tatsächlichen Sensor ersetzen, welcher den Füllstand des realen Behälters enthält.<br /><br />
<img src="./img/bem_img_change_nodes.png">
<br />
<br />

<hr>
<h3>Handhabung und Funktionsweise</h3>
<b>Erläuterungen zur Handhabung und Funktionsweise</b>
<br />
<br />
