local _, MEM = ...

if MEM.State and MEM.State.libraryIncompatible then return end

-- Library
local AWL = ArcaneWizardLibrary

MEM.ZONE_TYPES = {
	{kind = "zone", variableName = "zone-open-world"},
	{kind = "party", variableName = "zone-dungeon"},
	{kind = "raid", variableName = "zone-raid"}
}
if not AWL.GAME_TYPE_CLASSIC and not AWL.GAME_TYPE_TBC and not AWL.GAME_TYPE_FOREVER then
	MEM.ZONE_TYPES[#MEM.ZONE_TYPES + 1] = {kind = "scenario", variableName = "zone-scenario"}
end
MEM.ZONE_TYPES[#MEM.ZONE_TYPES + 1] = {kind = "pvp", variableName = "zone-battleground"}
if not AWL.GAME_TYPE_CLASSIC then
	MEM.ZONE_TYPES[#MEM.ZONE_TYPES + 1] = {kind = "arena", variableName = "zone-arena"}
end
if AWL.GAME_TYPE_RETAIL then
	MEM.ZONE_TYPES[#MEM.ZONE_TYPES + 1] = {kind = "neighborhood", variableName = "zone-neighborhood"}
end

MEM.ZONE_SETTING_BY_TYPE = {}
for _, area in ipairs(MEM.ZONE_TYPES) do
	MEM.ZONE_SETTING_BY_TYPE[area.kind] = area.variableName
end

MEM.NOTIFICATION_OPTIONS = {
	{variableName = "notification-timestamp", localizationKey = "options.general.notification.timestamp"},
	{variableName = "notification-class", localizationKey = "options.general.notification.class"},
	{variableName = "notification-time-played", localizationKey = "options.general.notification.time-played"},
	{variableName = "notification-level-time-played", localizationKey = "options.general.notification.level-time-played"}
}

MEM.LOOT_TOAST_OPTIONS = {
	{variableName = "loot-toast-item", localizationKey = "options.event.other.loot-toast.item"},
	{variableName = "loot-toast-money", localizationKey = "options.event.other.loot-toast.money"},
	{variableName = "loot-toast-currency", localizationKey = "options.event.other.loot-toast.currency"}
}

MEM.OPTIONS_DEFAULTS = {
	["general"] = {
		["minimap-button"] = {
			["hide"] = false,
			["minimapPos"] = 225,
			["lock"] = false,
			["showInCompartment"] = false
		},
		["notification"] = true,
		["notification-timestamp"] = false,
		["notification-class"] = false,
		["notification-time-played"] = false,
		["notification-level-time-played"] = false,
		["hide-ui"] = false,
		["hide-ui-message"] = false,
		["timestamp-format"] = "iso",
		["screenshot-sound"] = false,
		["screenshot-sound-style"] = "memento-camera",
		["debug-mode"] = false,
	},
	["manual"] = {
		["manual-button-visible"] = false,
		["manual-button-x"] = 0,
		["manual-button-y"] = 0,
		["manual-countdown-active"] = false,
		["manual-countdown-seconds"] = 3,
		["manual-hide-ui"] = true,
		["manual-show-message"] = false,
	},
	["event"] = {
		["login-active"] = false,
		["login-delay"] = 5,
		["zone-active"] = false,
		["zone-delay"] = 2,
		["zone-open-world"] = true,
		["zone-dungeon"] = true,
		["zone-raid"] = true,
		["zone-scenario"] = true,
		["zone-battleground"] = true,
		["zone-arena"] = true,
		["zone-neighborhood"] = true,
		["level-up-active"] = true,
		["level-up-delay"] = 5,
		["level-up-time-played"] = false,
		["reputation-active"] = true,
		["reputation-delay"] = 3,
		["death-active"] = true,
		["death-delay"] = 1,
		["death-instance"] = 0,

		["achievement-personal-active"] = true,
		["achievement-personal-delay"] = 3,
		["achievement-personal-exist"] = false,
		["achievement-criteria-active"] = false,
		["achievement-criteria-delay"] = 3,
		["achievement-guild-active"] = true,
		["achievement-guild-delay"] = 3,

		["encounter-victory-world-active"] = true,
		["encounter-victory-world-delay"] = 2,
		["encounter-victory-world-first"] = false,
		["encounter-victory-party-active"] = true,
		["encounter-victory-party-delay"] = 2,
		["encounter-victory-party-first"] = false,
		["encounter-wipe-party-active"] = false,
		["encounter-wipe-party-delay"] = 2,
		["encounter-victory-raid-active"] = true,
		["encounter-victory-raid-delay"] = 2,
		["encounter-victory-raid-first"] = false,
		["encounter-wipe-raid-active"] = false,
		["encounter-wipe-raid-delay"] = 2,
		["encounter-victory-scenario-active"] = true,
		["encounter-victory-scenario-delay"] = 2,
		["encounter-victory-scenario-first"] = false,
		["encounter-wipe-scenario-active"] = false,
		["encounter-wipe-scenario-delay"] = 2,
		["mythic-active"] = false,
		["mythic-delay"] = 1,

		["pvp-duel-active"] = true,
		["pvp-duel-delay"] = 1,
		["pvp-arena-active"] = true,
		["pvp-arena-delay"] = 3,
		["pvp-battleground-active"] = true,
		["pvp-battleground-delay"] = 3,
		["pvp-battleground-victory-only"] = false,
		["pvp-brawl-active"] = true,
		["pvp-brawl-delay"] = 3,
		["pvp-brawl-victory-only"] = false,

		["collection-pet-active"] = false,
		["collection-pet-delay"] = 1,
		["collection-mount-active"] = false,
		["collection-mount-delay"] = 1,
		["collection-toy-active"] = false,
		["collection-toy-delay"] = 1,
		["collection-recipe-active"] = false,
		["collection-recipe-delay"] = 1,
		["collection-housing-active"] = false,
		["collection-housing-delay"] = 1,

		["interval-active"] = false,
		["interval-timer"] = 5,
		["perks-activity-active"] = false,
		["perks-activity-delay"] = 1,
		["loot-toast-active"] = false,
		["loot-toast-delay"] = 1,
		["loot-toast-item"] = true,
		["loot-toast-quality"] = Enum.ItemQuality.Rare,
		["loot-toast-money"] = false,
		["loot-toast-currency"] = false,
	},
}
