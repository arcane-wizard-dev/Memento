local _, MEM = ...

if MEM.State and MEM.State.libraryIncompatible then return end

-- Library
local AWL = ArcaneWizardLibrary

-- Localization
local L = MEM.Localization

-- Current module
local Capture = MEM.Modules.Capture

-- Module imports
local CaptureConfig = MEM.UIConfig.Capture
local Utils = MEM.Modules.Utils

local MessageFrame = nil
local captureQueue = {}
local captureInProgress = false

-----------------------
--- Local Functions ---
-----------------------

local function CreateMessageFrame()
	local frame = CreateFrame("Frame")
	frame:ClearAllPoints()
	frame:SetPoint(CaptureConfig.point, 0, CaptureConfig.offsetY)
	frame:SetSize(CaptureConfig.width, CaptureConfig.height)

	frame.background = frame:CreateTexture(nil, "BACKGROUND")
	frame.background:ClearAllPoints()
	frame.background:SetAllPoints(frame)
	frame.background:SetTexture(CaptureConfig.backgroundTexture)

	frame.textTop = frame:CreateFontString(nil, "OVERLAY", CaptureConfig.topFont)
	frame.textTop:ClearAllPoints()
	frame.textTop:SetPoint("CENTER", 0, CaptureConfig.topOffsetY)
	frame.textTop:SetFont(tostring(frame.textTop:GetFont()), CaptureConfig.fontSize)
	frame.textTop:SetText(L["capture.message"])

	frame.textBottom = frame:CreateFontString(nil, "OVERLAY", CaptureConfig.bottomFont)
	frame.textBottom:ClearAllPoints()
	frame.textBottom:SetPoint("CENTER", 0, CaptureConfig.bottomOffsetY)
	frame.textBottom:SetFont(tostring(frame.textBottom:GetFont()), CaptureConfig.fontSize)
	frame.textBottom:SetText(tostring(date(Utils:GetTimestampFormat(), GetServerTime())))

	return frame
end

local function UpdateMessageFrame()
	if not MessageFrame then
		MessageFrame = CreateMessageFrame()
	end

	MessageFrame.textBottom:SetText(tostring(date(Utils:GetTimestampFormat(), GetServerTime())))

	return MessageFrame
end

local function GetSoundKitID(sound)
	return SOUNDKIT and SOUNDKIT[sound] or nil
end

local function PlayScreenshotSound(ignoreSetting, soundKey)
	if not ignoreSetting and not MEM.Settings.general["screenshot-sound"] then return end

	soundKey = soundKey or MEM.Settings.general["screenshot-sound-style"] or MEM.SCREENSHOT_SOUND_DEFAULT
	local soundData = MEM.SCREENSHOT_SOUND_BY_KEY[soundKey]

	if not soundData then return end

	if soundData.filePath then
		local status, willPlay = pcall(PlaySoundFile, soundData.filePath, MEM.SCREENSHOT_SOUND_CHANNEL)

		if status and willPlay ~= false then
			return
		end
	end

	local soundKitNames = soundData.soundKitNames

	if not soundKitNames then return end

	for _, soundKitName in ipairs(soundKitNames) do
		local soundKitID = GetSoundKitID(soundKitName)

		if soundKitID then
			local status, willPlay = pcall(PlaySound, soundKitID, MEM.SCREENSHOT_SOUND_CHANNEL)

			if status and willPlay then
				return
			end
		end
	end
end

local function ProcessCaptureQueue()
	-- Aufträge nacheinander abarbeiten, damit ausgeblendete UI und Meldungsbox den nächsten Screenshot nicht beeinflussen.
	if captureInProgress or #captureQueue == 0 then return end

	local request = table.remove(captureQueue, 1)
	local hiddenUI = false
	local frame = nil
	captureInProgress = true

	local function FinishCapture()
		if hiddenUI then
			UIParent:Show()
		end
		if frame then
			frame:Hide()
		end
		captureInProgress = false
		ProcessCaptureQueue()
	end

	local function RecordScreenshot()
		local status, err = pcall(function()
			Screenshot()
			PlayScreenshotSound()
		end)
		if not status then
			Utils:PrintDebug("Screenshot failed: " .. tostring(err))
		else
			Utils:PrintDebug("Screenshot taken.")
		end
	end

	local status, err = pcall(function()
		if request.hideUI and not InCombatLockdown() then
			if UIParent:IsShown() then
				hiddenUI = true
				UIParent:Hide()
			end
			if request.showMessage then
				frame = UpdateMessageFrame()
				frame:Show()
			end
		end
	end)

	if not status then
		Utils:PrintDebug("Screenshot preparation failed: " .. tostring(err))
		if hiddenUI then
			UIParent:Show()
			hiddenUI = false
		end
		if frame then
			frame:Hide()
		end
		RecordScreenshot()
		FinishCapture()
	elseif hiddenUI or frame then
		C_Timer.After(MEM.SCREENSHOT_RENDER_DELAY, function()
			RecordScreenshot()
			C_Timer.After(MEM.SCREENSHOT_RESTORE_DELAY, FinishCapture)
		end)
	else
		RecordScreenshot()
		FinishCapture()
	end
end

local function TakeScreenshot()
	captureQueue[#captureQueue + 1] = {
		hideUI = MEM.Settings.general["hide-ui"],
		showMessage = MEM.Settings.general["hide-ui-message"]
	}
	ProcessCaptureQueue()
end

local function NotifyScreenshot(message, previousLevel, timePlayedOnPreviousLevel)
	Utils:PrintMessage(message, previousLevel, timePlayedOnPreviousLevel)
	TakeScreenshot()
end

local function AchievementPersonalEventHandler(achievementID, alreadyEarned)
	local achievementLink = GetAchievementLink(achievementID)

	if achievementLink then
		if not alreadyEarned then
			NotifyScreenshot(L["chat.event.achievement.personal.new"]:format(achievementLink))
		elseif MEM.Settings.event["achievement-personal-exist"] then
			NotifyScreenshot(L["chat.event.achievement.personal.exist"]:format(achievementLink))
		else
			Utils:PrintDebug(string.format(
				"The achievement %s has already been reached by another character. No screenshot requested.",
				tostring(achievementLink)
			))
		end
	else
		Utils:PrintDebug("Unknown AchievementLink. (nil value / unknown ID)")

		if not alreadyEarned then
			NotifyScreenshot(L["chat.event.achievement.personal.no-link.new"])
		elseif MEM.Settings.event["achievement-personal-exist"] then
			NotifyScreenshot(L["chat.event.achievement.personal.no-link.exist"])
		else
			Utils:PrintDebug("The achievement has already been reached by another character. No screenshot requested.")
		end
	end
end

local function AchievementGuildEventHandler(achievementID)
	local name = select(2, GetAchievementInfo(achievementID))

	NotifyScreenshot(L["chat.event.achievement.guild.new"]:format(name))
end

local function CriteriaEventHandler(achievementID, description)
	local achievementLink = GetAchievementLink(achievementID)

	if achievementLink then
		NotifyScreenshot(L["chat.event.achievement.criteria.new"]:format(achievementLink, description))
	else
		Utils:PrintDebug("Unknown AchievementLink. (nil value / unknown ID)")
		NotifyScreenshot(L["chat.event.achievement.criteria.no-link.new"])
	end
end

local function EncounterVictoryEventHandler(encounterName, difficultyName, difficulty, encounterID)
	NotifyScreenshot(L["chat.event.encounter.victory.new"]:format(encounterName, difficultyName))

	if not MEM.Data.bossKill[difficulty] then
		MEM.Data.bossKill[difficulty] = {}
	end

	MEM.Data.bossKill[difficulty][encounterID] = true
end

local function EncounterWipeEventHandler(encounterName, difficultyName)
	NotifyScreenshot(L["chat.event.encounter.wipe.new"]:format(encounterName, difficultyName))
end

local function PvPDuelEventHandler()
	NotifyScreenshot(L["chat.event.pvp.duel.new"])
end

local function PvPArenaEventHandler()
	NotifyScreenshot(L["chat.event.pvp.arena.new"])
end

local function PvPBattlegroundEventHandler()
	NotifyScreenshot(L["chat.event.pvp.battleground.new"])
end

local function PvPBrawlEventHandler()
	NotifyScreenshot(L["chat.event.pvp.brawl.new"])
end

local function NewPetEventHandler()
	NotifyScreenshot(L["chat.event.warband-collection.new-pet.new"])
end

local function NewMountEventHandler()
	NotifyScreenshot(L["chat.event.warband-collection.new-mount.new"])
end

local function NewToyEventHandler()
	NotifyScreenshot(L["chat.event.warband-collection.new-toy.new"])
end

local function NewRecipeEventHandler()
	NotifyScreenshot(L["chat.event.warband-collection.new-recipe.new"])
end

local function NewHousingItemEventHandler()
	NotifyScreenshot(L["chat.event.warband-collection.new-housing-item.new"])
end

local function LoginEventHandler()
	NotifyScreenshot(L["chat.event.login.new"])
end

local function ZoneEventHandler(name)
	NotifyScreenshot(L["chat.event.zone.new"]:format(name))
end

local function LevelUpEventHandler(level, timePlayedOnPreviousLevel)
	local message = nil

	if AWL.GAME_TYPE_CLASSIC or AWL.GAME_TYPE_TBC then
		message = L["chat.event.level-up.classic.new"]:format(tostring(level))
	elseif AWL.GAME_TYPE_MISTS or AWL.GAME_TYPE_RETAIL or AWL.GAME_TYPE_FOREVER then
		message = L["chat.event.level-up.retail.new"]:format(tostring(level))
	end

	if message then
		NotifyScreenshot(message, level - 1, timePlayedOnPreviousLevel)
	else
		TakeScreenshot()
	end
end

local function ReputationEventHandler(factionName, rankName)
	NotifyScreenshot(L["chat.event.reputation.new"]:format(factionName, rankName))
end

local function DeathEventHandler()
	NotifyScreenshot(L["chat.event.death.new"])
end

local function MythicEventHandler()
	NotifyScreenshot(L["chat.event.mythic.new"])
end

local function PerksActivityEventHandler()
	NotifyScreenshot(L["chat.event.perks-activity.new"])
end

local function LootToastEventHandler(typeIdentifier, itemLink, quantity)
	if typeIdentifier == MEM.LOOT_TOAST_TYPE.ITEM then
		NotifyScreenshot(L["chat.event.loot-toast.item.new"]:format(itemLink or UNKNOWN))
	elseif typeIdentifier == MEM.LOOT_TOAST_TYPE.MONEY then
		NotifyScreenshot(L["chat.event.loot-toast.money.new"]:format(GetMoneyString(quantity or 0, true)))
	elseif typeIdentifier == MEM.LOOT_TOAST_TYPE.CURRENCY then
		NotifyScreenshot(L["chat.event.loot-toast.currency.new"]:format(itemLink or UNKNOWN, quantity or 0))
	else
		TakeScreenshot()
	end
end

local function IntervalEventHandler()
	NotifyScreenshot(L["chat.event.interval.new"])
end

local handlerTable = {
	["AchievementPersonalEventHandler"] = AchievementPersonalEventHandler,
	["AchievementGuildEventHandler"]    = AchievementGuildEventHandler,
	["CriteriaEventHandler"]            = CriteriaEventHandler,
	["EncounterVictoryEventHandler"]    = EncounterVictoryEventHandler,
	["EncounterWipeEventHandler"]       = EncounterWipeEventHandler,
	["PvPDuelEventHandler"]             = PvPDuelEventHandler,
	["PvPArenaEventHandler"]            = PvPArenaEventHandler,
	["PvPBattlegroundEventHandler"]     = PvPBattlegroundEventHandler,
	["PvPBrawlEventHandler"]            = PvPBrawlEventHandler,
	["NewPetEventHandler"]              = NewPetEventHandler,
	["NewMountEventHandler"]            = NewMountEventHandler,
	["NewToyEventHandler"]              = NewToyEventHandler,
	["NewRecipeEventHandler"]           = NewRecipeEventHandler,
	["NewHousingItemEventHandler"]      = NewHousingItemEventHandler,
	["LoginEventHandler"]               = LoginEventHandler,
	["ZoneEventHandler"]                = ZoneEventHandler,
	["LevelUpEventHandler"]             = LevelUpEventHandler,
	["ReputationEventHandler"]          = ReputationEventHandler,
	["DeathEventHandler"]               = DeathEventHandler,
	["MythicEventHandler"]              = MythicEventHandler,
	["PerksActivityEventHandler"]       = PerksActivityEventHandler,
	["LootToastEventHandler"]           = LootToastEventHandler,
	["IntervalEventHandler"]            = IntervalEventHandler
}

------------------------
--- Module Functions ---
------------------------

function Capture:PreviewScreenshotSound(soundKey)
	PlayScreenshotSound(true, soundKey)
end

function Capture:ScheduleTimer(handler, delay, ...)
	local args = {...}

	C_Timer.After(delay, function()
		if handlerTable[handler] then
			handlerTable[handler](unpack(args))
		else
			Utils:PrintDebug(string.format(
				"Handler '%s' not found.",
				tostring(handler)
			))
		end
	end)
end
