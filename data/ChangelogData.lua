local addonName, MEM = ...

if MEM.State and MEM.State.libraryIncompatible then return end

local version = C_AddOns.GetAddOnMetadata(addonName, "Version") or ""
local buildDate = C_AddOns.GetAddOnMetadata(addonName, "X-BuildDate") or ""

MEM.CHANGELOG = {
	notices = {},
	-- BEGIN GENERATED CHANGELOG
	{
		version = version,
		date = buildDate ~= "" and buildDate or nil,
		entries = {
			"Fixed: Renown events for invalid factions could trigger screenshots"
		}
	},
	{
		version = "v2.45",
		date = "2026-11-06",
		entries = {
			"Changed: The Basic debug level now shows important messages, while Advanced also includes technical details",
			"Updated: deDE, enUS, ruRU localizations",
			"Removed obsolete code for better maintainability"
		}
	},
	{
		version = "v2.44",
		date = "2026-11-05",
		entries = {
			"Changed: Debug messages are now converted and formatted only when debug mode is enabled",
			"Requires Arcane Wizard: Library revision 4 or later"
		}
	},
	{
		version = "v2.43",
		date = "2026-11-03",
		entries = {
			"Changed: The debug mode option now combines an enable checkbox with a Basic or Advanced level selector",
			"Updated: deDE, enUS, ruRU localizations",
			"Minor code adjustments"
		}
	},
	{
		version = "v2.42",
		date = "2026-11-01",
		entries = {
			"Added: Manual screenshots with a movable button, a key binding configurable in the addon settings, optional countdown and capture notice",
			"Changed: The TOC no longer restricts loading by game type",
			"Requires Arcane Wizard: Library revision 3 or later",
			"Minor code adjustments"
		}
	},
	{
		version = "v2.41",
		date = "2026-11-01",
		entries = {
			"Changed: Grouped related settings in the options menu and added individual choices for supported area types",
			"Changed: Areas count as visited when Memento requests a screenshot",
			"Changed: Limited loading to Retail, Forever, Classic, and Talebound",
			"Updated: deDE, enUS, ruRU localizations",
			"Fixed: Housing neighborhoods were not recognized by the 'New area' event [retail]",
			"Fixed: Visited areas were lost after a reload or logout",
			"Requires Arcane Wizard: Library revision 2 or later",
			"Minor code adjustments"
		}
	},
	{
		version = "v2.40",
		date = "2026-10-29",
		entries = {
			"Added: TOC version for patch 12.1.7 [retail]",
			"Updated: Addon description",
			"Removed: TOC version for patch 12.1.0 [retail]"
		}
	},
	{
		version = "v2.39",
		date = "2026-10-28",
		entries = {
			"Added: Startup check for the minimum required Library revision",
			"Added: New event 'New area entered' - A screenshot can now be taken automatically when a character first enters an open-world zone or instance, with a choice of zones, instances or both",
			"Updated: deDE, enUS, ruRU localizations",
			"Updated: Addon description",
			"Fixed: Playtime for the current level now resets when leveling up even if level-up screenshots are disabled",
			"Minor code adjustments"
		}
	},
	{
		version = "v2.38",
		date = "2026-10-21",
		entries = {
			"Added: Options to choose the screenshot file format and JPEG quality",
			"Changed: Regrouped screenshot events in the options menu"
		}
	},
	{
		version = "v2.37",
		date = "2026-10-16",
		entries = {
			"Adapted to the latest version of Arcane Wizard: Library to ensure full compatibility"
		}
	}
	-- END GENERATED CHANGELOG
}
