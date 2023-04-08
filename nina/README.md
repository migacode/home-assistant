# Home Assistant - NINA Warnungen

<strong>Erweiterungen für die <a href="https://www.home-assistant.io/integrations/nina/">NINA-Integration</a> von Home Assistant</strong><br />
<ul>
<li><a href="#automation">Native Automation zum Versenden von NINA-Warnungen an Telegram<sup>1</sup>, HA-App<sup>2</sup> und Dashboard</a></li>
<li><a href="#nodered">NodeRed-Flow zum Versenden von NINA-Warnungen an Telegram<sup>1</sup>, HA-App<sup>2</sup> und Dashboard</a></li>
<li><a href="#dashboard">Dashboard-Karte zur Anzeige von NINA-Warnungen in Home Assistant</a></li>
</ul>
(1) Für den Versand von Benachrichtigungen an Telegram muss die entsprechende <a href="https://www.home-assistant.io/integrations/telegram">Telegram-Integration</a> natürlich zuvor eingerichtet sein.<br />
(2) Ebenso erfolgt der Versand an die HA-App natürlich auch nur, wenn diese auf dem Endgerät installiert und eingerichtet ist.<br />

<a id="automation"></a>
<hr>
<strong>Automation zum Versenden von NINA-Warnungen an Telegram, HA-App und Dashboard (native)</strong><br />
<a href="https://github.com/migacode/home-assistant/blob/main/nina/NINA_warnings_automation.yaml">NINA_warnings_automation.yaml</a><br />
<br />
Previews:<br />
<img src="./img/NINA_notification.png">

<a id="nodered"></a>
<hr>
<strong>NodeRed-Flow zum Versenden von NINA-Warnungen an Telegram, HA-App und Dashboard</strong><br />
<a href="">NINA_warnings_nodered_flow.json</a><br />
<br />
Previews:<br />
<img src="./img/NINA_NodeRED_Flow.png">

<a id="dashboard"></a>
<hr>
<strong>Dashboard-Karte zur Anzeige von NINA-Warnungen in Home Assistant</strong><br />
<a href="https://github.com/migacode/home-assistant/blob/main/nina/NINA_warnings_dashboard_card.yaml"><strong>NINA_warnings_dashboard_card.yaml</strong></a><br />
<br />
Previews:<br />
<img src="./img/NINA_no_warnings.png"><br />
<img src="./img/NINA_warnings.png">
<hr>
