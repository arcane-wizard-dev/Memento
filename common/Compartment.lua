local addonName, MEM = ...

if MEM.State and MEM.State.libraryIncompatible then return end

-- Library
local AWL = ArcaneWizardLibrary
local Addon = AWL:GetAddon(addonName)

-- Localization
local L = MEM.Localization

-- Variables
local handlers = Addon:CreateCompartmentHandlers({
	tooltip = L["minimap-button.tooltip"]
})

------------------------
--- Public Functions ---
------------------------

function Memento_CompartmentOnEnter(self, button)
	handlers.OnEnter(self, button)
end

function Memento_CompartmentOnLeave()
	handlers.OnLeave()
end

function Memento_CompartmentOnClick(self, button)
	handlers.OnClick(self, button)
end
