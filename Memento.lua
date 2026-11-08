local addonName, MEM = ...

if MEM.State and MEM.State.libraryIncompatible then return end

-- Library
local AWL = ArcaneWizardLibrary
local Addon = AWL:GetAddon(addonName)

-- Localization
local L = MEM.Localization

-- Module imports
local Capture = MEM.Modules.Capture
local Options = MEM.Modules.Options
local Reputation = MEM.Modules.Reputation
local Utils = MEM.Modules.Utils

local ZoneSettingKeys = MEM.ZONE_SETTING_BY_TYPE

-- Variables
local isInitialized = false
local minutesPassed = 0
local sessionStartTime = 0

--------------
--- Frames ---
--------------

local MementoFrame = CreateFrame("Frame", "Memento")

-----------------------
--- Local Functions ---
-----------------------

local function TimePlayed()
	local currentTime = GetTime()
	local timeLastCheck = currentTime - sessionStartTime

	MEM.State.totalTimePlayed = MEM.State.totalTimePlayed + timeLastCheck
	MEM.State.timePlayedThisLevel = MEM.State.timePlayedThisLevel + timeLastCheck

	sessionStartTime = currentTime
end

local function ScheduleScreenshot(handler, delay, ...)
	TimePlayed()
	Capture:ScheduleTimer(handler, delay, ...)
end

local function GetCurrentArea()
	local name, instanceType, _, _, _, _, _, instanceID = GetInstanceInfo()
	Utils:PrintDebugAdvanced(
		"GetInstanceInfo() returned: name=%s, instanceType=%s, instanceID=%s",
		name, instanceType, instanceID
	)

	if not instanceType or instanceType == "" then return nil end

	if instanceType ~= "none" then
		if instanceType == "zone" or not ZoneSettingKeys[instanceType] then return nil end
		if not instanceID or instanceID <= 0 or not name or name == "" then return nil end

		return instanceType, instanceID, name
	end

	local mapID = C_Map.GetBestMapForUnit("player")
	Utils:PrintDebugAdvanced("C_Map.GetBestMapForUnit('player') returned: mapID=%s", mapID)
	if not mapID or mapID <= 0 then return nil end

	local info = MapUtil.GetMapParentInfo(mapID, Enum.UIMapType.Zone)
	Utils:PrintDebugAdvanced(
		"MapUtil.GetMapParentInfo() returned: mapID=%s, name=%s",
		info and info.mapID, info and info.name
	)
	if not info or not info.mapID or info.mapID <= 0 or not info.name or info.name == "" then return nil end

	return "zone", info.mapID, info.name
end

local function ScheduleReputationScreenshot(factionName, rankName, reason)
	if not factionName then
		Utils:PrintDebugAdvanced("%s No screenshot requested.", reason or "No reputation rank increase detected.")
	elseif not MEM.Settings.event["reputation-active"] then
		Utils:PrintDebugAdvanced("Reputation screenshots are disabled. No screenshot requested.")
	else
		ScheduleScreenshot("ReputationEventHandler", MEM.Settings.event["reputation-delay"] + MEM.CAPTURE_DELAY_OFFSET, factionName, rankName)
	end
end

local function ProcessLootToast(itemLink, minimumQuality, delay, retriesRemaining)
	local itemQuality = C_Item.GetItemQualityByID(itemLink)
	Utils:PrintDebugAdvanced(
		"C_Item.GetItemQualityByID() returned: itemLink=%s, itemQuality=%s, minimumQuality=%s",
		itemLink, itemQuality, minimumQuality
	)

	if itemQuality == nil then
		if retriesRemaining > 0 then
			Utils:PrintDebugAdvanced("Item quality is unavailable. Waiting for item data.")
			C_Item.RequestLoadItemDataByID(itemLink)

			C_Timer.After(MEM.LOOT_TOAST_ITEM_LOAD_RETRY_DELAY, function()
				ProcessLootToast(itemLink, minimumQuality, delay, retriesRemaining - 1)
			end)
		else
			Utils:PrintDebug(
				"Item quality for '%s' could not be loaded. No screenshot requested.",
				itemLink
			)
			Utils:PrintDebugAdvanced("Event 'SHOW_LOOT_TOAST' completed.")
		end

		return
	end

	if itemQuality < minimumQuality then
		Utils:PrintDebugAdvanced(
			"Item quality %s is below the configured minimum quality %s. No screenshot requested.",
			itemQuality, minimumQuality
		)
		Utils:PrintDebugAdvanced("Event 'SHOW_LOOT_TOAST' completed.")
		return
	end

	ScheduleScreenshot("LootToastEventHandler", delay + MEM.CAPTURE_DELAY_OFFSET, MEM.LOOT_TOAST_TYPE.ITEM, itemLink, nil)
	Utils:PrintDebugAdvanced("Event 'SHOW_LOOT_TOAST' completed.")
end

local function CheckInterval()
	Utils:PrintDebugAdvanced("Timer triggered.")

	minutesPassed = minutesPassed + 1

	if MEM.Settings.event["interval-active"] and minutesPassed >= MEM.Settings.event["interval-timer"] then
		ScheduleScreenshot("IntervalEventHandler", MEM.CAPTURE_DELAY_OFFSET)

		minutesPassed = 0
	elseif not MEM.Settings.event["interval-active"] then
		Utils:PrintDebugAdvanced("Interval screenshots are disabled. No screenshot requested.")
	else
		Utils:PrintDebugAdvanced("The screenshot interval has not elapsed. No screenshot requested.")
	end

	Utils:PrintDebugAdvanced("Timer completed.")
end

local function IsPlayerWinner(winner)
	local playerTeam = GetBattlefieldArenaFaction()
	Utils:PrintDebugAdvanced("GetBattlefieldArenaFaction() returned: team=%s, winner=%s", playerTeam, winner)

	return (winner == 0 or winner == 1) and playerTeam == winner
end

local function SlashCommand(msg)
	if not isInitialized then return end

	local command = strtrim(msg or "")

	if command == "" then
		Utils:OpenSettings()
	elseif command == "changelog" then
		AWL.Frames:OpenChangelog(addonName, MEM.CHANGELOG)
	else
		Utils:PrintDebug("These arguments are not accepted.")
	end
end

------------------------
--- Public Functions ---
------------------------

function MementoFrame:OnEvent(event, ...)
	self[event](self, event, ...)
end

function MementoFrame:ADDON_LOADED(_, addOnName)
	if addOnName ~= addonName or isInitialized then return end

	local dbInit = Utils:InitializeDatabase()

	if not dbInit then
		Addon:AbortInitialization(self)

		return
	end

	Utils:InitializeMinimapButton()
	Options:Initialize()
	MEM.Modules.ScreenshotButton:Initialize()

	Utils:RequestTimePlayed()
	Addon:OpenSettingsOnLoading()

	sessionStartTime = GetTime()
	C_Timer.NewTicker(MEM.INTERVAL_CHECK_SECONDS, CheckInterval)

	isInitialized = true

	Utils:PrintDebugAdvanced(
		"InitializeDatabase: key=%s, createdProfile=%s, createdProfileKey=%s, cleanedOptions=%s, activeProfile=%s",
		dbInit.characterGUID,
		dbInit.createdProfile,
		dbInit.createdProfileKey,
		dbInit.cleanedOptions,
		dbInit.activeProfile
	)
	Utils:PrintDebug("Addon fully loaded.")
end

function MementoFrame:TIME_PLAYED_MSG(_, totalTimePlayed, timePlayedThisLevel)
	Utils:PrintDebugAdvanced(
		"Event 'TIME_PLAYED_MSG' fired. Payload: totalTimePlayed=%s, timePlayedThisLevel=%s",
		totalTimePlayed, timePlayedThisLevel
	)

	MEM.State.totalTimePlayed = totalTimePlayed
	MEM.State.timePlayedThisLevel = timePlayedThisLevel
	MEM.State.timePlayedInitialized = true

	sessionStartTime = GetTime()

	Utils:PrintDebugAdvanced("Event 'TIME_PLAYED_MSG' completed.")
end

function MementoFrame:SHOW_LOOT_TOAST(_, typeIdentifier, itemLink, quantity, specID, sex, personalLootToast, toastMethod, lessAwesome, upgraded, corrupted)
	Utils:PrintDebugAdvanced(
		"Event 'SHOW_LOOT_TOAST' fired. Payload: typeIdentifier=%s, itemLink=%s, quantity=%s, specID=%s, sex=%s, personalLootToast=%s, toastMethod=%s, lessAwesome=%s, upgraded=%s, corrupted=%s",
		typeIdentifier,
		itemLink,
		quantity,
		specID,
		sex,
		personalLootToast,
		toastMethod,
		lessAwesome,
		upgraded,
		corrupted
	)

	if not MEM.Settings.event["loot-toast-active"] then
		Utils:PrintDebugAdvanced("Loot toast screenshots are disabled. No screenshot requested.")
		Utils:PrintDebugAdvanced("Event 'SHOW_LOOT_TOAST' completed.")
		return
	end

	local settingKey = MEM.LOOT_TOAST_SETTING_BY_TYPE[typeIdentifier]

	if not settingKey then
		Utils:PrintDebugAdvanced(
			"Event 'SHOW_LOOT_TOAST' has unsupported typeIdentifier '%s'. No screenshot requested.",
			typeIdentifier
		)
		Utils:PrintDebugAdvanced("Event 'SHOW_LOOT_TOAST' completed.")
		return
	end

	if not MEM.Settings.event[settingKey] then
		Utils:PrintDebugAdvanced(
			"Event 'SHOW_LOOT_TOAST' type '%s' is disabled. No screenshot requested.",
			typeIdentifier
		)
		Utils:PrintDebugAdvanced("Event 'SHOW_LOOT_TOAST' completed.")
		return
	end

	local delay = MEM.Settings.event["loot-toast-delay"] or MEM.OPTIONS_DEFAULTS.event["loot-toast-delay"]

	if typeIdentifier == MEM.LOOT_TOAST_TYPE.ITEM then
		if not itemLink then
			Utils:PrintDebugAdvanced("Event 'SHOW_LOOT_TOAST' did not contain an item link. No screenshot requested.")
			Utils:PrintDebugAdvanced("Event 'SHOW_LOOT_TOAST' completed.")
			return
		end

		local minimumQuality = MEM.Settings.event["loot-toast-quality"] or MEM.LOOT_TOAST_QUALITY_DEFAULT

		ProcessLootToast(itemLink, minimumQuality, delay, MEM.LOOT_TOAST_ITEM_LOAD_RETRY_COUNT)
	else
		ScheduleScreenshot("LootToastEventHandler", delay + MEM.CAPTURE_DELAY_OFFSET, typeIdentifier, itemLink, quantity)
		Utils:PrintDebugAdvanced("Event 'SHOW_LOOT_TOAST' completed.")
	end
end

function MementoFrame:ACHIEVEMENT_EARNED(_, achievementID, alreadyEarned)
	Utils:PrintDebugAdvanced(
		"Event 'ACHIEVEMENT_EARNED' fired. Payload: achievementID=%s, alreadyEarned=%s",
		achievementID, alreadyEarned
	)

	local isGuildAchievement = select(12, GetAchievementInfo(achievementID))
	Utils:PrintDebugAdvanced("GetAchievementInfo() returned: isGuildAchievement=%s", isGuildAchievement)

	if AWL.GAME_TYPE_FOREVER and (isGuildAchievement or alreadyEarned) then
		local reason = isGuildAchievement and "Guild achievements are not supported on this client."
			or "Previously earned achievements are excluded on this client."
		Utils:PrintDebugAdvanced("%s No screenshot requested.", reason)
		Utils:PrintDebugAdvanced("Event 'ACHIEVEMENT_EARNED' completed.")
		return
	end

	if not isGuildAchievement then
		if MEM.Settings.event["achievement-personal-active"] then
			ScheduleScreenshot(
				"AchievementPersonalEventHandler",
				MEM.Settings.event["achievement-personal-delay"] + MEM.CAPTURE_DELAY_OFFSET,
				achievementID,
				alreadyEarned
			)
		else
			Utils:PrintDebugAdvanced("Personal achievement screenshots are disabled. No screenshot requested.")
		end
	else
		if MEM.Settings.event["achievement-guild-active"] then
			ScheduleScreenshot("AchievementGuildEventHandler", MEM.Settings.event["achievement-guild-delay"] + MEM.CAPTURE_DELAY_OFFSET, achievementID)
		else
			Utils:PrintDebugAdvanced("Guild achievement screenshots are disabled. No screenshot requested.")
		end
	end

	Utils:PrintDebugAdvanced("Event 'ACHIEVEMENT_EARNED' completed.")
end

function MementoFrame:CRITERIA_EARNED(_, achievementID, description, achievementAlreadyEarnedOnAccount)
	Utils:PrintDebugAdvanced(
		"Event 'CRITERIA_EARNED' fired. Payload: achievementID=%s, description=%s, achievementAlreadyEarnedOnAccount=%s",
		achievementID,
		description,
		achievementAlreadyEarnedOnAccount
	)

	if not AWL.GAME_TYPE_RETAIL then
		Utils:PrintDebugAdvanced("Achievement criteria screenshots are not supported on this client.")
		Utils:PrintDebugAdvanced("Event 'CRITERIA_EARNED' completed.")
		return
	end

	if MEM.Settings.event["achievement-criteria-active"] then
		ScheduleScreenshot("CriteriaEventHandler", MEM.Settings.event["achievement-criteria-delay"] + MEM.CAPTURE_DELAY_OFFSET, achievementID, description)
	else
		Utils:PrintDebugAdvanced("Achievement criteria screenshots are disabled. No screenshot requested.")
	end

	Utils:PrintDebugAdvanced("Event 'CRITERIA_EARNED' completed.")
end

function MementoFrame:CHALLENGE_MODE_COMPLETED(_)
	Utils:PrintDebugAdvanced("Event 'CHALLENGE_MODE_COMPLETED' fired. No payload.")

	if MEM.Settings.event["mythic-active"] then
		ScheduleScreenshot("MythicEventHandler", MEM.Settings.event["mythic-delay"] + MEM.CAPTURE_DELAY_OFFSET)
	else
		Utils:PrintDebugAdvanced("Mythic dungeon screenshots are disabled. No screenshot requested.")
	end

	Utils:PrintDebugAdvanced("Event 'CHALLENGE_MODE_COMPLETED' completed.")
end

function MementoFrame:PERKS_ACTIVITY_COMPLETED(_, perksActivityID)
	Utils:PrintDebugAdvanced(
		"Event 'PERKS_ACTIVITY_COMPLETED' fired. Payload: perksActivityID=%s",
		perksActivityID
	)

	if MEM.Settings.event["perks-activity-active"] then
		ScheduleScreenshot("PerksActivityEventHandler", MEM.Settings.event["perks-activity-delay"] + MEM.CAPTURE_DELAY_OFFSET)
	else
		Utils:PrintDebugAdvanced("Traveler's Log screenshots are disabled. No screenshot requested.")
	end

	Utils:PrintDebugAdvanced("Event 'PERKS_ACTIVITY_COMPLETED' completed.")
end

function MementoFrame:PVP_MATCH_COMPLETE(_, winner, duration)
	Utils:PrintDebugAdvanced(
		"Event 'PVP_MATCH_COMPLETE' fired. Payload: winner=%s, duration=%s",
		winner, duration
	)

	local isArena = C_PvP.IsArena()
	local isBattleground = C_PvP.IsBattleground()
	local isSoloRBG = C_PvP.IsSoloRBG()
	local isInBrawl = AWL.GAME_TYPE_RETAIL and C_PvP.IsInBrawl()
	Utils:PrintDebugAdvanced(
		"PvP API results: isArena=%s, isBattleground=%s, isSoloRBG=%s, isInBrawl=%s",
		isArena, isBattleground, isSoloRBG, isInBrawl
	)

	if isArena then
		if AWL.GAME_TYPE_RETAIL and MEM.Settings.event["pvp-arena-active"] then
			ScheduleScreenshot("PvPArenaEventHandler", MEM.Settings.event["pvp-arena-delay"] + MEM.CAPTURE_DELAY_OFFSET)
		elseif not AWL.GAME_TYPE_RETAIL then
			Utils:PrintDebugAdvanced("Arena screenshots are not supported on this client. No screenshot requested.")
		else
			Utils:PrintDebugAdvanced("Arena screenshots are disabled. No screenshot requested.")
		end
	elseif isInBrawl then
		if MEM.Settings.event["pvp-brawl-active"] then
			if MEM.Settings.event["pvp-brawl-victory-only"] then
				if IsPlayerWinner(winner) then
					ScheduleScreenshot("PvPBrawlEventHandler", MEM.Settings.event["pvp-brawl-delay"] + MEM.CAPTURE_DELAY_OFFSET)
				else
					Utils:PrintDebugAdvanced("The player was not identified as the winner of the brawl. No screenshot requested.")
				end
			else
				ScheduleScreenshot("PvPBrawlEventHandler", MEM.Settings.event["pvp-brawl-delay"] + MEM.CAPTURE_DELAY_OFFSET)
			end
		else
			Utils:PrintDebugAdvanced("Brawl screenshots are disabled. No screenshot requested.")
		end
	elseif isBattleground or isSoloRBG then
		if MEM.Settings.event["pvp-battleground-active"] then
			if MEM.Settings.event["pvp-battleground-victory-only"] then
				if IsPlayerWinner(winner) then
					ScheduleScreenshot("PvPBattlegroundEventHandler", MEM.Settings.event["pvp-battleground-delay"] + MEM.CAPTURE_DELAY_OFFSET)
				else
					Utils:PrintDebugAdvanced("The player was not identified as the winner of the battleground. No screenshot requested.")
				end
			else
				ScheduleScreenshot("PvPBattlegroundEventHandler", MEM.Settings.event["pvp-battleground-delay"] + MEM.CAPTURE_DELAY_OFFSET)
			end
		else
			Utils:PrintDebugAdvanced("Battleground screenshots are disabled. No screenshot requested.")
		end
	else
		Utils:PrintDebugAdvanced("Unknown PvP match type. No screenshot requested.")
	end

	Utils:PrintDebugAdvanced("Event 'PVP_MATCH_COMPLETE' completed.")
end

function MementoFrame:NEW_PET_ADDED(_, battlePetGUID)
	Utils:PrintDebugAdvanced(
		"Event 'NEW_PET_ADDED' fired. Payload: battlePetGUID=%s",
		battlePetGUID
	)

	if MEM.Settings.event["collection-pet-active"] then
		ScheduleScreenshot("NewPetEventHandler", MEM.Settings.event["collection-pet-delay"] + MEM.CAPTURE_DELAY_OFFSET)
	else
		Utils:PrintDebugAdvanced("Pet collection screenshots are disabled. No screenshot requested.")
	end

	Utils:PrintDebugAdvanced("Event 'NEW_PET_ADDED' completed.")
end

function MementoFrame:NEW_MOUNT_ADDED(_, mountID)
	Utils:PrintDebugAdvanced(
		"Event 'NEW_MOUNT_ADDED' fired. Payload: mountID=%s",
		mountID
	)

	if MEM.Settings.event["collection-mount-active"] then
		ScheduleScreenshot("NewMountEventHandler", MEM.Settings.event["collection-mount-delay"] + MEM.CAPTURE_DELAY_OFFSET)
	else
		Utils:PrintDebugAdvanced("Mount collection screenshots are disabled. No screenshot requested.")
	end

	Utils:PrintDebugAdvanced("Event 'NEW_MOUNT_ADDED' completed.")
end

function MementoFrame:NEW_TOY_ADDED(_, itemID)
	Utils:PrintDebugAdvanced(
		"Event 'NEW_TOY_ADDED' fired. Payload: itemID=%s",
		itemID
	)

	if MEM.Settings.event["collection-toy-active"] then
		ScheduleScreenshot("NewToyEventHandler", MEM.Settings.event["collection-toy-delay"] + MEM.CAPTURE_DELAY_OFFSET)
	else
		Utils:PrintDebugAdvanced("Toy collection screenshots are disabled. No screenshot requested.")
	end

	Utils:PrintDebugAdvanced("Event 'NEW_TOY_ADDED' completed.")
end

function MementoFrame:NEW_HOUSING_ITEM_ACQUIRED(_, itemType, itemName, icon)
	Utils:PrintDebugAdvanced(
		"Event 'NEW_HOUSING_ITEM_ACQUIRED' fired. Payload: itemType=%s, itemName=%s, icon=%s",
		itemType, itemName, icon
	)

	if MEM.Settings.event["collection-housing-active"] then
		ScheduleScreenshot("NewHousingItemEventHandler", MEM.Settings.event["collection-housing-delay"] + MEM.CAPTURE_DELAY_OFFSET)
	else
		Utils:PrintDebugAdvanced("Housing collection screenshots are disabled. No screenshot requested.")
	end

	Utils:PrintDebugAdvanced("Event 'NEW_HOUSING_ITEM_ACQUIRED' completed.")
end

function MementoFrame:PLAYER_ENTERING_WORLD(_, isInitialLogin, isReloadingUi)
	Utils:PrintDebugAdvanced(
		"Event 'PLAYER_ENTERING_WORLD' fired. Payload: isInitialLogin=%s, isReloadingUi=%s",
		isInitialLogin, isReloadingUi
	)

	Reputation:Initialize()

	if MEM.Settings.event["login-active"] and isInitialLogin then
		ScheduleScreenshot("LoginEventHandler", MEM.Settings.event["login-delay"] + MEM.CAPTURE_DELAY_OFFSET)
	elseif not MEM.Settings.event["login-active"] then
		Utils:PrintDebugAdvanced("Login screenshots are disabled. No screenshot requested.")
	else
		Utils:PrintDebugAdvanced("This world entry is not the initial login. No screenshot requested.")
	end

	Utils:PrintDebugAdvanced("Event 'PLAYER_ENTERING_WORLD' completed.")
end

function MementoFrame:ZONE_CHANGED_NEW_AREA()
	Utils:PrintDebugAdvanced("Event 'ZONE_CHANGED_NEW_AREA' fired. No payload.")

	local kind, id, name = GetCurrentArea()
	Utils:PrintDebugAdvanced("Area detected: type=%s, id=%s, name=%s", kind, id, name)

	if not kind or not id then
		Utils:PrintDebugAdvanced("Unknown area. No screenshot requested.")
		Utils:PrintDebugAdvanced("Event 'ZONE_CHANGED_NEW_AREA' completed.")
		return
	end

	local settings = MEM.Settings.event
	if not settings["zone-active"] then
		Utils:PrintDebugAdvanced("New area screenshots are disabled. No screenshot requested.")
	elseif not settings[ZoneSettingKeys[kind]] then
		Utils:PrintDebugAdvanced("Area type '%s' is not selected. No screenshot requested.", kind)
	else
		local visits = kind == "zone" and MEM.Data.zone.zone or MEM.Data.zone.instance
		if visits[id] then
			Utils:PrintDebugAdvanced("Area already visited. No screenshot requested.")
		else
			ScheduleScreenshot("ZoneEventHandler", settings["zone-delay"] + MEM.CAPTURE_DELAY_OFFSET, name)
			visits[id] = true
		end
	end

	Utils:PrintDebugAdvanced("Event 'ZONE_CHANGED_NEW_AREA' completed.")
end

function MementoFrame:PLAYER_DEAD(_)
	Utils:PrintDebugAdvanced("Event 'PLAYER_DEAD' fired. No payload.")

	if MEM.Settings.event["death-active"] then
		local inInstance = IsInInstance()
		Utils:PrintDebugAdvanced("IsInInstance() returned: inInstance=%s", inInstance)

		if MEM.Settings.event["death-instance"] == 0 then
			ScheduleScreenshot("DeathEventHandler", MEM.Settings.event["death-delay"] + MEM.CAPTURE_DELAY_OFFSET)
		elseif inInstance and MEM.Settings.event["death-instance"] == 1 then
			ScheduleScreenshot("DeathEventHandler", MEM.Settings.event["death-delay"] + MEM.CAPTURE_DELAY_OFFSET)
		elseif not inInstance and MEM.Settings.event["death-instance"] == 2 then
			ScheduleScreenshot("DeathEventHandler", MEM.Settings.event["death-delay"] + MEM.CAPTURE_DELAY_OFFSET)
		else
			Utils:PrintDebugAdvanced("Player died in the wrong area. No screenshot requested.")
		end
	else
		Utils:PrintDebugAdvanced("Death screenshots are disabled. No screenshot requested.")
	end

	Utils:PrintDebugAdvanced("Event 'PLAYER_DEAD' completed.")
end

function MementoFrame:PLAYER_LEVEL_UP(_, level)
	Utils:PrintDebugAdvanced(
		"Event 'PLAYER_LEVEL_UP' fired. Payload: level=%s",
		level
	)

	TimePlayed()

	local timePlayedOnPreviousLevel = MEM.State.timePlayedThisLevel
	MEM.State.timePlayedThisLevel = 0

	if MEM.Settings.event["level-up-active"] then
		Capture:ScheduleTimer("LevelUpEventHandler", MEM.Settings.event["level-up-delay"] + MEM.CAPTURE_DELAY_OFFSET, level, timePlayedOnPreviousLevel)
	else
		Utils:PrintDebugAdvanced("Level-up screenshots are disabled. No screenshot requested.")
	end

	Utils:PrintDebugAdvanced("Event 'PLAYER_LEVEL_UP' completed.")
end

function MementoFrame:MAJOR_FACTION_RENOWN_LEVEL_CHANGED(_, majorFactionID, newRenownLevel, oldRenownLevel)
	Utils:PrintDebugAdvanced(
		"Event 'MAJOR_FACTION_RENOWN_LEVEL_CHANGED' fired. Payload: majorFactionID=%s, newRenownLevel=%s, oldRenownLevel=%s",
		majorFactionID, newRenownLevel, oldRenownLevel
	)

	ScheduleReputationScreenshot(Reputation:GetRenownIncrease(majorFactionID, newRenownLevel, oldRenownLevel))

	Utils:PrintDebugAdvanced("Event 'MAJOR_FACTION_RENOWN_LEVEL_CHANGED' completed.")
end

function MementoFrame:FACTION_STANDING_CHANGED(_, factionID, updatedStanding)
	Utils:PrintDebugAdvanced(
		"Event 'FACTION_STANDING_CHANGED' fired. Payload: factionID=%s, updatedStanding=%s",
		factionID, updatedStanding
	)

	if not Reputation:IsInitialized() then
		Utils:PrintDebugAdvanced("Reputation tracking is not initialized. No screenshot requested.")
		Utils:PrintDebugAdvanced("Event 'FACTION_STANDING_CHANGED' completed.")
		return
	end

	C_Timer.After(0, function()
		ScheduleReputationScreenshot(Reputation:GetFactionIncrease(factionID))
		Utils:PrintDebugAdvanced("Event 'FACTION_STANDING_CHANGED' completed.")
	end)
end

function MementoFrame:BOSS_KILL(_, encounterID, encounterName)
	Utils:PrintDebugAdvanced(
		"Event 'BOSS_KILL' fired. Payload: encounterID=%s, encounterName=%s",
		encounterID, encounterName
	)

	local inInstance = IsInInstance()
	Utils:PrintDebugAdvanced("IsInInstance() returned: inInstance=%s", inInstance)

	if inInstance then
		Utils:PrintDebugAdvanced("Boss killed inside an instance instead of the open world. No screenshot requested.")
		Utils:PrintDebugAdvanced("Event 'BOSS_KILL' completed.")
		return
	end

	if MEM.Settings.event["encounter-victory-world-active"] then
		local worldBossKills = MEM.Data.bossKill["W"]

		if MEM.Settings.event["encounter-victory-world-first"] and worldBossKills and worldBossKills[encounterID] then
			Utils:PrintDebugAdvanced("World boss already killed. No screenshot requested.")
		else
			ScheduleScreenshot("EncounterVictoryEventHandler", MEM.Settings.event["encounter-victory-world-delay"] + MEM.CAPTURE_DELAY_OFFSET,
				encounterName, L["options.event.pve.world"], "W", encounterID)
		end
	else
		Utils:PrintDebugAdvanced("World boss screenshots are disabled. No screenshot requested.")
	end

	Utils:PrintDebugAdvanced("Event 'BOSS_KILL' completed.")
end

function MementoFrame:ENCOUNTER_END(_, encounterID, encounterName, difficultyID, groupSize, success)
	Utils:PrintDebugAdvanced(
		"Event 'ENCOUNTER_END' fired. Payload: encounterID=%s, encounterName=%s, difficultyID=%s, groupSize=%s, success=%s",
		encounterID, encounterName, difficultyID, groupSize, success
	)

	local inInstance = IsInInstance()
	Utils:PrintDebugAdvanced("IsInInstance() returned: inInstance=%s", inInstance)

	if not inInstance then
		Utils:PrintDebugAdvanced("Encounter ended outside an instance. No screenshot requested.")
		Utils:PrintDebugAdvanced("Event 'ENCOUNTER_END' completed.")
		return
	end

	local difficultyName, groupType = GetDifficultyInfo(difficultyID)
	local difficulty = "D" .. tostring(difficultyID)
	Utils:PrintDebugAdvanced(
		"GetDifficultyInfo() returned: difficultyName=%s, groupType=%s",
		difficultyName, groupType
	)
	if groupType == "party" or groupType == "raid" or (groupType == "scenario" and AWL.GAME_TYPE_RETAIL) then
		if success == 1 then
			local isActive = (groupType == "party" and MEM.Settings.event["encounter-victory-party-active"])
				or (groupType == "raid" and MEM.Settings.event["encounter-victory-raid-active"])
				or (groupType == "scenario" and MEM.Settings.event["encounter-victory-scenario-active"])

			local delay = (groupType == "party" and MEM.Settings.event["encounter-victory-party-delay"])
				or (groupType == "raid" and MEM.Settings.event["encounter-victory-raid-delay"])
				or (groupType == "scenario" and MEM.Settings.event["encounter-victory-scenario-delay"])

			local firstOnly = (groupType == "party" and MEM.Settings.event["encounter-victory-party-first"])
				or (groupType == "raid" and MEM.Settings.event["encounter-victory-raid-first"])
				or (groupType == "scenario" and MEM.Settings.event["encounter-victory-scenario-first"])

			if isActive then
				if not MEM.Data.bossKill[difficulty] then
					MEM.Data.bossKill[difficulty] = {}
				end

				if MEM.Data.bossKill[difficulty][encounterID] and firstOnly then
					Utils:PrintDebugAdvanced("Encounter already killed. No screenshot requested.")
				else
					ScheduleScreenshot("EncounterVictoryEventHandler", delay + MEM.CAPTURE_DELAY_OFFSET, encounterName, difficultyName, difficulty, encounterID)
				end
			else
				Utils:PrintDebugAdvanced("Victory screenshots for this instance type are disabled. No screenshot requested.")
			end
		else
			local isActive = (groupType == "party" and MEM.Settings.event["encounter-wipe-party-active"])
				or (groupType == "raid" and MEM.Settings.event["encounter-wipe-raid-active"])
				or (groupType == "scenario" and MEM.Settings.event["encounter-wipe-scenario-active"])

			local delay = (groupType == "party" and MEM.Settings.event["encounter-wipe-party-delay"])
				or (groupType == "raid" and MEM.Settings.event["encounter-wipe-raid-delay"])
				or (groupType == "scenario" and MEM.Settings.event["encounter-wipe-scenario-delay"])

			if isActive then
				ScheduleScreenshot("EncounterWipeEventHandler", delay + MEM.CAPTURE_DELAY_OFFSET, encounterName, difficultyName)
			else
				Utils:PrintDebugAdvanced("Wipe screenshots for this instance type are disabled. No screenshot requested.")
			end
		end
	else
		Utils:PrintDebugAdvanced(
			"Unsupported groupType '%s' for this client. No screenshot requested.",
			groupType
		)
	end

	Utils:PrintDebugAdvanced("Event 'ENCOUNTER_END' completed.")
end

function MementoFrame:DUEL_FINISHED(_)
	Utils:PrintDebugAdvanced("Event 'DUEL_FINISHED' fired. No payload.")

	if MEM.Settings.event["pvp-duel-active"] then
		ScheduleScreenshot("PvPDuelEventHandler", MEM.Settings.event["pvp-duel-delay"] + MEM.CAPTURE_DELAY_OFFSET)
	else
		Utils:PrintDebugAdvanced("Duel screenshots are disabled. No screenshot requested.")
	end

	Utils:PrintDebugAdvanced("Event 'DUEL_FINISHED' completed.")
end

function MementoFrame:NEW_RECIPE_LEARNED(_, recipeID, recipeLevel, baseRecipeID)
	Utils:PrintDebugAdvanced(
		"Event 'NEW_RECIPE_LEARNED' fired. Payload: recipeID=%s, recipeLevel=%s, baseRecipeID=%s",
		recipeID, recipeLevel, baseRecipeID
	)

	if MEM.Settings.event["collection-recipe-active"] then
		ScheduleScreenshot("NewRecipeEventHandler", MEM.Settings.event["collection-recipe-delay"] + MEM.CAPTURE_DELAY_OFFSET)
	else
		Utils:PrintDebugAdvanced("Recipe collection screenshots are disabled. No screenshot requested.")
	end

	Utils:PrintDebugAdvanced("Event 'NEW_RECIPE_LEARNED' completed.")
end

--------------------------
--- Event Registration ---
--------------------------

MementoFrame:RegisterEvent("ADDON_LOADED")
MementoFrame:RegisterEvent("TIME_PLAYED_MSG")

if AWL.GAME_TYPE_MISTS then
	MementoFrame:RegisterEvent("ACHIEVEMENT_EARNED")
	MementoFrame:RegisterEvent("NEW_PET_ADDED")
	MementoFrame:RegisterEvent("NEW_MOUNT_ADDED")
	MementoFrame:RegisterEvent("NEW_TOY_ADDED")
elseif AWL.GAME_TYPE_FOREVER then
	MementoFrame:RegisterEvent("ACHIEVEMENT_EARNED")
	MementoFrame:RegisterEvent("MAJOR_FACTION_RENOWN_LEVEL_CHANGED")
	MementoFrame:RegisterEvent("PVP_MATCH_COMPLETE")
	MementoFrame:RegisterEvent("ENCOUNTER_END")
	MementoFrame:RegisterEvent("NEW_PET_ADDED")
elseif AWL.GAME_TYPE_RETAIL then
	MementoFrame:RegisterEvent("ACHIEVEMENT_EARNED")
	MementoFrame:RegisterEvent("BOSS_KILL")
	MementoFrame:RegisterEvent("CRITERIA_EARNED")
	MementoFrame:RegisterEvent("CHALLENGE_MODE_COMPLETED")
	MementoFrame:RegisterEvent("PERKS_ACTIVITY_COMPLETED")
	MementoFrame:RegisterEvent("MAJOR_FACTION_RENOWN_LEVEL_CHANGED")
	MementoFrame:RegisterEvent("PVP_MATCH_COMPLETE")
	MementoFrame:RegisterEvent("ENCOUNTER_END")
	MementoFrame:RegisterEvent("NEW_PET_ADDED")
	MementoFrame:RegisterEvent("NEW_MOUNT_ADDED")
	MementoFrame:RegisterEvent("NEW_TOY_ADDED")
	MementoFrame:RegisterEvent("NEW_HOUSING_ITEM_ACQUIRED")
	MementoFrame:RegisterEvent("SHOW_LOOT_TOAST")
end

MementoFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
MementoFrame:RegisterEvent("ZONE_CHANGED_NEW_AREA")
MementoFrame:RegisterEvent("PLAYER_DEAD")
MementoFrame:RegisterEvent("PLAYER_LEVEL_UP")
MementoFrame:RegisterEvent("FACTION_STANDING_CHANGED")
MementoFrame:RegisterEvent("DUEL_FINISHED")
MementoFrame:RegisterEvent("NEW_RECIPE_LEARNED")

MementoFrame:SetScript("OnEvent", MementoFrame.OnEvent)

SLASH_Memento1, SLASH_Memento2 = '/mem', '/memento'
SlashCmdList["Memento"] = SlashCommand
