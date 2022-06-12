local addon_name, core = ...

local Cinnabar = LibStub("AceAddon-3.0"):NewAddon("CinnabarUI", "AceSerializer-3.0")
local config = Cinnabar:NewModule("Config", "AceSerializer-3.0")

Cinnabar.lsm = LibStub("LibSharedMedia-3.0")

-------------
-- Modules --
-------------
local m = {}

m["UnitFrames"] = Cinnabar:NewModule("UnitFrames")
m["Tooltip"]    = Cinnabar:NewModule("Tooltip")
m["Databar"]    = Cinnabar:NewModule("Databar")
m['Skin']       = Cinnabar:NewModule("Skin")
m['Nameplates'] = Cinnabar:NewModule('Nameplates')

-------------
--  Extra  --
-------------
Cinnabar.data = {
  NAME = addon_name,
  MAX_LEVEL = GetMaxPlayerLevel(),
  Mount = {
    IDs = {},
    SpellIDs = {},
  },
  COLORS = {
    UI_FG       = {r = 1, g = 0.88, b = 0.85,hex = "ffffe1da"},
    UI_PRIMARY  = {r = 0.89, g = 0.3, b = 0.18,hex = "ffE44D2E"},
  },
}

------------
-- Assign --
------------
core[1] = Cinnabar  -- Core Table, holds central functions to the addon used in the majority of modules
core[2] = {}        -- Utility Table, any debug stuff or other utility functions will be placed in here
core[3] = config    -- Configuration Table, holds all config data
core[4] = m         -- Modules Table, Holds all Module tables
