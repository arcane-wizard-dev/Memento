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
			"Changed: HDR is restored one second after the last screenshot [forever]"
		}
	},
	{
		version = "v2.52",
		date = "2026-11-25",
		entries = {
			"Added: In-game help answers common questions and explains each chat command. Open it from the addon settings or type the addon's slash command followed by 'help'",
			"Requires Arcane Wizard: Library revision 8 or later"
		}
	},
	{
		version = "v2.51",
		date = "2026-11-23",
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
	}
	-- END GENERATED CHANGELOG
}
