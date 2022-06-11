local Cinnabar, Util, Cfg, Module = unpack(select(2,...))

local MODULE_NAME = "UnitFrames"
local NAME = Cinnabar.data.NAME
local oUF = select(2,...).oUF

if false then return end

local _, PlayerClass = UnitClass('player')
local PowerType, PowerName
local width, height = 85, 10
local TargetInfo
local default_texture = Cinnabar.lsm:Fetch('statusbar', 'Simple')
local default_font = Cinnabar.lsm:Fetch('font', 'BebasNeue-Regular')

local function SetupClassPowerInfo()
  if PlayerClass == 'WARLOCK' then
    PowerType = Enum.PowerType.SoulShards or 7
    PowerName = 'SOUL_SHARDS'
    return 5
  elseif PlayerClass == 'PALADIN' then
    PowerType = Enum.PowerType.HolyPower or 9
    PowerName = 'HOLY_POWER'
    return 5
  elseif PlayerClass == 'MONK' then
    PowerType = Enum.PowerType.Chi or 12
    PowerName = 'CHI'
    return 6
  elseif PlayerClass == 'MAGE' then
    PowerType = Enum.PowerType.ArcaneCharges or 16
    PowerName = 'ARCANE_CHARGES'
    return 4
  elseif PlayerClass == 'DRUID' or PlayerClass == 'ROGUE' then
    PowerType = Enum.PowerType.ComboPoints or 4
    PowerName = 'COMBO_POINTS'
    return 5
  elseif PlayerClass == 'DEATHKNIGHT' then
    return 0
  end
  return 0
end

local function GetClassPowerColor()

  if PlayerClass == 'MONK' then
    return {0.71, 1.00, 0.92}
  elseif PlayerClass == 'MAGE' then
    return {0.10, 0.10, 0.98}
  elseif PlayerClass == 'PALADIN' then
    return {0.95, 0.90, 0.60}
  elseif PlayerClass == 'WARLOCK' then
    return {0.50, 0.32, 0.55}
  else
    return {1.00, 0.96, 0.41}
  end

  return {1,1,1}

end

local function CreateTargetInfo()

  -- Setup frame stuff
  TargetInfo = CreateFrame('Frame', nil, UIParent)
  TargetInfo:SetSize(width, height)

  -- Some Helper Functions to make moving the panel
  -- from nameplate to nameplate a bit easier
  function TargetInfo:AttachToFrame(frame)
    assert(type(frame) == 'table', "Usage: Argument given to TargetInfo:AttachToFrame(frame) is of type " .. type(frame) .. ', expected "table"')
    self:ClearAllPoints()
    self:SetAllPoints(frame)
    self:SetParent(frame)
    self:Show()
  end

  function TargetInfo:ClearAttachments()

    self:ClearAllPoints()
    self:SetParent(UIParent)
    self:Hide()

  end

  local ClassPower = {}
  -- Check to see how many bars to create for the class power
  local max = SetupClassPowerInfo()
  local r,g,b = unpack(GetClassPowerColor())
  for i = 1, max do
    local bar = CreateFrame('StatusBar', nil, TargetInfo)
    bar:SetStatusBarTexture(default_texture)
    bar:SetSize(width / max - 2, 3)
    bar:SetPoint(
      'TOPLEFT',
      TargetInfo,
      'BOTTOM',
      ((i - 1) * (bar:GetWidth() + 2)) - ((bar:GetWidth() + 2) * (max / 2)) + 1, -- essentially {(bar offset) - [(total width) / 2] + 1}
      -3
    )
    bar:SetStatusBarTexture(default_texture)
    bar:SetMinMaxValues(0,1)
    bar:SetStatusBarColor(r, g, b, 1)
    bar:SetValue(0)
    bar.bg = bar:CreateTexture(nil, 'BACKGROUND')
    bar.bg:SetAllPoints(bar)
    bar.bg:SetTexture(default_texture)
    bar.bg:SetVertexColor(r * 0.3, g * 0.3, b * 0.3, 1)
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
    ClassPower[i] = bar
  end

  function ClassPower:Realign()

    -- See which ones are shown
    local count = 0
    for i = 1, max do
      if self[i]:IsShown() then
        count = count + 1
      end
    end

    -- Realign bars
    for i = 1, max do
      self[i]:SetSize(width / count - 2, 3)
      bar:SetPoint(
        'TOPLEFT',
        TargetInfo,
        'BOTTOM',
        ((i - 1) * (bar:GetWidth() + 2)) - ((bar:GetWidth() + 2) * (count / 2)) + 1, -- essentially {(bar offset) - [(total width) / 2] + 1}
        -3
      )
    end
  end

  function ClassPower:Disable()

    for i = 1, max do
      self[i]:Hide()
    end

  end

  function ClassPower:Enable()
    for i = 1, max do
      self[i]:Show()
    end
  end

  function ClassPower.Visibility(self, event, unit)

    local needsRealign = false
    if     PlayerClass == 'MONK' then
      if GetSpecialization() ~= 3 and GetSpecialization() ~= nil then
        ClassPower:Disable()
      else
        ClassPower:Enable()
      end
      if UnitPowerMax(unit, 12) ~= max then
        for i = UnitPowerMax(unit, 12), max do
          if ClassPower[i] then
            ClassPower[i]:Hide()
          end
        end
        needsRealign = true
      end
    elseif PlayerClass == 'MAGE' then
      if GetSpecialization() ~= 1
        then ClassPower:Disable()
        else ClassPower:Enable()
      end
    elseif PlayerClass == 'PALADIN' or
           PlayerClass == 'WARLOCK' or
           PlayerClass == 'ROGUE' then
      ClassPower:Enable()
    elseif PlayerClass == 'DRUID' then
      if UnitPowerType('player') == 3 then ClassPower:Enable() else ClassPower:Disable() end
    elseif PlayerClass == 'DEATHKNIGHT' then
      ClassPower:Enable()
    end


  end

  TargetInfo.ClassPower = ClassPower

  -- Copied from oUF's ClassPower
  function TargetInfo.UpdateBars(unit, powerType)
    if(not (unit and (UnitIsUnit(unit, 'player') and (not powerType or powerType == PowerName)
      or unit == 'vehicle' and powerType == 'COMBO_POINTS'))) then
      return
    end
    local element = ClassPower

    local cur, mod, chargedPoints = 0, 0, 0
    local powerID = unit == 'vehicle' and 4 or PowerType
    cur = UnitPower(unit, powerID, true)
    max = UnitPowerMax(unit, powerID)
    mod = UnitPowerDisplayMod(powerID)

    -- mod should never be 0, but according to Blizz code it can actually happen
    cur = mod == 0 and 0 or cur / mod

    -- BUG: Destruction is supposed to show partial soulshards, but Affliction and Demonology should only show full ones
    if(PowerType == 7 and GetSpecialization() ~= SPEC_WARLOCK_DESTRUCTION) then
      cur = cur - cur % 1
    end

    if(PlayerClass == 'ROGUE') then
      chargedPoints = GetUnitChargedPowerPoints(unit)

      -- UNIT_POWER_POINT_CHARGE doesn't provide a power type
      powerType = powerType or 'COMBO_POINTS'
    end

    local numActive = cur + 0.9
    for i = 1, max do
      if(i > numActive) then
        element[i]:SetValue(0)
      else
        element[i]:SetValue(cur - i + 1)
      end
    end
  end

  local function Route(self, event, ...)
    if event == 'PLAYER_TALENT_UPDATE' or event == 'UNIT_DISPLAYPOWER' then
      ClassPower.Visibility(...)
    elseif event == 'UNIT_POWER_FREQUENT' or event == 'UNIT_POWER_POINT_CHARGE' then
      TargetInfo.UpdateBars(...)
    end

  end

  if PlayerClass == 'MONK' or PlayerClass == 'MAGE' then
    TargetInfo:RegisterEvent('PLAYER_TALENT_UPDATE')
  end

  if PlayerClass == 'DRUID' then
    TargetInfo:RegisterEvent('UNIT_DISPLAYPOWER')
  end

  TargetInfo:RegisterEvent('UNIT_POWER_FREQUENT')
  TargetInfo:RegisterEvent('UNIT_POWER_POINT_CHARGE')
  TargetInfo:SetScript('OnEvent', Route)
  ClassPower.Visibility()

end

local function NameplateCallback(self, event, unit)

  if event == 'PLAYER_TARGET_CHANGED' then
    TargetInfo:ClearAttachments()
    if self then TargetInfo:AttachToFrame(self) end
  end

end

local function CreateNameplate(self,  unit)

  self:SetSize(width, height)
  self:SetPoint('CENTER')

  -- Create the Healthbar portion of the nameplate
  local Health = CreateFrame('StatusBar', nil, self)
  Health:SetStatusBarTexture(default_texture)
  Health:SetAllPoints(self)
  Health.bg = Health:CreateTexture(nil, 'BACKGROUND')
  Health.bg:SetAllPoints(Health)
  Health.bg:SetTexture(default_texture)
  Health.bg.multiplier = 0.3
  Health.Smooth = true
  Health.colorClass = true
  Health.colorReaction = true

  local name = Health:CreateFontString(nil, 'ARTWORK')
  name:SetFont(default_font, 10, 'OUTLINE')
  name:SetPoint('BOTTOM', self, 'TOP', 0, 0)
  self:Tag(name, '[name]')

  local level = Health:CreateFontString(nil, 'ARTWORK')
  level:SetFont(default_font, 12, 'OUTLINE')
  level:SetPoint('LEFT', Health, 'LEFT', 0, -1)
  self:Tag(level, '[Cinnabar:smartlevel]')

  local perhp = Health:CreateFontString(nil, 'ARTWORK')
  perhp:SetFont(default_font, 12, 'OUTLINE')
  perhp:SetPoint('RIGHT', Health, 'RIGHT', 0, -1)
  self:Tag(perhp, '[perhp]')


  -- Setup Highlights
  self.Highlight = self:CreateTexture(nil, 'ARTWORK')
  self.Highlight:SetAllPoints(self)
  self.Highlight:SetColorTexture(1,1,1,1)
  self.Highlight:SetBlendMode('ADD')
  self.Highlight:Hide()
  self:HookScript('OnEnter', function()
    self.Highlight:Show()
  end)
  self:HookScript('OnLeave', function()
    self.Highlight:Hide()
  end)

  -- Register it with oUF
  self.Health     = Health
  self.Backdrop   = CreateFrame("Frame", nil, self, "BackdropTemplate")
  self.Backdrop:SetAllPoints(self)
  self.Backdrop:SetFrameLevel(self:GetFrameLevel() == 0 and 0 or self:GetFrameLevel() - 1)

  self.Backdrop:SetBackdrop {
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
  self.Backdrop:SetBackdropColor(0,0,0, 1)

end

oUF:RegisterStyle("CinnabarNameplate", CreateNameplate)

oUF:Factory(function(self)

  local cvars = {
    ['nameplateShowAll']        = 1,      -- Shows all Nameplates
    ['nameplateGlobalScale']    = 1,      -- Controls Size of Nameplates
    ['nameplateSelectedScale']  = 1.2,    -- Controls Size of Target's Nameplate
    ['nameplateMotion']         = 1,      -- Whether to stack or overlap nameplates
    ["nameplateMotionSpeed"]    = 0.01,   -- How fast it moves
  }
  CreateTargetInfo()
  self:SetActiveStyle("CinnabarNameplate")
  self:SpawnNamePlates("CinnabarUI_", NameplateCallback, cvars)

end)