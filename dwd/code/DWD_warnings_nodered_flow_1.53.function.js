// ============================================================================
// DWD-Warnungen versenden - NodeRED-Funktionsblock
// Version: 1.53
// Datum:   03.05.2024
// Quelle:  https://github.com/migacode/home-assistant
// ============================================================================
// Konfiguration
// ============================================================================
// ----------------------------------------------------------------------------
// Mitteilungsversand
// * = Nur bei Ausgang 1, auf Ausgang 2 werden immer alle Warnungen gesendet
// ----------------------------------------------------------------------------
// Kleinste Warnstufe, ab der Mitteilungen versendet werden (1 = alle)*
var minimum_warning_level     = 1;
// Doppelte Warnungen unterdrücken (true | false)*
var suppress_double_warnings  = true;
// Mitteilung versenden, wenn alle Meldungen aufgehoben wurden (true | false)
var send_cancellation_message = true;
// ----------------------------------------------------------------------------
// Darstellung
// ----------------------------------------------------------------------------
// Wetter-Symbole anzeigen (true | false)
var show_weather_symbols      = true;
// Aktuelle Warnstufe anzeigen (true | false)
var show_warning_level        = true;
// Zeitpunkt der letzten Aktualisierung anzeigen (true | false)
var show_last_update_time     = true;
// Im Mitteilungstext "Amtliche Warnung vor " entfernen (true | false)
var remove_pre_text_amtliche  = true;
// Zusätzlicher Text, der hinter der Haupt-Überschrift angezeigt wird
var main_headline_add_text    = '(über Node-RED)';
// ============================================================================
// Gesendete Daten des vorherigen Node einlesen
// ============================================================================
var triggering_entity   = msg.trigger_id;       // Triggernde Entität
var entity_current_data = msg.current_warnings; // Daten zu Aktuelle Warnstufe
var entity_advance_data = msg.advance_warnings; // Daten zu Vorwarnstufe
// ============================================================================
// Initialisierung
// ============================================================================
// ----------------------------------------------------------------------------
// Anzahl der vorhandenen Warnmeldungen ermitteln
// ----------------------------------------------------------------------------
var number_of_current_warnings = parseInt(entity_current_data.daten.attributes.warning_count);
var number_of_advance_warnings = parseInt(entity_advance_data.daten.attributes.warning_count);
var number_of_active_warnings  = number_of_current_warnings + number_of_advance_warnings;
// ----------------------------------------------------------------------------
// Wetter-Symbole definieren
// ACHTUNG: Die Position der Schlüsselwörter in weather_warnidx entspricht der
//          jeweiligen Position des entsprechenden Symbols in weather_symbols!
// ----------------------------------------------------------------------------
var weather_warnidx  = ['EIS', 'FROST', 'GEWITTER', 'HAGEL', 'HITZE', 'KALT', 'KÄLTE', 'ORKAN', 'REGEN', 'SCHNEE', 'STURM', 'WASSER', 'WIND'];
var weather_symbols  = ['❄️', '❄️', '🌩', '🌩', '☀️', '❄️', '❄️', '🌪', '☂️', '⛄️', '🌪', '🌊', '💨'];
var blitz            = '⚡️ ';
// ----------------------------------------------------------------------------
// Textbausteine definieren
// ----------------------------------------------------------------------------
var trennlinie       = '\n───\n';    // Trennlinie für Mitteilungen in vollen Meldungen
var trennstrich      = ' | ';        // Trennzeichen für Werte in reinen Text-Meldungen
var ende_marker      = ' |!| ';      // Trennzeichen für Warnungen in reinen Text-Meldungen
var double_warn_flag = "(Doppelt) "; // Hinweis für doppelte/redundante Warnmeldungen
// Haupt-Überschrift der Mitteilung, (CCC) wird später automatisch ersetzt
var ueberschrift     = "DWD-WARNUNG" + ((number_of_active_warnings > 1) ? 'EN (CCC)' : '');
// ----------------------------------------------------------------------------
// Intern verwendete Variablen initialisieren
// (NICHT ändern, Änderungen erfolgen zur Laufzeit nur durch das Skript selbst)
// ----------------------------------------------------------------------------
// Warnungen
var warnings_to_show = 0;     // Anzahl Meldungen größer/gleich Mindest-Warnstufe
var warning_type     = '';    // Text für Art der Warnung (Aktuell oder Vorwarnung)
var work_warning_id  = '';    // Interne ID zur Identifikation doppelter Warnungen
var warnings_id_list = '';    // Liste mit IDs bereits angezeigter Warnungen
var warning_exists   = false; // Warnung existiert in der Liste bekannter Warnungen
var warn_list_type   = null;  // Datentyp der eingelesenen Liste

// Texte für Ausgang 1
var full_message_1   = '';    // Volle Meldung mit Sonderzeichen (Wettersymbole etc.)
var short_message_1  = '';    // Gekürzte Meldung mit Sonderzeichen (max 256 Zeichen)
var text_message_1   = '';    // Volle Meldung als reiner Text ohne Sonderzeichen
// Texte für Ausgang 2
var full_message_2   = '';    // Volle Meldung mit Sonderzeichen (Wettersymbole etc.)
var short_message_2  = '';    // Gekürzte Meldung mit Sonderzeichen (max 256 Zeichen)
var text_message_2   = '';    // Volle Meldung als reiner Text ohne Sonderzeichen
// Sonstige
var entity_data      = [];    // Arbeits-Kopie der jeweiligen Entitäts-Daten

// ============================================================================
// Here we go ...
// ============================================================================
if (number_of_active_warnings > 0)
{
  // --------------------------------------------------------------------------
  // Haupt-Überschrift der Mitteilung(en)
  // --------------------------------------------------------------------------
  if (!show_weather_symbols) { blitz = ''; }
  full_message_1  = blitz + "***" + ueberschrift + "*** " + blitz + main_headline_add_text + trennlinie;
  full_message_2  = full_message_1;
  short_message_1 = full_message_1;
  short_message_2 = short_message_1;
  text_message_1  = ueberschrift + " " + main_headline_add_text + trennstrich;
  text_message_2  = text_message_1;
  // --------------------------------------------------------------------------
  // Warnmeldungen verarbeiten und der Mitteilung hinzufügen
  // ---------------------------------------------------------------------------
  // 1. Aktuelle Warnungen
  // ----------------------
  if (number_of_current_warnings > 0)
  {
    entity_data = entity_current_data;
    warning_type = 'Aktuelle Warnstufe: ';
    add_warnings(number_of_current_warnings);
  }
  // ----------------
  // 2. Vorwarnungen
  // ----------------
  if (number_of_advance_warnings > 0)
  {
    entity_data = entity_advance_data;
    warning_type = 'Vorwarnstufe: ';
    add_warnings(number_of_advance_warnings);
  }
}
else
{
  // --------------------------------------------------------------------------
  // Wenn keine Warnungen mehr vorhanden sind, entsprechenden Hinweis senden,
  // sofern dies nicht mit "send_cancellation_message = false" abgestellt ist
  // --------------------------------------------------------------------------
  if (send_cancellation_message)
  {
    // -----------------------------------------------------------------------
    // Um mehrfache Mitteilungen durch Löschen aller DWD-Warnmeldungen zu
    // verhindern, nur senden wenn die Letzte schon 10 Minuten her ist
    // -----------------------------------------------------------------------
    var minimum_time_diff = 600; // 600 Sekunden = 10 Minuten
    var time_saved = global.get("dwd_last_cancellation_time");
    var t_time_saved = typeof time_saved;
    if (time_saved == '' || t_time_saved === 'undefined' || time_saved === null || t_time_saved === null)
    {
      time_saved = Date.now();
      time_saved = time_saved - minimum_time_diff;
    }
    var time_now = Date.now();
    global.set("dwd_last_cancellation_time", time_now);
    time_saved = Math.round(time_saved / 1000);
    time_now   = Math.round(time_now / 1000);
    var cancellation_message = "";
    if ((time_now - time_saved) >= minimum_time_diff)
    {
      warnings_to_show = 1;
      cancellation_message = "Alle DWD-Warnmeldungen wurden aufgehoben. " + main_headline_add_text;
    }
    // ---------------------------------------------------------
    // Alle Mitteilungstexte mit entsprechendm Hinweis befüllen
    // ---------------------------------------------------------
    full_message_1  = cancellation_message;
    full_message_2  = cancellation_message;
    short_message_1 = cancellation_message;
    short_message_2 = cancellation_message;
    text_message_1  = cancellation_message;
    text_message_2  = cancellation_message;
    // ---------------------------------------------------
    // Wenn es keine Warnungen mehr gibt, dann auch die
    // gespeicherte Liste der bekannten Warnungen löschen
    // ---------------------------------------------------
    global.set("dwd_nodered_warnings_list", '');
  }
}
// ----------------------------------------------------------------------------
// Mitteilung zum Versand als Payload vorbereiten
// ----------------------------------------------------------------------------
// Anzahl der tatsächlich angezeigten Meldungen in den Mitteilungen einfügen
// --------------------------------------------------------------------------
full_message_1 = full_message_1.replace('CCC', warnings_to_show.toString());
full_message_2 = full_message_2.replace('CCC', number_of_active_warnings.toString());
short_message_1 = short_message_1.replace('CCC', warnings_to_show.toString());
short_message_2 = short_message_2.replace('CCC', number_of_active_warnings.toString());
text_message_1 = text_message_1.replace('CCC', warnings_to_show.toString());
text_message_2 = text_message_2.replace('CCC', number_of_active_warnings.toString());
// --------------------------------
// Daten für Ausgang 1 vorbereiten
// --------------------------------
var output_1 = {};
output_1.payload = {
  msg_full: full_message_1,
  msg_short: short_message_1,
  msg_text: text_message_1
}
// --------------------------------
// Daten für Ausgang 2 vorbereiten
// --------------------------------
var output_2 = {};
output_2.payload = {
  msg_full: full_message_2,
  msg_short: short_message_2,
  msg_text: text_message_2
}
// ----------------------------------------------------------------------------
// Mitteilung ausgeben (an nachfolgende/n Node/s senden)
// ----------------------------------------------------------------------------
// Alten Payload löschen, um keine Daten daraus mit weiterzuleiten
// ----------------------------------------------------------------
msg.payload = [];
// ----------------------------------------------------------------------
// Wenn es neue Mitteilungen gibt, Daten an Ausgang 1 und 2 ausgeben ...
// ----------------------------------------------------------------------
if (warnings_to_show > 0)
{
  // Nur wenn es auch wirklich etwas zu melden gibt ...
  if (full_message_1 != "" || short_message_1 != "" || text_message_1 != "")
  {
    node.send([output_1, output_2]); // asynchron
    node.done();
    // return [output_1, output_2]; // synchron
  }
}
// ----------------------------------------------------------------------
// ... sonst Daten nur an Ausgang 2 ausgeben
// ----------------------------------------------------------------------
else
{
  // Nur wenn es auch wirklich etwas zu melden gibt ...
  if (full_message_2 != "" || short_message_2 != "" || text_message_2 != "")
  {
    node.send([null, output_2]); // asynchron
    node.done();
    // return [null, output_2]; // synchron
  }
}
// ----------------------------------------------------------------------------
// Skript OHNE Rückmeldung beenden (Daten wurden schon mit node.send gesendet)
// ----------------------------------------------------------------------------
return null;

// ============================================================================
// Umwandlung einer ISO-Zeitangabe in ein eigenes Format
// ============================================================================
function time_convert(iso_string) {
  var date = new Date(iso_string);
  var year = parseInt(date.getFullYear());
  var month = parseInt(date.getMonth()) + 1;
  var day = parseInt(date.getDate());
  var hour = parseInt(date.getHours());
  var minute = parseInt(date.getMinutes());
  if (day < 10) { day = '0' + day; }
  if (month < 10) { month = '0' + month; }
  if (hour < 10) { hour = '0' + hour; }
  if (minute < 10) { minute = '0' + minute; }
  return '***' + day + '.' + month + '.' + year + '*** um ***' + hour + ':' + minute + '***';
}

// ============================================================================
// Einfache Prüfsumme erstellen
// ============================================================================
function get_cs(the_text)
{
  var the_text = the_text.toString();
  var cs_value = 0;
  for (var i=0;i<the_text.length;i++)
  {
    cs_value = cs_value + the_text.charCodeAt(i);
  }
  return cs_value;
}

// ============================================================================
// Hinzufügen der Warnmeldungen zu den zu versendenden Mitteilungen
// ============================================================================
function add_warnings(number_of_warnings) {
  var level          = 0;  // Warnstufe als Zahl
  // var level_text     = ''; // Warnstufe als Text
  var headline       = ''; // Kopfzeile
  var weather_symbol = ''; // Wetter-Symbol
  var description    = ''; // Beschreibung
  var last_update    = ''; // Letzte Aktualisierung
  var time_start     = ''; // Beginn
  var time_end       = ''; // Ende
  var time_text      = ''; // Zeitangabe in lesbarem Text
  var work_full_msg  = ''; // Arbeitsbereich für Vollständige Meldung
  var work_short_msg = ''; // Arbeitsbereich für Kurzmeldung
  var work_text_msg  = ''; // Arbeitsbereich für reine Text-Meldung
  var last_pre_text  = "Letzte Aktualisierung: ";
  var anzahl = parseInt(number_of_warnings);
  if (anzahl > 0)
  {
    for (var i = 1; i <= anzahl; i++)
    {
      // ----------------------------------------------------
      // Bei jeder Warnung mit leeren Arbeitstexten beginnen
      // ----------------------------------------------------
      work_full_msg  = '';
      work_short_msg = '';
      work_text_msg  = '';
      // ----------------------
      // 1. Warnstufe auslesen
      // ----------------------
      level = parseInt(entity_data.daten.attributes['warning_' + i + '_level']);
      // -------------------------------------------------------------------
      // Meldung nur hinzufügen wenn diese definiert ist (einen Inhalt hat)
      // -------------------------------------------------------------------
      if (typeof level !== 'undefined')
      {
        // -----------------------------------
        // 2.a Kopfzeile der Meldung auslesen
        // -----------------------------------
        headline = entity_data.daten.attributes['warning_' + i + '_headline'];
        // -------------------------------------------
        // 2.b Wetter-Symbole zur Kopfzeile ermitteln
        // -------------------------------------------
        weather_symbol = '';
        if (show_weather_symbols)
        {
          for (var w = 0; w < weather_warnidx.length; w++)
          {
            if (headline.toUpperCase().indexOf(weather_warnidx[w]) !== -1) { weather_symbol += weather_symbols[w]; }
          }
        }
        // -------------------------------------
        // 3. Beschreibung der Meldung auslesen
        // -------------------------------------
        description = entity_data.daten.attributes['warning_' + i + '_description'];
        // -------------------------------
        // 4. Zeiten der Meldung auslesen
        // -------------------------------
        time_text = "";
        last_update = time_convert(entity_data.daten.attributes.last_update) + " Uhr";
        if (last_update.indexOf('NaN') >= 0)
        {
          last_pre_text = "";
          last_update = "";
        }
        time_start = time_convert(entity_data.daten.attributes['warning_' + i + '_start']);
        if (time_start.indexOf('NaN') < 0) {
          time_text += "Ab " + time_start + " Uhr"; }
        time_end = time_convert(entity_data.daten.attributes['warning_' + i + '_end']);
        if (time_end.indexOf('NaN') < 0) {
          time_text += " bis " + time_end + " Uhr"; }
        // --------------------------------------------------------------------
        // Nachrichten aus den einzelnen Warnmeldungs-Komponenten zusammenbauen
        // --------------------------------------------------------------------
        // Vollständige Meldung
        // ---------------------
        work_full_msg += "***" + headline + "*** " + weather_symbol + "\n";
        if (show_warning_level) {
          work_full_msg += warning_type + "***" + level + "***\n"; }
        if (show_last_update_time)
        {
          work_full_msg += "UUU";
          if (last_update != "") { work_full_msg += "\n"; }
        }
        work_full_msg += description + "\n";
        work_full_msg += time_text + trennlinie;
        // ------------
        // Kurzmeldung
        // ------------
        work_short_msg += headline + " " + weather_symbol + "\n" + time_text + trennlinie;
        work_short_msg = work_short_msg.replace(/ Uhr /g, ' ');
        work_short_msg = work_short_msg.replace(/ um /g, ' ');
        // -------------------
        // Reine Text-Meldung
        // -------------------
        work_text_msg += headline + trennstrich;
        if (show_warning_level) {
          work_text_msg += warning_type + level + trennstrich; }
        if (show_last_update_time)
        {
          work_text_msg += "UUU";
          if (last_update != "") { work_text_msg += trennstrich; }
        }
        work_text_msg += description + trennstrich;
        work_text_msg += time_text + ende_marker;
        // -----------------
        // Texte bereinigen
        // -----------------
        if (remove_pre_text_amtliche)
        {
          work_full_msg = work_full_msg.replace(/Amtliche Warnung vor /gis, '');
          work_short_msg = work_short_msg.replace(/Amtliche Warnung vor /gis, '');
          work_text_msg = work_text_msg.replace(/Amtliche Warnung vor /gis, '');
        }
        work_short_msg = work_short_msg.substring(0, 255) + " (Details siehe HA-App)" + trennlinie;
        work_text_msg = work_text_msg.replace(/\*\*\*/gis, '');
        // -----------------------------------------------------------------
        // Wenn doppelte Warnungen unterdrückt werden sollen, prüfen ob die
        // Warnung schon in der Liste bekannter Warnungen enthalten ist
        // -----------------------------------------------------------------
        warning_exists = false;
        if (suppress_double_warnings)
        {
          // ----------------------------------------------------------
          // ID für die Warnung erstellen
          // ----------------------------------------------------------
          work_warning_id = headline.charAt(0).toString() +
                          description.charAt(0).toString() +
                          get_cs(work_text_msg).toString();
          // ----------------------------------------------------------
          // Wenn es schon eine Liste mit bekannten Warnungen gibt,
          // ermitteln ob die neue Warnung darin bereits enthalten ist
          // ----------------------------------------------------------
          warnings_id_list = global.get("dwd_nodered_warnings_list");
          warn_list_type = typeof warnings_id_list;
          if (warnings_id_list != '' && warn_list_type !== 'undefined' && warnings_id_list !== null && warn_list_type !== null)
          {
            if (warnings_id_list.indexOf(work_warning_id + ',') >= 0)
            {
              warning_exists = true;
            }
          }
          else
          {
            warnings_id_list = '';
          }
          // -----------------------------------------------------
          // Wenn es die Warnung noch nicht gibt, diese der Liste
          // bekannter Warnungen hinzufügen und Liste speichern
          // -----------------------------------------------------
          if (!warning_exists)
          {
            warnings_id_list += work_warning_id + ',';
            global.set("dwd_nodered_warnings_list", warnings_id_list);
          }
        }
        // ----------------------------------------------
        // Zeitpunkt der letzten Aktualisierung einfügen
        // ----------------------------------------------
        if (show_last_update_time)
        {
           work_full_msg = work_full_msg.replace('UUU', last_pre_text + last_update);
           work_text_msg = work_text_msg.replace('UUU', last_pre_text + last_update);
        }
        // ----------------------------------
        // Redundante Warnungen kennzeichnen
        // ----------------------------------
        if (warning_exists)
        {
          work_full_msg  = double_warn_flag + work_full_msg;
          work_short_msg = double_warn_flag + work_short_msg;
          work_text_msg  = double_warn_flag + work_text_msg;
        }
        // -----------------------------------------------------------------
        // Warnmeldung für Ausgang 1 nur hinzufügen, wenn diese größer oder
        // gleich der Mindest-Warnstufe ist und noch nicht existiert
        // -----------------------------------------------------------------
        if (level >= minimum_warning_level && !warning_exists)
        {
          warnings_to_show++;
          full_message_1  += work_full_msg;
          short_message_1 += work_short_msg;
          text_message_1  += work_text_msg;
        }
        // ---------------------------------------------
        // Warnmeldungen für Ausgang 2 immer hinzufügen
        // ---------------------------------------------
        full_message_2  += work_full_msg;
        short_message_2 += work_short_msg;
        text_message_2  += work_text_msg;
      }
    }
  }
  return;
}
