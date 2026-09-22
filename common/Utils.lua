local addonName, MEM = ...

-- Library
local AWL = ArcaneWizardLibrary
local Addon = AWL:GetAddon(addonName)

-- Localization
local L = MEM.Localization

-- Current module
local Utils = MEM.Modules.Utils

-----------------------
--- Local Functions ---
-----------------------

local function PrintChatMessage(color, prefix, msg)
	DEFAULT_CHAT_FRAME:AddMessage(color:WrapTextInColorCode(prefix .. ": ") .. tostring(msg))
end

------------------------
--- Module Functions ---
------------------------

function Utils:GetDurationParts(totalSeconds)
	local seconds = math.max(0, math.floor(totalSeconds or 0))
	local days = math.floor(seconds / 86400)
	seconds = seconds % 86400

	local hours = math.floor(seconds / 3600)
	seconds = seconds % 3600

	local minutes = math.floor(seconds / 60)
	seconds = seconds % 60

	return days, hours, minutes, seconds
end

function Utils:RequestTimePlayed()
	if not (MEM.Settings.general["notification-time-played"] or MEM.Settings.general["notification-level-time-played"] or MEM.Settings.event["level-up-time-played"]) or MEM.State.timePlayedInitialized then
		self:PrintDebug("RequestTimePlayed() skipped.")

		return
	end

	self:PrintDebug("RequestTimePlayed() scheduled.")

	RequestTimePlayed()
end

function Utils:PrintMessage(msg)
	if MEM.Settings.general["notification"] then
		if MEM.Settings.general["notification-timestamp"] then
			local formattedTime = date("%d.%m.%y - %H:%M:%S")
			PrintChatMessage(NORMAL_FONT_COLOR, addonName, msg .. " [" .. formattedTime .. "]")
		else
			PrintChatMessage(NORMAL_FONT_COLOR, addonName, msg)
		end

		if MEM.Settings.general["notification-class"] then
			local className = UnitClass("player")
			PrintChatMessage(NORMAL_FONT_COLOR, addonName, L["chat.notification.class"]:format(className))
		end

		if MEM.Settings.general["notification-time-played"] then
			local days, hours, minutes, seconds = self:GetDurationParts(MEM.State.totalTimePlayed)

			PrintChatMessage(NORMAL_FONT_COLOR, addonName, L["chat.notification.time-played"]:format(days, hours, minutes, seconds))
		end

		if MEM.Settings.general["notification-level-time-played"] then
			local days, hours, minutes, seconds = self:GetDurationParts(MEM.State.timePlayedThisLevel)

			PrintChatMessage(NORMAL_FONT_COLOR, addonName, L["chat.notification.level-time-played"]:format(days, hours, minutes, seconds))
		end
	end
end

function Utils:PrintDebug(msg)
	if MEM.Settings.general["debug-mode"] then
		PrintChatMessage(ORANGE_FONT_COLOR, addonName .. " (Debug)", msg)
	end
end

function Utils:OpenSettings()
	if not Addon:OpenCategory() then
		self:PrintDebug("In combat. The options menu cannot be opened.")
		return false
	end

	return true
end

function Utils:InitializeDatabase()
	local dbInit = Addon:InitializeOptions({
		databaseName = "Memento_Options_v6",
		defaults = MEM.OPTIONS_DEFAULTS,
		onOpenSettings = function()
			return self:OpenSettings()
		end
	})

	if not dbInit then
		return nil
	end

	MEM.Settings.global = dbInit.global
	MEM.Settings.general = dbInit.settings["general"]
	MEM.Settings.event = dbInit.settings["event"]

	if not Memento_DataBossKill then
		Memento_DataBossKill = {}
	end

	MEM.Data.bossKill = Memento_DataBossKill

	return dbInit
end

function Utils:InitializeMinimapButton()
	self.minimapButton = Addon:RegisterMinimapButton({
		db = MEM.Settings.general["minimap-button"],
		tooltip = L["minimap-button.tooltip"]
	})
end
