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

local function SavePosition(frame)
	frame:StopMovingOrSizing()
	local x, y = frame:GetCenter()
	if not x or not y then return end
	MEM.Settings.manual["manual-button-x"] = x - UIParent:GetWidth() / 2
	MEM.Settings.manual["manual-button-y"] = y - UIParent:GetHeight() / 2
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

function ScreenshotButton:UpdateAppearance()
	local frame = ScreenshotButtonFrame
	if not frame or not CaptureButton then return end

	local showFrame = not MEM.Settings.manual["manual-button-hide-frame"]
	local locked = MEM.Settings.manual["manual-button-locked"] == true
	frame:SetSize(showFrame and ButtonConfig.width or ButtonConfig.buttonSize,
		showFrame and ButtonConfig.height or ButtonConfig.buttonSize)
	frame:ClearAllPoints()
	frame:SetPoint("CENTER", UIParent, "CENTER",
		MEM.Settings.manual["manual-button-x"] or 0, MEM.Settings.manual["manual-button-y"] or 0)
	frame:SetBorderShown(showFrame)
	frame.background:SetAlpha(showFrame and ButtonConfig.backgroundAlpha or 0)
	frame.closeButton:SetShown(showFrame and not locked)
	frame:SetMovable(not locked)

	if showFrame and not locked then
		frame:RegisterForDrag("LeftButton", "RightButton")
	else
		frame:RegisterForDrag()
	end

	if not locked then
		CaptureButton:RegisterForDrag("RightButton")
	else
		CaptureButton:RegisterForDrag()
	end
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
	local frame = ScreenshotButtonFrame
	frame:SetBackdropColor(unpack(ButtonConfig.backgroundColor))
	frame:SetScript("OnDragStop", SavePosition)
	frame.closeButton:SetScript("OnClick", function()
		if ScreenshotButton.visibilitySetting then
			ScreenshotButton.visibilitySetting:SetValue(false)
		else
			ScreenshotButton:SetShown(false)
		end
	end)

	CaptureButton = CreateFrame("Button", nil, frame)
	CaptureButton:SetSize(ButtonConfig.buttonSize, ButtonConfig.buttonSize)
	CaptureButton:SetPoint("CENTER", frame, "CENTER", 0, ButtonConfig.buttonOffsetY)
	CaptureButton:RegisterForClicks("LeftButtonUp")
	CaptureButton:SetScript("OnDragStart", function()
		frame:StartMoving()
	end)
	CaptureButton:SetScript("OnDragStop", function()
		SavePosition(frame)
	end)
	CaptureButton:SetHighlightTexture(ButtonConfig.icon, "ADD")
	CaptureIcon = CaptureButton:CreateTexture(nil, "ARTWORK")
	CaptureIcon:SetSize(ButtonConfig.buttonSize, ButtonConfig.buttonSize)
	CaptureIcon:SetPoint("CENTER")
	CaptureIcon:SetTexture(ButtonConfig.icon)
	CaptureButton:SetScript("OnMouseDown", function(_, button)
		if button ~= "LeftButton" or not CaptureButton:IsEnabled() then return end
		CaptureIcon:ClearAllPoints()
		CaptureIcon:SetPoint("CENTER", CaptureButton, "CENTER", 1, -1)
	end)
	CaptureButton:SetScript("OnMouseUp", function()
		CaptureIcon:ClearAllPoints()
		CaptureIcon:SetPoint("CENTER")
	end)
	CaptureButton:SetScript("OnClick", Memento_TakeManualScreenshot)
	UpdateButton(true)
	self:UpdateAppearance()
	self:SetShown(MEM.Settings.manual["manual-button-visible"])
end
