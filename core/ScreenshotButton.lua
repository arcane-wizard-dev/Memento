local addonName, MEM = ...

if MEM.State and MEM.State.libraryIncompatible then return end

-- Library
local AWL = ArcaneWizardLibrary

-- Localization
local L = MEM.Localization

-- Current module
local ScreenshotButton = MEM.Modules.ScreenshotButton

-- Module imports
local ButtonConfig = MEM.UIConfig.ScreenshotButton
local Capture = MEM.Modules.Capture

BINDING_HEADER_MEMENTO = addonName
BINDING_NAME_MEMENTO_MANUAL_SCREENSHOT = L["bindings.manual-screenshot"]

--------------
--- Frames ---
--------------

local ScreenshotButtonFrame = nil
local CaptureButton = nil ---@type Button?
local CaptureIcon = nil ---@type Texture?

-----------------------
--- Local Functions ---
-----------------------

local function UpdateButton(enabled)
	if not CaptureButton then return end
	CaptureButton:SetEnabled(enabled)
	CaptureButton:GetHighlightTexture():SetAlpha(enabled and ButtonConfig.hoverAlpha or 0)
	if CaptureIcon then
		CaptureIcon:SetTexture(enabled and ButtonConfig.icon or ButtonConfig.waitingIcon)
	end
end

------------------------
--- Public Functions ---
------------------------

function Memento_TakeManualScreenshot()
	if not CaptureButton or not CaptureButton:IsEnabled() then return end
	UpdateButton(false)
	local delay = MEM.Settings.manual["manual-countdown-active"]
		and MEM.Settings.manual["manual-countdown-seconds"] or 0
	Capture:ScheduleTimer("ManualEventHandler", delay, function()
		UpdateButton(true)
	end)
end

------------------------
--- Module Functions ---
------------------------

function ScreenshotButton:SetShown(shown)
	MEM.Settings.manual["manual-button-visible"] = shown
	if not ScreenshotButtonFrame then return end
	ScreenshotButtonFrame:SetShown(shown)
end

function ScreenshotButton:Initialize()
	if ScreenshotButtonFrame then return end

	ScreenshotButtonFrame = AWL.Frames:CreatePopup({
		addonName = addonName,
		width = ButtonConfig.width,
		height = ButtonConfig.height,
		style = "tooltip",
		backgroundAlpha = ButtonConfig.backgroundAlpha,
		showBorder = true,
		showCloseButton = true,
		closeButton = ButtonConfig.closeButton,
		movable = true,
		closeOnEscape = false
	})
	ScreenshotButtonFrame:SetBackdropColor(unpack(ButtonConfig.backgroundColor))
	ScreenshotButtonFrame:ClearAllPoints()
	ScreenshotButtonFrame:SetPoint("CENTER", UIParent, "CENTER",
		MEM.Settings.manual["manual-button-x"] or 0, MEM.Settings.manual["manual-button-y"] or 0)
	ScreenshotButtonFrame:SetScript("OnDragStop", function(self)
		self:StopMovingOrSizing()
		local x, y = self:GetCenter()
		if not x or not y then return end
		MEM.Settings.manual["manual-button-x"] = x - UIParent:GetWidth() / 2
		MEM.Settings.manual["manual-button-y"] = y - UIParent:GetHeight() / 2
	end)
	ScreenshotButtonFrame.closeButton:SetScript("OnClick", function()
		if ScreenshotButton.visibilitySetting then
			ScreenshotButton.visibilitySetting:SetValue(false)
		else
			ScreenshotButton:SetShown(false)
		end
	end)

	CaptureButton = CreateFrame("Button", nil, ScreenshotButtonFrame)
	CaptureButton:SetSize(ButtonConfig.buttonSize, ButtonConfig.buttonSize)
	CaptureButton:SetPoint("CENTER", ScreenshotButtonFrame, "CENTER", 0, ButtonConfig.buttonOffsetY)
	CaptureButton:SetHighlightTexture(ButtonConfig.icon, "ADD")
	CaptureIcon = CaptureButton:CreateTexture(nil, "ARTWORK")
	CaptureIcon:SetSize(ButtonConfig.buttonSize, ButtonConfig.buttonSize)
	CaptureIcon:SetPoint("CENTER")
	CaptureIcon:SetTexture(ButtonConfig.icon)
	CaptureButton:SetScript("OnMouseDown", function()
		if not CaptureButton:IsEnabled() then return end
		CaptureIcon:ClearAllPoints()
		CaptureIcon:SetPoint("CENTER", CaptureButton, "CENTER", 1, -1)
	end)
	CaptureButton:SetScript("OnMouseUp", function()
		CaptureIcon:ClearAllPoints()
		CaptureIcon:SetPoint("CENTER")
	end)
	CaptureButton:SetScript("OnClick", Memento_TakeManualScreenshot)
	UpdateButton(true)
	self:SetShown(MEM.Settings.manual["manual-button-visible"])
end
