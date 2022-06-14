local Cinnabar, Util, Cfg, Module = unpack(select(2,...))

-- If the player isn't on a class that needs class power
-- Don't Run this file
local _, PlayerClass = UnitClass('player')
if PlayerClass ~= 'ROGUE'   and
   PlayerClass ~= 'DRUID'   and
   PlayerClass ~= 'PALADIN' and
   PlayerClass ~= 'WARLOCK' and
   PlayerClass ~= 'MONK'    and
   PlayerClass ~= 'MAGE'    then
    return
end

local MODULE_NAME = "Nameplates"
local NAME = Cinnabar.data.NAME
local Nameplate = Module[MODULE_NAME]
local TargetInfo = Nameplate.TargetInfo
local default_texture = Cinnabar.lsm:Fetch('statusbar', 'Simple')
local default_font = Cinnabar.lsm:Fetch('font', 'BebasNeue-Regular')

local ClassPower = {}
local height = 3

local MAX = {
  ['ROGUE']     = 5,
  ['DRUID']     = 5,
  ['PALADIN']   = 5,
  ['WARLOCK']   = 5,
  ['MONK']      = 6,
  ['MAGE']      = 4
}

-- sourced from FrameXML/Constants.lua
local SPEC_MAGE_ARCANE = _G.SPEC_MAGE_ARCANE or 1
local SPEC_MONK_WINDWALKER = _G.SPEC_MONK_WINDWALKER or 3
local SPEC_WARLOCK_DESTRUCTION = _G.SPEC_WARLOCK_DESTRUCTION or 3
local SPELL_POWER_ENERGY = Enum.PowerType.Energy or 3
local SPELL_POWER_COMBO_POINTS = Enum.PowerType.ComboPoints or 4
local SPELL_POWER_SOUL_SHARDS = Enum.PowerType.SoulShards or 7
local SPELL_POWER_HOLY_POWER = Enum.PowerType.HolyPower or 9
local SPELL_POWER_CHI = Enum.PowerType.Chi or 12
local SPELL_POWER_ARCANE_CHARGES = Enum.PowerType.ArcaneCharges or 16

-- Holds the class specific stuff.
local ClassPowerID, ClassPowerType
local ClassPowerEnable, ClassPowerDisable
local RequireSpec, RequirePower, RequireSpell

-- Create the Class Powers
do
  local w = TargetInfo:GetWidth()
  for i = 1, MAX[PlayerClass] do
    local bar = CreateFrame('StatusBar', nil, TargetInfo)
    local Width = w / MAX[PlayerClass] - 3
    bar:SetSize((w / 6) - 3, height)
    bar:SetPoint(
      'TOP',
      TargetInfo,
      'BOTTOM',
      ((i - 1) * (Width + 3)) - (w / 2) + (Width / 2) + Width / 6, -- [TODO] (HlafSyp) Simplify this mess of an equation
      -3
    )
    bar:SetMinMaxValues(0, 1)
    bar:SetValue(1)
    bar:SetStatusBarTexture(default_texture)
    bar.bg = bar:CreateTexture(nil, 'BACKGROUND')
    bar.bg:SetAllPoints(bar)
    bar.bg:SetTexture(default_texture)
    bar.Backdrop = CreateFrame("Frame", nil, bar, "BackdropTemplate")
    bar.Backdrop:SetAllPoints(bar)
    bar.Backdrop:SetFrameLevel(bar:GetFrameLevel() == 0 and 0 or bar:GetFrameLevel() - 1)

    bar.Backdrop:SetBackdrop {
      bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
      tile = false,
      tileSize = 0,
      insets = {
        left = -1,
        right = -1,
        top = -1,
        bottom = -1,
      }
    }
    bar.Backdrop:SetBackdropColor(0,0,0, 1)

    -- Helper function to make moving the runes easier
    function bar:ChangeVOffset(offset)
      bar:ClearAllPoints()
      bar:SetPoint(
        'TOP',
        TargetInfo,
        'BOTTOM',
        ((i - 1) * (Width + 3)) - (w / 2) + (Width / 2) + Width / 6, -- [TODO] (HlafSyp) Simplify this mess of an equation
        -3 - offset
      )

    end

    ClassPower[i] = bar
  end

end

-- Works just like Array.Map in js
function ClassPower:Map(func)

  assert(type(func) == 'function', 'Usage: ClassPower:Map(func) expected type \'function\' for argument #1, got ' .. type(func))
  for i = 1, MAX[PlayerClass] do
    func(ClassPower[i], i)
  end

end

function ClassPower:ResizeBars()

  local w = TargetInfo:GetWidth()
  local count = 0
  ClassPower:Map(function(bar)
    if bar:IsShown() then
      count = count + 1
    end
  end)

  local Width = w / count - 3
  ClassPower:Map(function(bar, index)
    bar:SetSize((w / 6) - 3, height)
    bar:SetPoint(
      'TOP',
      TargetInfo,
      'BOTTOM',
      ((index - 1) * (Width + 3)) - (w / 2) + (Width / 2) + Width / 6, -- [TODO] (HlafSyp) Simplify this mess of an equation
      -3
    )
  end)

end

local function Route(self, event, ...)

  if      event == 'SPELLS_CHANGED'           or
          event == 'UNIT_DISPLAYPOWER'        or
          event == 'PLAYER_TALENT_UPDATE'     then
    ClassPower:Visibility(...)
  elseif  event == 'UNIT_POWER_FREQUENT'      or
          event == 'UNIT_MAXPOWER'            or
          event == 'UNIT_POWER_POINT_CHARGE'  then
    ClassPower:Update(...)
  end
end

function ClassPower:Update(event, unit, powerType)

	local element = ClassPower

	local cur, max, mod, oldMax, chargedPoints
	if(event ~= 'ClassPowerDisable') then
		local powerID = unit == 'vehicle' and SPELL_POWER_COMBO_POINTS or ClassPowerID
		cur = UnitPower(unit, powerID, true)
		max = UnitPowerMax(unit, powerID)
		mod = UnitPowerDisplayMod(powerID)

		-- mod should never be 0, but according to Blizz code it can actually happen
		cur = mod == 0 and 0 or cur / mod

		-- BUG: Destruction is supposed to show partial soulshards, but Affliction and Demonology should only show full ones
		if(ClassPowerType == 'SOUL_SHARDS' and GetSpecialization() ~= SPEC_WARLOCK_DESTRUCTION) then
			cur = cur - cur % 1
		end

		if(PlayerClass == 'ROGUE') then
			chargedPoints = GetUnitChargedPowerPoints(unit)

			-- UNIT_POWER_POINT_CHARGE doesn't provide a power type
			powerType = powerType or ClassPowerType
		end

		local numActive = cur + 0.9
		for i = 1, max do
			if(i > numActive) then
				element[i]:SetValue(0)
			else
        element[i]:Show()
				element[i]:SetValue(cur - i + 1)
			end
		end

	end
end

function ClassPower:Visibility(event)

  local element = self
  local toEnable

  if UnitHasVehicleUI('player') then
    shouldEnable = PlayerVehicleHasComboPoints()
    unit = 'vehicle'
  elseif ClassPowerID then
    if not RequireSpec or RequireSpec == GetSpecialization() then
      if not RequirePower or RequirePower == UnitPowerType('player') then
        if not RequireSpell or IsPlayerSpell(RequireSpell) then
          TargetInfo:UnregisterEvent('SPELLS_CHANGED', ClassPower.Visibility)
          toEnable = true
          unit = 'player'
        else
          Targetinfo:RegisterEvent('SPELLS_CHANGED', ClassPower.Visibility, true)
        end
      end
    end
    local isEnabled = element.__isEnabled
    local powerType = unit == 'vehicle' and 'COMBO_POINTS' or ClassPowerType

    if toEnable and not isEnabled then
      TargetInfo:RegisterEvent('UNIT_POWER_FREQUENT', ClassPower.Update)
      TargetInfo:RegisterEvent('UNIT_MAXPOWER', ClassPower.Update)

      if(PlayerClass == 'ROGUE') then
        TargetInfo:RegisterEvent('UNIT_POWER_POINT_CHARGE', ClassPower.Update)
      end

      self.__isEnabled = true

      if(UnitHasVehicleUI('player')) then
        ClassPower:Update('ClassPowerEnable', 'vehicle', 'COMBO_POINTS')
      else
        ClassPower:Update('ClassPowerEnable', 'player', ClassPowerType)
      end
    elseif not toEnable and (isEnabled or isEnabled == nil) then
      TargetInfo:UnregisterEvent('UNIT_POWER_FREQUENT', ClassPower.Update)
      TargetInfo:UnregisterEvent('UNIT_MAXPOWER', ClassPower.Update)
      TargetInfo:UnregisterEvent('UNIT_POWER_POINT_CHARGE', ClassPower.Update)

      local element = ClassPower
      for i = 1, #element do
        element[i]:Hide()
      end

      element.__isEnabled = false
      ClassPower:Update('ClassPowerDisable', 'player', ClassPowerType)
    elseif toEnable and isEnabled then
      ClassPower:Update(event, unit, powerType)
    end
  end
end

function ClassPower:Color()
  local Colors = {
    ['CHI']             = {0.71, 1.00, 0.92},
    ['HOLY_POWER']      = {0.95, 0.90, 0.60},
    ['SOUL_SHARDS']     = {0.50, 0.32, 0.55},
    ['COMBO_POINTS']    = {1.00, 0.96, 0.41},
    ['ARCANE_CHARGES']  = {0.10, 0.10, 0.98},
  }

  local r,g,b = unpack(Colors[ClassPowerType])
  ClassPower:Map(function(bar)

    bar:SetStatusBarColor(r,g,b, 1)
    bar.bg:SetVertexColor(r * 0.3, g * 0.3, b * 0.3, 1)

  end)

end

do
  if(PlayerClass == 'MONK') then
		ClassPowerID = SPELL_POWER_CHI
		ClassPowerType = 'CHI'
		RequireSpec = SPEC_MONK_WINDWALKER
	elseif(PlayerClass == 'PALADIN') then
		ClassPowerID = SPELL_POWER_HOLY_POWER
		ClassPowerType = 'HOLY_POWER'
	elseif(PlayerClass == 'WARLOCK') then
		ClassPowerID = SPELL_POWER_SOUL_SHARDS
		ClassPowerType = 'SOUL_SHARDS'
	elseif(PlayerClass == 'ROGUE' or PlayerClass == 'DRUID') then
		ClassPowerID = SPELL_POWER_COMBO_POINTS
		ClassPowerType = 'COMBO_POINTS'

		if(PlayerClass == 'DRUID') then
			RequirePower = SPELL_POWER_ENERGY
			RequireSpell = 5221 -- Shred
		end
	elseif(PlayerClass == 'MAGE') then
		ClassPowerID = SPELL_POWER_ARCANE_CHARGES
		ClassPowerType = 'ARCANE_CHARGES'
		RequireSpec = SPEC_MAGE_ARCANE
	end

  ClassPower:Color()
  local element = ClassPower
	if(element) then
		element.__owner = TargetInfo
		element.__max = #element
		if(RequireSpec or RequireSpell) then
			TargetInfo:RegisterEvent('PLAYER_TALENT_UPDATE', ClassPower.Visibility, true)
		end

		if(RequirePower) then
			TargetInfo:RegisterEvent('UNIT_DISPLAYPOWER', ClassPower.Visibility)
		end
  end
  TargetInfo:HookScript('OnEvent', Route)
end