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

function Utils:IsAccountProfile()
	local characterGUID = AWL.Utils:GetCharacterGUID()

	return Memento_Options_v6.profileKeys[characterGUID]["use-account"]
end

function Utils:OpenSettingsOnLoading()
	local characterGUID = AWL.Utils:GetCharacterGUID()

	if Memento_Options_v6.profileKeys[characterGUID]["open-settings"] then
		if not self:OpenSettings() then
			return
		end

		Memento_Options_v6.profileKeys[characterGUID]["open-settings"] = false
	end
end

function Utils:ToggleProfileMode()
	local characterGUID = AWL.Utils:GetCharacterGUID()
	local useAccountProfile = self:IsAccountProfile()

	Memento_Options_v6.profileKeys[characterGUID]["use-account"] = not useAccountProfile
	Memento_Options_v6.profileKeys[characterGUID]["open-settings"] = true
end

function Utils:ResetAllCharacterProfiles()
	local characterGUID = AWL.Utils:GetCharacterGUID()

	Memento_Options_v6.profiles = {}
	Memento_Options_v6.profileKeys = {}

	Memento_Options_v6.profileKeys[characterGUID] = {
		["use-account"] = true,
		["open-settings"] = true
	}
end

function Utils:InitializeDatabase()
	local characterGUID = AWL.Utils:GetCharacterGUID()

	if not characterGUID then
		return nil
	end

	local createdProfile = false
	local createdProfileKey = false

	local defaults = {
		["general"] = {
			["minimap-button"] = {
				["hide"] = false
			}
		},
		["event"] = {}
	}

	if not Memento_Options_v6 then
		Memento_Options_v6 = {
			["account"] = AWL.Utils:CopyTable(defaults),
			["profiles"] = {},
			["profileKeys"] = {}
		}
	end

	if not Memento_Options_v6.profiles[characterGUID] then
		Memento_Options_v6.profiles[characterGUID] = AWL.Utils:CopyTable(defaults)
		createdProfile = true
	end

	if not Memento_Options_v6.profileKeys[characterGUID] then
		Memento_Options_v6.profileKeys[characterGUID] = {
			["use-account"] = true,
			["open-settings"] = false
		}
		createdProfileKey = true
	end

	local useAccountProfile = Memento_Options_v6.profileKeys[characterGUID]["use-account"]

	if useAccountProfile then
		MEM.Settings.general = Memento_Options_v6.account["general"]
		MEM.Settings.event = Memento_Options_v6.account["event"]
	else
		MEM.Settings.general = Memento_Options_v6.profiles[characterGUID]["general"]
		MEM.Settings.event = Memento_Options_v6.profiles[characterGUID]["event"]
	end

	if not Memento_DataBossKill then
		Memento_DataBossKill = {}
	end

	MEM.Data.bossKill = Memento_DataBossKill

	return {
		characterGUID = characterGUID,
		createdProfile = createdProfile,
		createdProfileKey = createdProfileKey,
		activeProfile = useAccountProfile and "account" or "character"
	}
end

function Utils:InitializeMinimapButton()
	self.minimapButton = Addon:RegisterMinimapButton({
		db = MEM.Settings.general["minimap-button"],
		tooltip = L["minimap-button.tooltip"]
	})
end
