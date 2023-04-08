




Integration des DWD-Warndienstes in der <b>configuration.yaml</b> (Beispiel Hörstel):
```yaml
sensor:
  - platform: dwd_weather_warnings
    name: DWD-Warnungen Hoerstel
    region_name: 805566016
```
Der <i>name</i> ist frei wählbar, HA setzt daraus allerdings den Name der zugehörigen Entitäten zusammen ;)
Tipp: Als <i>region_name</i> nicht den Namen, sondern die entsprechende <i>Warncell-ID</i> eintragen, welche in folgender Liste zu finden ist.<br/>
Warncell-IDs: https://www.dwd.de/DE/leistungen/opendata/help/warnungen/cap_warncellids_csv.html
<hr>
