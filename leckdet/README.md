<h1>Home Assistant // LeckDet - Leckage Detektiv</h1>

<b>LeckDet</b> ist eine einfache Automatisierung für Home Assistant zur Erkennung von unerwünschten Verbräuchen in beliebigen Leitungssystemen, wie beispielsweise Rohrbrüche von Wasserleitungen im Haus.<br /><br />
<b>Funktionsweise</b><br />
Innerhalb eines Zeitraums, in welchem kein beabsichtigter Verbrauch zu erwarten ist (typischerweise nachts), wird in bestimmten Abständen der jeweils aktuelle Zählerstand eingelesen und intern gespeichert.
Nach der letzten Messung werden alle gemessenen Zählerstände miteinander verglichen. Wenn sich alle eingelesenen Zählerstände mindestens um einen frei konfigurierbaren Wert voneinander unterscheiden, liegt vermutlich eine Leckage vor.
Durch die Verwendung mehrfacher Zählerstanderfassungen können innerhalb des überwachten Zeitraums sogar (natürlich nicht zu viele) normale Entnahmen erfolgen, ohne dass dadurch die Erkennung eines permanenten unerwünschten Verbrauchs beeinträchtigt wird.<br />
Darüber hinaus verwendet <b>LeckDet</b> nur die Standard-Funktionen von Home Assistant und ggf. NodeRED, es werden keine zusätzlichen Integrationen, Add-Ons, HACS-Module oder NodeRED-Paletten benötigt.
<hr>
<h2>Vorbereitung</h2>
<b>LeckDet</b> benötigt lediglich einen beliebigen bereits in Home Assistant eingerichteten Verbrauchs-Sensor, welcher den aktuellen Zählerstand als Entität bereitstellt.<br />
<br />
Die folgenden drei Helfer werden nur für die <b>LeckDet</b>-Variante als native Automatisierung (<i>YAML-Code</i>) benötigt. Bei Verwendung des aktuellen <b>NodeRED-Flows</b> werden diese Helfer <b>nicht</b> benötigt.
Die Helfer jeweils als Typ <b>Zahlenwert-Eingabe</b> anlegen. Dabei beachten, im <b>Namen</b> die fortlaufende Nummer zu ändern <b>(s.u. 1)</b>.<br /><b>Achtung:</b> Die Entitäten der Helfer werden bei der Anlage des Helfers automatisch aus dessen eingegebenen Namen erzeugt - dabei werden alle Umlaute umgewandelt, so dass in den Namen der entsprechenden Entitäten ~z<i>a</i>hlerstand~ statt ~z<i>ä</i>hlerstand~ enthalten ist.<br />
<br /><ul>
<li><b>Leckage Detektiv Zählerstand 1</b> (input_number.leckage_detektiv_zahlerstand_1)</li>
<li><b>Leckage Detektiv Zählerstand 2</b> (input_number.leckage_detektiv_zahlerstand_2)</li>
<li><b>Leckage Detektiv Zählerstand 3</b> (input_number.leckage_detektiv_zahlerstand_3)</li>
</ul>
Der <b>Maximalwert</b> muss so hoch gesetzt werden, dass dieser durch einen Wert des Sensors zur Verbrauchsmessung nie erreicht werden kann <b>(s.u. 2)</b>.<br />
<br />
Ebenfalls ist es sehr wichtig, die <b>Schrittweite</b> mit hinreichend vielen Stellen hinter dem Komma anzugeben - beispielsweise entsprechen vier Stellen [0,0001] der aktuellen Standard-Auflösung der in Deutschland verbauten Wasserzähler <b>(s.u. 3)</b>.<br />
<br />
<img src="./img/leckdet_img_helper_1.png">
<br />
Die fertigen Entitäten sollten danach in der Liste der Helfer so zu finden sein:<br />
<br />
<img src="./img/leckdet_img_helpers.png">
<hr>
<h2>LeckDet (Varianten)</h2><ul>
<li><b>LeckDet</b> steht aktuell nur als <a href="#nodered_flow">NodeRED-Flow</a> zur Verfügung.</li>
</ul>
<a id="nodered_flow"></a>
<hr>
<h3>NodeRED-Flow</h3>
<img src="./img/leckdet_img_nodered_flow.png">
<b>Download</b> NodeRED-Flow&nbsp;&raquo;&nbsp;<a href="https://github.com/migacode/home-assistant/blob/main/leckdet/code/leckdet_nodered_flow_1.10.json"><strong>leckdet_nodered_flow_1.10.json</strong></a><br />
<br />
<b>Hinweis:</b> Ab der Version 1.10 verwendet der NodeRED-Flow von <b>LeckDet</b> erweiterte Funktionen zur internen Speicherung von Werten, so dass dafür keine Helfer mehr benötigt werden.
Je nach verwendeter Version von Home Assistant bzw. Node-RED kann es sein, dass diese Funktionalität noch nicht unterstützt wird. In diesem Fall kann noch die alte Version 1.01 hier &nbsp;&raquo;&nbsp;<a href="https://github.com/migacode/home-assistant/blob/main/leckdet/code/leckdet_nodered_flow_1.01.json"><strong>leckdet_nodered_flow_1.01.json</strong></a> heruntergeladen werden - bei Verwendung dieser Version müssen dann allerdings auch die oben genannten Helfer angelegt werden.<br />
<br />
Den Quelltext/Flow in NodeRED importieren und wie folgt anpassen.<br />
<br />
<b>1.</b> In allen Nodes "<i>Aktuellen Zählerstand einlesen</i>" (fünf Vorkommen) muss die Entitäts-ID des Sensors gegen die des eigenen ersetzt werden.<br />
<br />
<img src="./img/leckdet_img_changes_node_1.png">
<br />
<b>2.</b> (Optional) In den vier Inject-Nodes "<i>Erste Messung um ...</i>" bis "<i>Vierte Messung um ...</i>" sind bei Bedarf die Uhrzeiten auf die individuellen Gegebenheiten vor Ort anzupassen. <b>Achtung:</b> Nicht nur im Namen des Node, sondern insbesondere in dem relevanten unteren Teil der Maske ;).<br />
<br />
<img src="./img/leckdet_img_changes_node_2.png"><br />
<b>3.</b> Für die Benachrichtigungen bei einer Leckage-Erkennung (Nodes 3.a bis 3.c) müssen bei Bedarf die entsprechenden Dienste (Services) an die eigenen Gegebenheiten angepasst und die Nodes (de-)aktiviert werden.<br />
Anstelle der Benachrichtigungen können hier selbstverständlich auch andere Aktionen eingefügt werden.<br />
<br />
<b>4.</b> (Optional) Die eigentliche Logik der Leckage-Erkennung ist in dem Funktions-Node "<i>Auf Leckage prüfen</i>" untergebracht. Für eine individuelle Erweiterung oder Konfiguration der Logik kann dieser Node bei Bedarf natürlich ebenfalls einfach angepasst werden.<br />
<br />
<hr>
Fertig.<br />
<br />
