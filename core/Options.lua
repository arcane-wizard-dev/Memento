local addonName, MEM = ...

if MEM.State and MEM.State.libraryIncompatible then return end

-- Library
local AWL = ArcaneWizardLibrary
local Addon = AWL:GetAddon(addonName)

-- Localization
local L = MEM.Localization

-- Current module
local Options = MEM.Modules.Options

-- Module imports
local TimestampConfig = MEM.UIConfig.Timestamp
local Capture = MEM.Modules.Capture
local Utils = MEM.Modules.Utils

-- Variables
local minimapButtonProxy = setmetatable({}, {
	__index = function(_, key)
		if key == "hide" then
			return not MEM.Settings.general["minimap-button"]["hide"]
		end
	end,
	__newindex = function(_, key, value)
		if key ~= "hide" then
			return
		end

		MEM.Settings.general["minimap-button"]["hide"] = not value

		if value then
			Utils.minimapButton:Show(addonName)
		else
			Utils.minimapButton:Hide(addonName)
		end
	end,
})

local screenshotSoundOptions = {}

for _, soundData in ipairs(MEM.SCREENSHOT_SOUNDS) do
	screenshotSoundOptions[#screenshotSoundOptions + 1] = {
		value = soundData.key,
		label = L[soundData.labelKey]
	}
end

local timestampFormatOptions = {}

local screenshotSettingsProxy = setmetatable({}, {
	__index = function(_, key)
		local value = C_CVar.GetCVar(key)

		if key == "screenshotQuality" then
			return tonumber(value)
		end

		if value == "jpg" then
			return "jpeg"
		end

		return value
	end,
	__newindex = function(_, key, value)
		C_CVar.SetCVar(key, tostring(value))
	end
})

for _, formatData in ipairs(TimestampConfig.formats) do
	timestampFormatOptions[#timestampFormatOptions + 1] = {
		value = formatData.key,
		label = L[formatData.labelKey]
	}
end

-----------------------
--- Local Functions ---
-----------------------

local function GetVal(setting) return setting:GetValue() end

local function FormatSeconds(value) return value .. " " .. L["general.seconds-short"] end

local function FormatMinutes(value) return value .. " " .. L["general.minutes-short"] end

local function TimePlayedOptionChanged(_, value)
	if value then
		Utils:RequestTimePlayed()
	end
end

local function CreateMultiSelectOptions(definitions, variables, defaults, selectionKey)
	local optionKeys = {}
	local options = {}

	for position, option in ipairs(definitions) do
		optionKeys[position] = option.variableName
		options[position] = {
			value = position,
			label = L[option.localizationKey .. ".name"],
			tooltip = L[option.localizationKey .. ".tooltip"]
		}
	end

	local proxy = AWL.Settings:CreateMultiSelectProxy(variables, selectionKey, optionKeys)
	local defaultProxy = AWL.Settings:CreateMultiSelectProxy(defaults, selectionKey, optionKeys)

	return proxy, defaultProxy[selectionKey], options
end

------------------------
--- Module Functions ---
------------------------

function Options:Initialize()
	local category, layout = AWL.Settings:CreateCategory(addonName)

	layout:AddInitializer(CreateSettingsListSectionHeaderInitializer(L["options.general"]))

	-- Notification
	local notificationVariables, notificationDefault, notificationOptions = CreateMultiSelectOptions(
		MEM.NOTIFICATION_OPTIONS, MEM.Settings.general, MEM.OPTIONS_DEFAULTS.general, "notification-details"
	)
	local hadTimePlayed = MEM.Settings.general["notification-time-played"]
	local hadLevelTimePlayed = MEM.Settings.general["notification-level-time-played"]

	AWL.Settings:AddCheckboxDropdownCombo(category, layout, {
		variableTable			= notificationVariables,
		checkboxSettingKey		= addonName .. "_notification",
		checkboxVariableName	= "notification",
		checkboxName			= L["options.general.notification.name"],
		checkboxTooltip			= L["options.general.notification.tooltip"],
		checkboxDefault			= MEM.OPTIONS_DEFAULTS.general.notification,
		dropdownSettingKey		= addonName .. "_notification-details",
		dropdownVariableName	= "notification-details",
		dropdownName			= L["options.general.notification.details.name"],
		dropdownTooltip			= L["options.general.notification.details.tooltip"],
		dropdownDefault			= notificationDefault,
		dropdownOptions			= notificationOptions,
		multiSelect				= true,
		dropdownOnClick			= function()
			local hasTimePlayed = MEM.Settings.general["notification-time-played"]
			local hasLevelTimePlayed = MEM.Settings.general["notification-level-time-played"]

			if (hasTimePlayed and not hadTimePlayed) or (hasLevelTimePlayed and not hadLevelTimePlayed) then
				Utils:RequestTimePlayed()
			end

			hadTimePlayed = hasTimePlayed
			hadLevelTimePlayed = hasLevelTimePlayed
		end
	})

	-- Timestamp Format
	AWL.Settings:AddDropdown(category, {
		variableTable	= MEM.Settings.general,
		settingKey		= addonName .. "_timestamp-format",
		variableName	= "timestamp-format",
		name			= L["options.general.timestamp-format.name"],
		tooltip			= L["options.general.timestamp-format.tooltip"],
		default			= MEM.OPTIONS_DEFAULTS["general"]["timestamp-format"],
		options			= timestampFormatOptions
	})

	AWL.Settings:AddSeparator(layout)

	if C_CVar and C_CVar.GetCVar("screenshotFormat") and C_CVar.GetCVar("screenshotQuality") then
		-- Screenshot Format
		local initializerFormat = AWL.Settings:AddDropdown(category, {
			variableTable	= screenshotSettingsProxy,
			settingKey		= addonName .. "_screenshot-format",
			variableName	= "screenshotFormat",
			name			= L["options.general.screenshot-format.name"],
			tooltip			= L["options.general.screenshot-format.tooltip"],
			default			= C_CVar.GetCVarDefault("screenshotFormat") or "jpeg",
			options			= MEM.SCREENSHOT_FORMATS
		})

		-- Screenshot Quality
		AWL.Settings:AddSlider(category, {
			variableTable	= screenshotSettingsProxy,
			settingKey		= addonName .. "_screenshot-quality",
			variableName	= "screenshotQuality",
			name			= L["options.general.screenshot-quality.name"],
			tooltip			= L["options.general.screenshot-quality.tooltip"],
			default			= tonumber(C_CVar.GetCVarDefault("screenshotQuality")) or MEM.SCREENSHOT_QUALITY.default,
			minValue		= MEM.SCREENSHOT_QUALITY.minimum,
			maxValue		= MEM.SCREENSHOT_QUALITY.maximum,
			step			= 1,
			formatter		= tostring,
			parentInit		= initializerFormat,
			parentCondition	= function() return screenshotSettingsProxy.screenshotFormat == "jpeg" end
		})
	end

	-- Hide UI
	local initializerHideUI, settingHideUI = AWL.Settings:AddCheckbox(category, {
		variableTable	= MEM.Settings.general,
		settingKey		= addonName .. "_hide-ui",
		variableName	= "hide-ui",
		name			= L["options.general.hide-ui.name"],
		tooltip			= L["options.general.hide-ui.tooltip"],
		default			= MEM.OPTIONS_DEFAULTS["general"]["hide-ui"]
	})

	-- Hide UI: Message Box
	AWL.Settings:AddCheckbox(category, {
		variableTable	= MEM.Settings.general,
		settingKey		= addonName .. "_hide-ui-message",
		variableName	= "hide-ui-message",
		name			= L["options.general.hide-ui.message.name"],
		tooltip			= L["options.general.hide-ui.message.tooltip"],
		default			= MEM.OPTIONS_DEFAULTS["general"]["hide-ui-message"],
		parentInit		= initializerHideUI,
		parentCondition	= function() return GetVal(settingHideUI) end
	})

	-- Screenshot Sound
	AWL.Settings:AddCheckboxDropdownCombo(category, layout, {
		variableTable			= MEM.Settings.general,
		checkboxSettingKey		= addonName .. "_screenshot-sound",
		checkboxVariableName	= "screenshot-sound",
		checkboxName			= L["options.general.screenshot-sound.name"],
		checkboxTooltip			= L["options.general.screenshot-sound.tooltip"],
		checkboxDefault			= MEM.OPTIONS_DEFAULTS.general["screenshot-sound"],
		dropdownSettingKey		= addonName .. "_screenshot-sound-style",
		dropdownVariableName	= "screenshot-sound-style",
		dropdownName			= L["options.general.screenshot-sound-style.name"],
		dropdownTooltip			= L["options.general.screenshot-sound-style.tooltip"],
		dropdownDefault			= MEM.OPTIONS_DEFAULTS.general["screenshot-sound-style"],
		dropdownOptions			= screenshotSoundOptions,
		dropdownOnClick			= function(_, value)
			Capture:PreviewScreenshotSound(value)
		end
	})

	AWL.Settings:AddSeparator(layout)

	-- Minimap Button Visibility
	AWL.Settings:AddCheckbox(category, {
		variableTable	= minimapButtonProxy,
		settingKey		= addonName .. "_hide",
		variableName	= "hide",
		name			= L["options.general.minimap-button.name"],
		tooltip			= L["options.general.minimap-button.tooltip"],
		default			= not MEM.OPTIONS_DEFAULTS.general["minimap-button"].hide
	})

	-- Debug Mode
	AWL.Settings:AddCheckboxDropdownCombo(category, layout, {
		variableTable			= MEM.Settings.general,
		checkboxSettingKey		= addonName .. "_debug-mode",
		checkboxVariableName	= "debug-mode",
		checkboxName			= L["options.general.debug-mode.name"],
		checkboxTooltip			= L["options.general.debug-mode.tooltip"],
		checkboxDefault			= MEM.OPTIONS_DEFAULTS.general["debug-mode"],
		dropdownSettingKey		= addonName .. "_debug-level",
		dropdownVariableName	= "debug-level",
		dropdownName			= L["options.general.debug-mode.level.name"],
		dropdownTooltip			= L["options.general.debug-mode.level.tooltip"],
		dropdownDefault			= MEM.OPTIONS_DEFAULTS.general["debug-level"],
		dropdownOptions			= {
			{value = "basic", label = L["options.general.debug-mode.level.value.basic"]},
			{value = "advanced", label = L["options.general.debug-mode.level.value.advanced"]}
		}
	})

	layout:AddInitializer(CreateSettingsListSectionHeaderInitializer(L["options.event"]))

	local _, isCharacterExpanded = AWL.Settings:AddExpandableHeader(layout, L["options.event.character"])

	-- Login
	AWL.Settings:AddCheckboxSliderCombo(category, layout, {
		variableTable			= MEM.Settings.event,
		checkboxSettingKey		= addonName .. "_login-active",
		checkboxVariableName	= "login-active",
		checkboxName			= L["options.event.character.login"],
		checkboxTooltip			= L["options.event.character.login.tooltip"],
		checkboxDefault			= MEM.OPTIONS_DEFAULTS["event"]["login-active"],

		sliderSettingKey		= addonName .. "_login-delay",
		sliderVariableName		= "login-delay",
		sliderName				= L["options.event.general.delay.name"],
		sliderTooltip			= L["options.event.general.delay.tooltip"]:format(
			L["options.event.character.login"],
			MEM.OPTIONS_DEFAULTS["event"]["login-delay"]
		),
		sliderDefault			= MEM.OPTIONS_DEFAULTS["event"]["login-delay"],
		sliderMin				= 1,
		sliderMax				= 10,
		sliderStep				= 1,
		sliderFormatter			= FormatSeconds,

		shownPredicate			= isCharacterExpanded
	})

	-- Level-Up
	local initializerLevelUp, settingLevelUp = AWL.Settings:AddCheckboxSliderCombo(category, layout, {
		variableTable			= MEM.Settings.event,
		checkboxSettingKey		= addonName .. "_level-up-active",
		checkboxVariableName	= "level-up-active",
		checkboxName			= L["options.event.character.level-up"],
		checkboxTooltip			= L["options.event.character.level-up.tooltip"],
		checkboxDefault			= MEM.OPTIONS_DEFAULTS["event"]["level-up-active"],

		sliderSettingKey		= addonName .. "_level-up-delay",
		sliderVariableName		= "level-up-delay",
		sliderName				= L["options.event.general.delay.name"],
		sliderTooltip			= L["options.event.general.delay.tooltip"]:format(
			L["options.event.character.level-up"],
			MEM.OPTIONS_DEFAULTS["event"]["level-up-delay"]
		),
		sliderDefault			= MEM.OPTIONS_DEFAULTS["event"]["level-up-delay"],
		sliderMin				= 1,
		sliderMax				= 10,
		sliderStep				= 1,
		sliderFormatter			= FormatSeconds,

		shownPredicate			= isCharacterExpanded
	})

	-- Level-Up: Show Time Played
	AWL.Settings:AddCheckbox(category, {
		variableTable	= MEM.Settings.event,
		settingKey		= addonName .. "_level-up-time-played",
		variableName	= "level-up-time-played",
		name			= L["options.event.character.level-up.time-played.name"],
		tooltip			= L["options.event.character.level-up.time-played.tooltip"],
		default			= MEM.OPTIONS_DEFAULTS["event"]["level-up-time-played"],
		parentInit		= initializerLevelUp,
		parentCondition	= function() return GetVal(settingLevelUp) end,
		onClick			= TimePlayedOptionChanged,
		shownPredicate	= isCharacterExpanded
	})

	-- Death
	local initializerDeath, settingDeath = AWL.Settings:AddCheckboxSliderCombo(category, layout, {
		variableTable			= MEM.Settings.event,
		checkboxSettingKey		= addonName .. "_death-active",
		checkboxVariableName	= "death-active",
		checkboxName			= L["options.event.character.death"],
		checkboxTooltip			= L["options.event.character.death.tooltip"],
		checkboxDefault			= MEM.OPTIONS_DEFAULTS["event"]["death-active"],

		sliderSettingKey		= addonName .. "_death-delay",
		sliderVariableName		= "death-delay",
		sliderName				= L["options.event.general.delay.name"],
		sliderTooltip			= L["options.event.general.delay.tooltip"]:format(
			L["options.event.character.death"],
			MEM.OPTIONS_DEFAULTS["event"]["death-delay"]
		),
		sliderDefault			= MEM.OPTIONS_DEFAULTS["event"]["death-delay"],
		sliderMin				= 1,
		sliderMax				= 10,
		sliderStep				= 1,
		sliderFormatter			= FormatSeconds,

		shownPredicate			= isCharacterExpanded
	})

	-- Death: Instance
	AWL.Settings:AddDropdown(category, {
		variableTable	= MEM.Settings.event,
		settingKey		= addonName .. "_death-instance",
		variableName	= "death-instance",
		name			= L["options.event.character.death.instance.name"],
		tooltip			= L["options.event.character.death.instance.tooltip"],
		default			= MEM.OPTIONS_DEFAULTS["event"]["death-instance"],
		options			= {
			{value = 0, label = L["options.event.character.death.instance.option.0"]},
			{value = 1, label = L["options.event.character.death.instance.option.1"]},
			{value = 2, label = L["options.event.character.death.instance.option.2"]}
		},
		parentInit		= initializerDeath,
		parentCondition	= function() return GetVal(settingDeath) end,
		shownPredicate	= isCharacterExpanded
	})

	-- Reputation
	AWL.Settings:AddCheckboxSliderCombo(category, layout, {
		variableTable			= MEM.Settings.event,
		checkboxSettingKey		= addonName .. "_reputation-active",
		checkboxVariableName	= "reputation-active",
		checkboxName			= L["options.event.character.reputation"],
		checkboxTooltip			= L["options.event.character.reputation.tooltip"],
		checkboxDefault			= MEM.OPTIONS_DEFAULTS["event"]["reputation-active"],
		sliderSettingKey		= addonName .. "_reputation-delay",
		sliderVariableName		= "reputation-delay",
		sliderName				= L["options.event.general.delay.name"],
		sliderTooltip			= L["options.event.general.delay.tooltip"]:format(
			L["options.event.character.reputation"],
			MEM.OPTIONS_DEFAULTS["event"]["reputation-delay"]
		),
		sliderDefault			= MEM.OPTIONS_DEFAULTS["event"]["reputation-delay"],
		sliderMin				= 1,
		sliderMax				= 10,
		sliderStep				= 1,
		sliderFormatter			= FormatSeconds,
		shownPredicate			= isCharacterExpanded
	})

	-- New Area
	local initializerZone, settingZone = AWL.Settings:AddCheckboxSliderCombo(category, layout, {
		isNew					= true,
		variableTable			= MEM.Settings.event,
		checkboxSettingKey		= addonName .. "_zone-active",
		checkboxVariableName	= "zone-active",
		checkboxName			= L["options.event.character.zone"],
		checkboxTooltip			= L["options.event.character.zone.tooltip"],
		checkboxDefault			= MEM.OPTIONS_DEFAULTS["event"]["zone-active"],
		sliderSettingKey		= addonName .. "_zone-delay",
		sliderVariableName		= "zone-delay",
		sliderName				= L["options.event.general.delay.name"],
		sliderTooltip			= L["options.event.general.delay.tooltip"]:format(
			L["options.event.character.zone"],
			MEM.OPTIONS_DEFAULTS["event"]["zone-delay"]
		),
		sliderDefault			= MEM.OPTIONS_DEFAULTS["event"]["zone-delay"],
		sliderMin				= 1,
		sliderMax				= 10,
		sliderStep				= 1,
		sliderFormatter			= FormatSeconds,
		shownPredicate			= isCharacterExpanded
	})

	local zoneKeys = {}
	local zoneOptions = {}

	for position, area in ipairs(MEM.ZONE_TYPES) do
		zoneKeys[position] = area.variableName
		zoneOptions[position] = {value = position, label = L["options.event.character.zone.type." .. area.kind]}
	end

	local zoneDefaults = AWL.Settings:CreateMultiSelectProxy(MEM.OPTIONS_DEFAULTS.event, "zone-types", zoneKeys)

	-- Area Types
	AWL.Settings:AddDropdown(category, {
		variableTable	= AWL.Settings:CreateMultiSelectProxy(MEM.Settings.event, "zone-types", zoneKeys),
		settingKey		= addonName .. "_zone-types",
		variableName	= "zone-types",
		name			= L["options.event.character.zone.type.name"],
		tooltip			= L["options.event.character.zone.type.tooltip"],
		default			= zoneDefaults["zone-types"],
		options			= zoneOptions,
		multiSelect		= true,
		parentInit		= initializerZone,
		parentCondition	= function() return GetVal(settingZone) end,
		shownPredicate	= isCharacterExpanded
	})

	if AWL.GAME_TYPE_RETAIL or AWL.GAME_TYPE_FOREVER or AWL.GAME_TYPE_MISTS then
		local _, isAchievementExpanded = AWL.Settings:AddExpandableHeader(layout, L["options.event.achievement"])

		-- Personal Achievement
		local initializerAchievementPersonal, settingAchievementPersonal = AWL.Settings:AddCheckboxSliderCombo(category, layout, {
			variableTable			= MEM.Settings.event,
			checkboxSettingKey		= addonName .. "_achievement-personal-active",
			checkboxVariableName	= "achievement-personal-active",
			checkboxName			= L["options.event.achievement.personal"],
			checkboxTooltip			= L["options.event.achievement.personal.tooltip"],
			checkboxDefault			= MEM.OPTIONS_DEFAULTS["event"]["achievement-personal-active"],

			sliderSettingKey		= addonName .. "_achievement-personal-delay",
			sliderVariableName		= "achievement-personal-delay",
			sliderName				= L["options.event.general.delay.name"],
			sliderTooltip			= L["options.event.general.delay.tooltip"]:format(
				L["options.event.achievement.personal"],
				MEM.OPTIONS_DEFAULTS["event"]["achievement-personal-delay"]
			),
			sliderDefault			= MEM.OPTIONS_DEFAULTS["event"]["achievement-personal-delay"],
			sliderMin				= 1,
			sliderMax				= 10,
			sliderStep				= 1,
			sliderFormatter			= FormatSeconds,

			shownPredicate			= isAchievementExpanded
		})

		-- Personal Achievement: Exist Check
		if not AWL.GAME_TYPE_FOREVER then
			AWL.Settings:AddCheckbox(category, {
				variableTable	= MEM.Settings.event,
				settingKey		= addonName .. "_achievement-personal-exist",
				variableName	= "achievement-personal-exist",
				name			= L["options.event.achievement.personal.exist.name"],
				tooltip			= L["options.event.achievement.personal.exist.tooltip"],
				default			= MEM.OPTIONS_DEFAULTS["event"]["achievement-personal-exist"],
				parentInit		= initializerAchievementPersonal,
				parentCondition	= function() return GetVal(settingAchievementPersonal) end,
				shownPredicate	= isAchievementExpanded
			})
		end

		-- Criteria Achievement
		if AWL.GAME_TYPE_RETAIL then
			AWL.Settings:AddCheckboxSliderCombo(category, layout, {
				variableTable			= MEM.Settings.event,
				checkboxSettingKey		= addonName .. "_achievement-criteria-active",
				checkboxVariableName	= "achievement-criteria-active",
				checkboxName			= L["options.event.achievement.criteria"],
				checkboxTooltip			= L["options.event.achievement.criteria.tooltip"],
				checkboxDefault			= MEM.OPTIONS_DEFAULTS["event"]["achievement-criteria-active"],

				sliderSettingKey		= addonName .. "_achievement-criteria-delay",
				sliderVariableName		= "achievement-criteria-delay",
				sliderName				= L["options.event.general.delay.name"],
				sliderTooltip			= L["options.event.general.delay.tooltip"]:format(
					L["options.event.achievement.criteria"],
					MEM.OPTIONS_DEFAULTS["event"]["achievement-criteria-delay"]
				),
				sliderDefault			= MEM.OPTIONS_DEFAULTS["event"]["achievement-criteria-delay"],
				sliderMin				= 1,
				sliderMax				= 10,
				sliderStep				= 1,
				sliderFormatter			= FormatSeconds,

				shownPredicate			= isAchievementExpanded
			})
		end

		-- Guild Achievement
		if not AWL.GAME_TYPE_FOREVER then
			AWL.Settings:AddCheckboxSliderCombo(category, layout, {
				variableTable			= MEM.Settings.event,
				checkboxSettingKey		= addonName .. "_achievement-guild-active",
				checkboxVariableName	= "achievement-guild-active",
				checkboxName			= L["options.event.achievement.guild"],
				checkboxTooltip			= L["options.event.achievement.guild.tooltip"],
				checkboxDefault			= MEM.OPTIONS_DEFAULTS["event"]["achievement-guild-active"],

				sliderSettingKey		= addonName .. "_achievement-guild-delay",
				sliderVariableName		= "achievement-guild-delay",
				sliderName				= L["options.event.general.delay.name"],
				sliderTooltip			= L["options.event.general.delay.tooltip"]:format(
					L["options.event.achievement.guild"],
					MEM.OPTIONS_DEFAULTS["event"]["achievement-guild-delay"]
				),
				sliderDefault			= MEM.OPTIONS_DEFAULTS["event"]["achievement-guild-delay"],
				sliderMin				= 1,
				sliderMax				= 10,
				sliderStep				= 1,
				sliderFormatter			= FormatSeconds,

				shownPredicate			= isAchievementExpanded
			})
		end
	end

	if AWL.GAME_TYPE_RETAIL or AWL.GAME_TYPE_FOREVER then
		local _, isPvEExpanded = AWL.Settings:AddExpandableHeader(layout, L["options.event.pve"])

		if AWL.GAME_TYPE_RETAIL then
			local eventWorldVictory = L["options.event.pve.world"] .. " (" .. L["options.event.pve.victory"] .. ")"

			-- World Boss
			local initializerVictoryWorld, settingVictoryWorld = AWL.Settings:AddCheckboxSliderCombo(category, layout, {
				variableTable			= MEM.Settings.event,
				checkboxSettingKey		= addonName .. "_encounter-victory-world-active",
				checkboxVariableName	= "encounter-victory-world-active",
				checkboxName			= eventWorldVictory,
				checkboxTooltip			= L["options.event.pve.world.tooltip"],
				checkboxDefault			= MEM.OPTIONS_DEFAULTS["event"]["encounter-victory-world-active"],

				sliderSettingKey		= addonName .. "_encounter-victory-world-delay",
				sliderVariableName		= "encounter-victory-world-delay",
				sliderName				= L["options.event.general.delay.name"],
				sliderTooltip			= L["options.event.general.delay.tooltip"]:format(
					eventWorldVictory,
					MEM.OPTIONS_DEFAULTS["event"]["encounter-victory-world-delay"]
				),
				sliderDefault			= MEM.OPTIONS_DEFAULTS["event"]["encounter-victory-world-delay"],
				sliderMin				= 1,
				sliderMax				= 10,
				sliderStep				= 1,
				sliderFormatter			= FormatSeconds,

				shownPredicate			= isPvEExpanded
			})

			-- World Boss: Only First Victory
			AWL.Settings:AddCheckbox(category, {
				variableTable	= MEM.Settings.event,
				settingKey		= addonName .. "_encounter-victory-world-first",
				variableName	= "encounter-victory-world-first",
				name			= L["options.event.pve.world.first.name"],
				tooltip			= L["options.event.pve.world.first.tooltip"],
				default			= MEM.OPTIONS_DEFAULTS["event"]["encounter-victory-world-first"],
				parentInit		= initializerVictoryWorld,
				parentCondition	= function() return GetVal(settingVictoryWorld) end,
				shownPredicate	= isPvEExpanded
			})

			AWL.Settings:AddSeparator(layout):AddShownPredicate(isPvEExpanded)
		end

		local eventPartyVictory    = L["options.event.pve.party"] .. " (" .. L["options.event.pve.victory"] .. ")"
		local eventPartyWipe       = L["options.event.pve.party"] .. " (" .. L["options.event.pve.wipe"] .. ")"
		local eventRaidVictory     = L["options.event.pve.raid"] .. " (" .. L["options.event.pve.victory"] .. ")"
		local eventRaidWipe        = L["options.event.pve.raid"] .. " (" .. L["options.event.pve.wipe"] .. ")"
		local eventScenarioVictory = L["options.event.pve.scenario"] .. " (" .. L["options.event.pve.victory"] .. ")"
		local eventScenarioWipe    = L["options.event.pve.scenario"] .. " (" .. L["options.event.pve.wipe"] .. ")"

		-- Dungeon
		local initializerVictoryParty, settingVictoryParty = AWL.Settings:AddCheckboxSliderCombo(category, layout, {
			variableTable			= MEM.Settings.event,
			checkboxSettingKey		= addonName .. "_encounter-victory-party-active",
			checkboxVariableName	= "encounter-victory-party-active",
			checkboxName			= eventPartyVictory,
			checkboxTooltip			= L["options.event.pve.party.victory.tooltip"],
			checkboxDefault			= MEM.OPTIONS_DEFAULTS["event"]["encounter-victory-party-active"],

			sliderSettingKey		= addonName .. "_encounter-victory-party-delay",
			sliderVariableName		= "encounter-victory-party-delay",
			sliderName				= L["options.event.general.delay.name"],
			sliderTooltip			= L["options.event.general.delay.tooltip"]:format(
				eventPartyVictory,
				MEM.OPTIONS_DEFAULTS["event"]["encounter-victory-party-delay"]
			),
			sliderDefault			= MEM.OPTIONS_DEFAULTS["event"]["encounter-victory-party-delay"],
			sliderMin				= 1,
			sliderMax				= 10,
			sliderStep				= 1,
			sliderFormatter			= FormatSeconds,

			shownPredicate			= isPvEExpanded
		})

		-- Dungeon: Only First Victory
		AWL.Settings:AddCheckbox(category, {
			variableTable	= MEM.Settings.event,
			settingKey		= addonName .. "_encounter-victory-party-first",
			variableName	= "encounter-victory-party-first",
			name			= L["options.event.pve.victory.first.name"],
			tooltip			= L["options.event.pve.victory.first.tooltip"],
			default			= MEM.OPTIONS_DEFAULTS["event"]["encounter-victory-party-first"],
			parentInit		= initializerVictoryParty,
			parentCondition	= function() return GetVal(settingVictoryParty) end,
			shownPredicate	= isPvEExpanded
		})

		-- Dungeon: Wipe
		AWL.Settings:AddCheckboxSliderCombo(category, layout, {
			variableTable			= MEM.Settings.event,
			checkboxSettingKey		= addonName .. "_encounter-wipe-party-active",
			checkboxVariableName	= "encounter-wipe-party-active",
			checkboxName			= eventPartyWipe,
			checkboxTooltip			= L["options.event.pve.party.wipe.tooltip"],
			checkboxDefault			= MEM.OPTIONS_DEFAULTS["event"]["encounter-wipe-party-active"],

			sliderSettingKey		= addonName .. "_encounter-wipe-party-delay",
			sliderVariableName		= "encounter-wipe-party-delay",
			sliderName				= L["options.event.general.delay.name"],
			sliderTooltip			= L["options.event.general.delay.tooltip"]:format(
				eventPartyWipe,
				MEM.OPTIONS_DEFAULTS["event"]["encounter-wipe-party-delay"]
			),
			sliderDefault			= MEM.OPTIONS_DEFAULTS["event"]["encounter-wipe-party-delay"],
			sliderMin				= 1,
			sliderMax				= 10,
			sliderStep				= 1,
			sliderFormatter			= FormatSeconds,

			shownPredicate			= isPvEExpanded
		})

		-- Raid
		local initializerVictoryRaid, settingVictoryRaid = AWL.Settings:AddCheckboxSliderCombo(category, layout, {
			variableTable			= MEM.Settings.event,
			checkboxSettingKey		= addonName .. "_encounter-victory-raid-active",
			checkboxVariableName	= "encounter-victory-raid-active",
			checkboxName			= eventRaidVictory,
			checkboxTooltip			= L["options.event.pve.raid.victory.tooltip"],
			checkboxDefault			= MEM.OPTIONS_DEFAULTS["event"]["encounter-victory-raid-active"],

			sliderSettingKey		= addonName .. "_encounter-victory-raid-delay",
			sliderVariableName		= "encounter-victory-raid-delay",
			sliderName				= L["options.event.general.delay.name"],
			sliderTooltip			= L["options.event.general.delay.tooltip"]:format(
				eventRaidVictory,
				MEM.OPTIONS_DEFAULTS["event"]["encounter-victory-raid-delay"]
			),
			sliderDefault			= MEM.OPTIONS_DEFAULTS["event"]["encounter-victory-raid-delay"],
			sliderMin				= 1,
			sliderMax				= 10,
			sliderStep				= 1,
			sliderFormatter			= FormatSeconds,

			shownPredicate			= isPvEExpanded
		})

		-- Raid: Only First Victory
		AWL.Settings:AddCheckbox(category, {
			variableTable	= MEM.Settings.event,
			settingKey		= addonName .. "_encounter-victory-raid-first",
			variableName	= "encounter-victory-raid-first",
			name			= L["options.event.pve.victory.first.name"],
			tooltip			= L["options.event.pve.victory.first.tooltip"],
			default			= MEM.OPTIONS_DEFAULTS["event"]["encounter-victory-raid-first"],
			parentInit		= initializerVictoryRaid,
			parentCondition	= function() return GetVal(settingVictoryRaid) end,
			shownPredicate	= isPvEExpanded
		})

		-- Raid: Wipe
		AWL.Settings:AddCheckboxSliderCombo(category, layout, {
			variableTable			= MEM.Settings.event,
			checkboxSettingKey		= addonName .. "_encounter-wipe-raid-active",
			checkboxVariableName	= "encounter-wipe-raid-active",
			checkboxName			= eventRaidWipe,
			checkboxTooltip			= L["options.event.pve.raid.wipe.tooltip"],
			checkboxDefault			= MEM.OPTIONS_DEFAULTS["event"]["encounter-wipe-raid-active"],

			sliderSettingKey		= addonName .. "_encounter-wipe-raid-delay",
			sliderVariableName		= "encounter-wipe-raid-delay",
			sliderName				= L["options.event.general.delay.name"],
			sliderTooltip			= L["options.event.general.delay.tooltip"]:format(
				eventRaidWipe,
				MEM.OPTIONS_DEFAULTS["event"]["encounter-wipe-raid-delay"]
			),
			sliderDefault			= MEM.OPTIONS_DEFAULTS["event"]["encounter-wipe-raid-delay"],
			sliderMin				= 1,
			sliderMax				= 10,
			sliderStep				= 1,
			sliderFormatter			= FormatSeconds,

			shownPredicate			= isPvEExpanded
		})

		if AWL.GAME_TYPE_RETAIL then
			-- Scenario
			local initializerVictoryScenario, settingVictoryScenario = AWL.Settings:AddCheckboxSliderCombo(category, layout, {
				variableTable			= MEM.Settings.event,
				checkboxSettingKey		= addonName .. "_encounter-victory-scenario-active",
				checkboxVariableName	= "encounter-victory-scenario-active",
				checkboxName			= eventScenarioVictory,
				checkboxTooltip			= L["options.event.pve.scenario.victory.tooltip"],
				checkboxDefault			= MEM.OPTIONS_DEFAULTS["event"]["encounter-victory-scenario-active"],

				sliderSettingKey		= addonName .. "_encounter-victory-scenario-delay",
				sliderVariableName		= "encounter-victory-scenario-delay",
				sliderName				= L["options.event.general.delay.name"],
				sliderTooltip			= L["options.event.general.delay.tooltip"]:format(
					eventScenarioVictory,
					MEM.OPTIONS_DEFAULTS["event"]["encounter-victory-scenario-delay"]
				),
				sliderDefault			= MEM.OPTIONS_DEFAULTS["event"]["encounter-victory-scenario-delay"],
				sliderMin				= 1,
				sliderMax				= 10,
				sliderStep				= 1,
				sliderFormatter			= FormatSeconds,

				shownPredicate			= isPvEExpanded
			})

			-- Scenario: Only First Victory
			AWL.Settings:AddCheckbox(category, {
				variableTable	= MEM.Settings.event,
				settingKey		= addonName .. "_encounter-victory-scenario-first",
				variableName	= "encounter-victory-scenario-first",
				name			= L["options.event.pve.victory.first.name"],
				tooltip			= L["options.event.pve.victory.first.tooltip"],
				default			= MEM.OPTIONS_DEFAULTS["event"]["encounter-victory-scenario-first"],
				parentInit		= initializerVictoryScenario,
				parentCondition	= function() return GetVal(settingVictoryScenario) end,
				shownPredicate	= isPvEExpanded
			})

			-- Scenario: Wipe
			AWL.Settings:AddCheckboxSliderCombo(category, layout, {
				variableTable			= MEM.Settings.event,
				checkboxSettingKey		= addonName .. "_encounter-wipe-scenario-active",
				checkboxVariableName	= "encounter-wipe-scenario-active",
				checkboxName			= eventScenarioWipe,
				checkboxTooltip			= L["options.event.pve.scenario.wipe.tooltip"],
				checkboxDefault			= MEM.OPTIONS_DEFAULTS["event"]["encounter-wipe-scenario-active"],

				sliderSettingKey		= addonName .. "_encounter-wipe-scenario-delay",
				sliderVariableName		= "encounter-wipe-scenario-delay",
				sliderName				= L["options.event.general.delay.name"],
				sliderTooltip			= L["options.event.general.delay.tooltip"]:format(
					eventScenarioWipe,
					MEM.OPTIONS_DEFAULTS["event"]["encounter-wipe-scenario-delay"]
				),
				sliderDefault			= MEM.OPTIONS_DEFAULTS["event"]["encounter-wipe-scenario-delay"],
				sliderMin				= 1,
				sliderMax				= 10,
				sliderStep				= 1,
				sliderFormatter			= FormatSeconds,

				shownPredicate			= isPvEExpanded
			})
		end

		-- Mythic+
		if AWL.GAME_TYPE_RETAIL then
			AWL.Settings:AddSeparator(layout):AddShownPredicate(isPvEExpanded)

			AWL.Settings:AddCheckboxSliderCombo(category, layout, {
				variableTable			= MEM.Settings.event,
				checkboxSettingKey		= addonName .. "_mythic-active",
				checkboxVariableName	= "mythic-active",
				checkboxName			= L["options.event.pve.mythic"],
				checkboxTooltip			= L["options.event.pve.mythic.tooltip"],
				checkboxDefault			= MEM.OPTIONS_DEFAULTS["event"]["mythic-active"],

				sliderSettingKey		= addonName .. "_mythic-delay",
				sliderVariableName		= "mythic-delay",
				sliderName				= L["options.event.general.delay.name"],
				sliderTooltip			= L["options.event.general.delay.tooltip"]:format(
					L["options.event.pve.mythic"],
					MEM.OPTIONS_DEFAULTS["event"]["mythic-delay"]
				),
				sliderDefault			= MEM.OPTIONS_DEFAULTS["event"]["mythic-delay"],
				sliderMin				= 1,
				sliderMax				= 10,
				sliderStep				= 1,
				sliderFormatter			= FormatSeconds,

				shownPredicate			= isPvEExpanded
			})
		end

	end

	local _, isPvPExpanded = AWL.Settings:AddExpandableHeader(layout, L["options.event.pvp"])

	-- Duel (Global)
	AWL.Settings:AddCheckboxSliderCombo(category, layout, {
		variableTable			= MEM.Settings.event,
		checkboxSettingKey		= addonName .. "_pvp-duel-active",
		checkboxVariableName	= "pvp-duel-active",
		checkboxName			= L["options.event.pvp.duel"],
		checkboxTooltip			= L["options.event.pvp.duel.tooltip"],
		checkboxDefault			= MEM.OPTIONS_DEFAULTS["event"]["pvp-duel-active"],

		sliderSettingKey		= addonName .. "_pvp-duel-delay",
		sliderVariableName		= "pvp-duel-delay",
		sliderName				= L["options.event.general.delay.name"],
		sliderTooltip			= L["options.event.general.delay.tooltip"]:format(
			L["options.event.pvp.duel"],
			MEM.OPTIONS_DEFAULTS["event"]["pvp-duel-delay"]
		),
		sliderDefault			= MEM.OPTIONS_DEFAULTS["event"]["pvp-duel-delay"],
		sliderMin				= 1,
		sliderMax				= 10,
		sliderStep				= 1,
		sliderFormatter			= FormatSeconds,

		shownPredicate			= isPvPExpanded
	})

	if AWL.GAME_TYPE_RETAIL then
		-- Arena
		AWL.Settings:AddCheckboxSliderCombo(category, layout, {
			variableTable			= MEM.Settings.event,
			checkboxSettingKey		= addonName .. "_pvp-arena-active",
			checkboxVariableName	= "pvp-arena-active",
			checkboxName			= L["options.event.pvp.arena"],
			checkboxTooltip			= L["options.event.pvp.arena.tooltip"],
			checkboxDefault			= MEM.OPTIONS_DEFAULTS["event"]["pvp-arena-active"],

			sliderSettingKey		= addonName .. "_pvp-arena-delay",
			sliderVariableName		= "pvp-arena-delay",
			sliderName				= L["options.event.general.delay.name"],
			sliderTooltip			= L["options.event.general.delay.tooltip"]:format(
				L["options.event.pvp.arena"],
				MEM.OPTIONS_DEFAULTS["event"]["pvp-arena-delay"]
			),
			sliderDefault			= MEM.OPTIONS_DEFAULTS["event"]["pvp-arena-delay"],
			sliderMin				= 1,
			sliderMax				= 10,
			sliderStep				= 1,
			sliderFormatter			= FormatSeconds,

			shownPredicate			= isPvPExpanded
		})
	end

	if AWL.GAME_TYPE_RETAIL or AWL.GAME_TYPE_FOREVER then
		-- Battleground
		local initializerBattleground, settingBattleground = AWL.Settings:AddCheckboxSliderCombo(category, layout, {
			variableTable			= MEM.Settings.event,
			checkboxSettingKey		= addonName .. "_pvp-battleground-active",
			checkboxVariableName	= "pvp-battleground-active",
			checkboxName			= L["options.event.pvp.battleground"],
			checkboxTooltip			= L["options.event.pvp.battleground.tooltip"],
			checkboxDefault			= MEM.OPTIONS_DEFAULTS["event"]["pvp-battleground-active"],

			sliderSettingKey		= addonName .. "_pvp-battleground-delay",
			sliderVariableName		= "pvp-battleground-delay",
			sliderName				= L["options.event.general.delay.name"],
			sliderTooltip			= L["options.event.general.delay.tooltip"]:format(
				L["options.event.pvp.battleground"],
				MEM.OPTIONS_DEFAULTS["event"]["pvp-battleground-delay"]
			),
			sliderDefault			= MEM.OPTIONS_DEFAULTS["event"]["pvp-battleground-delay"],
			sliderMin				= 1,
			sliderMax				= 10,
			sliderStep				= 1,
			sliderFormatter			= FormatSeconds,

			shownPredicate			= isPvPExpanded
		})

		-- Battleground: Only Victory
		AWL.Settings:AddCheckbox(category, {
			variableTable	= MEM.Settings.event,
			settingKey		= addonName .. "_pvp-battleground-victory-only",
			variableName	= "pvp-battleground-victory-only",
			name			= L["options.event.pvp.victory.name"],
			tooltip			= L["options.event.pvp.victory.tooltip"],
			default			= MEM.OPTIONS_DEFAULTS["event"]["pvp-battleground-victory-only"],
			parentInit		= initializerBattleground,
			parentCondition	= function() return GetVal(settingBattleground) end,
			shownPredicate	= isPvPExpanded
		})

		if AWL.GAME_TYPE_RETAIL then
			-- Brawl
			local initializerBrawl, settingBrawl = AWL.Settings:AddCheckboxSliderCombo(category, layout, {
				variableTable			= MEM.Settings.event,
				checkboxSettingKey		= addonName .. "_pvp-brawl-active",
				checkboxVariableName	= "pvp-brawl-active",
				checkboxName			= L["options.event.pvp.brawl"],
				checkboxTooltip			= L["options.event.pvp.brawl.tooltip"],
				checkboxDefault			= MEM.OPTIONS_DEFAULTS["event"]["pvp-brawl-active"],

				sliderSettingKey		= addonName .. "_pvp-brawl-delay",
				sliderVariableName		= "pvp-brawl-delay",
				sliderName				= L["options.event.general.delay.name"],
				sliderTooltip			= L["options.event.general.delay.tooltip"]:format(
					L["options.event.pvp.brawl"],
					MEM.OPTIONS_DEFAULTS["event"]["pvp-brawl-delay"]
				),
				sliderDefault			= MEM.OPTIONS_DEFAULTS["event"]["pvp-brawl-delay"],
				sliderMin				= 1,
				sliderMax				= 10,
				sliderStep				= 1,
				sliderFormatter			= FormatSeconds,

				shownPredicate			= isPvPExpanded
			})

			-- Brawl: Only Victory
			AWL.Settings:AddCheckbox(category, {
				variableTable	= MEM.Settings.event,
				settingKey		= addonName .. "_pvp-brawl-victory-only",
				variableName	= "pvp-brawl-victory-only",
				name			= L["options.event.pvp.victory.name"],
				tooltip			= L["options.event.pvp.victory.tooltip"],
				default			= MEM.OPTIONS_DEFAULTS["event"]["pvp-brawl-victory-only"],
				parentInit		= initializerBrawl,
				parentCondition	= function() return GetVal(settingBrawl) end,
				shownPredicate	= isPvPExpanded
			})
		end
	end

	local _, isCollectionExpanded = AWL.Settings:AddExpandableHeader(layout, L["options.event.collection"])

	if AWL.GAME_TYPE_RETAIL or AWL.GAME_TYPE_FOREVER or AWL.GAME_TYPE_MISTS then
		-- New Pet
		AWL.Settings:AddCheckboxSliderCombo(category, layout, {
			variableTable			= MEM.Settings.event,
			checkboxSettingKey		= addonName .. "_collection-pet-active",
			checkboxVariableName	= "collection-pet-active",
			checkboxName			= L["options.event.collection.new-pet"],
			checkboxTooltip			= L["options.event.collection.new-pet.tooltip"],
			checkboxDefault			= MEM.OPTIONS_DEFAULTS["event"]["collection-pet-active"],

			sliderSettingKey		= addonName .. "_collection-pet-delay",
			sliderVariableName		= "collection-pet-delay",
			sliderName				= L["options.event.general.delay.name"],
			sliderTooltip			= L["options.event.general.delay.tooltip"]:format(
				L["options.event.collection.new-pet"],
				MEM.OPTIONS_DEFAULTS["event"]["collection-pet-delay"]
			),
			sliderDefault			= MEM.OPTIONS_DEFAULTS["event"]["collection-pet-delay"],
			sliderMin				= 1,
			sliderMax				= 10,
			sliderStep				= 1,
			sliderFormatter			= FormatSeconds,

			shownPredicate			= isCollectionExpanded
		})
	end

	if AWL.GAME_TYPE_RETAIL or AWL.GAME_TYPE_MISTS then
		-- New Mount
		AWL.Settings:AddCheckboxSliderCombo(category, layout, {
			variableTable			= MEM.Settings.event,
			checkboxSettingKey		= addonName .. "_collection-mount-active",
			checkboxVariableName	= "collection-mount-active",
			checkboxName			= L["options.event.collection.new-mount"],
			checkboxTooltip			= L["options.event.collection.new-mount.tooltip"],
			checkboxDefault			= MEM.OPTIONS_DEFAULTS["event"]["collection-mount-active"],

			sliderSettingKey		= addonName .. "_collection-mount-delay",
			sliderVariableName		= "collection-mount-delay",
			sliderName				= L["options.event.general.delay.name"],
			sliderTooltip			= L["options.event.general.delay.tooltip"]:format(
				L["options.event.collection.new-mount"],
				MEM.OPTIONS_DEFAULTS["event"]["collection-mount-delay"]
			),
			sliderDefault			= MEM.OPTIONS_DEFAULTS["event"]["collection-mount-delay"],
			sliderMin				= 1,
			sliderMax				= 10,
			sliderStep				= 1,
			sliderFormatter			= FormatSeconds,

			shownPredicate			= isCollectionExpanded
		})

		-- New Toy
		AWL.Settings:AddCheckboxSliderCombo(category, layout, {
			variableTable			= MEM.Settings.event,
			checkboxSettingKey		= addonName .. "_collection-toy-active",
			checkboxVariableName	= "collection-toy-active",
			checkboxName			= L["options.event.collection.new-toy"],
			checkboxTooltip			= L["options.event.collection.new-toy.tooltip"],
			checkboxDefault			= MEM.OPTIONS_DEFAULTS["event"]["collection-toy-active"],

			sliderSettingKey		= addonName .. "_collection-toy-delay",
			sliderVariableName		= "collection-toy-delay",
			sliderName				= L["options.event.general.delay.name"],
			sliderTooltip			= L["options.event.general.delay.tooltip"]:format(
				L["options.event.collection.new-toy"],
				MEM.OPTIONS_DEFAULTS["event"]["collection-toy-delay"]
			),
			sliderDefault			= MEM.OPTIONS_DEFAULTS["event"]["collection-toy-delay"],
			sliderMin				= 1,
			sliderMax				= 10,
			sliderStep				= 1,
			sliderFormatter			= FormatSeconds,

			shownPredicate			= isCollectionExpanded
		})
	end

	-- New Recipe
	AWL.Settings:AddCheckboxSliderCombo(category, layout, {
		variableTable			= MEM.Settings.event,
		checkboxSettingKey		= addonName .. "_collection-recipe-active",
		checkboxVariableName	= "collection-recipe-active",
		checkboxName			= L["options.event.collection.new-recipe"],
		checkboxTooltip			= L["options.event.collection.new-recipe.tooltip"],
		checkboxDefault			= MEM.OPTIONS_DEFAULTS["event"]["collection-recipe-active"],

		sliderSettingKey		= addonName .. "_collection-recipe-delay",
		sliderVariableName		= "collection-recipe-delay",
		sliderName				= L["options.event.general.delay.name"],
		sliderTooltip			= L["options.event.general.delay.tooltip"]:format(
			L["options.event.collection.new-recipe"],
			MEM.OPTIONS_DEFAULTS["event"]["collection-recipe-delay"]
		),
		sliderDefault			= MEM.OPTIONS_DEFAULTS["event"]["collection-recipe-delay"],
		sliderMin				= 1,
		sliderMax				= 10,
		sliderStep				= 1,
		sliderFormatter			= FormatSeconds,

		shownPredicate			= isCollectionExpanded
	})

	if AWL.GAME_TYPE_RETAIL then
		-- New Housing Decor
		AWL.Settings:AddCheckboxSliderCombo(category, layout, {
			variableTable			= MEM.Settings.event,
			checkboxSettingKey		= addonName .. "_collection-housing-active",
			checkboxVariableName	= "collection-housing-active",
			checkboxName			= L["options.event.collection.new-housing-item"],
			checkboxTooltip			= L["options.event.collection.new-housing-item.tooltip"],
			checkboxDefault			= MEM.OPTIONS_DEFAULTS["event"]["collection-housing-active"],

			sliderSettingKey		= addonName .. "_collection-housing-delay",
			sliderVariableName		= "collection-housing-delay",
			sliderName				= L["options.event.general.delay.name"],
			sliderTooltip			= L["options.event.general.delay.tooltip"]:format(
				L["options.event.collection.new-housing-item"],
				MEM.OPTIONS_DEFAULTS["event"]["collection-housing-delay"]
			),
			sliderDefault			= MEM.OPTIONS_DEFAULTS["event"]["collection-housing-delay"],
			sliderMin				= 1,
			sliderMax				= 10,
			sliderStep				= 1,
			sliderFormatter			= FormatSeconds,

			shownPredicate			= isCollectionExpanded
		})
	end

	local _, isOtherExpanded = AWL.Settings:AddExpandableHeader(layout, L["options.event.other"])

	-- Interval
	AWL.Settings:AddCheckboxSliderCombo(category, layout, {
		variableTable			= MEM.Settings.event,
		checkboxSettingKey		= addonName .. "_interval-active",
		checkboxVariableName	= "interval-active",
		checkboxName			= L["options.event.other.interval"],
		checkboxTooltip			= L["options.event.other.interval.tooltip"],
		checkboxDefault			= MEM.OPTIONS_DEFAULTS["event"]["interval-active"],

		sliderSettingKey		= addonName .. "_interval-timer",
		sliderVariableName		= "interval-timer",
		sliderName				= L["options.event.other.interval-timer.name"],
		sliderTooltip			= L["options.event.other.interval-timer.tooltip"],
		sliderDefault			= MEM.OPTIONS_DEFAULTS["event"]["interval-timer"],
		sliderMin				= 1,
		sliderMax				= 60,
		sliderStep				= 1,
		sliderFormatter			= FormatMinutes,

		shownPredicate			= isOtherExpanded
	})

	if AWL.GAME_TYPE_RETAIL then
		-- Traveler's Log
		AWL.Settings:AddCheckboxSliderCombo(category, layout, {
			variableTable			= MEM.Settings.event,
			checkboxSettingKey		= addonName .. "_perks-activity-active",
			checkboxVariableName	= "perks-activity-active",
			checkboxName			= L["options.event.other.perks-activity"],
			checkboxTooltip			= L["options.event.other.perks-activity.tooltip"],
			checkboxDefault			= MEM.OPTIONS_DEFAULTS["event"]["perks-activity-active"],

			sliderSettingKey		= addonName .. "_perks-activity-delay",
			sliderVariableName		= "perks-activity-delay",
			sliderName				= L["options.event.general.delay.name"],
			sliderTooltip			= L["options.event.general.delay.tooltip"]:format(
				L["options.event.other.perks-activity"],
				MEM.OPTIONS_DEFAULTS["event"]["perks-activity-delay"]
			),
			sliderDefault			= MEM.OPTIONS_DEFAULTS["event"]["perks-activity-delay"],
			sliderMin				= 1,
			sliderMax				= 10,
			sliderStep				= 1,
			sliderFormatter			= FormatSeconds,

			shownPredicate			= isOtherExpanded
		})

		-- Special Loot
		local initializerLootToast, settingLootToast = AWL.Settings:AddCheckboxSliderCombo(category, layout, {
			variableTable			= MEM.Settings.event,
			checkboxSettingKey		= addonName .. "_loot-toast-active",
			checkboxVariableName	= "loot-toast-active",
			checkboxName			= L["options.event.other.loot-toast"],
			checkboxTooltip			= L["options.event.other.loot-toast.tooltip"],
			checkboxDefault			= MEM.OPTIONS_DEFAULTS["event"]["loot-toast-active"],

			sliderSettingKey		= addonName .. "_loot-toast-delay",
			sliderVariableName		= "loot-toast-delay",
			sliderName				= L["options.event.general.delay.name"],
			sliderTooltip			= L["options.event.general.delay.tooltip"]:format(
				L["options.event.other.loot-toast"],
				MEM.OPTIONS_DEFAULTS["event"]["loot-toast-delay"]
			),
			sliderDefault			= MEM.OPTIONS_DEFAULTS["event"]["loot-toast-delay"],
			sliderMin				= 1,
			sliderMax				= 10,
			sliderStep				= 1,
			sliderFormatter			= FormatSeconds,

			shownPredicate			= isOtherExpanded
		})

		local function IsLootToastEnabled()
			return GetVal(settingLootToast)
		end

		local lootVariables, lootDefault, lootOptions = CreateMultiSelectOptions(
			MEM.LOOT_TOAST_OPTIONS, MEM.Settings.event, MEM.OPTIONS_DEFAULTS.event, "loot-toast-types"
		)

		-- Special Loot: Types
		local initializerLootTypes = AWL.Settings:AddDropdown(category, {
			variableTable	= lootVariables,
			settingKey		= addonName .. "_loot-toast-types",
			variableName	= "loot-toast-types",
			name			= L["options.event.other.loot-toast.types.name"],
			tooltip			= L["options.event.other.loot-toast.types.tooltip"],
			default			= lootDefault,
			options			= lootOptions,
			multiSelect		= true,
			parentInit		= initializerLootToast,
			parentCondition	= IsLootToastEnabled,
			shownPredicate	= isOtherExpanded
		})

		local lootToastQualityOptions = {}

		for _, quality in ipairs(MEM.LOOT_TOAST_QUALITIES) do
			lootToastQualityOptions[#lootToastQualityOptions + 1] = {
				value = quality,
				label = _G["ITEM_QUALITY" .. quality .. "_DESC"]
			}
		end

		-- Special Loot: Minimum Item Quality
		AWL.Settings:AddDropdown(category, {
			variableTable	= MEM.Settings.event,
			settingKey		= addonName .. "_loot-toast-quality",
			variableName	= "loot-toast-quality",
			name			= L["options.event.other.loot-toast.quality.name"],
			tooltip			= L["options.event.other.loot-toast.quality.tooltip"],
			default			= MEM.OPTIONS_DEFAULTS["event"]["loot-toast-quality"],
			options			= lootToastQualityOptions,
			parentInit		= initializerLootTypes,
			parentCondition	= function() return IsLootToastEnabled() and MEM.Settings.event["loot-toast-item"] end,
			shownPredicate	= isOtherExpanded
		})
	end

	-- Manual Screenshots
	local manualHeader = Settings.CreateElementInitializer("Memento_ManualScreenshotsHeader", {name = L["options.manual"]})
	hooksecurefunc(manualHeader, "InitFrame", function(_, frame)
		AWL.Controls:AttachInfoTooltip(frame.InfoButton, function() return L["options.manual.help"] end)
	end)
	layout:AddInitializer(manualHeader)

	-- Manual Screenshots: Button
	local initializerManualButton, manualVisibilitySetting = AWL.Settings:AddCheckbox(category, {
		isNew			= true,
		variableTable	= MEM.Settings.manual,
		settingKey		= addonName .. "_manual-button-visible",
		variableName	= "manual-button-visible",
		name			= L["options.manual.button.name"],
		tooltip			= L["options.manual.button.tooltip"],
		default			= MEM.OPTIONS_DEFAULTS.manual["manual-button-visible"],
		onClick			= function(_, value)
			MEM.Modules.ScreenshotButton:SetShown(value)
		end
	})
	MEM.Modules.ScreenshotButton.visibilitySetting = manualVisibilitySetting

	-- Manual Screenshots: Hide Frame
	AWL.Settings:AddCheckbox(category, {
		variableTable	= MEM.Settings.manual,
		settingKey		= addonName .. "_manual-button-hide-frame",
		variableName	= "manual-button-hide-frame",
		name			= L["options.manual.button.hide-frame.name"],
		tooltip			= L["options.manual.button.hide-frame.tooltip"],
		default			= MEM.OPTIONS_DEFAULTS.manual["manual-button-hide-frame"],
		parentInit		= initializerManualButton,
		parentCondition	= function() return GetVal(manualVisibilitySetting) end,
		onClick			= function()
			MEM.Modules.ScreenshotButton:UpdateAppearance()
		end
	})

	-- Manual Screenshots: Lock Position
	AWL.Settings:AddCheckbox(category, {
		variableTable	= MEM.Settings.manual,
		settingKey		= addonName .. "_manual-button-locked",
		variableName	= "manual-button-locked",
		name			= L["options.manual.button.lock-position.name"],
		tooltip			= L["options.manual.button.lock-position.tooltip"],
		default			= MEM.OPTIONS_DEFAULTS.manual["manual-button-locked"],
		parentInit		= initializerManualButton,
		parentCondition	= function() return GetVal(manualVisibilitySetting) end,
		onClick			= function()
			MEM.Modules.ScreenshotButton:UpdateAppearance()
		end
	})

	-- Manual Screenshots: Key Binding
	AWL.Settings:AddKeyBinding(layout, {
		binding	= "MEMENTO_MANUAL_SCREENSHOT"
	})

	-- Manual Screenshots: Countdown
	AWL.Settings:AddCheckboxSliderCombo(category, layout, {
		variableTable			= MEM.Settings.manual,
		checkboxSettingKey		= addonName .. "_manual-countdown-active",
		checkboxVariableName	= "manual-countdown-active",
		checkboxName			= L["options.manual.countdown.name"],
		checkboxTooltip			= L["options.manual.countdown.tooltip"],
		checkboxDefault			= MEM.OPTIONS_DEFAULTS.manual["manual-countdown-active"],
		sliderSettingKey		= addonName .. "_manual-countdown-seconds",
		sliderVariableName		= "manual-countdown-seconds",
		sliderName				= L["options.manual.delay.name"],
		sliderTooltip			= L["options.manual.delay.tooltip"],
		sliderDefault			= MEM.OPTIONS_DEFAULTS.manual["manual-countdown-seconds"],
		sliderMin				= 1,
		sliderMax				= 10,
		sliderStep				= 1,
		sliderFormatter			= FormatSeconds
	})

	-- Manual Screenshots: Hide UI
	local initializerManualUI, settingManualUI = AWL.Settings:AddCheckbox(category, {
		variableTable	= MEM.Settings.manual,
		settingKey		= addonName .. "_manual-hide-ui",
		variableName	= "manual-hide-ui",
		name			= L["options.general.hide-ui.name"],
		tooltip			= L["options.general.hide-ui.tooltip"],
		default			= MEM.OPTIONS_DEFAULTS.manual["manual-hide-ui"]
	})

	-- Manual Screenshots: Capture Notice
	AWL.Settings:AddCheckbox(category, {
		variableTable	= MEM.Settings.manual,
		settingKey		= addonName .. "_manual-show-message",
		variableName	= "manual-show-message",
		name			= L["options.general.hide-ui.message.name"],
		tooltip			= L["options.general.hide-ui.message.tooltip"],
		default			= MEM.OPTIONS_DEFAULTS.manual["manual-show-message"],
		parentInit		= initializerManualUI,
		parentCondition	= function() return GetVal(settingManualUI) end
	})

	-- Profiles Section
	AWL.Settings:AddProfilesSection(layout, {
		useAccountProfile			= Addon:IsAccountProfile(),
		onSwitchProfile				= function()
			Addon:ToggleProfileMode()
			ReloadUI()
		end,
		onDeleteCharacterProfiles	= function()
			Addon:ResetAllCharacterProfiles()
			ReloadUI()
		end
	})

	-- About Section
	AWL.Settings:AddAboutSection(layout, addonName, MEM.CHANGELOG)

	Settings.RegisterAddOnCategory(category)

	Addon:SetMainCategoryId(category:GetID())
end
