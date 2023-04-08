# Home Assistant - NINA Warnungen

<strong>Erweiterungen für die <a href="https://www.home-assistant.io/integrations/nina/">NINA-Integration</a> von Home Assistant</strong><br />
<ul>
<li><a href="#automation">Native Automation zum Versenden von NINA-Warnungen an Telegram<sup>1</sup>, HA-App<sup>2</sup> und Dashboard</a></li>
<li><a href="#nodered">NodeRed-Flow zum Versenden von NINA-Warnungen an Telegram<sup>1</sup>, HA-App<sup>2</sup> und Dashboard</a></li>
<li><a href="#dashboard">Dashboard-Karte zur Anzeige von NINA-Warnungen in Home Assistant</a></li>
</ul>
(1) Für den Versand von Benachrichtigungen an Telegram muss die entsprechende <a href="https://www.home-assistant.io/integrations/telegram">Telegram-Integration</a> natürlich zuvor eingerichtet sein.<br />
(2) Ebenso erfolgt der Versand an die HA-App natürlich auch nur, wenn diese auf dem/n Endgerät/en installiert und eingerichtet ist.<br />

<a id="automation"></a>
<hr>
<strong>Automation zum Versenden von NINA-Warnungen an Telegram, HA-App und Dashboard (native)</strong><br />
<br />
<img src="./img/NINA_img_notification.png">
Quelltext: <a href="https://github.com/migacode/home-assistant/blob/main/nina/NINA_warnings_automation.yaml">NINA_warnings_automation.yaml</a><br />
<br />
Den Quelltext wie folgt anpassen und in die <b>automations.yaml</b> kopieren.<br />
<br />
1. An den markierten Stellen die Entitäts-Namen jeweils durch die eigenen ersetzen.<br />
Dabei beachten, als <i>nina_entity_name</i> den Entitäts-Namen generisch ohne Nummern, aber mit Unterstrich am Ende zu schreiben ;)<br />
<br />
<img src="./img/NINA_img_changes_automation.png">
Selbstverständlich muss man auch nicht alle Kanäle nutzen - wer keine Benachrichtigung an Telegram, die HA-App oder das Dashboard wünscht, kann in dem Bereich <i>action:</i> die Zeilen für den jeweiligen Service einfach löschen.<br />
<br />
2. Nicht vergessen bei den Entwicklerwerkzeugen die Konfiguration zu püfen und Automatisierungen neu zu laden ;)<br />
<br />

<a id="nodered"></a>
<hr>
<strong>NodeRed-Flow zum Versenden von NINA-Warnungen an Telegram, HA-App und Dashboard</strong><br />
<br />
<img src="./img/NINA_img_nodered_flow.png">
NodeRED-Flow: <a href="https://github.com/migacode/home-assistant/blob/main/nina/NINA_warnings_nodered_flow.json">NINA_warnings_nodered_flow.json</a><br />
<br />
Die Datei in NodeRED importieren und wie folgt anpassen.<br />
<br />
1. Im Node 1 (NINA-Warnungen triggern) an den markierten Stellen die Entitäts-Namen geweils durch die eigenen ersetzen.<br />
Dabei beachten, als <i>msg.topic</i> den Entitäts-Namen generisch ohne Nummern, aber mit Unterstrich am Ende zu schreiben ;)<br />
<br />
<img src="./img/NINA_img_changes_flow.png">
2. Danach noch in den Nodes 7.a und 7.b jeweils den Service-Namen durch den eigenen ersetzen.<br />
Selbstverständlich muss man auch nicht alle Kanäle nutzen - wer keine Benachrichtigung an Telegram, die HA-App oder das Dashboard wünscht, kann den entsprechenden Node (7.a, 7.b, 7.c) einfach löschen.<br />
<br />

<a id="dashboard"></a>
<hr>
<strong>Dashboard-Karte zur Anzeige von NINA-Warnungen in Home Assistant</strong><br />
<br />
<img src="./img/NINA_img_no_warnings.png">
<img src="./img/NINA_img_warnings.png">
Quelltext: <a href="https://github.com/migacode/home-assistant/blob/main/nina/NINA_warnings_dashboard_card.yaml"><strong>NINA_warnings_dashboard_card.yaml</strong></a><br />
<br />
Den Quelltext wie folgt anpassen und als neue Karte (manuell über YAML-Code einfügen) im Dashboard anlegen.<br />
<br />
1. An der markierten Stelle den Entitäts-Namen durch den eigenen ersetzen. Dabei beachten, als <i>nina_entity_name</i> den Entitäts-Namen generisch ohne Nummern, aber mit Unterstrich am Ende zu schreiben ;)<br />
<br />
<img src="./img/NINA_img_changes_dashboard.png">
2. Wer einen anderen Ort als Hörstel verwendet, möchte vermutlich auch noch die Überschrift <i>title:</i> anpassen :)<br/>
<br />
3. Die Schriftfarben sind für die Darstellung auf dunklem Hintergrund konfiguriert. Wer die Karte auf einem hellen Hintergrund nutzen möchte (oder andere Farben bevorzugt), kann die Farben ggf. sehr einfach durch andere RGB-Werte in den entsprechend selbsterklärenden color-Variablen anpassen :)<br />
Darüber hinaus verwendet die Karte das HACS-Modul "card-mod", jedoch nur zur Gestaltung der Karten-Umrandung. Wer card-mod nicht verwendet, oder wem die Karte unformattiert besser gefällt, der kann die entsprechenden Style-Angaben problemlos entfernen.<br />
<br />

<hr>
