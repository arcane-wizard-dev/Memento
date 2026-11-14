local addonName, MEM = ...

if MEM.State and MEM.State.libraryIncompatible then return end

local AWL = ArcaneWizardLibrary
local Reputation = MEM.Modules.Reputation
local Utils = MEM.Modules.Utils
local L = MEM.Localization

MEM.State.reputation = {
	initialized = false,
	ranks = {},
	renown = {}
}

local state = MEM.State.reputation

local function GetLegacyFactionData(getInfo, identifier)
	local name, _, reaction, _, _, _, _, _, isHeader, isCollapsed, isHeaderWithRep, _, _, factionID = getInfo(identifier)

	if not name then return end

	return {
		name = name,
		reaction = reaction,
		isHeader = isHeader,
		isCollapsed = isCollapsed,
		isHeaderWithRep = isHeaderWithRep,
		factionID = factionID
	}
end

local function GetFactionDataByIndex(index)
	if C_Reputation and C_Reputation.GetFactionDataByIndex then
		return C_Reputation.GetFactionDataByIndex(index)
	end

	return GetLegacyFactionData(GetFactionInfo, index)
end

local function GetFactionDataByID(factionID)
	if C_Reputation and C_Reputation.GetFactionDataByID then
		return C_Reputation.GetFactionDataByID(factionID)
	end

	return GetLegacyFactionData(GetFactionInfoByID, factionID)
end

local function GetRank(factionID, data)
	if not data or (data.isHeader and not data.isHeaderWithRep) then return end

	if C_Reputation and C_Reputation.IsMajorFaction and C_Reputation.IsMajorFaction(factionID) then return end

	if C_GossipInfo and C_GossipInfo.GetFriendshipReputation then
		local friendship = C_GossipInfo.GetFriendshipReputation(factionID)

		if friendship and friendship.friendshipFactionID > 0 then
			return {
				kind = "friendship",
				level = friendship.reactionThreshold,
				label = friendship.reaction
			}
		end
	end

	if not data.reaction or data.reaction <= 0 then return end

	return {
		kind = "reputation",
		level = data.reaction,
		label = GetText("FACTION_STANDING_LABEL" .. data.reaction, UnitSex("player"), nil)
	}
end

function Reputation:IsInitialized()
	return state.initialized
end

function Reputation:Initialize()
	if state.initialized then return end

	if AWL.GAME_TYPE_RETAIL or AWL.GAME_TYPE_FOREVER then
		for _, factionID in ipairs(C_MajorFactions.GetMajorFactionIDs()) do
			local data = C_MajorFactions.GetMajorFactionData(factionID)

			if data and data.isUnlocked then
				state.renown[factionID] = data.renownLevel
			end
		end
	end

	local getNumFactions = C_Reputation and C_Reputation.GetNumFactions or GetNumFactions
	local expandHeader = C_Reputation and C_Reputation.ExpandFactionHeader or ExpandFactionHeader
	local collapseHeader = C_Reputation and C_Reputation.CollapseFactionHeader or CollapseFactionHeader
	local sortType = C_Reputation and C_Reputation.GetReputationSortType and C_Reputation.GetReputationSortType()
	local showLegacy = C_Reputation and C_Reputation.AreLegacyReputationsShown and C_Reputation.AreLegacyReputationsShown()
	local collapsedHeaders = {}

	if sortType and sortType ~= Enum.ReputationSortType.None then
		C_Reputation.SetReputationSortType(Enum.ReputationSortType.None)
	end

	if showLegacy == false then
		C_Reputation.SetLegacyReputationsShown(true)
	end

	local index = 1

	while index <= getNumFactions() do
		local data = GetFactionDataByIndex(index)

		if data then
			if data.isHeader and data.isCollapsed then
				collapsedHeaders[#collapsedHeaders + 1] = index
				expandHeader(index)
			end

			if data.factionID and data.factionID > 0 then
				state.ranks[data.factionID] = GetRank(data.factionID, data)
			end
		end

		index = index + 1
	end

	for headerIndex = #collapsedHeaders, 1, -1 do
		collapseHeader(collapsedHeaders[headerIndex])
	end

	if showLegacy == false then
		C_Reputation.SetLegacyReputationsShown(false)
	end

	if sortType and sortType ~= Enum.ReputationSortType.None then
		C_Reputation.SetReputationSortType(sortType)
	end

	state.initialized = true
end

function Reputation:GetFactionIncrease(factionID)
	if not state.initialized then
		return nil, nil, "Reputation tracking is not initialized."
	end

	if not factionID then
		return nil, nil, "No faction ID was supplied."
	end

	local data = GetFactionDataByID(factionID)
	local rank = GetRank(factionID, data)
	Utils:PrintDebugAdvanced(
		"Faction lookup returned: factionID=%s, name=%s, reaction=%s, rankKind=%s, rankLevel=%s",
		factionID, data and data.name, data and data.reaction,
		rank and rank.kind, rank and rank.level
	)

	if not data then
		return nil, nil, "Faction data is unavailable."
	end

	if not rank then
		return nil, nil, "No supported reputation rank is available for this faction."
	end

	local previous = state.ranks[factionID]
	state.ranks[factionID] = rank
	Utils:PrintDebugAdvanced(
		"Reputation comparison: previousKind=%s, previousLevel=%s, currentKind=%s, currentLevel=%s",
		previous and previous.kind, previous and previous.level, rank.kind, rank.level
	)

	if previous and previous.kind == rank.kind and rank.level > previous.level then
		return data.name, rank.label
	end

	if not previous or previous.kind ~= rank.kind then
		return nil, nil, "No matching previous reputation rank is available."
	end

	return nil, nil, "The reputation rank did not increase."
end

function Reputation:GetRenownIncrease(factionID, newLevel, oldLevel)
	if not state.initialized then
		return nil, nil, "Reputation tracking is not initialized."
	end

	if not factionID or not newLevel or not oldLevel then
		return nil, nil, "Renown event data is incomplete."
	end

	if not C_Reputation.IsMajorFaction(factionID) then
		return nil, nil, "The faction is not a major faction."
	end

	local data = C_MajorFactions.GetMajorFactionData(factionID)
	Utils:PrintDebugAdvanced(
		"C_MajorFactions.GetMajorFactionData() returned: name=%s, renownLevel=%s, isUnlocked=%s",
		data and data.name, data and data.renownLevel, data and data.isUnlocked
	)

	if not data or not data.name or data.name == "" then
		return nil, nil, "Major faction data is incomplete."
	end

	if not data.isUnlocked then
		return nil, nil, "The major faction is not unlocked."
	end

	local previous = state.renown[factionID]
	state.renown[factionID] = newLevel
	Utils:PrintDebugAdvanced(
		"Renown comparison: factionID=%s, previousLevel=%s, oldLevel=%s, newLevel=%s",
		factionID, previous, oldLevel, newLevel
	)

	if newLevel <= oldLevel then
		return nil, nil, "The renown level did not increase."
	end

	if previous and newLevel <= previous then
		return nil, nil, "This renown level was already processed."
	end

	return data.name, L["chat.event.reputation.renown"]:format(newLevel)
end
