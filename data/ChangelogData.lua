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
			"Added: Option to temporarily disable HDR for manual and automatic screenshots"
		}
	},
	{
		version = "v2.51-alpha.1",
		date = "2026-11-20",
		entries = {
			"Added: Option to temporarily disable HDR for manual and automatic screenshots"
		}
	},
	{
		version = "v2.50",
		date = "2026-11-17",
		entries = {
			"Added: A help command lists available slash commands, and unknown commands show a hint in chat",
			"Requires Arcane Wizard: Library revision 6 or later"
		}
	},
	{
		version = "v2.49",
		date = "2026-11-14",
		entries = {
			"Minor code adjustments"
		}
	},
	{
		version = "v2.48",
		date = "2026-11-10",
		entries = {
			"Changed: Reworked the options menu to prevent errors in Blizzard's settings and added a button to restore default values",
			"Removed: Addon options from Blizzard's settings search",
			"Requires Arcane Wizard: Library revision 5 or later"
		}
	},
	{
		version = "v2.47",
		date = "2026-11-08",
		entries = {
			"Added: Chat notifications for manual screenshots",
			"Added: Options to hide the screenshot button's border and background and lock its position",
			"Fixed: The PvP victory filter now checks the player's match team [forever] [retail]",
			"Minor code adjustments",
			"Removed obsolete code for better maintainability"
		}
	},
	{
		version = "v2.46",
		date = "2026-11-08",
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
	}
	-- END GENERATED CHANGELOG
}
