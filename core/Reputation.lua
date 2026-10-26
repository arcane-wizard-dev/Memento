local _, MEM = ...

if MEM.State and MEM.State.libraryIncompatible then return end

local AWL = ArcaneWizardLibrary
local Reputation = MEM.Modules.Reputation
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

	---@diagnostic disable-next-line: undefined-global
	return GetLegacyFactionData(GetFactionInfo, index)
end

local function GetFactionDataByID(factionID)
	if C_Reputation and C_Reputation.GetFactionDataByID then
		return C_Reputation.GetFactionDataByID(factionID)
	end

	---@diagnostic disable-next-line: undefined-global
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

	---@diagnostic disable-next-line: undefined-global
	local getNumFactions = C_Reputation and C_Reputation.GetNumFactions or GetNumFactions
	---@diagnostic disable-next-line: undefined-global
	local expandHeader = C_Reputation and C_Reputation.ExpandFactionHeader or ExpandFactionHeader
	---@diagnostic disable-next-line: undefined-global
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
	if not state.initialized or not factionID then return end

	local data = GetFactionDataByID(factionID)
	local rank = GetRank(factionID, data)

	if not data or not rank then return end

	local previous = state.ranks[factionID]
	state.ranks[factionID] = rank

	if previous and previous.kind == rank.kind and rank.level > previous.level then
		return data.name, rank.label
	end
end

function Reputation:GetRenownIncrease(factionID, newLevel, oldLevel)
	if not state.initialized or not factionID or not newLevel or not oldLevel then return end

	local previous = state.renown[factionID]
	state.renown[factionID] = newLevel

	if newLevel <= oldLevel or (previous and newLevel <= previous) then return end

	local data = C_MajorFactions.GetMajorFactionData(factionID)

	return data and data.name or UNKNOWN, L["chat.event.reputation.renown"]:format(newLevel)
end

