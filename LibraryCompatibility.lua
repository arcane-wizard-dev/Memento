local addonName, MEM = ...

MEM.State = MEM.State or {}

local requiredRevision = tonumber(C_AddOns.GetAddOnMetadata(addonName, "X-Library-Revision"))
local installedRevision = ArcaneWizardLibrary and tonumber(ArcaneWizardLibrary.ADDON_REVISION)

local compatible = requiredRevision and requiredRevision >= 1 and requiredRevision % 1 == 0
	and installedRevision and installedRevision % 1 == 0 and installedRevision >= requiredRevision

MEM.State.libraryIncompatible = not compatible

if compatible then return end

local message = string.format(
	"%s: Arcane Wizard: Library revision %s or newer is required (installed: %s). Update Arcane Wizard: Library and reload the UI. Addon startup aborted.",
	addonName,
	tostring(requiredRevision or "unknown"),
	tostring(installedRevision or "unknown")
)

print(message)
geterrorhandler()(message)
