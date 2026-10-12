local addonName, MEM = ...

local version = C_AddOns.GetAddOnMetadata(addonName, "Version") or ""
local buildDate = C_AddOns.GetAddOnMetadata(addonName, "X-BuildDate") or ""

MEM.CHANGELOG = {
	{
		version = version,
		date = buildDate ~= "" and buildDate or nil,
		entries = {
			"Refactoring of the addon structure and source code"
		}
	},
	{
		version = "v2.34",
		date = "2026-10-10",
		entries = {
			"Added: New event 'Reputation rank increased' - A screenshot can now be taken automatically when a reputation, friendship, or renown rank increases"
		}
	},
	{
		version = "v2.33",
		date = "2026-10-09",
		entries = {
			"Added: Option to hide the notification box in screenshots taken without the user interface",
			"Added: Option to choose the timestamp format for chat notifications and the screenshot notification box",
			"Added: ruRU localization",
			"Changed: Level-up notifications display the level without a hyperlink [mists of pandaria - classic] [forever] [retail]",
			"Updated: Compatibility with the beta client [forever]",
			"Minor code adjustments"
		}
	},
	{
		version = "v2.32",
		date = "2026-10-03",
		entries = {
			"Added: New event 'World boss defeated' - A screenshot can now be taken automatically when a world boss is defeated [retail]",
			"Added: New event 'Traveler's Log activity completed' - A screenshot can now be taken automatically when a Traveler's Log activity is completed [retail]",
			"Changed: Reordered options and separated subsections within option groups with horizontal lines",
			"Updated: Logo",
			"Updated: Compatibility with the beta client [forever]"
		}
	},
	{
		version = "v2.31",
		date = "2026-09-27",
		entries = {
			"Changed: Level-up notifications show the previous level's playtime once on a separate line",
			"Updated: Compatibility with the beta client [forever]",
			"Updated: deDE, enUS localizations",
			"Minor code adjustments"
		}
	},
	{
		version = "v2.30",
		date = "2026-09-24",
		entries = {
			"Updated: Compatibility with the beta client [forever]",
			"Adapted to the latest version of Arcane Wizard: Library to ensure full compatibility"
		}
	},
	{
		version = "v2.29",
		date = "2026-09-22",
		entries = {
			"Adapted to the latest version of Arcane Wizard: Library to ensure full compatibility",
			"Minor code adjustments"
		}
	},
	{
		version = "v2.28",
		date = "2026-09-18",
		entries = {
			"Added: Support for 'Forever'",
			"Changed: Character profiles now use GUIDs",
			"Changed: Addon initialization stops if the player identity is unavailable"
		}
	},
	{
		version = "v2.27",
		date = "2026-09-13",
		entries = {
			"Updated: GitHub links following the organization rename to 'arcane-wizard-dev'"
		}
	},
	{
		version = "v2.26",
		date = "2026-09-06",
		entries = {
			"Added: TOC version for patch 12.1.5 [retail]"
		}
	}
}
