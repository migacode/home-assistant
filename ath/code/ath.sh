#!/bin/bash
# =============================================================================
# AbfuhrTerminHinweise (ATH) - Anzeige von Terminen zur Abfallabholung
# -----------------------------------------------------------------------------
# Name:    ath.sh
# Version: 1.24
# Datum:   28.04.2024
# Quelle:  https://github.com/migacode/home-assistant
# -----------------------------------------------------------------------------
#
# Syntax: ath.sh [Zeit] [Optionen] [Filter]
#
# Zeiten (nur einzeln zu verwenden)
#  -h        sucht nach Terminen heute
#  -m        sucht nach Terminen morgen (Default ohne Zeit-Parameter)
#  -n        sucht nach den nächsten Terminen ab morgen
#
# Optionen
#  -a        unterdrückt die Anzeige der Abfuhr/Abfallarten
#  -d Datum  sucht beginnend mit diesem Datum (Format: TTMM) statt morgen
#  -o        unterdrückt die Anzeige des Straßenamens/Ortes
#  -s Index  sucht nur in der Straße mit dem Index (1 .. n wie in DATA_FILES)
#  -w        stellt dem Datum (sofern angezeigt) auch den Wochentag voran
#
# Filter
#   Eine beliebige Zeichenfolge (ohne Leerzeichen und mindestens
#   drei Zeichen lang), die in der Abfuhrart vorkommen soll.
#
# -----------------------------------------------------------------------------
#
# Beispiel 1: ath.sh -m
# sucht für alle Straßen nach allen Abfuhrarten am morgigen Tag
#
# Beispiel 2: ath.sh -h papier
# sucht für alle Straßen nach einer Abfuhr der Papiertonne am heutigen Tag
#
# Beispiel 3: ath.sh -n -s 1 -d 0107 bio
# sucht nur für die Straße mit dem Index 1 nach dem ersten Termin zur
# Abfuhr der Biotonne ab dem 01.07. des laufenden Jahres
#
# =============================================================================
# Konfiguration
# =============================================================================
# -----------------------------------------------------------------------------
# Absoluter Pfad zu den Dateien mit den Informationen der Abfuhrtermine
# (Angabe ohne Schrägstrich / Slash am Ende)
# -----------------------------------------------------------------------------
FILES_PATH="/config/www/ath"
# -----------------------------------------------------------------------------
# Quellangaben der zu verwendenden Info-Dateien
# WICHTIG: Die Dateien müssen im Format ICS sein.
# Bei mehreren Straßen Einträge je Array fortlaufend nummerieren.
# -----------------------------------------------------------------------------
declare -A DATA_FILES # Dateien mit Informationen zu den Abfuhrterminen
declare -A DATA_NAMES # Angezeigte Sraßennamen
# ----------------------------------------------------------------------
DATA_FILES[1]="vennweghoerstel.ics"
DATA_NAMES[1]="Vennweg"
# -----------
# DATA_FILES[2]="stuewwestrassehoerstel.ics"
# DATA_NAMES[2]="Stüwwestraße"
# -----------
# DATA_FILES[3]="awb-abfuhrtermine.ics"
# DATA_NAMES[3]="Köln"
# -----------------------------------------------------------------------------
# Angezeigtes Trennzeichen zwischen den Straßen
# -----------------------------------------------------------------------------
SEPERATOR=" | "
# =============================================================================
# Here we go ...
# =============================================================================
# -----------------------------------------------------------------------------
# Ausgabe / Rückgabetext initialisieren
# -----------------------------------------------------------------------------
COLLECTIONS_FOUND=""
# -----------------------------------------------------------------------------
# Hinweistext / Ausgabe wenn keine Abfuhr geplant ist definieren
# ACHTUNG: Nicht ändern! Die zugehörige Automatisierung und der NodeRED-Flow
#          prüfen auf das Vorhandensein dieses Textes. Wenn ein anderer Text
#          angezeigt werden soll, müssen diese ebenfalls angepasst werden!
# -----------------------------------------------------------------------------
NO_COLLECTION="Keine"
# -----------------------------------------------------------------------------
# Aktuelle Jahreszahlen ermitteln
# -----------------------------------------------------------------------------
THIS_YEAR=$(date +"%Y")
NEXT_YEAR=$((THIS_YEAR+1))
# -----------------------------------------------------------------------------
# Anzahl der zu überwachenden (konfigurierten) Straßen ermitteln
# -----------------------------------------------------------------------------
NUMBER_OF_STREETS=${#DATA_FILES[@]}
# -----------------------------------------------------------------------------
# Prüfen ob Daten für alle zu überwachenden Straßen vorhanden sind
# -----------------------------------------------------------------------------
CURRENT_STREET=1
while [ $CURRENT_STREET -le $NUMBER_OF_STREETS ];
do
  MISSING_TEXT="Keine Daten für "
  if [ "${DATA_NAMES[$CURRENT_STREET]}" != "" ];
  then
    MISSING_TEXT+="${DATA_NAMES[$CURRENT_STREET]} "
  fi
  MISSING_TEXT+="[$CURRENT_STREET]$SEPERATOR"
  # ------------------------------------------------------
  # 1. Prüfen ob eine Info-Datei für die Straße existiert
  # ------------------------------------------------------
  INFO_DATA_FILE="$FILES_PATH/${DATA_FILES[$CURRENT_STREET]}"
  if [ ! -s "$INFO_DATA_FILE" ];
  then
    COLLECTIONS_FOUND+="$MISSING_TEXT"
  else
    # ------------------------------------------------
    # 2. Prüfen ob die Info-Datei für dieses Jahr ist
    # ------------------------------------------------
    if [ $(grep -c -E "DATE:$THIS_YEAR" "$INFO_DATA_FILE") -eq 0 ];
    then
      COLLECTIONS_FOUND+="$MISSING_TEXT"
    fi
  fi
  ((CURRENT_STREET+=1))
done
# -----------------------------------------------------------------------------
# Berechnungen der Eckdaten für die Zeitangaben
# (Etwas kompliziert, aber dafür kompatibel mit diversen Shells ;)
# -----------------------------------------------------------------------------
SECONDS_A_DAY=86400
TODAY_FIRST_SECOND=$(date -d"$(date +%Y)-$(date +%m)-$(date +%d)" +"%s")
FROM_FIRST_SECOND=$TODAY_FIRST_SECOND
TOMORROW_FIRST_SECOND=$((TODAY_FIRST_SECOND+SECONDS_A_DAY))
TODAY_LAST_SECOND=$((TODAY_FIRST_SECOND+SECONDS_A_DAY-1))
TOMORROW_LAST_SECOND=$((TODAY_LAST_SECOND+SECONDS_A_DAY))
NEXT_YEAR_FIRST_SECOND=$(date -d"$NEXT_YEAR-01-01" +"%s")
THIS_YEAR_LAST_SECOND=$((NEXT_YEAR_FIRST_SECOND-1))
# -----------------------------------------------------------------------------
# Festlegen des abzufragenden Zeitraums
# Default: Nur morgen nach Terminen suchen
# -----------------------------------------------------------------------------
SEARCH_MODE="TOMORROW"
# -----------------------------------------------------------------------------
# Beim Aufruf übergebene Parameter einlesen
# -----------------------------------------------------------------------------
PARAMETER_LIST=()
for arg in $@;
do
  arg=$(printf %b "${arg}" | tr A-Z a-z | sed -E 's/[^a-z0-9]//gi' | xargs)
  PARAMETER_LIST+=("$arg")
done
ARG_ANZ=${#PARAMETER_LIST[@]}
# --------------------------------------------------------
# Der letzte Parameter ist der Text-Filter, sofern dieser
# nicht zu einem anderen Parameter gehört (siehe unten)
# --------------------------------------------------------
SEARCH_FILTER=""
if [ $ARG_ANZ -gt 0 ];
then
  SEARCH_FILTER="$(echo ${!ARG_ANZ} | sed -E 's/\-//g' | xargs)" # "${!ARG_ANZ}"
  if [ ${#SEARCH_FILTER} -lt 3 ];
  then
    SEARCH_FILTER=""
  fi
fi
# ------------------------------
# Gewählte Optionen analysieren
# ------------------------------
SEARCH_STREET=0
SHOW_WEEK_DAY=0
HIDE_STREET_NAME=0
HIDE_TRASH_TYPE=0
ARG_POS=1
for arg in ${PARAMETER_LIST[@]};
do
  ((ARG_POS+=1))
  # -----------------------------------
  # Anzeige der Abfallart unterdrücken
  # -----------------------------------
  if [ "$arg" == "a" ]; then HIDE_TRASH_TYPE=1; fi
  # -----------------------------------------
  # Suche ab einem bestimmten Datum anfangen
  # -----------------------------------------
  if [ "$arg" == "d" ];
  then
    USER_DATE=$(echo ${!ARG_POS} | sed -E 's/[^0-9]//gi' | xargs)
    USER_SECONDS=$(date -d"$THIS_YEAR-${USER_DATE:2:2}-${USER_DATE:0:2}" +"%s" 2>/dev/null)
    if [ $? -eq 0 ];
    then
      SEARCH_MODE="FROM"
      FROM_FIRST_SECOND=$USER_SECONDS
    fi
  fi
  # ------------
  # Suche heute
  # ------------
  if [ "$arg" == "h" ]; then SEARCH_MODE="TODAY"; fi
  # -------------
  # Suche morgen
  # -------------
  if [ "$arg" == "m" ]; then SEARCH_MODE="TOMORROW"; fi
  # ----------------------
  # Suche nächsten Termin
  # ----------------------
  if [ "$arg" == "n" ]; then SEARCH_MODE="NEXT"; fi
  # ---------------------------------------
  # Anzeige des Straßennamens unterdrücken
  # ---------------------------------------
  if [ "$arg" == "o" ]; then HIDE_STREET_NAME=1; fi
  # ---------------------------
  # Nur für eine Straße suchen
  # ---------------------------
  if [ "$arg" == "s" ];
  then
    SEARCH_STREET=$(echo ${!ARG_POS} | sed -E 's/[^0-9]//gi' | xargs)
    if [ "$SEARCH_STREET" == "" ];
    then
      SEARCH_STREET=0
    else
      if [ $SEARCH_STREET -gt $NUMBER_OF_STREETS ];
      then
        SEARCH_STREET=0
      fi
    fi
  fi
  # -------------------
  # Wochentag anzeigen
  # -------------------
  if [ "$arg" == "w" ]; then SHOW_WEEK_DAY=1; fi
  # ----------------------------------------------------
  # Wenn der letzte Parameter zu dem vorherigen gehört,
  # ist dieser kein Filter, so dass jener leer bleibt
  # ----------------------------------------------------
  if [ $ARG_POS -eq $ARG_ANZ ];
  then
    if [ "$arg" == "d" ] ||
       [ "$arg" == "s" ];
    then
      SEARCH_FILTER=""
    fi
  fi
done
# -----------------------------------------------------------------------------
# Anpassung des abzufragenden Zeitraums
# -----------------------------------------------------------------------------
# Mit Parameter "d" ab einem bestimmten Tag suchen
if [ "$SEARCH_MODE" == "FROM" ];
then
  CURRENT_DATE=$FROM_FIRST_SECOND
  LAST_DATE=$THIS_YEAR_LAST_SECOND
fi
# Mit Parameter "h" nur heute nach Terminen suchen
if [ "$SEARCH_MODE" == "TODAY" ];
then
  CURRENT_DATE=$TODAY_FIRST_SECOND
  LAST_DATE=$TODAY_LAST_SECOND
fi
# Mit Parameter "m" oder ohne Parameter nur morgen nach Terminen suchen
if [ "$SEARCH_MODE" == "TOMORROW" ];
then
  CURRENT_DATE=$TOMORROW_FIRST_SECOND
  LAST_DATE=$TOMORROW_LAST_SECOND
fi
# Mit Parameter "n" den nächsten Termin bis zum Ende des Jahres suchen
if [ "$SEARCH_MODE" == "NEXT" ];
then
  CURRENT_DATE=$TOMORROW_FIRST_SECOND
  LAST_DATE=$THIS_YEAR_LAST_SECOND
fi
# -----------------------------------------------------------------------------
# NUR ZUM TESTEN
# -----------------------------------------------------------------------------
# echo -e "START:  $(date -d "@$CURRENT_DATE" +"%Y%m%d")"
# echo -e "ENDE:   $(date -d "@$LAST_DATE" +"%Y%m%d")"
# echo -e "STRIDX: $SEARCH_STREET"
# echo -e "FILTER: $SEARCH_FILTER"
# exit 0
# -----------------------------------------------------------------------------
# Tage durchlaufen (zur einfacheren Kalkulation mit Hilfe von Sekunden)
# -----------------------------------------------------------------------------
FOUND=0
while [ $CURRENT_DATE -le $LAST_DATE ] &&
      [ $FOUND -eq 0 ];
do
  # ---------------------------------------------
  # Datum konvertieren (Sekunden in Tagesformat)
  # ---------------------------------------------
  SEARCH_DATE=$(date -d "@$CURRENT_DATE" +%Y%m%d)
  # -------------------------
  # Alle Straßen durchlaufen
  # -------------------------
  CURRENT_STREET=1
  while [ $CURRENT_STREET -le $NUMBER_OF_STREETS ];
  do
    # ---------------------------------------------------------
    # Wenn ein Straßenfilter gesetzt ist, nur für diese suchen
    # ---------------------------------------------------------
    if [[ $SEARCH_STREET -eq 0 || $SEARCH_STREET -eq $CURRENT_STREET ]];
    then
      # ------------------------------------------------------
      # Relevante Daten für das zu suchende Datum extrahieren
      # ------------------------------------------------------
      INFO_DATA_FILE="$FILES_PATH/${DATA_FILES[$CURRENT_STREET]}"
      if [ -s "$INFO_DATA_FILE" ];
      then
        # ---------------------------------------------------------------------
        # The Magic begins ;) ...
        # ---------------------------------------------------------------------
        # - 16 Zeilen nach jedem "BEGIN:VEVENT" und
        # - 16 Zeilen vor jedem "END:VEVENT" und daraus
        # - alle Zeilen, in denen "DTSTART" oder "SUMMARY" vorkommt extrahieren
        # => ergibt jeweils 2 Zeilen
        # ---------------------------------------------------------------------
        TOMORROW_COLLECTIONS=$(grep -i -A 16 "BEGIN:VEVENT" "$INFO_DATA_FILE" | grep -i -B 16 "END:VEVENT" | grep -i -E "(DTSTART|SUMMARY)")
        # ---------------------------------------------------------------------
        # Nur die Einträge extrahieren, die auch das gesuchte Datum enthalten:
        # Leider kann sich die Reihenfolge der Eintragszeilen unterscheiden,
        # d.h. je nachdem ob zuerst DTSTART oder SUMMARY in den zwei Zeilen
        # steht, steht die entsprechende Abfuhrart "SUMMARY" in der jeweils
        # anderen Zeile, also danach (A) oder davor (B) ;)
        # ---------------------------------------------------------------------
        if [ $(echo "$TOMORROW_COLLECTIONS" | head -n 1 | grep -c -i "DTSTART") -gt 0 ];
        then
          TOMORROW_COLLECTIONS=$(echo "$TOMORROW_COLLECTIONS" | grep -A 1 "$SEARCH_DATE")
        else
          TOMORROW_COLLECTIONS=$(echo "$TOMORROW_COLLECTIONS" | grep -B 1 "$SEARCH_DATE")
        fi
        # ---------------------------------------------------------------------
        # Nur die Abfuhrarten auswählen, die den Such-Filter beinhalten und
        # danach alle doppelten Einträge / Zeilen entfernen
        # ---------------------------------------------------------------------
        TOMORROW_COLLECTIONS=$(echo "$TOMORROW_COLLECTIONS" | grep -i -E "SUMMARY" | grep -i "$SEARCH_FILTER" | awk '!seen[$0]++')
        # ---------------------------------------------------------------------
        # Aus der fertigen "Liste" die Anzahl der Anfuhren ermitteln
        # ---------------------------------------------------------------------
        NUMBER_OF_COLLECTIONS=$(echo "$TOMORROW_COLLECTIONS" | grep -c -i "SUMMARY")
        # ---------------------------------------------------------------------
        # Wenn es Abfuhren gibt ...
        # --------------------------
        if [ $NUMBER_OF_COLLECTIONS -gt 0 ];
        then
          # --------------------------------------------
          # Im Modus "FROM" und "NEXT" Datum hinzufügen
          # --------------------------------------------
          if [ "$SEARCH_MODE" == "FROM" ] ||
             [ "$SEARCH_MODE" == "NEXT" ];
          then
            if [ $SHOW_WEEK_DAY -eq 1 ];
            then
              case $(date -d "${SEARCH_DATE:0:4}-${SEARCH_DATE:4:2}-${SEARCH_DATE:6:2}" +"%w") in
                0) WEEK_DAY="Sonntag"    ;;
                1) WEEK_DAY="Montag"     ;;
                2) WEEK_DAY="Dienstag"   ;;
                3) WEEK_DAY="Mittwoch"   ;;
                4) WEEK_DAY="Donnerstag" ;;
                5) WEEK_DAY="Freitag"    ;;
                6) WEEK_DAY="Samstag"    ;;
              esac
              COLLECTIONS_FOUND+="$WEEK_DAY "
            fi
            COLLECTIONS_FOUND+="${SEARCH_DATE:6:2}.${SEARCH_DATE:4:2}.: "
          fi
          # ------------------------------------------------------------------
          # Wenn es mehr als eine Straße gibt, dann Straßennamen mit anzeigen
          # (wenn dies nicht unterdrückt werden soll)
          # ------------------------------------------------------------------
          if [ $NUMBER_OF_STREETS -gt 1 ] &&
             [ $HIDE_STREET_NAME -eq 0 ];
          then
            COLLECTIONS_FOUND+="${DATA_NAMES[$CURRENT_STREET]}: "
          fi
          # -------------------------------------------------------------------
          # Abfuhrarten
          # (wenn dies nicht unterdrückt werden soll)
          # -------------------------------------------------------------------
          if [ $HIDE_TRASH_TYPE -eq 0 ];
          then
            # ---------------------------------------------------------
            # Arten der Abfuhr extrahieren und durch Semikolon trennen
            # ---------------------------------------------------------
            TOMORROW_COLLECTIONS=$(echo ${TOMORROW_COLLECTIONS} | sed "s/SUMMARY\s*\:\s*//gi")
            TOMORROW_COLLECTIONS=$(echo "$TOMORROW_COLLECTIONS" | tr -s '\r\n' ';' | tr -s '\r' ';' | tr -s '\n' ';')
            TOMORROW_COLLECTIONS=$(echo "$TOMORROW_COLLECTIONS" | sed -e 's/;\s*$//gi')
            # -------------------------------------------------------------
            # Wenn es mehr als eine Abfuhr gibt, diese durch "und" trennen
            # -------------------------------------------------------------
            if [ $NUMBER_OF_COLLECTIONS -gt 1 ];
            then
              TOMORROW_COLLECTIONS=$(echo "$TOMORROW_COLLECTIONS" | sed -e 's/;/ und/gi')
            fi
            # ------------------------------
            # Gefundene Abfuhren hinzufügen
            # ------------------------------
            COLLECTIONS_FOUND+="$TOMORROW_COLLECTIONS"
          fi
          # ------------------------------------------------------
          # Wenn es weitere Straßen gibt, Trennzeichen hinzufügen
          # ------------------------------------------------------
          if [ "$COLLECTIONS_FOUND" != "" ] &&
             [ $CURRENT_STREET -lt $NUMBER_OF_STREETS ];
          then
            COLLECTIONS_FOUND+="$SEPERATOR"
          fi
          # ---------------------------------------
          # Merken wenn eine Abfuhr gefunden wurde
          # ---------------------------------------
          FOUND=1
        fi
      fi
    fi
    ((CURRENT_STREET+=1))
  done
  ((CURRENT_DATE+=SECONDS_A_DAY))
done
# -----------------------------------------------------------------------------
# Ergebnis bereinigen und ausgeben
# -----------------------------------------------------------------------------
if [ "$COLLECTIONS_FOUND" == "" ]; then COLLECTIONS_FOUND="$NO_COLLECTION"; fi
echo $(echo "$COLLECTIONS_FOUND" | sed -e "s/$SEPERATOR\s*$//" | sed -e "s/\:\s*$//")
