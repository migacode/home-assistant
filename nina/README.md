# Home Assistant // NINA-Warnungen

<strong>Erweiterungen für die <a href="https://www.home-assistant.io/integrations/nina/">NINA-Integration</a> von Home Assistant</strong><br />
<ul>
<li><a href="#automation">Native Automation zum Versenden von NINA-Warnungen an Telegram<sup>1</sup>, HA-App<sup>2</sup> und Dashboard</a></li>
<li><a href="#nodered">NodeRED-Flow zum Versenden von NINA-Warnungen an Telegram<sup>1</sup>, HA-App<sup>2</sup> und Dashboard</a></li>
<li><a href="#dashboard">Dashboard-(Lovelace-)Karte zur Anzeige von NINA-Warnungen in Home Assistant</a></li>
</ul>
(1) Für den Versand von Benachrichtigungen an Telegram muss die entsprechende <a href="https://www.home-assistant.io/integrations/telegram">Telegram-Integration</a> natürlich zuvor eingerichtet sein.<br />
(2) Ebenso erfolgt der Versand an die HA-App natürlich auch nur, wenn diese auf dem/n Endgerät/en installiert und eingerichtet ist.<br />

<a id="automation"></a>
<hr>
<strong>Automation zum Versenden von NINA-Warnungen an Telegram, HA-App und Dashboard (native)</strong><br />
<br />
<img src="./img/NINA_img_notification.png">
Quelltext: <a href="https://github.com/migacode/home-assistant/blob/main/nina/code/NINA_warnings_automation.yaml">NINA_warnings_automation.yaml</a><br />
<br />
Den Quelltext wie folgt anpassen und in die <b>automations.yaml</b> kopieren.<br />
<br />
1. An den markierten Stellen die Entitäts-Namen der Sensoren jeweils durch die eigenen ersetzen.<br />
Dabei beachten, für den Eintrag <i>nina_entity_name</i> den Entitäts-Namen generisch ohne Nummern, aber mit Unterstrich am Ende zu schreiben ;)<br />
<br />
<img src="./img/NINA_img_changes_automation_1.png">
2. An den markierten Stellen die Service-Namen für die Benachrichtigungen jeweils durch die eigenen ersetzen.<br />
<br />
<img src="./img/NINA_img_changes_automation_2.png">
Selbstverständlich muss man auch nicht alle Kanäle nutzen - wer keine Benachrichtigung an Telegram, die HA-App oder das Dashboard wünscht, kann in dem Bereich <i>action:</i> die Zeilen für den jeweiligen Service einfach löschen.<br />
<br />
3. Nicht vergessen bei den Entwicklerwerkzeugen die Konfiguration zu prüfen und Automatisierungen neu zu laden :)<br />
<br />

<a id="nodered"></a>
<hr>
<strong>NodeRED-Flow zum Versenden von NINA-Warnungen an Telegram, HA-App und Dashboard</strong><br />
<br />
<img src="./img/NINA_img_nodered_flow.png">
NodeRED-Flow: <a href="https://github.com/migacode/home-assistant/blob/main/nina/code/NINA_warnings_nodered_flow.json">NINA_warnings_nodered_flow.json</a><br />
<br />
Den Quelltext/Flow in NodeRED importieren und wie folgt anpassen.<br />
<br />
1. Im Node 1 (NINA-Warnungen triggern) an den markierten Stellen die Entitäts-Namen der Sensoren jeweils durch die eigenen ersetzen.<br />
<br />
<img src="./img/NINA_img_changes_flow_1.png">
2. In Node 2 (Warnungen auslesen und Nachricht zusammenbauen) an den markierten Stellen die Entitäts-Namen der Sensoren jeweils durch die eigenen ersetzen. Dabei beachten, für den Eintrag <i>nina_entity_name</i> den Entitäts-Namen generisch ohne Nummern, aber mit Unterstrich am Ende zu schreiben ;)<br />
<br />
<img src="./img/NINA_img_changes_flow_2.png">
3. In den Nodes 3.a und 3.b jeweils den Service-Namen für die Benachrichtigung durch den eigenen ersetzen.<br />
Selbstverständlich muss man auch nicht alle Kanäle nutzen - wer keine Benachrichtigung an Telegram, die HA-App oder das Dashboard wünscht, kann den entsprechenden Node (3.a, 3.b, 3.c) einfach löschen.<br />
<br />

<a id="dashboard"></a>
<hr>
<strong>Dashboard-(Lovelace-)Karte zur Anzeige von NINA-Warnungen in Home Assistant</strong><br />
<br />
<img src="./img/NINA_img_no_warnings.png">
<img src="./img/NINA_img_warning.png">
Quelltext: <a href="https://github.com/migacode/home-assistant/blob/main/nina/code/NINA_warnings_dashboard_card.yaml"><strong>NINA_warnings_dashboard_card.yaml</strong></a><br />
<br />
Den Quelltext wie folgt anpassen und als neue Karte (manuell über YAML-Code einfügen) im Dashboard anlegen.<br />
<br />
1. An der markierten Stelle den Entitäts-Namen des Sensors durch den eigenen ersetzen. Dabei beachten, für den Eintrag <i>nina_entity_name</i> den Entitäts-Namen generisch ohne Nummern, aber mit Unterstrich am Ende zu schreiben ;)<br />
<br />
<img src="./img/NINA_img_changes_dashboard.png">
2. Wer einen anderen Ort als Hörstel verwendet, möchte vermutlich auch noch die Überschrift mit der Angabe <i>title:</i> anpassen.<br/>
<br />
3. Die Schriftfarben sind für die Darstellung auf dunklem Hintergrund konfiguriert. Wer die Karte auf einem hellen Hintergrund nutzen möchte (oder andere Farben bevorzugt), kann die Farben ggf. sehr einfach durch andere RGB-Werte in den entsprechend selbsterklärenden color-Variablen anpassen.<br />
Darüber hinaus verwendet die Karte das HACS-Modul "card-mod", jedoch nur zur Gestaltung der Karten-Umrandung. Wer card-mod nicht verwendet, oder wem die Karte unformatiert besser gefällt, der kann die entsprechenden Style-Angaben problemlos entfernen.<br />
<br />

<hr>
