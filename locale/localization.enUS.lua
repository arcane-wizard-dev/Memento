local _, MEM = ...

if MEM.State and MEM.State.libraryIncompatible then return end

MEM.Localization = setmetatable({}, {
	__index=function(self, key)
		rawset(self, key, key)

		geterrorhandler()("Memento (Debug): Missing entry for '" .. tostring(key) .. "'")

		return key
	end
})

local L = MEM.Localization

-- Options

L["options.general"] = "General Options"
L["options.general.notification.name"] = "Chat Notification"
L["options.general.notification.tooltip"] = "Shows a chat notification after a screenshot is taken."
L["options.general.notification.details.name"] = "Additional Information"
L["options.general.notification.details.tooltip"] = "Sets which additional information is included in screenshot notifications."
L["options.general.notification.timestamp.name"] = "Show Timestamp"
L["options.general.notification.timestamp.tooltip"] = "Adds a timestamp to screenshot chat notifications."
L["options.general.notification.class.name"] = "Show Class"
L["options.general.notification.class.tooltip"] = "Shows the character's class in the chat after a screenshot is taken."
L["options.general.notification.time-played.name"] = "Show Total Time Played"
L["options.general.notification.time-played.tooltip"] = "Shows the character's total time played in the chat after a screenshot is taken."
L["options.general.notification.level-time-played.name"] = "Show Time Played at This Level"
L["options.general.notification.level-time-played.tooltip"] = "Shows the time played at the current level in the chat after a screenshot is taken. Level-up screenshots show the time played at the previous level instead."
L["options.general.hide-ui.name"] = "Hide User Interface for Screenshot"
L["options.general.hide-ui.tooltip"] = "Hides the user interface for the screenshot.\n\nNote: The user interface cannot be hidden automatically during combat. In this case, the screenshot is taken with the user interface."
L["options.general.hide-ui.message.name"] = "Show Notification Box in Screenshot"
L["options.general.hide-ui.message.tooltip"] = "Shows a small notification box with a timestamp in screenshots taken with the user interface hidden."
L["options.general.screenshot-format.name"] = "Screenshot File Format"
L["options.general.screenshot-format.tooltip"] = "Sets the file format.\n\n|cnHIGHLIGHT_FONT_COLOR:JPEG (.jpg):|r Small files, adjustable quality.\n\n|cnHIGHLIGHT_FONT_COLOR:PNG (.png):|r Lossless, larger files.\n\n|cnHIGHLIGHT_FONT_COLOR:TGA (.tga):|r Uncompressed, very large files.\n\nThis changes the WoW setting for all screenshots, including manually taken screenshots, independently of Memento profiles."
L["options.general.screenshot-quality.name"] = "JPEG Quality"
L["options.general.screenshot-quality.tooltip"] = "Sets the JPEG quality from 1 to 10. Higher values preserve more detail and produce larger files. Does not affect PNG or TGA. This WoW setting also applies to manually taken screenshots."
L["options.general.timestamp-format.name"] = "Timestamp Format"
L["options.general.timestamp-format.tooltip"] = "Sets the date and time format for chat notifications and the screenshot notification box."
L["options.general.timestamp-format.option.iso"] = "YYYY-MM-DD - HH:mm:ss"
L["options.general.timestamp-format.option.day-first"] = "DD.MM.YYYY - HH:mm:ss"
L["options.general.timestamp-format.option.month-first"] = "MM/DD/YYYY - hh:mm:ss AM/PM"
L["options.general.screenshot-sound.name"] = "Screenshot Sound Effect"
L["options.general.screenshot-sound.tooltip"] = "Plays a sound effect after a screenshot is taken."
L["options.general.screenshot-sound-style.name"] = "Sound Effect"
L["options.general.screenshot-sound-style.tooltip"] = "Sets the sound effect that is played after a screenshot."
L["options.general.screenshot-sound-style.option.memento-camera"] = "Camera Shutter (Memento)"
L["options.general.screenshot-sound-style.option.notification"] = "Notification (Memento)"
L["options.general.screenshot-sound-style.option.melody"] = "Melody (Memento)"
L["options.general.screenshot-sound-style.option.quest-complete"] = "Quest Complete"
L["options.general.screenshot-sound-style.option.ready-check"] = "Ready Check"
L["options.general.screenshot-sound-style.option.raid-warning"] = "Raid Warning"
L["options.general.minimap-button.name"] = "Minimap Button"
L["options.general.minimap-button.tooltip"] = "Shows the minimap button."
L["options.general.debug-mode.name"] = "Debug Mode"
L["options.general.debug-mode.tooltip"] = "Displays additional debug information in the chat."

L["options.event.general.delay.name"] = "Delay"
L["options.event.general.delay.tooltip"] = "Sets how long to wait after \"%s\" before the screenshot is taken.\n\nDefault: %d |4second:seconds;"

L["options.event"] = "Screenshots"

L["options.event.character"] = "Character"
L["options.event.character.login"] = "Player Login"
L["options.event.character.login.tooltip"] = "Takes a screenshot on login. Reloading the user interface or a loading screen does not trigger a screenshot."
L["options.event.character.level-up"] = "Level-Up"
L["options.event.character.level-up.tooltip"] = "Takes a screenshot when this character reaches a new level."
L["options.event.character.level-up.time-played.name"] = "Show Time Played on the Previous Level"
L["options.event.character.level-up.time-played.tooltip"] = "Shows the time played on the previous level on a separate chat line when a level-up screenshot is taken, even if \"Show Time Played at This Level\" is disabled."
L["options.event.character.death"] = "Player Death"
L["options.event.character.death.tooltip"] = "Takes a screenshot when the character dies."
L["options.event.character.death.instance.name"] = "Screenshot Behavior in Instances"
L["options.event.character.death.instance.tooltip"] = "Sets whether a screenshot is taken on death only inside instances, only outside instances, or everywhere.\n\nInstances include dungeons, raids, scenarios, battlegrounds, and arenas."
L["options.event.character.death.instance.option.0"] = "Inside and Outside Instances"
L["options.event.character.death.instance.option.1"] = "Only Inside Instances"
L["options.event.character.death.instance.option.2"] = "Only Outside Instances"
L["options.event.character.reputation"] = "Reputation Rank Increased"
L["options.event.character.reputation.tooltip"] = "Takes a screenshot when a higher reputation rank or renown level is reached."
L["options.event.character.zone"] = "New Area"
L["options.event.character.zone.tooltip"] = "Takes a screenshot when this character enters a new area. The area counts as visited for this character once Memento requests the screenshot."
L["options.event.character.zone.type.name"] = "Area Types"
L["options.event.character.zone.type.tooltip"] = "Sets which area types trigger a screenshot on the first visit. Floors and difficulties of the same instance count as one area."
L["options.event.character.zone.type.zone"] = "Open World"
L["options.event.character.zone.type.party"] = "Dungeons"
L["options.event.character.zone.type.raid"] = "Raids"
L["options.event.character.zone.type.scenario"] = "Scenarios"
L["options.event.character.zone.type.pvp"] = "Battlegrounds"
L["options.event.character.zone.type.arena"] = "Arenas"
L["options.event.character.zone.type.neighborhood"] = "Housing Neighborhoods"

L["options.event.achievement"] = "Achievements"
L["options.event.achievement.personal"] = "Personal Achievement"
L["options.event.achievement.personal.tooltip"] = "Takes a screenshot when an achievement is earned."
L["options.event.achievement.personal.exist.name"] = "Also for Achievements Already Earned"
L["options.event.achievement.personal.exist.tooltip"] = "Also takes a screenshot if the achievement has already been earned by another character."
L["options.event.achievement.criteria"] = "Personal Achievement Criteria"
L["options.event.achievement.criteria.tooltip"] = "Takes a screenshot when a criterion of an achievement is completed, e.g. one step of a multi-step achievement."
L["options.event.achievement.guild"] = "Guild Achievement"
L["options.event.achievement.guild.tooltip"] = "Takes a screenshot when the guild earns an achievement."

L["options.event.pve"] = "Instances and World Bosses (PvE)"
L["options.event.pve.victory"] = "Victory"
L["options.event.pve.wipe"] = "Wipe"
L["options.event.pve.world"] = "World Boss"
L["options.event.pve.world.tooltip"] = "Takes a screenshot when a world boss is defeated."
L["options.event.pve.world.first.name"] = "First Victory Only"
L["options.event.pve.world.first.tooltip"] = "Sets whether a screenshot is taken only for the first victory per world boss."
L["options.event.pve.party"] = "Dungeon Boss"
L["options.event.pve.party.victory.tooltip"] = "Takes a screenshot when a boss is defeated in a dungeon."
L["options.event.pve.party.wipe.tooltip"] = "Takes a screenshot when a boss fight in a dungeon ends in a wipe."
L["options.event.pve.raid"] = "Raid Boss"
L["options.event.pve.raid.victory.tooltip"] = "Takes a screenshot when a boss is defeated in a raid."
L["options.event.pve.raid.wipe.tooltip"] = "Takes a screenshot when a boss fight in a raid ends in a wipe."
L["options.event.pve.scenario"] = "Scenario / Delve Boss"
L["options.event.pve.scenario.victory.tooltip"] = "Takes a screenshot when a boss is defeated in a scenario or delve."
L["options.event.pve.scenario.wipe.tooltip"] = "Takes a screenshot when a boss fight in a scenario or delve ends in a wipe."
L["options.event.pve.victory.first.name"] = "First Victory Only per Difficulty"
L["options.event.pve.victory.first.tooltip"] = "Sets whether a screenshot is taken only for the first victory per boss and difficulty."
L["options.event.pve.mythic"] = "Mythic+ Dungeon Completion"
L["options.event.pve.mythic.tooltip"] = "Takes a screenshot when a Mythic+ dungeon is completed, even if the timer has expired."

L["options.event.pvp"] = "Player vs. Player (PvP)"
L["options.event.pvp.duel"] = "Duel Finished"
L["options.event.pvp.duel.tooltip"] = "Takes a screenshot when a duel ends, whether it is won, lost, or canceled."
L["options.event.pvp.arena"] = "Arena Completed"
L["options.event.pvp.arena.tooltip"] = "Takes a screenshot when an arena match ends."
L["options.event.pvp.battleground"] = "Battleground Completed"
L["options.event.pvp.battleground.tooltip"] = "Takes a screenshot when a battleground ends."
L["options.event.pvp.brawl"] = "Brawl Completed"
L["options.event.pvp.brawl.tooltip"] = "Takes a screenshot when a brawl ends."
L["options.event.pvp.victory.name"] = "Only on Victory"
L["options.event.pvp.victory.tooltip"] = "Takes a screenshot only if the PvP match is won."

L["options.event.collection"] = "Collections"
L["options.event.collection.new-pet"] = "New Pet"
L["options.event.collection.new-pet.tooltip"] = "Takes a screenshot when a new pet is added to the collection."
L["options.event.collection.new-mount"] = "New Mount"
L["options.event.collection.new-mount.tooltip"] = "Takes a screenshot when a new mount is added to the collection."
L["options.event.collection.new-toy"] = "New Toy"
L["options.event.collection.new-toy.tooltip"] = "Takes a screenshot when a new toy is added to the collection."
L["options.event.collection.new-recipe"] = "New Recipe"
L["options.event.collection.new-recipe.tooltip"] = "Takes a screenshot when a new recipe is learned."
L["options.event.collection.new-housing-item"] = "New Housing Decor"
L["options.event.collection.new-housing-item.tooltip"] = "Takes a screenshot when a new housing decor item is acquired."

L["options.event.other"] = "Other"
L["options.event.other.interval"] = "Regular Interval"
L["options.event.other.interval.tooltip"] = "Takes a screenshot at a regular interval while the character is logged in."
L["options.event.other.interval-timer.name"] = "Interval"
L["options.event.other.interval-timer.tooltip"] = "Sets the time interval at which a screenshot is taken.\n\nDefault: 5 minutes"
L["options.event.other.perks-activity"] = "Traveler's Log Activity Completed"
L["options.event.other.perks-activity.tooltip"] = "Takes a screenshot when a Traveler's Log activity is completed."
L["options.event.other.loot-toast"] = "Special Loot"
L["options.event.other.loot-toast.tooltip"] = "Takes screenshots of loot that WoW displays in a loot notification."
L["options.event.other.loot-toast.types.name"] = "Loot Types"
L["options.event.other.loot-toast.types.tooltip"] = "Sets which types of loot notifications trigger screenshots."
L["options.event.other.loot-toast.item.name"] = "Items"
L["options.event.other.loot-toast.item.tooltip"] = "Takes screenshots when WoW displays an item in a loot notification. The configured minimum quality applies."
L["options.event.other.loot-toast.quality.name"] = "Minimum Quality"
L["options.event.other.loot-toast.quality.tooltip"] = "Sets the minimum quality required for an item displayed in a loot notification to trigger a screenshot."
L["options.event.other.loot-toast.money.name"] = "Gold"
L["options.event.other.loot-toast.money.tooltip"] = "Takes screenshots when WoW displays gold in a loot notification."
L["options.event.other.loot-toast.currency.name"] = "Currencies"
L["options.event.other.loot-toast.currency.tooltip"] = "Takes screenshots when WoW displays a currency in a loot notification."

-- General

L["minimap-button.tooltip"] = "|cnLINK_FONT_COLOR:Right-click|r to open the options."

L["general.seconds-short"] = "sec"
L["general.minutes-short"] = "min"

-- Chat Notifications

L["chat.notification.class"] = "Class: %s"
L["chat.notification.time-played"] = "Total time played: %d |4day:days;, %d |4hour:hours;, %d |4minute:minutes;, %d |4second:seconds;"
L["chat.notification.level-time-played"] = "Time played on current level: %d |4day:days;, %d |4hour:hours;, %d |4minute:minutes;, %d |4second:seconds;"

-- Event Messages

L["chat.event.login.new"] = "Screenshot taken - |cnGOLD_FONT_COLOR:Player Login|r"
L["chat.event.zone.new"] = "Screenshot taken - |cnGOLD_FONT_COLOR:New Area|r - %s"
L["chat.event.level-up.retail.new"] = "Screenshot taken - |cnGOLD_FONT_COLOR:Level-Up|r - |cffFF4E00[Level %1$s]|r"
L["chat.event.level-up.classic.new"] = "Screenshot taken - |cnGOLD_FONT_COLOR:Level-Up|r - |cffFF4E00[Level %1$s]|r"
L["chat.event.level-up.time-played"] = "Time played on level %d: %d |4day:days;, %d |4hour:hours;, %d |4minute:minutes;, %d |4second:seconds;"
L["chat.event.death.new"] = "Screenshot taken - |cnGOLD_FONT_COLOR:Player Death|r"
L["chat.event.reputation.new"] = "Screenshot taken - |cnGOLD_FONT_COLOR:Reputation Rank Increased|r - %s (%s)"
L["chat.event.reputation.renown"] = "Renown %d"

L["chat.event.achievement.personal.new"] = "Screenshot taken - |cnGOLD_FONT_COLOR:Personal Achievement|r - %s"
L["chat.event.achievement.personal.exist"] = "Screenshot taken - |cnGOLD_FONT_COLOR:Personal Achievement|r - %s (has already been earned by another character)"
L["chat.event.achievement.personal.no-link.new"] = "Screenshot taken - |cnGOLD_FONT_COLOR:Personal Achievement|r"
L["chat.event.achievement.personal.no-link.exist"] = "Screenshot taken - |cnGOLD_FONT_COLOR:Personal Achievement|r (has already been earned by another character)"
L["chat.event.achievement.criteria.new"] = "Screenshot taken - |cnGOLD_FONT_COLOR:Personal Achievement Criteria|r - %s - %s"
L["chat.event.achievement.criteria.no-link.new"] = "Screenshot taken - |cnGOLD_FONT_COLOR:Personal Achievement Criteria|r"
L["chat.event.achievement.guild.new"] = "Screenshot taken - |cnGOLD_FONT_COLOR:Guild Achievement|r - %s"

L["chat.event.encounter.victory.new"] = "Screenshot taken - |cnGOLD_FONT_COLOR:Boss Fight - Victory|r - %s (%s)"
L["chat.event.encounter.wipe.new"] = "Screenshot taken - |cnGOLD_FONT_COLOR:Boss Fight - Wipe|r - %s (%s)"
L["chat.event.mythic.new"] = "Screenshot taken - |cnGOLD_FONT_COLOR:Mythic+ Dungeon Completion|r"

L["chat.event.pvp.duel.new"] = "Screenshot taken - |cnGOLD_FONT_COLOR:PvP - Duel Finished|r"
L["chat.event.pvp.arena.new"] = "Screenshot taken - |cnGOLD_FONT_COLOR:PvP - Arena Completed|r"
L["chat.event.pvp.battleground.new"] = "Screenshot taken - |cnGOLD_FONT_COLOR:PvP - Battleground Completed|r"
L["chat.event.pvp.brawl.new"] = "Screenshot taken - |cnGOLD_FONT_COLOR:PvP - Brawl Completed|r"

L["chat.event.warband-collection.new-pet.new"] = "Screenshot taken - |cnGOLD_FONT_COLOR:New Pet|r"
L["chat.event.warband-collection.new-mount.new"] = "Screenshot taken - |cnGOLD_FONT_COLOR:New Mount|r"
L["chat.event.warband-collection.new-toy.new"] = "Screenshot taken - |cnGOLD_FONT_COLOR:New Toy|r"
L["chat.event.warband-collection.new-recipe.new"] = "Screenshot taken - |cnGOLD_FONT_COLOR:New Recipe|r"
L["chat.event.warband-collection.new-housing-item.new"] = "Screenshot taken - |cnGOLD_FONT_COLOR:New Housing Decor|r"

L["chat.event.interval.new"] = "Screenshot taken - |cnGOLD_FONT_COLOR:Regular Interval|r"
L["chat.event.perks-activity.new"] = "Screenshot taken - |cnGOLD_FONT_COLOR:Traveler's Log Activity Completed|r"
L["chat.event.loot-toast.item.new"] = "Screenshot taken - |cnGOLD_FONT_COLOR:Special Loot - Item|r - %s"
L["chat.event.loot-toast.money.new"] = "Screenshot taken - |cnGOLD_FONT_COLOR:Special Loot - Gold|r - %s"
L["chat.event.loot-toast.currency.new"] = "Screenshot taken - |cnGOLD_FONT_COLOR:Special Loot - Currency|r - %s x%d"

-- Capture

L["capture.message"] = "Screenshot taken"
