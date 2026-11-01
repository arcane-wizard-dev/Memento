local _, MEM = ...

if MEM.State and MEM.State.libraryIncompatible then return end

MEM.UIConfig.ScreenshotButton = {
	width = 88,
	height = 72,
	buttonSize = 36,
	buttonOffsetY = 0,
	hoverAlpha = 0.4,
	backgroundAlpha = 0.6,
	backgroundColor = {0, 0, 0, 1},
	icon = "Interface\\AddOns\\Memento\\assets\\icon-filled.tga",
	closeButton = {size = 16, point = "TOPRIGHT", x = 4, y = 4}
}
