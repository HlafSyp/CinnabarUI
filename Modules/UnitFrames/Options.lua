local Cinnabar, Util, Cfg, Module = unpack(select(2,...))

local MODULE_NAME = "UnitFrames"
local oUF = select(2,...).oUF
local uf = Module[MODULE_NAME]

local COLOR = Cinnabar.data.COLORS.UI_FG

-- Section to modify Auras Lists
-- Section to Enable/Disable Various Units
-- Section to change what specs have percentage power
-- Section for each unit to control size/pos of frame

local CLASSID = {
  ['DEATHKNIGHT'] = 6,
  ['DEMONHUNTER'] = 12,
  ['DRUID'] = 11,
  ['HUNTER'] = 3,
  ['MAGE'] = 8,
  ['MONK'] = 10,
  ['PALADIN'] = 2,
  ['PRIEST'] = 5,
  ['ROGUE'] = 4,
  ['SHAMAN'] = 7,
  ['WARLOCK'] = 9,
  ['WARRIOR'] = 1,
}

