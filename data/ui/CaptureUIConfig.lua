local _, MEM = ...

if MEM.State and MEM.State.libraryIncompatible then return end

MEM.UIConfig.Capture = {
	point = "BOTTOM",
	offsetY = 100,
	width = 164,
	height = 41,
	backgroundTexture = 612384,
	fontSize = 7,
	topFont = "GameFontBlackTiny",
	topOffsetY = 5,
	bottomFont = "GameFontWhiteTiny",
	bottomOffsetY = -6
}
