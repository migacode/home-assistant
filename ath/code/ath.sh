#!/bin/bash
# =============================================================================
# AbfuhrTerminHinweise
# ---------------------------------------------------------------------
# Anzeige der am heutigen oder morgigen Tag geplanten Abfallabholungen
# ---------------------------------------------------------------------
# Name:    ath
# Version: 1.10
# Datum:   25.04.2024
# Quelle:  https://github.com/migacode/home-assistant
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
DATA_FILES[1]="vennweghoerstel.ics"
DATA_NAMES[1]="Vennweg"
# -----------
# DATA_FILES[2]="stuewwestrassehoerstel.ics"
# DATA_NAMES[2]="Stüwwestraße"
# -----------
# DATA_FILES[3]="dateiname3.ics"
# DATA_NAMES[3]="Straße 3"
# -----------
# -----------------------------------------------------------------------------
# Angezeigtes Trennzeichen zwischen den Straßen
# -----------------------------------------------------------------------------
SEPERATOR=" | "
# -----------------------------------------------------------------------------
# Hinweistext / Ausgabe wenn keine Abfuhr geplant ist
# ACHTUNG: Nicht ändern! Die zugehörige Automatisierung und der NodeRED-Flow
#          prüfen auf das Vorhandensein dieses Textes. Wenn ein anderer Text
#          angezeigt werden soll, müssen diese ebenfalls angepasst werden!
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
# Laufendes Jahr
THIS_YEAR=$(date +%Y)
# Anzahl der Straßen
NUMBER_OF_STREETS=${#DATA_FILES[@]}
# Text der Ausgabe
RESULT=""
# =============================================================================
# Here we go ...
# =============================================================================
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
    RESULT+="$MISSING_TEXT"
  else
    # ------------------------------------------------
    # 2. Prüfen ob die Info-Datei für dieses Jahr ist
    # ------------------------------------------------
    if [ $(grep -c -E "DATE:$THIS_YEAR" "$INFO_DATA_FILE") -eq 0 ];
    then
      RESULT+="$MISSING_TEXT"
    fi
  fi
  ((CURRENT_STREET+=1))
done
# -----------------------------------------------------------------------------
# Festlegen des abzufragenden Datums (heute oder morgen)
# -----------------------------------------------------------------------------
if [ "$SCRIPT_MODE" == "-h" ] ||
   [ "$SCRIPT_MODE" == "h" ];
then
  SEARCH_DATE="$TODAY_DATE"
else
  SEARCH_DATE="$TOMORROW_DATE"
fi
# -----------------------------------------------------------------------------
# Alle Straßen durchlaufen
# -----------------------------------------------------------------------------
CURRENT_STREET=1
while [ $CURRENT_STREET -le $NUMBER_OF_STREETS ];
do
  # ------------------------------------------------------
  # Relevante Daten für das zu suchende Datum extrahieren
  # ------------------------------------------------------
  INFO_DATA_FILE="$FILES_PATH/${DATA_FILES[$CURRENT_STREET]}"
  if [ -s "$INFO_DATA_FILE" ];
  then
    TOMORROW_COLLECTIONS=$(grep -i -A 20 "BEGIN:VEVENT" "$INFO_DATA_FILE" | grep -i -B 20 "END:VEVENT" | grep -i -E "(DTSTART|SUMMARY)" | grep -A 1 "$SEARCH_DATE" | grep -i -E "SUMMARY")
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
      # ------------------------------
      # Gefundene Abfuhren hinzufügen
      # ------------------------------
      RESULT+="$TOMORROW_COLLECTIONS"
      # ------------------------------------------------------
      # Wenn es weitere Straßen gibt, Trennzeichen hinzufügen
      # ------------------------------------------------------
      if [ "$RESULT" != "" ] &&
         [ $CURRENT_STREET -lt $NUMBER_OF_STREETS ];
      then
        RESULT+="$SEPERATOR"
      fi
    fi
  fi
  ((CURRENT_STREET+=1))
done
# -----------------------------------------------------------------------------
# Ergebnis bereinigen und ausgeben
# -----------------------------------------------------------------------------
if [ "$RESULT" == "" ]; then RESULT="$NO_COLLECTION"; fi
echo $(echo "$RESULT" | sed -e "s/$SEPERATOR\s*$//")
