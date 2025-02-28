<h1>Home Assistant // Noticade - Notification Cascade - Benachrichtigungs-Kaskade</h1>

<b>Noticade</b> löst bei dem Auftreten eines Ereignisses eine Banachrichtigungs-Kaskade aus, bei welcher nacheinander verschiedene Empfänger über die HA-App und per Telefon-Anruf kontaktiert werden.
<b>Noticade</b> sendet Nachrichten dazu an die HA-Apps, welche dort sowohl als Text angezeigt als auch als Sprache ausgegeben werden (Letzteres aktuell leider nur auf Geräten mit Android).<br />
Dazu verwendet <b>Noticade</b> nur die Standard-Funktionen von Home Assistant und ggf. NodeRED, es werden keine zusätzlichen Add-Ons, HACS-Module oder NodeRED-Paletten benötigt. Bei Verwendung der Telefon-Anruf-Funktion muss lediglich die Integration <a src="https://www.home-assistant.io/integrations/fritzbox/" target="_blank">AVM FRITZ!SmartHome</a> zusätzlich installiert werden.
<hr>
<h2>Vorbereitung</h2>
Zur Ausführung benötigt <b>Noticade</b> keine Helfer - zur Triggerung kann jede beliebige Entität verwendet werden, welche den Zustand "on" einnehmen kann (natürlich kann auch jeder andere Zustand überwacht werden, allerdings muss dies dann auch an allen relevanten Stellen im Script bzw. Flow angepasst werden.).<br />
Es wird jedoch trotzdem die Verwendung eines separaten Helfers als Trigger empfohlen, der nur bei Auftreten des eigentlich zu überwachenden Ereignisses auf "on" gesetzt wird. Auf diese Weise kann man die Benachrichtigungs-Kaskade ggf. abschalten, selbst wenn der auslösende Zustand vielleicht noch nicht behoben ist (bspw. Heizungsaufall).<br />
Sofern <b>Noticade</b> auch Telefon-Anrufe anstoßen soll, müssen dazu vorher in einer FRITZ!Box im Bereich "Smart Home" entsprechende Vorlagen für automatische Anrufe erstellt werden. Wie das geht, kann man sich &nbsp;&raquo;&nbsp;<a href="https://github.com/migacode/home-assistant/blob/main/noticade/img/fb_smarthome_vorlage_anruf_erstellen.png" target="_blank">hier</a> ansehen.<br />
Zur Integration von <b>Noticade</b> in Home Assistant stehen zwei Varianten zur Verfügung, so dass sich jeder seine bevorzugte Variante aussuchen kann.
<br />

<hr>
<h2>Noticade für Home Assistant (Varianten)</h2><ul>
<li><a href="#automation">Native Automatisierung (Yaml-Code)</a></li>
<li><a href="#nodered_flow">NodeRED-Flow (mit JavaScript-Funktionsblock)</a></li>
</ul>

<a id="automation"></a>
<hr>
<h3>Automatisierung (native)</h3>
<b>Quelltext</b>&nbsp;&raquo;&nbsp;<a href="https://github.com/migacode/home-assistant/blob/main/noticade/code/noticade_1.00.yaml"><strong>noticade_1.00.yaml</strong></a><br />
<br />
Den Quelltext in die <b>automations.yaml</b> kopieren und im Bereich "Individuelle Konfiguration" <br />
<br />
1. Die Parameter im Absatz "Individuelle Konfiguration / variables" gemäß eigenen Vorstellungen anpassen.<br />
<br />
2. In der Vorlage sind drei Iterationen / Empfänger angelegt. Wenn weniger benötigt werden, überzählige Iterationen einfach löschen. Wenn mehr benötigt werden, einen beliebigen Iterations-Block vollständig kopieren und am Ende hinzufügen.<br />
<br />
3. Sämtliche Vorkommen von "input_boolean.ereignis_zustand" mit der Entität des eigenen zu überwachenden Helfers oder Sensors ersetzen.<br />
<br />
4. Sämtliche Vorkommen von "notify.mobile_app_(1 .. n)" mit den Entitäten der jeweils eigenen mobilen HA-Apps ersetzen.<br />
<br />
5. Wenn Telefon-Anrufe sämtliche Vorkommen von "button.anruf_telefon_(1 .. n)" jeweils mit den entsprechenden eigenen Entitäten ersetzt werden. Wenn durch diese Automatisierung keine Anrufe erfolgen sollen, sollten die entsprechenden Aktionen entweder auskommentiert oder gelöscht werden.<br />
<br />
<br />
<a id="nodered_flow"></a>
<hr>
<h3>NodeRED-Flow</h3>
<img src="./img/noticade_img_nodered_flow.png">
<b>Download</b> NodeRED-Flow&nbsp;&raquo;&nbsp;<a href="https://github.com/migacode/home-assistant/blob/main/noticade/code/noticade_nodered_flow_1.00.json"><strong>noticade_nodered_flow_1.00.json</strong></a><br />
<br />
Den Quelltext/Flow in NodeRED importieren und wie folgt anpassen.<br />
<br />
1. In Node "Ereignis (Zustand)" die Entität durch die gewünschte zu überwachende Entität bzw. einen entsprechenden Helfer ersetzen.<br /><br />
<img src="./img/noticade_img_node_1_trigger.png">
<br />
2. In Node "Initalisierung" im Bereich "Konfiguration" die dort vorhandenen Werte gemäß den eigenen Wünschen anpassen..<br />
In der Voreingestellung werden je Empfänger 3 mal jeweils im Abstand von 60 Sekunden Benachrichtigung versendet. In der
<br /><br />
<img src="./img/noticade_img_node_2_initialisierung.png">
<br />
<hr>
