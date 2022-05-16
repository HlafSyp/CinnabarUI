local addon_name, core = ...

local Cinnabar = LibStub("AceAddon-3.0"):NewAddon("CinnabarUI", "AceSerializer-3.0")

local config = Cinnabar:NewModule("Config", "AceSerializer-3.0")

-------------
-- Modules --
-------------
local m = {}

m["UnitFrames"] = Cinnabar:NewModule("UnitFrames")
m["Tooltip"]    = Cinnabar:NewModule("Tooltip")

-------------
--  Extra  --
-------------
Cinnabar.data = {
    NAME = addon_name,
    MAX_LEVEL = 60,
    Mount = {
        IDs = {},
        SpellIDs = {},
    }
}

------------
-- Assign --
------------
core[1] = Cinnabar   -- Core Table, holds central functions to the addon used in the majority of modules
core[2] = {}        -- Utility Table, any debug stuff or other utility functions will be placed in here
core[3] = config    -- Configuration Table, holds all config data
core[5] = m         -- Modules Table, Holds all Module tables

