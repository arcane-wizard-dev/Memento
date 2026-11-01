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

local ZoneData = MEM.ZONE_DATA

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
	Utils:PrintDebug(string.format(
		"GetInstanceInfo() returned: name=%s, instanceType=%s, instanceID=%s",
		tostring(name), tostring(instanceType), tostring(instanceID)
	))

	if not instanceType or instanceType == "" then return nil end

	if instanceType ~= "none" then
		if not ZoneData.instanceTypes[instanceType] then return nil end
		if not instanceID or instanceID <= 0 or not name or name == "" then return nil end

		return "instance", instanceID, name
	end

	local mapID = C_Map.GetBestMapForUnit("player")
	Utils:PrintDebug(string.format("C_Map.GetBestMapForUnit('player') returned: mapID=%s", tostring(mapID)))
	if not mapID or mapID <= 0 then return nil end

	local info = MapUtil.GetMapParentInfo(mapID, Enum.UIMapType.Zone)
	Utils:PrintDebug(string.format(
		"MapUtil.GetMapParentInfo() returned: mapID=%s, name=%s",
		tostring(info and info.mapID), tostring(info and info.name)
	))
	if not info or not info.mapID or info.mapID <= 0 or not info.name or info.name == "" then return nil end

	return "zone", info.mapID, info.name
end

local function ScheduleReputationScreenshot(factionName, rankName, reason)
	if not factionName then
		Utils:PrintDebug((reason or "No reputation rank increase detected.") .. " No screenshot requested.")
	elseif not MEM.Settings.event["reputation-active"] then
		Utils:PrintDebug("Reputation screenshots are disabled. No screenshot requested.")
	else
		ScheduleScreenshot("ReputationEventHandler", MEM.Settings.event["reputation-delay"] + MEM.CAPTURE_DELAY_OFFSET, factionName, rankName)
	end
end

local function ProcessLootToast(itemLink, minimumQuality, delay, retriesRemaining)
	local itemQuality = C_Item.GetItemQualityByID(itemLink)
	Utils:PrintDebug(string.format(
		"C_Item.GetItemQualityByID() returned: itemLink=%s, itemQuality=%s, minimumQuality=%s",
		tostring(itemLink), tostring(itemQuality), tostring(minimumQuality)
	))

	if itemQuality == nil then
		if retriesRemaining > 0 then
			Utils:PrintDebug("Item quality is unavailable. Waiting for item data.")
			C_Item.RequestLoadItemDataByID(itemLink)

			C_Timer.After(MEM.LOOT_TOAST_ITEM_LOAD_RETRY_DELAY, function()
				ProcessLootToast(itemLink, minimumQuality, delay, retriesRemaining - 1)
			end)
		else
			Utils:PrintDebug(string.format(
				"Item quality for '%s' could not be loaded. No screenshot requested.",
				tostring(itemLink)
			))
			Utils:PrintDebug("Event 'SHOW_LOOT_TOAST' completed.")
		end

		return
	end

	if itemQuality < minimumQuality then
		Utils:PrintDebug(string.format(
			"Item quality %s is below the configured minimum quality %s. No screenshot requested.",
			tostring(itemQuality), tostring(minimumQuality)
		))
		Utils:PrintDebug("Event 'SHOW_LOOT_TOAST' completed.")
		return
	end

	ScheduleScreenshot("LootToastEventHandler", delay + MEM.CAPTURE_DELAY_OFFSET, MEM.LOOT_TOAST_TYPE.ITEM, itemLink, nil)
	Utils:PrintDebug("Event 'SHOW_LOOT_TOAST' completed.")
end

local function CheckInterval()
	Utils:PrintDebug("Timer triggered.")

	minutesPassed = minutesPassed + 1

	if MEM.Settings.event["interval-active"] and minutesPassed >= MEM.Settings.event["interval-timer"] then
		ScheduleScreenshot("IntervalEventHandler", MEM.CAPTURE_DELAY_OFFSET)

		minutesPassed = 0
	elseif not MEM.Settings.event["interval-active"] then
		Utils:PrintDebug("Interval screenshots are disabled. No screenshot requested.")
	else
		Utils:PrintDebug("The screenshot interval has not elapsed. No screenshot requested.")
	end

	Utils:PrintDebug("Timer completed.")
end

local function IsPlayerWinner(winner)
	local playerFaction = UnitFactionGroup("player")
	Utils:PrintDebug(string.format("UnitFactionGroup('player') returned: faction=%s, winner=%s", tostring(playerFaction), tostring(winner)))

	return (playerFaction == "Alliance" and winner == 1) or (playerFaction == "Horde" and winner == 0)
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

	Utils:RequestTimePlayed()
	Addon:OpenSettingsOnLoading()

	sessionStartTime = GetTime()
	C_Timer.NewTicker(MEM.INTERVAL_CHECK_SECONDS, CheckInterval)

	isInitialized = true

	Utils:PrintDebug(string.format(
		"InitializeDatabase: key=%s, createdProfile=%s, createdProfileKey=%s, cleanedOptions=%s, activeProfile=%s",
		tostring(dbInit.characterGUID),
		tostring(dbInit.createdProfile),
		tostring(dbInit.createdProfileKey),
		tostring(dbInit.cleanedOptions),
		tostring(dbInit.activeProfile)
	))
	Utils:PrintDebug("Addon fully loaded.")
end

function MementoFrame:TIME_PLAYED_MSG(_, totalTimePlayed, timePlayedThisLevel)
	Utils:PrintDebug(string.format(
		"Event 'TIME_PLAYED_MSG' fired. Payload: totalTimePlayed=%s, timePlayedThisLevel=%s",
		tostring(totalTimePlayed), tostring(timePlayedThisLevel)
	))

	MEM.State.totalTimePlayed = totalTimePlayed
	MEM.State.timePlayedThisLevel = timePlayedThisLevel
	MEM.State.timePlayedInitialized = true

	sessionStartTime = GetTime()

	Utils:PrintDebug("Event 'TIME_PLAYED_MSG' completed.")
end

function MementoFrame:SHOW_LOOT_TOAST(_, typeIdentifier, itemLink, quantity, specID, sex, personalLootToast, toastMethod, lessAwesome, upgraded, corrupted)
	Utils:PrintDebug(string.format(
		"Event 'SHOW_LOOT_TOAST' fired. Payload: typeIdentifier=%s, itemLink=%s, quantity=%s, specID=%s, sex=%s, personalLootToast=%s, toastMethod=%s, lessAwesome=%s, upgraded=%s, corrupted=%s",
		tostring(typeIdentifier),
		tostring(itemLink),
		tostring(quantity),
		tostring(specID),
		tostring(sex),
		tostring(personalLootToast),
		tostring(toastMethod),
		tostring(lessAwesome),
		tostring(upgraded),
		tostring(corrupted)
	))

	if not MEM.Settings.event["loot-toast-active"] then
		Utils:PrintDebug("Loot toast screenshots are disabled. No screenshot requested.")
		Utils:PrintDebug("Event 'SHOW_LOOT_TOAST' completed.")
		return
	end

	local settingKey = MEM.LOOT_TOAST_SETTING_BY_TYPE[typeIdentifier]

	if not settingKey then
		Utils:PrintDebug(string.format(
			"Event 'SHOW_LOOT_TOAST' has unsupported typeIdentifier '%s'. No screenshot requested.",
			tostring(typeIdentifier)
		))
		Utils:PrintDebug("Event 'SHOW_LOOT_TOAST' completed.")
		return
	end

	if not MEM.Settings.event[settingKey] then
		Utils:PrintDebug(string.format(
			"Event 'SHOW_LOOT_TOAST' type '%s' is disabled. No screenshot requested.",
			tostring(typeIdentifier)
		))
		Utils:PrintDebug("Event 'SHOW_LOOT_TOAST' completed.")
		return
	end

	local delay = MEM.Settings.event["loot-toast-delay"] or MEM.OPTIONS_DEFAULTS.event["loot-toast-delay"]

	if typeIdentifier == MEM.LOOT_TOAST_TYPE.ITEM then
		if not itemLink then
			Utils:PrintDebug("Event 'SHOW_LOOT_TOAST' did not contain an item link. No screenshot requested.")
			Utils:PrintDebug("Event 'SHOW_LOOT_TOAST' completed.")
			return
		end

		local minimumQuality = MEM.Settings.event["loot-toast-quality"] or MEM.LOOT_TOAST_QUALITY_DEFAULT

		ProcessLootToast(itemLink, minimumQuality, delay, MEM.LOOT_TOAST_ITEM_LOAD_RETRY_COUNT)
	else
		ScheduleScreenshot("LootToastEventHandler", delay + MEM.CAPTURE_DELAY_OFFSET, typeIdentifier, itemLink, quantity)
		Utils:PrintDebug("Event 'SHOW_LOOT_TOAST' completed.")
	end
end

function MementoFrame:ACHIEVEMENT_EARNED(_, achievementID, alreadyEarned)
	Utils:PrintDebug(string.format(
		"Event 'ACHIEVEMENT_EARNED' fired. Payload: achievementID=%s, alreadyEarned=%s",
		tostring(achievementID), tostring(alreadyEarned)
	))

	local isGuildAchievement = select(12, GetAchievementInfo(achievementID))
	Utils:PrintDebug(string.format("GetAchievementInfo() returned: isGuildAchievement=%s", tostring(isGuildAchievement)))

	if AWL.GAME_TYPE_FOREVER and (isGuildAchievement or alreadyEarned) then
		local reason = isGuildAchievement and "Guild achievements are not supported on this client."
			or "Previously earned achievements are excluded on this client."
		Utils:PrintDebug(reason .. " No screenshot requested.")
		Utils:PrintDebug("Event 'ACHIEVEMENT_EARNED' completed.")
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
			Utils:PrintDebug("Personal achievement screenshots are disabled. No screenshot requested.")
		end
	else
		if MEM.Settings.event["achievement-guild-active"] then
			ScheduleScreenshot("AchievementGuildEventHandler", MEM.Settings.event["achievement-guild-delay"] + MEM.CAPTURE_DELAY_OFFSET, achievementID)
		else
			Utils:PrintDebug("Guild achievement screenshots are disabled. No screenshot requested.")
		end
	end

	Utils:PrintDebug("Event 'ACHIEVEMENT_EARNED' completed.")
end

function MementoFrame:CRITERIA_EARNED(_, achievementID, description, achievementAlreadyEarnedOnAccount)
	Utils:PrintDebug(string.format(
		"Event 'CRITERIA_EARNED' fired. Payload: achievementID=%s, description=%s, achievementAlreadyEarnedOnAccount=%s",
		tostring(achievementID),
		tostring(description),
		tostring(achievementAlreadyEarnedOnAccount)
	))

	if not AWL.GAME_TYPE_RETAIL then
		Utils:PrintDebug("Achievement criteria screenshots are not supported on this client.")
		Utils:PrintDebug("Event 'CRITERIA_EARNED' completed.")
		return
	end

	if MEM.Settings.event["achievement-criteria-active"] then
		ScheduleScreenshot("CriteriaEventHandler", MEM.Settings.event["achievement-criteria-delay"] + MEM.CAPTURE_DELAY_OFFSET, achievementID, description)
	else
		Utils:PrintDebug("Achievement criteria screenshots are disabled. No screenshot requested.")
	end

	Utils:PrintDebug("Event 'CRITERIA_EARNED' completed.")
end

function MementoFrame:CRITERIA_COMPLETE(_, criteriaID)
	Utils:PrintDebug(string.format(
		"Event 'CRITERIA_COMPLETE' fired. Payload: criteriaID=%s",
		tostring(criteriaID)
	))

	Utils:PrintDebug("Event 'CRITERIA_COMPLETE' completed.")
end

function MementoFrame:CRITERIA_UPDATE(_)
	Utils:PrintDebug("Event 'CRITERIA_UPDATE' fired. No payload.")

	Utils:PrintDebug("Event 'CRITERIA_UPDATE' completed.")
end

function MementoFrame:CHALLENGE_MODE_COMPLETED(_)
	Utils:PrintDebug("Event 'CHALLENGE_MODE_COMPLETED' fired. No payload.")

	if MEM.Settings.event["mythic-active"] then
		ScheduleScreenshot("MythicEventHandler", MEM.Settings.event["mythic-delay"] + MEM.CAPTURE_DELAY_OFFSET)
	else
		Utils:PrintDebug("Mythic dungeon screenshots are disabled. No screenshot requested.")
	end

	Utils:PrintDebug("Event 'CHALLENGE_MODE_COMPLETED' completed.")
end

function MementoFrame:PERKS_ACTIVITY_COMPLETED(_, perksActivityID)
	Utils:PrintDebug(string.format(
		"Event 'PERKS_ACTIVITY_COMPLETED' fired. Payload: perksActivityID=%s",
		tostring(perksActivityID)
	))

	if MEM.Settings.event["perks-activity-active"] then
		ScheduleScreenshot("PerksActivityEventHandler", MEM.Settings.event["perks-activity-delay"] + MEM.CAPTURE_DELAY_OFFSET)
	else
		Utils:PrintDebug("Traveler's Log screenshots are disabled. No screenshot requested.")
	end

	Utils:PrintDebug("Event 'PERKS_ACTIVITY_COMPLETED' completed.")
end

function MementoFrame:PVP_MATCH_COMPLETE(_, winner, duration)
	Utils:PrintDebug(string.format(
		"Event 'PVP_MATCH_COMPLETE' fired. Payload: winner=%s, duration=%s",
		tostring(winner), tostring(duration)
	))

	local isArena = C_PvP.IsArena()
	local isBattleground = C_PvP.IsBattleground()
	local isSoloRBG = C_PvP.IsSoloRBG()
	local isInBrawl = AWL.GAME_TYPE_RETAIL and C_PvP.IsInBrawl()
	Utils:PrintDebug(string.format(
		"PvP API results: isArena=%s, isBattleground=%s, isSoloRBG=%s, isInBrawl=%s",
		tostring(isArena), tostring(isBattleground), tostring(isSoloRBG), tostring(isInBrawl)
	))

	if isArena then
		if AWL.GAME_TYPE_RETAIL and MEM.Settings.event["pvp-arena-active"] then
			ScheduleScreenshot("PvPArenaEventHandler", MEM.Settings.event["pvp-arena-delay"] + MEM.CAPTURE_DELAY_OFFSET)
		elseif not AWL.GAME_TYPE_RETAIL then
			Utils:PrintDebug("Arena screenshots are not supported on this client. No screenshot requested.")
		else
			Utils:PrintDebug("Arena screenshots are disabled. No screenshot requested.")
		end
	elseif isInBrawl then
		if MEM.Settings.event["pvp-brawl-active"] then
			if MEM.Settings.event["pvp-brawl-victory-only"] then
				if IsPlayerWinner(winner) then
					ScheduleScreenshot("PvPBrawlEventHandler", MEM.Settings.event["pvp-brawl-delay"] + MEM.CAPTURE_DELAY_OFFSET)
				else
					Utils:PrintDebug("The player was not identified as the winner of the brawl. No screenshot requested.")
				end
			else
				ScheduleScreenshot("PvPBrawlEventHandler", MEM.Settings.event["pvp-brawl-delay"] + MEM.CAPTURE_DELAY_OFFSET)
			end
		else
			Utils:PrintDebug("Brawl screenshots are disabled. No screenshot requested.")
		end
	elseif isBattleground or isSoloRBG then
		if MEM.Settings.event["pvp-battleground-active"] then
			if MEM.Settings.event["pvp-battleground-victory-only"] then
				if IsPlayerWinner(winner) then
					ScheduleScreenshot("PvPBattlegroundEventHandler", MEM.Settings.event["pvp-battleground-delay"] + MEM.CAPTURE_DELAY_OFFSET)
				else
					Utils:PrintDebug("The player was not identified as the winner of the battleground. No screenshot requested.")
				end
			else
				ScheduleScreenshot("PvPBattlegroundEventHandler", MEM.Settings.event["pvp-battleground-delay"] + MEM.CAPTURE_DELAY_OFFSET)
			end
		else
			Utils:PrintDebug("Battleground screenshots are disabled. No screenshot requested.")
		end
	else
		Utils:PrintDebug("Unknown PvP match type. No screenshot requested.")
	end

	Utils:PrintDebug("Event 'PVP_MATCH_COMPLETE' completed.")
end

function MementoFrame:NEW_PET_ADDED(_, battlePetGUID)
	Utils:PrintDebug(string.format(
		"Event 'NEW_PET_ADDED' fired. Payload: battlePetGUID=%s",
		tostring(battlePetGUID)
	))

	if MEM.Settings.event["collection-pet-active"] then
		ScheduleScreenshot("NewPetEventHandler", MEM.Settings.event["collection-pet-delay"] + MEM.CAPTURE_DELAY_OFFSET)
	else
		Utils:PrintDebug("Pet collection screenshots are disabled. No screenshot requested.")
	end

	Utils:PrintDebug("Event 'NEW_PET_ADDED' completed.")
end

function MementoFrame:NEW_MOUNT_ADDED(_, mountID)
	Utils:PrintDebug(string.format(
		"Event 'NEW_MOUNT_ADDED' fired. Payload: mountID=%s",
		tostring(mountID)
	))

	if MEM.Settings.event["collection-mount-active"] then
		ScheduleScreenshot("NewMountEventHandler", MEM.Settings.event["collection-mount-delay"] + MEM.CAPTURE_DELAY_OFFSET)
	else
		Utils:PrintDebug("Mount collection screenshots are disabled. No screenshot requested.")
	end

	Utils:PrintDebug("Event 'NEW_MOUNT_ADDED' completed.")
end

function MementoFrame:NEW_TOY_ADDED(_, itemID)
	Utils:PrintDebug(string.format(
		"Event 'NEW_TOY_ADDED' fired. Payload: itemID=%s",
		tostring(itemID)
	))

	if MEM.Settings.event["collection-toy-active"] then
		ScheduleScreenshot("NewToyEventHandler", MEM.Settings.event["collection-toy-delay"] + MEM.CAPTURE_DELAY_OFFSET)
	else
		Utils:PrintDebug("Toy collection screenshots are disabled. No screenshot requested.")
	end

	Utils:PrintDebug("Event 'NEW_TOY_ADDED' completed.")
end

function MementoFrame:NEW_HOUSING_ITEM_ACQUIRED(_, itemType, itemName, icon)
	Utils:PrintDebug(string.format(
		"Event 'NEW_HOUSING_ITEM_ACQUIRED' fired. Payload: itemType=%s, itemName=%s, icon=%s",
		tostring(itemType), tostring(itemName), tostring(icon)
	))

	if MEM.Settings.event["collection-housing-active"] then
		ScheduleScreenshot("NewHousingItemEventHandler", MEM.Settings.event["collection-housing-delay"] + MEM.CAPTURE_DELAY_OFFSET)
	else
		Utils:PrintDebug("Housing collection screenshots are disabled. No screenshot requested.")
	end

	Utils:PrintDebug("Event 'NEW_HOUSING_ITEM_ACQUIRED' completed.")
end

function MementoFrame:PLAYER_ENTERING_WORLD(_, isInitialLogin, isReloadingUi)
	Utils:PrintDebug(string.format(
		"Event 'PLAYER_ENTERING_WORLD' fired. Payload: isInitialLogin=%s, isReloadingUi=%s",
		tostring(isInitialLogin), tostring(isReloadingUi)
	))

	Reputation:Initialize()

	if MEM.Settings.event["login-active"] and isInitialLogin then
		ScheduleScreenshot("LoginEventHandler", MEM.Settings.event["login-delay"] + MEM.CAPTURE_DELAY_OFFSET)
	elseif not MEM.Settings.event["login-active"] then
		Utils:PrintDebug("Login screenshots are disabled. No screenshot requested.")
	else
		Utils:PrintDebug("This world entry is not the initial login. No screenshot requested.")
	end

	Utils:PrintDebug("Event 'PLAYER_ENTERING_WORLD' completed.")
end

function MementoFrame:ZONE_CHANGED_NEW_AREA()
	Utils:PrintDebug("Event 'ZONE_CHANGED_NEW_AREA' fired. No payload.")

	local kind, id, name = GetCurrentArea()
	Utils:PrintDebug(string.format("Area detected: type=%s, id=%s, name=%s", tostring(kind), tostring(id), tostring(name)))

	if not kind or not id then
		Utils:PrintDebug("Unknown area. No screenshot requested.")
		Utils:PrintDebug("Event 'ZONE_CHANGED_NEW_AREA' completed.")
		return
	end

	local settings = MEM.Settings.event
	if not settings["zone-active"] then
		Utils:PrintDebug("New area screenshots are disabled. No screenshot requested.")
	elseif MEM.Data.zone[kind][id] then
		Utils:PrintDebug("Area already visited. No screenshot requested.")
	elseif settings["zone-type"] ~= "both" and settings["zone-type"] ~= kind then
		Utils:PrintDebug(string.format(
			"Area type '%s' does not match the selected type '%s'. No screenshot requested.",
			tostring(kind), tostring(settings["zone-type"])
		))
	else
		ScheduleScreenshot("ZoneEventHandler", settings["zone-delay"] + MEM.CAPTURE_DELAY_OFFSET, name)
		MEM.Data.zone[kind][id] = true
	end

	Utils:PrintDebug("Event 'ZONE_CHANGED_NEW_AREA' completed.")
end

function MementoFrame:PLAYER_DEAD(_)
	Utils:PrintDebug("Event 'PLAYER_DEAD' fired. No payload.")

	if MEM.Settings.event["death-active"] then
		local inInstance = IsInInstance()
		Utils:PrintDebug(string.format("IsInInstance() returned: inInstance=%s", tostring(inInstance)))

		if MEM.Settings.event["death-instance"] == 0 then
			ScheduleScreenshot("DeathEventHandler", MEM.Settings.event["death-delay"] + MEM.CAPTURE_DELAY_OFFSET)
		elseif inInstance and MEM.Settings.event["death-instance"] == 1 then
			ScheduleScreenshot("DeathEventHandler", MEM.Settings.event["death-delay"] + MEM.CAPTURE_DELAY_OFFSET)
		elseif not inInstance and MEM.Settings.event["death-instance"] == 2 then
			ScheduleScreenshot("DeathEventHandler", MEM.Settings.event["death-delay"] + MEM.CAPTURE_DELAY_OFFSET)
		else
			Utils:PrintDebug("Player died in the wrong area. No screenshot requested.")
		end
	else
		Utils:PrintDebug("Death screenshots are disabled. No screenshot requested.")
	end

	Utils:PrintDebug("Event 'PLAYER_DEAD' completed.")
end

function MementoFrame:PLAYER_LEVEL_UP(_, level)
	Utils:PrintDebug(string.format(
		"Event 'PLAYER_LEVEL_UP' fired. Payload: level=%s",
		tostring(level)
	))

	TimePlayed()

	local timePlayedOnPreviousLevel = MEM.State.timePlayedThisLevel
	MEM.State.timePlayedThisLevel = 0

	if MEM.Settings.event["level-up-active"] then
		Capture:ScheduleTimer("LevelUpEventHandler", MEM.Settings.event["level-up-delay"] + MEM.CAPTURE_DELAY_OFFSET, level, timePlayedOnPreviousLevel)
	else
		Utils:PrintDebug("Level-up screenshots are disabled. No screenshot requested.")
	end

	Utils:PrintDebug("Event 'PLAYER_LEVEL_UP' completed.")
end

function MementoFrame:MAJOR_FACTION_RENOWN_LEVEL_CHANGED(_, majorFactionID, newRenownLevel, oldRenownLevel)
	Utils:PrintDebug(string.format(
		"Event 'MAJOR_FACTION_RENOWN_LEVEL_CHANGED' fired. Payload: majorFactionID=%s, newRenownLevel=%s, oldRenownLevel=%s",
		tostring(majorFactionID), tostring(newRenownLevel), tostring(oldRenownLevel)
	))

	ScheduleReputationScreenshot(Reputation:GetRenownIncrease(majorFactionID, newRenownLevel, oldRenownLevel))

	Utils:PrintDebug("Event 'MAJOR_FACTION_RENOWN_LEVEL_CHANGED' completed.")
end

function MementoFrame:FACTION_STANDING_CHANGED(_, factionID, updatedStanding)
	Utils:PrintDebug(string.format(
		"Event 'FACTION_STANDING_CHANGED' fired. Payload: factionID=%s, updatedStanding=%s",
		tostring(factionID), tostring(updatedStanding)
	))

	if not Reputation:IsInitialized() then
		Utils:PrintDebug("Reputation tracking is not initialized. No screenshot requested.")
		Utils:PrintDebug("Event 'FACTION_STANDING_CHANGED' completed.")
		return
	end

	C_Timer.After(0, function()
		ScheduleReputationScreenshot(Reputation:GetFactionIncrease(factionID))
		Utils:PrintDebug("Event 'FACTION_STANDING_CHANGED' completed.")
	end)
end

function MementoFrame:BOSS_KILL(_, encounterID, encounterName)
	Utils:PrintDebug(string.format(
		"Event 'BOSS_KILL' fired. Payload: encounterID=%s, encounterName=%s",
		tostring(encounterID), tostring(encounterName)
	))

	local inInstance = IsInInstance()
	Utils:PrintDebug(string.format("IsInInstance() returned: inInstance=%s", tostring(inInstance)))

	if inInstance then
		Utils:PrintDebug("Boss killed inside an instance instead of the open world. No screenshot requested.")
		Utils:PrintDebug("Event 'BOSS_KILL' completed.")
		return
	end

	if MEM.Settings.event["encounter-victory-world-active"] then
		local worldBossKills = MEM.Data.bossKill["W"]

		if MEM.Settings.event["encounter-victory-world-first"] and worldBossKills and worldBossKills[encounterID] then
			Utils:PrintDebug("World boss already killed. No screenshot requested.")
		else
			ScheduleScreenshot("EncounterVictoryEventHandler", MEM.Settings.event["encounter-victory-world-delay"] + MEM.CAPTURE_DELAY_OFFSET,
				encounterName, L["options.event.pve.world"], "W", encounterID)
		end
	else
		Utils:PrintDebug("World boss screenshots are disabled. No screenshot requested.")
	end

	Utils:PrintDebug("Event 'BOSS_KILL' completed.")
end

function MementoFrame:ENCOUNTER_END(_, encounterID, encounterName, difficultyID, groupSize, success)
	Utils:PrintDebug(string.format(
		"Event 'ENCOUNTER_END' fired. Payload: encounterID=%s, encounterName=%s, difficultyID=%s, groupSize=%s, success=%s",
		tostring(encounterID), tostring(encounterName), tostring(difficultyID), tostring(groupSize), tostring(success)
	))

	local inInstance = IsInInstance()
	Utils:PrintDebug(string.format("IsInInstance() returned: inInstance=%s", tostring(inInstance)))

	if not inInstance then
		Utils:PrintDebug("Encounter ended outside an instance. No screenshot requested.")
		Utils:PrintDebug("Event 'ENCOUNTER_END' completed.")
		return
	end

	local difficultyName, groupType = GetDifficultyInfo(difficultyID)
	local difficulty = "D" .. tostring(difficultyID)
	Utils:PrintDebug(string.format(
		"GetDifficultyInfo() returned: difficultyName=%s, groupType=%s",
		tostring(difficultyName), tostring(groupType)
	))
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
					Utils:PrintDebug("Encounter already killed. No screenshot requested.")
				else
					ScheduleScreenshot("EncounterVictoryEventHandler", delay + MEM.CAPTURE_DELAY_OFFSET, encounterName, difficultyName, difficulty, encounterID)
				end
			else
				Utils:PrintDebug("Victory screenshots for this instance type are disabled. No screenshot requested.")
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
				Utils:PrintDebug("Wipe screenshots for this instance type are disabled. No screenshot requested.")
			end
		end
	else
		Utils:PrintDebug(string.format(
			"Unsupported groupType '%s' for this client. No screenshot requested.",
			tostring(groupType)
		))
	end

	Utils:PrintDebug("Event 'ENCOUNTER_END' completed.")
end

function MementoFrame:DUEL_FINISHED(_)
	Utils:PrintDebug("Event 'DUEL_FINISHED' fired. No payload.")

	if MEM.Settings.event["pvp-duel-active"] then
		ScheduleScreenshot("PvPDuelEventHandler", MEM.Settings.event["pvp-duel-delay"] + MEM.CAPTURE_DELAY_OFFSET)
	else
		Utils:PrintDebug("Duel screenshots are disabled. No screenshot requested.")
	end

	Utils:PrintDebug("Event 'DUEL_FINISHED' completed.")
end

function MementoFrame:NEW_RECIPE_LEARNED(_, recipeID, recipeLevel, baseRecipeID)
	Utils:PrintDebug(string.format(
		"Event 'NEW_RECIPE_LEARNED' fired. Payload: recipeID=%s, recipeLevel=%s, baseRecipeID=%s",
		tostring(recipeID), tostring(recipeLevel), tostring(baseRecipeID)
	))

	if MEM.Settings.event["collection-recipe-active"] then
		ScheduleScreenshot("NewRecipeEventHandler", MEM.Settings.event["collection-recipe-delay"] + MEM.CAPTURE_DELAY_OFFSET)
	else
		Utils:PrintDebug("Recipe collection screenshots are disabled. No screenshot requested.")
	end

	Utils:PrintDebug("Event 'NEW_RECIPE_LEARNED' completed.")
end

--------------------------
--- Event Registration ---
--------------------------

MementoFrame:RegisterEvent("ADDON_LOADED")
MementoFrame:RegisterEvent("TIME_PLAYED_MSG")

if AWL.GAME_TYPE_CLASSIC then
elseif AWL.GAME_TYPE_TBC then
elseif AWL.GAME_TYPE_MISTS then
	MementoFrame:RegisterEvent("ACHIEVEMENT_EARNED")
	MementoFrame:RegisterEvent("NEW_PET_ADDED")
	MementoFrame:RegisterEvent("NEW_MOUNT_ADDED")
	MementoFrame:RegisterEvent("NEW_TOY_ADDED")
elseif AWL.GAME_TYPE_FOREVER then
	MementoFrame:RegisterEvent("ACHIEVEMENT_EARNED")
	MementoFrame:RegisterEvent("CRITERIA_EARNED")
	MementoFrame:RegisterEvent("CRITERIA_COMPLETE")
	MementoFrame:RegisterEvent("CRITERIA_UPDATE")
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
