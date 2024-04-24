<h1>Home Assistant // AbfuhrTerminHinweise (ATH)</h1>

Mit diesem Tool können Abfuhrtermine für Abfall und jede beliebige andere Entsorgung überwacht, und automatisiert Hinweise auf eine am Folgetag anstehende Abfuhr versendet werden.
Die Einrichtung dieses Tools ist in wenigen einfachen Schritten erledigt. Zur Vorbereitung sind in Home Assistant lediglich zwei Sensoren anzulegen und die zugehörigen Dateien zu kopieren.
Danach können die gewünschten Funktionen und Erweiterungen mit Hilfe dieser Sensoren zur Verfügung gestellt werden.

1.) Datei(en) mit Abfuhrinformationen herunterladen (ICS-Format)
Beispiel: https://www.egst.de/de/abfallabholung -> "MEINESTRASSE.ics"
(<MEINESTRASSE> durch eigenen Dateinamen ersetzen)

2.) In Home Assistant Ordner anlegen
In der Konsole eingeben: mkdir -p /config/www/ath
HIINWEIS: Anstelle von /config/www/ath kann auch ein beliebiger anderer Pfad gewählt werden, dann müssen jedoch auch alle nachstehenden Auftreten sowie die Pfadangaben in der Datei "ath.sh", sowie ggf. die Zugriffsrechte auf diesen Pfad entsprechend geändert werden.

3.) Folgende Dateien in den Ordner /config/www/ath kopieren
- <a href="https://github.com/migacode/home-assistant/blob/main/ath/code/ath.sh"><strong>ath.sh</strong></a><br />
- <MEINESTRASSE>.ics (<MEINESTRASSE> durch eigenen Dateinamen ersetzen)

4.) In der Datei "ath.sh" die Konfiguration anpassen
- Bei den Einträgen für DATA_FILES die Dateiname(n) gemäß der(n) zuvor heruntergeladenen Datei(en) eintragen
- Bei den Einträgen für DATA_NAMES die entsprechend angezeigte(n) Name(n) anpassen
Wenn mehr als eine Straße konfiguriert wird, müssen die entsprechenden Zeilen noch auskommentiert und ggf. mit weiteren fortlaufenden Nummern erweitert werden.

5.) Datei "ath.sh" ausführbar machen
In der Konsole eingeben: chmod +x /config/www/ath/ath.sh

6.) Command-Line-Sensoren für Home Assistant einrichten
In der <b>configuration.yaml</b> folgende Sensoren anlegen:
```yaml
command_line:
  - sensor:
      command: "/config/www/ath/ath.sh"
      name: ath_morgen
      scan_interval: 60
  - sensor:
      command: "/config/www/ath/ath.sh -h"
      name: ath_heute
      scan_interval: 60
```
und Home Assistant neu starten um die Sensoren zu aktivieren.


<hr>
<h2>Erweiterungen für die Anzeige von Abfuhrterminen in Home Assistant</h2><ul>
<!-- <li><a href="#automation">Native Automatisierung zum Versenden von DWD-Warnungen an Telegram<sup>1</sup>, HA-App<sup>2</sup> und Dashboard</a></li> -->
<li><a href="#nodered">NodeRED-Flow zum Versenden von Hinweisen an Telegram<sup>1</sup>, HA-App<sup>2</sup> und Dashboard</a></li>
<li><a href="#dashboard">Dashboard-(Lovelace-)Karte zur Anzeige von Abfuhrterminen in Home Assistant</a></li>
</ul>



<a id="nodered"></a>
<hr>
<h3>NodeRED-Flow zum Versenden von Hinweisen an Telegram, HA-App und Dashboard</h3>
<img src="./img/ATH_img_nodered_flow.png">
<b>Download</b> NodeRED-Flow&nbsp;&raquo;&nbsp;<a href="https://github.com/migacode/home-assistant/blob/main/ath/code/ATH_nodered_flow_1.00.json"><strong>ATH_nodered_flow_1.00.json</strong></a><br />
<br />



<a id="dashboard"></a>
<hr>
<h3>Dashboard-(Lovelace-)Karte zur Anzeige von Abfuhrterminen in Home Assistant</h3>
<img src="./img/ATH_dashboard_card_1.png"><img src="./img/ATH_dashboard_card_2.png">
<b>Quelltext</b>&nbsp;&raquo;&nbsp;<a href="https://github.com/migacode/home-assistant/blob/main/ath/code/ATH_dashboard_card.yaml"><strong>ATH_dashboard_card.yaml</strong></a><br />
<br />
