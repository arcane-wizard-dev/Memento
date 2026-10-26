local _, MEM = ...

if MEM.State and MEM.State.libraryIncompatible then return end

if GetLocale() ~= "deDE" then return end

local L = MEM.Localization

-- Options

L["options.general"] = "Allgemeine Einstellungen"
L["options.general.notification.name"] = "Chatbenachrichtigung"
L["options.general.notification.tooltip"] = "Aktiviere oder deaktiviere die Benachrichtigung im Chat, wenn ein Screenshot erstellt wurde."
L["options.general.notification.timestamp.name"] = "Chatausgabe mit Zeitstempel"
L["options.general.notification.timestamp.tooltip"] = "Aktiviere oder deaktiviere die Chatausgabe mit Zeitstempel, wenn ein Screenshot erstellt wurde."
L["options.general.notification.class.name"] = "Chatausgabe der Klasse"
L["options.general.notification.class.tooltip"] = "Aktiviere oder deaktiviere die Chatausgabe der Klasse, wenn ein Screenshot erstellt wurde."
L["options.general.notification.time-played.name"] = "Chatausgabe der Gesamtspielzeit"
L["options.general.notification.time-played.tooltip"] = "Aktiviere oder deaktiviere die Chatausgabe der Gesamtspielzeit, wenn ein Screenshot erstellt wurde."
L["options.general.notification.level-time-played.name"] = "Chatausgabe der Spielzeit auf der aktuellen Stufe"
L["options.general.notification.level-time-played.tooltip"] = "Aktiviere oder deaktiviere die Chatausgabe der Spielzeit auf der aktuellen Stufe, wenn ein Screenshot erstellt wurde. Beim Stufenaufstieg wird stattdessen die Spielzeit der vorherigen Stufe angezeigt."
L["options.general.hide-ui.name"] = "Benutzeroberfläche für den Screenshot ausblenden"
L["options.general.hide-ui.tooltip"] = "Aktiviere oder deaktiviere die Option, dass die Benutzeroberfläche für den Screenshot ausgeblendet wird.\n\nHinweis: Während eines Kampfes kann die Benutzeroberfläche nicht automatisch ausgeblendet werden. In diesem Fall wird der Screenshot mit der Benutzeroberfläche erstellt."
L["options.general.hide-ui.message.name"] = "Hinweisbox auf dem Screenshot anzeigen"
L["options.general.hide-ui.message.tooltip"] = "Zeigt eine kleine Hinweisbox mit Zeitstempel auf Screenshots mit ausgeblendeter Benutzeroberfläche."
L["options.general.screenshot-format.name"] = "Screenshot-Dateiformat"
L["options.general.screenshot-format.tooltip"] = "Wähle das Dateiformat. Dies ändert die WoW-Einstellung für alle Screenshots, einschließlich manuell erstellter Aufnahmen, unabhängig vom Memento-Profil."
L["options.general.screenshot-quality.name"] = "JPEG-Qualität"
L["options.general.screenshot-quality.tooltip"] = "Wähle die JPEG-Qualität von 1 bis 10. Höhere Werte erhalten mehr Details und erzeugen größere Dateien. Wirkt sich nicht auf PNG oder TGA aus. Diese WoW-Einstellung gilt auch für manuell erstellte Screenshots."
L["options.general.timestamp-format.name"] = "Zeitstempelformat"
L["options.general.timestamp-format.tooltip"] = "Wähle das Datums- und Uhrzeitformat für Chatbenachrichtigungen und die Hinweisbox im Screenshot."
L["options.general.timestamp-format.option.iso"] = "JJJJ-MM-TT - HH:mm:ss"
L["options.general.timestamp-format.option.day-first"] = "TT.MM.JJJJ - HH:mm:ss"
L["options.general.timestamp-format.option.month-first"] = "MM/TT/JJJJ - hh:mm:ss AM/PM"
L["options.general.screenshot-sound.name"] = "Soundeffekt nach Screenshot"
L["options.general.screenshot-sound.tooltip"] = "Aktiviere oder deaktiviere einen Soundeffekt, nachdem ein Screenshot erstellt wurde."
L["options.general.screenshot-sound-style.name"] = "Soundeffekt"
L["options.general.screenshot-sound-style.tooltip"] = "Wähle den Soundeffekt, der nach einem Screenshot abgespielt wird. Bei der Auswahl wird der Sound einmal zur Vorschau abgespielt."
L["options.general.screenshot-sound-style.option.memento-camera"] = "Kameraauslöser (Memento)"
L["options.general.screenshot-sound-style.option.notification"] = "Benachrichtigung (Memento)"
L["options.general.screenshot-sound-style.option.melody"] = "Melodie (Memento)"
L["options.general.screenshot-sound-style.option.quest-complete"] = "Quest abgeschlossen"
L["options.general.screenshot-sound-style.option.ready-check"] = "Bereitschaftscheck"
L["options.general.screenshot-sound-style.option.raid-warning"] = "Raidwarnung"
L["options.general.minimap-button.name"] = "Minimap-Button"
L["options.general.minimap-button.tooltip"] = "Bei Aktivierung wird der Minimap-Button angezeigt."
L["options.general.debug-mode.name"] = "Debugmodus"
L["options.general.debug-mode.tooltip"] = "Die Aktivierung des Debugmodus zeigt zusätzliche Informationen im Chat an."

L["options.event.general.active.tooltip"] = "Aktiviere oder deaktiviere die automatische Erstellung eines Screenshots für das Event %s."
L["options.event.general.delay.name"] = "Verzögerung"
L["options.event.general.delay.tooltip"] = "Die zeitliche Verzögerung des Screenshots, nachdem das Event %s ausgelöst wurde.\n\nStandard: %d Sekunde(n)"

L["options.event"] = "Screenshots"

L["options.event.character"] = "Charakter"
L["options.event.character.login"] = "Spielerlogin"
L["options.event.character.zone"] = "Neues Gebiet"
L["options.event.character.zone.tooltip"] = "Erstellt einen Screenshot, wenn dieser Charakter ein neues Gebiet betritt. Besuchte Gebiete werden für jeden Charakter getrennt gespeichert, auch wenn dieses Ereignis deaktiviert ist."
L["options.event.character.zone.type.name"] = "Gebiete"
L["options.event.character.zone.type.tooltip"] = "Wähle, für welche neuen Gebiete ein Screenshot erstellt wird.\n\n|cnHIGHLIGHT_FONT_COLOR:Zone (offene Welt):|r Nur Zonen der offenen Welt.\n\n|cnHIGHLIGHT_FONT_COLOR:Instanz:|r Nur Dungeons, Schlachtzüge, Szenarien, Schlachtfelder und Arenen.\n\n|cnHIGHLIGHT_FONT_COLOR:Beides:|r Zonen der offenen Welt und Instanzen.\n\nBesuchte Gebiete werden unabhängig von dieser Auswahl gespeichert. Etagen und Schwierigkeitsgrade derselben Instanz zählen als ein Gebiet."
L["options.event.character.zone.type.zone"] = "Zone (offene Welt)"
L["options.event.character.zone.type.instance"] = "Instanz"
L["options.event.character.zone.type.both"] = "Beides"
L["options.event.character.level-up"] = "Stufenaufstieg"
L["options.event.character.level-up.time-played.name"] = "Spielzeit der vorherigen Stufe anzeigen"
L["options.event.character.level-up.time-played.tooltip"] = "Zeigt die Spielzeit der vorherigen Stufe als eigene Chatzeile an, wenn ein Screenshot beim Stufenaufstieg erstellt wird, auch wenn die allgemeine Stufenzeitanzeige deaktiviert ist."
L["options.event.character.reputation"] = "Rufstufenaufstieg"
L["options.event.character.reputation.tooltip"] = "Erstellt einen Screenshot, wenn du eine höhere Rufstufe erreichst."
L["options.event.character.death"] = "Spielertod"
L["options.event.character.death.instance.name"] = "Screenshotverhalten in Instanzen"
L["options.event.character.death.instance.tooltip"] = "Screenshots werden unter Berücksichtigung der folgenden Einstellungen für den Spielertod nur innerhalb und / oder außerhalb einer Instanz erstellt.\n\nZu einer Instanz zählen u.a. Arenen, Schlachtfelder, Raids oder Dungeons."
L["options.event.character.death.instance.option.0"] = "in- und außerhalb von Instanzen"
L["options.event.character.death.instance.option.1"] = "nur innerhalb von Instanzen"
L["options.event.character.death.instance.option.2"] = "nur außerhalb von Instanzen"

L["options.event.achievement"] = "Erfolge"
L["options.event.achievement.personal"] = "persönlicher Erfolg"
L["options.event.achievement.personal.exist.name"] = "Screenshot bei bereits erzieltem Erfolg erstellen"
L["options.event.achievement.personal.exist.tooltip"] = "Aktiviere oder deaktiviere die Erstellung eines Screenshots, wenn ein Erfolg bereits von einem anderen Charakter erlangt wurde."
L["options.event.achievement.criteria"] = "persönliches Erfolgskriterium"
L["options.event.achievement.guild"] = "Gildenerfolg"

L["options.event.pve"] = "Instanzen und Weltbosse (PvE)"
L["options.event.pve.victory"] = "Sieg"
L["options.event.pve.wipe"] = "Niederlage"
L["options.event.pve.world"] = "Weltboss"
L["options.event.pve.world.first.name"] = "nur erster Sieg"
L["options.event.pve.world.first.tooltip"] = "Legt fest, ob pro Weltboss nur beim ersten Sieg ein Screenshot erstellt wird."
L["options.event.pve.party"] = "Dungeon-Boss"
L["options.event.pve.raid"] = "Raid-Boss"
L["options.event.pve.scenario"] = "Szenario-/Tiefen-Boss"
L["options.event.pve.victory.first.name"] = "nur erster Sieg pro Schwierigkeit"
L["options.event.pve.victory.first.tooltip"] = "Legt fest, ob pro Boss und Schwierigkeit nur beim ersten Sieg ein Screenshot erstellt wird."
L["options.event.pve.mythic"] = "Abschluss Mythic+ Dungeon"

L["options.event.pvp"] = "Spieler gegen Spieler (PvP)"
L["options.event.pvp.duel"] = "Duell beendet"
L["options.event.pvp.arena"] = "Arena abgeschlossen"
L["options.event.pvp.battleground"] = "Schlachtfeld abgeschlossen"
L["options.event.pvp.brawl"] = "Rauferei abgeschlossen"
L["options.event.pvp.victory.name"] = "nur bei Sieg"
L["options.event.pvp.victory.tooltip"] = "Aktiviere oder deaktiviere die automatische Erstellung eines Screenshots, wenn du das PvP-Match gewonnen hast."

L["options.event.collection"] = "Sammlungen"
L["options.event.collection.new-pet"] = "neues Haustier"
L["options.event.collection.new-mount"] = "neues Reittier"
L["options.event.collection.new-toy"] = "neues Spielzeug"
L["options.event.collection.new-recipe"] = "neues Rezept"
L["options.event.collection.new-housing-item"] = "neuer Behausungsgegenstand"

L["options.event.other"] = "Sonstiges"
L["options.event.other.interval"] = "Reguläres Intervall"
L["options.event.other.interval-timer.name"] = "Intervall"
L["options.event.other.interval-timer.tooltip"] = "Das Zeitintervall, in dem ein Screenshot erstellt wird.\n\nStandard: 5 Minuten"
L["options.event.other.perks-activity"] = "Abschluss Reisetagebuch-Aktivität"
L["options.event.other.loot-toast"] = "Besondere Beute"
L["options.event.other.loot-toast.tooltip"] = "Aktiviere oder deaktiviere Screenshots für Beute, die WoW über einen Beute-Toast anzeigt. Gegenstände, Geld und Währungen können separat ausgewählt werden."
L["options.event.other.loot-toast.item.name"] = "Gegenstände"
L["options.event.other.loot-toast.item.tooltip"] = "Erstellt Screenshots, wenn WoW einen Gegenstand über einen Beute-Toast anzeigt. Dabei gilt die konfigurierte Mindestqualität."
L["options.event.other.loot-toast.quality.name"] = "Mindestqualität"
L["options.event.other.loot-toast.quality.tooltip"] = "Legt fest, ab welcher Qualität ein über einen Beute-Toast angezeigter Gegenstand einen Screenshot auslöst."
L["options.event.other.loot-toast.money.name"] = "Geld"
L["options.event.other.loot-toast.money.tooltip"] = "Erstellt Screenshots, wenn WoW erhaltenes Geld über einen Beute-Toast anzeigt."
L["options.event.other.loot-toast.currency.name"] = "Währungen"
L["options.event.other.loot-toast.currency.tooltip"] = "Erstellt Screenshots, wenn WoW eine erhaltene Währung über einen Beute-Toast anzeigt."

-- General

L["minimap-button.tooltip"] = "|cnLINK_FONT_COLOR:Rechtsklick|r zum Öffnen der Einstellungen."

L["general.seconds-short"] = "Sek."
L["general.minutes-short"] = "Min."

-- Chat Notifications

L["chat.notification.class"] = "Klasse: %s"
L["chat.notification.time-played"] = "Gesamtspielzeit: %d Tage, %d Stunden, %d Minuten, %d Sekunden"
L["chat.notification.level-time-played"] = "Spielzeit auf aktueller Stufe: %d Tage, %d Stunden, %d Minuten, %d Sekunden"

-- Event Messages

L["chat.event.login.new"] = "Screenshot erstellt - |cnGOLD_FONT_COLOR:Spielerlogin|r"
L["chat.event.zone.new"] = "Screenshot erstellt - |cnGOLD_FONT_COLOR:Neues Gebiet|r - %s"
L["chat.event.level-up.retail.new"] = "Screenshot erstellt - |cnGOLD_FONT_COLOR:Stufenaufstieg|r - |cffFF4E00[Stufe %1$s]|r"
L["chat.event.level-up.classic.new"] = "Screenshot erstellt - |cnGOLD_FONT_COLOR:Stufenaufstieg|r - |cffFF4E00[Stufe %1$s]|r"
L["chat.event.level-up.time-played"] = "Spielzeit auf Stufe %d: %d Tage, %d Stunden, %d Minuten, %d Sekunden"
L["chat.event.death.new"] = "Screenshot erstellt - |cnGOLD_FONT_COLOR:Spielertod|r"
L["chat.event.reputation.new"] = "Screenshot erstellt - |cnGOLD_FONT_COLOR:Rufstufenaufstieg|r - %s (%s)"
L["chat.event.reputation.renown"] = "Ruhm %d"

L["chat.event.achievement.personal.new"] = "Screenshot erstellt - |cnGOLD_FONT_COLOR:persönlicher Erfolg|r - %s"
L["chat.event.achievement.personal.exist"] = "Screenshot erstellt - |cnGOLD_FONT_COLOR:persönlicher Erfolg|r - %s (wurde bereits von einem anderen Charakter erzielt)"
L["chat.event.achievement.personal.no-link.new"] = "Screenshot erstellt - |cnGOLD_FONT_COLOR:persönlicher Erfolg|r"
L["chat.event.achievement.personal.no-link.exist"] = "Screenshot erstellt - |cnGOLD_FONT_COLOR:persönlicher Erfolg|r (wurde bereits von einem anderen Charakter erzielt)"
L["chat.event.achievement.criteria.new"] = "Screenshot erstellt - |cnGOLD_FONT_COLOR:persönliches Erfolgskriterium|r - %s - %s"
L["chat.event.achievement.criteria.no-link.new"] = "Screenshot erstellt - |cnGOLD_FONT_COLOR:persönliches Erfolgskriterium|r"
L["chat.event.achievement.guild.new"] = "Screenshot erstellt - |cnGOLD_FONT_COLOR:Gildenerfolg|r: %s"

L["chat.event.encounter.victory.new"] = "Screenshot erstellt - |cnGOLD_FONT_COLOR:Bosskampf - Sieg|r - %s (%s)"
L["chat.event.encounter.wipe.new"] = "Screenshot erstellt - |cnGOLD_FONT_COLOR:Bosskampf - Niederlage|r - %s (%s)"
L["chat.event.mythic.new"] = "Screenshot erstellt - |cnGOLD_FONT_COLOR:Abschluss Mythic+ Dungeon|r"

L["chat.event.pvp.duel.new"] = "Screenshot erstellt - |cnGOLD_FONT_COLOR:PvP - Duell beendet|r"
L["chat.event.pvp.arena.new"] = "Screenshot erstellt - |cnGOLD_FONT_COLOR:PvP - Arena abgeschlossen|r"
L["chat.event.pvp.battleground.new"] = "Screenshot erstellt - |cnGOLD_FONT_COLOR:PvP - Schlachtfeld abgeschlossen|r"
L["chat.event.pvp.brawl.new"] = "Screenshot erstellt - |cnGOLD_FONT_COLOR:PvP - Rauferei abgeschlossen|r"

L["chat.event.warband-collection.new-pet.new"] = "Screenshot erstellt - |cnGOLD_FONT_COLOR:neues Haustier|r"
L["chat.event.warband-collection.new-mount.new"] = "Screenshot erstellt - |cnGOLD_FONT_COLOR:neues Reittier|r"
L["chat.event.warband-collection.new-toy.new"] = "Screenshot erstellt - |cnGOLD_FONT_COLOR:neues Spielzeug|r"
L["chat.event.warband-collection.new-recipe.new"] = "Screenshot erstellt - |cnGOLD_FONT_COLOR:neues Rezept|r"
L["chat.event.warband-collection.new-housing-item.new"] = "Screenshot erstellt - |cnGOLD_FONT_COLOR:neuer Behausungsgegenstand|r"

L["chat.event.interval.new"] = "Screenshot erstellt - |cnGOLD_FONT_COLOR:Reguläres Intervall|r"
L["chat.event.perks-activity.new"] = "Screenshot erstellt - |cnGOLD_FONT_COLOR:Reisetagebuch-Aktivität abgeschlossen|r"
L["chat.event.loot-toast.item.new"] = "Screenshot erstellt - |cnGOLD_FONT_COLOR:besondere Beute - Gegenstand|r - %s"
L["chat.event.loot-toast.money.new"] = "Screenshot erstellt - |cnGOLD_FONT_COLOR:besondere Beute - Geld|r - %s"
L["chat.event.loot-toast.currency.new"] = "Screenshot erstellt - |cnGOLD_FONT_COLOR:besondere Beute - Währung|r - %s x%d"

-- Capture

L["capture.message"] = "Screenshot erstellt"
