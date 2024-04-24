#!/bin/bash
# =============================================================================
# AbfuhrTerminHinweise
# ---------------------------------------------------------------------
# Anzeige der am heutigen oder morgigen Tag geplanten Abfallabholungen
# ---------------------------------------------------------------------
# Name:    ath
# Version: 1.00
# Datum:   24.04.2024
# =============================================================================
# Konfiguration
# =============================================================================
# -----------------------------------------------------------------------------
# Quellangaben der zu verwendenden Info-Dateien
# WICHTIG: Die Dateien müssen im Format ICS sein.
# -----------------------------------------------------------------------------
declare -A DATA_FILES # Dateien mit Informationen zu den Abfuhrterminen
declare -A DATA_NAMES # Angezeigte Sraßennamen
# -----------------------------------------------------------------------------
# Absoluter Pfad zu den Dateien mit den Informationen der Abfuhrtermine
# (Angabe ohne Schrägstrich / Slash am Ende)
FILES_PATH="/config/www/ath"
# -----------------------------------------------------------------------------
DATA_FILES[1]="$FILES_PATH/vennweghoerstel.ics"
DATA_NAMES[1]="Vennweg"
# -----------
# DATA_FILES[2]="$FILES_PATH/stuewwestrassehoerstel.ics"
# DATA_NAMES[2]="Stüwwestraße"
# -----------
# DATA_FILES[3]="$FILES_PATH/dateiname3.ics"
# DATA_NAMES[3]="Name 3"
# -----------------------------------------------------------------------------
# Angezeigtes Trennzeichen zwischen Straßen
# -----------------------------------------------------------------------------
SEPERATOR=" | "
# -----------------------------------------------------------------------------
# Hinweistext / Ausgabe wenn keine Abfuhr geplant ist
# -----------------------------------------------------------------------------
NO_COLLECTION="Keine"
# =============================================================================
# Initialisierung (automatisch)
# =============================================================================
# Parameter zur Form der Ausgabe (-h => heute, keine/-m => morgen)
SCRIPT_MODE="${1}"
# Aktuelle Zeit (Sekunden seit Epochenbeginn)
TODAY=$(date +"%s")
# Heutiges Datum
TODAY_DATE=$(date +%Y%m%d)
# Morgen gleiche Zeit (Sekunden seit Epochenbeginn)
TOMORROW=$((TODAY+86400))
# Morgiges Datum
TOMORROW_DATE=$(date -d "@$TOMORROW" +%Y%m%d)
# Anzahl der Straßen
NUMBER_OF_STREETS=${#DATA_FILES[@]}
# Text der Ausgabe
RESULT=""
# =============================================================================
# Here we go ...
# =============================================================================
CURRENT_STREET=1
while [ $CURRENT_STREET -le $NUMBER_OF_STREETS ];
do
  # ---------------------------------------------------
  # Daten des heutigen bzw. morgigen Tages extrahieren
  # ---------------------------------------------------
  if [ "$SCRIPT_MODE" == "-h" ] ||
     [ "$SCRIPT_MODE" == "h" ];
  then
    SEARCH_DATE="$TODAY_DATE"
  else
    SEARCH_DATE="$TOMORROW_DATE"
  fi
  TOMORROW_COLLECTIONS=$(grep -i -A 20 "BEGIN:VEVENT" ${DATA_FILES[$CURRENT_STREET]} | grep -i -B 20 "END:VEVENT" | grep -i -E "(DTSTART|SUMMARY)" | grep -A 1 "$SEARCH_DATE" | grep -i -E "SUMMARY")
  NUMBER_OF_COLLECTIONS=$(echo "$TOMORROW_COLLECTIONS" | grep -c -i "SUMMARY")
  # --------------------------
  # Wenn es Abfuhren gibt ...
  # --------------------------
  if [ $NUMBER_OF_COLLECTIONS -gt 0 ];
  then
    # ------------------------------------------------------------------
    # Wenn es mehr als eine Straße gibt, dann Straßennamen mit anzeigen
    # ------------------------------------------------------------------
    if [ $NUMBER_OF_STREETS -gt 1 ];
    then
      RESULT+="${DATA_NAMES[$CURRENT_STREET]}: "
    fi
    # -----------------------------
    # Arten der Abfuhr extrahieren
    # -----------------------------
    TOMORROW_COLLECTIONS=$(echo ${TOMORROW_COLLECTIONS} | sed "s/SUMMARY\s*\:\s*//gi")
    TOMORROW_COLLECTIONS=$(echo "$TOMORROW_COLLECTIONS" | tr -s '\r\n' ';' | tr -s '\r' ';' | tr -s '\n' ';')
    TOMORROW_COLLECTIONS=$(echo "$TOMORROW_COLLECTIONS" | sed -e 's/;\s*$//')
    # -------------------------------------------------------------
    # Wenn es mehr als eine Abfuhr gibt, diese durch "und" trennen
    # -------------------------------------------------------------
    if [ $NUMBER_OF_COLLECTIONS -gt 1 ];
    then
      TOMORROW_COLLECTIONS=$(echo "$TOMORROW_COLLECTIONS" | sed -e 's/;/ und/')
    fi
    # -----------------------
    # Abfuhrarten hinzufügen
    # -----------------------
    RESULT+="$TOMORROW_COLLECTIONS"
    # --------------------------------------------------------
    # Wenn es noch mehr Straßen gibt, Trennzeichen hinzufügen
    # --------------------------------------------------------
    if [ "$RESULT" != "" ] &&
       [ $CURRENT_STREET -lt $NUMBER_OF_STREETS ];
    then
      RESULT+="$SEPERATOR"
    fi
  fi
  ((CURRENT_STREET+=1))
done
# -----------------------------------------------------------------------------
# Ergebnis bereinigen und ausgeben
# -----------------------------------------------------------------------------
if [ "$RESULT" == "" ]; then RESULT="$NO_COLLECTION"; fi
echo $(echo "$RESULT" | sed -e "s/$SEPERATOR\s*$//")
