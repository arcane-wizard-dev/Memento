-- Synthetic SavedVariables: previous addon version with the current database schema; fill defaults and remove obsolete options.
-- No real player data. Version "test" is the version supplied by the test harness.
-- Includes the current character's SavedVariablesPerCharacter table.

Memento_Options_v6 = {
	["account"] = {
		["event"] = {
			["encounter-victory-raid-first"] = true,
			["interval-timer"] = 10,
			["level-up-active"] = false,
			["obsolete-option"] = 1,
			["reputation-active"] = false,
			["reputation-delay"] = 0,
		},
		["general"] = {
			["debug-mode"] = "obsolete-type",
			["hide-ui-message"] = true,
			["screenshot-message-locked"] = false,
			["screenshot-message-position"] = {x = 0.5, y = 0.1},
			["minimap-button"] = {
				["hide"] = false,
				["minimapPos"] = 90,
				["obsolete"] = true,
			},
		},
		["obsolete-section"] = {
			["enabled"] = true,
		},
	},
	["global"] = {
		["obsolete"] = true,
		["version"] = "fixture-previous",
	},
	["profileKeys"] = {
		["Player-TEST-CURRENT"] = {
			["open-settings"] = false,
			["use-account"] = false,
		},
		["Player-TEST-OFFLINE"] = {
			["open-settings"] = false,
			["use-account"] = true,
		},
	},
	["profiles"] = {
		["Player-TEST-CURRENT"] = {
			["event"] = {
				["encounter-victory-raid-first"] = true,
				["interval-timer"] = 10,
				["level-up-active"] = false,
				["obsolete-option"] = 1,
				["reputation-active"] = false,
				["reputation-delay"] = 0,
			},
			["general"] = {
				["debug-mode"] = "obsolete-type",
				["hide-ui-message"] = true,
				["screenshot-message-locked"] = false,
				["screenshot-message-position"] = {x = 0, y = 0},
				["minimap-button"] = {
					["hide"] = true,
					["minimapPos"] = 0,
					["obsolete"] = true,
				},
			},
			["obsolete-section"] = {
				["enabled"] = true,
			},
		},
		["Player-TEST-OFFLINE"] = {
			["event"] = {
				["encounter-victory-raid-first"] = true,
				["interval-timer"] = 10,
				["level-up-active"] = false,
				["obsolete-option"] = 1,
				["reputation-active"] = false,
				["reputation-delay"] = 0,
			},
			["general"] = {
				["debug-mode"] = "obsolete-type",
				["hide-ui-message"] = false,
				["screenshot-message-locked"] = true,
				["screenshot-message-position"] = {x = 0.8, y = 0.9},
				["minimap-button"] = {
					["hide"] = false,
					["minimapPos"] = 270,
					["obsolete"] = true,
				},
			},
			["obsolete-section"] = {
				["enabled"] = true,
			},
		},
	},
}

Memento_DataBossKill = {
	["D14"] = {
		[123] = true,
		[456] = true,
	},
	["D15"] = {
		[123] = true,
	},
	["W"] = {
		[789] = true,
	},
}
