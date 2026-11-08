---@meta

-- Legacy Reputation API

--- Types the return values used by the reputation reader: name, reaction, header flags and faction ID.
---@alias MementoLegacyFactionLookup fun(identifier: integer): string?, any, integer?, any, any, any, any, any, boolean?, boolean?, boolean?, any, any, integer?

---@type MementoLegacyFactionLookup
GetFactionInfo = nil

---@type MementoLegacyFactionLookup
GetFactionInfoByID = nil

---@type fun(): integer
GetNumFactions = nil

---@type fun(index: integer)
ExpandFactionHeader = nil

---@type fun(index: integer)
CollapseFactionHeader = nil
