local Cinnabar, Util, Cfg, Module = unpack(select(2,...))

local MODULE_NAME = "Nameplates"
local NAME = Cinnabar.data.NAME
local Nameplate = Module[MODULE_NAME]
local oUF = select(2,...).oUF

if false then return end

local width, height = 85, 10
local default_texture = Cinnabar.lsm:Fetch('statusbar', 'Simple')
local default_font = Cinnabar.lsm:Fetch('font', 'BebasNeue-Regular')
local TargetInfo
-- Create the target info panel
-- This is in charge of holding things like runes and class powers
do
  TargetInfo = CreateFrame('Frame', nil, UIParent)
  TargetInfo:SetSize(width, height)
  function TargetInfo:Pin(frame)

    self:UnPin()
    self:SetParent(frame)
    self:ClearAllPoints()
    self:Show()
    self:SetPoint("CENTER", frame)

  end
  function TargetInfo:UnPin()

    self:SetParent(UIParent)
    self:Hide()
    self:ClearAllPoints()

  end

  function TargetInfo:Update(frame, reset)

    if frame:IsVisible() and not reset then
      if TargetInfo.Runes then
        TargetInfo.Runes:ChangeVOffset(frame:GetHeight() + 3)
      elseif TargetInfo.ClassPower then
        TargetInfo.ClassPower:ChangeVOffset(frame:GetHeight() + 3)
      end
    else
      if TargetInfo.Runes then
        TargetInfo.Runes:ChangeVOffset(0)
      elseif TargetInfo.ClassPower then
        TargetInfo.ClassPower:ChangeVOffset(0)
      end
    end
  end

  Nameplate.TargetInfo = TargetInfo

end


local tt = CreateFrame('GameTooltip', 'CinnabarScanningTooltip', Cinnabar.trash, 'GameTooltipTemplate')
tt:SetAlpha(0)
tt:SetOwner(WorldFrame, 'ANCHOR_NONE')
tt:AddFontStrings(
  tt:CreateFontString( "$parentTextLeft1", nil, "GameTooltipText" ),
  tt:CreateFontString( "$parentTextRight1", nil, "GameTooltipText" )
);
tt:RegisterEvent('QUEST_ACCEPTED')
tt:RegisterEvent('QUEST_WATCH_UPDATE')
local function IsQuestMob(unit)
  assert(type(unit) == 'string', 'Function IsQuestMob(unit) expected type \'string\' for argument #1, got ' .. type(unit))

  local function EnumerateTooltipLines_helper(...)
    for i = 1, select("#", ...) do
      local region = select(i, ...)
      if region and region:GetObjectType() == "FontString" then
        local text = region:GetText() -- string or nil
        local i, j = string.find(text or '', '%d+/%d+')

        if not i and not j then i, j = string.find(text or '', '%(%d+%%%)') end
        if i and j then
          -- Check if quest is complete before returning true
          local _, _, left, right = string.find(text or '', '(%d+)/(%d+)')
          if left and right and tonumber(left) == tonumber(right) then return false end
          local _, _, percentage = string.find(text or '', '%((%d+)%%%)')
          if percentage and tonumber(percentage) == 100 then return false end
          return true
        end
      end
    end
    return false
  end
  tt:ClearLines()
  tt:SetUnit(unit)
  return EnumerateTooltipLines_helper(tt:GetRegions())
end

-- Nameplates only update when they are added, removed, or the target is changed, so have to manually update them
-- if a quest is accepted to see if any of the mobs are quest mobs
tt:SetScript('OnEvent', function(self, event)

  for i = 1, 40 do
    local nameplate = _G['CinnabarUI_Nameplate'..i]
    if nameplate then
      if nameplate:IsVisible() then
        if UnitReaction('player', unit) < 5 and not UnitIsPlayer(unit) then
          if IsQuestMob(unit) then
            self.qMarker:Show()
          else
            self.qMarker:Hide()
          end
        end
      end
    end
  end

end)

local function NameplateCallback(self, event, unit)

  if event == 'NAME_PLATE_UNIT_ADDED' then
    self.qMarker:Hide()
    if UnitIsFriend('player', unit) then
      self:ChangeToNameOnly()
    end
    if UnitIsUnit(unit, 'target') then
      Nameplate.TargetInfo:Pin(self)
      Nameplate.TargetInfo:Update(self.Castbar)
    end
    if UnitReaction('player', unit) < 5 and not UnitIsPlayer(unit) then
      if IsQuestMob(unit) then
        self.qMarker:Show()
      end
    end

  elseif event == 'NAME_PLATE_UNIT_REMOVED' then
    self:Reset()
  elseif event == 'PLAYER_TARGET_CHANGED' then
    if UnitIsUnit(unit, 'target') and self then
      Nameplate.TargetInfo:Pin(self)
    else
      Nameplate.TargetInfo:UnPin()
    end
  end

end

local function SetCastbarsColor(castbar, unit)

  local Class = select(2, UnitClass('player'))
  local BgBrightness = 0.3
  local colors = oUF.colors.class[Class]
  castbar:SetStatusBarColor(colors[1], colors[2], colors[3], 1)
  castbar.bg:SetVertexColor(colors[1] * BgBrightness, colors[2] * BgBrightness, colors[3] * BgBrightness, 1)
  return castbar

end

local function CreateCastBar(self, unit)

  local Castbar = CreateFrame('StatusBar', nil, self)
  Castbar:SetPoint('TOPLEFT', self, 'BOTTOMLEFT', 0,  -3)
  Castbar:SetPoint('TOPRIGHT', self, 'BOTTOMRIGHT', 0, -3)
  Castbar:SetHeight(7)
  Castbar:SetStatusBarTexture(default_texture)

  -- Create Castbar background
  Castbar.bg = Castbar:CreateTexture(nil, 'BACKGROUND')
  Castbar.bg:SetAllPoints(Castbar)
  Castbar.bg:SetTexture(default_texture)


  -- Because oUF doesn't set the color of the cast bar automatically, I have to do myself
  Castbar = SetCastbarsColor(Castbar, unit)

  local height = Castbar:GetHeight()

  -- Add a spark
  Castbar.Spark = Castbar:CreateTexture(nil, 'OVERLAY')
  Castbar.Spark:SetSize(height, height)
  Castbar.Spark:SetBlendMode('ADD')
  Castbar.Spark:SetPoint('CENTER', Castbar:GetStatusBarTexture(), 'RIGHT', 0, 0)

  -- Add spell icon
  Castbar.Icon = Castbar:CreateTexture(nil, 'OVERLAY')
  Castbar.Icon:SetSize(height, height)
  Castbar.Icon:SetPoint('TOPLEFT', Castbar, 'TOPLEFT')
  Castbar.Icon:SetPoint('BOTTOMLEFT', Castbar, 'BOTTOMLEFT')

  -- Add Shield
  Castbar.Shield = Castbar:CreateTexture(nil, 'OVERLAY')
  Castbar.Shield:SetSize(height, height)
  Castbar.Shield:SetPoint('CENTER', Castbar, 'LEFT')

  -- Add a timer
  Castbar.Time = Castbar:CreateFontString(nil, 'OVERLAY')
  Castbar.Time:SetFont(default_font, 7, 'OUTLINE')
  Castbar.Time:SetPoint('RIGHT', Castbar)

  -- Add spell text
  Castbar.Text = Castbar:CreateFontString(nil, 'OVERLAY')
  Castbar.Text:SetFont(default_font, 7, 'OUTLINE')
  Castbar.Text:SetPoint('LEFT', Castbar.Icon, 'RIGHT', 2, 0)

  -- Add safezone
  Castbar.SafeZone = Castbar:CreateTexture(nil, 'OVERLAY')
  Castbar.SafeZone:SetColorTexture(1,0.5,0.5) -- Make it a light red so it isn't so intense to look at

  Castbar.Backdrop = CreateFrame("Frame", nil, Castbar, "BackdropTemplate")
  Castbar.Backdrop:SetAllPoints(Castbar)
  Castbar.Backdrop:SetFrameLevel(Castbar:GetFrameLevel() == 0 and 0 or Castbar:GetFrameLevel() - 1)

  Castbar.Backdrop:SetBackdrop {
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
  Castbar.Backdrop:SetBackdropColor(0,0,0, 1)

  function Castbar:PostCastStart(unit)

    Nameplate.TargetInfo:Update(self)

    if self.AlternativePower then
      self.AlternativePower:ClearAllPoints()
      AlternativePower:SetPoint('TOPLEFT', self.Castbar, 'BOTTOMLEFT', 0,  -3)
      AlternativePower:SetPoint('TOPRIGHT', self.Castbar, 'BOTTOMRIGHT', 0, -3)
    end

  end

  function Castbar:PostCastStop(unit)

    Nameplate.TargetInfo:Update(self, true)

    if self.AlternativePower then
      self.AlternativePower:ClearAllPoints()
      AlternativePower:SetPoint('TOPLEFT', self, 'BOTTOMLEFT', 0,  -3)
      AlternativePower:SetPoint('TOPRIGHT', self, 'BOTTOMRIGHT', 0, -3)
    end

  end


  return Castbar

end

local function CreateAuras(self, unit)

  local Debuffs = CreateFrame('Frame', nil, self)
  Debuffs:SetPoint('BOTTOMLEFT', self, 'TOPLEFT', 0, 12)
  Debuffs:SetPoint('BOTTOMRIGHT', self, 'TOPRIGHT', 0, 12)
  Debuffs:SetHeight(16 * 16)
  Debuffs.size = 14
  Debuffs.onlyShowPlayer = true
  Debuffs.disableMouse = false
  Debuffs.spacing = 2

  function Debuffs:PostCreateIcon(button)

    button.Backdrop = CreateFrame("Frame", nil, button, "BackdropTemplate")
    button.Backdrop:SetAllPoints(button)
    button.Backdrop:SetFrameLevel(button:GetFrameLevel() == 0 and 0 or button:GetFrameLevel() - 1)

    button.Backdrop:SetBackdrop {
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
    button.Backdrop:SetBackdropColor(0,0,0, 1)

  end

  return Debuffs

end

local function CreateHealthBar(self, unit)

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
  Health.colorTapping = true
  Health.colorThreat = true

  return Health

end

local function CreateNameplate(self,  unit)

  self:SetSize(width, height)
  self:SetPoint('CENTER')

  self.Health  = CreateHealthBar(self, unit)
  self.Castbar = CreateCastBar  (self, unit)
  self.Debuffs = CreateAuras    (self, unit)

  local RaidTargetIndicator = self:CreateTexture(nil, 'OVERLAY')
  RaidTargetIndicator:SetSize(23, 23)
  RaidTargetIndicator:SetPoint('BOTTOM', self, 'TOP', 0, 20)

  self.RaidTargetIndicator = RaidTargetIndicator

  local AlternativePower = CreateFrame('StatusBar', nil, self)
  AlternativePower:SetHeight(20)
  AlternativePower:SetPoint('TOPLEFT', self, 'BOTTOMLEFT', 0,  -3)
  AlternativePower:SetPoint('TOPRIGHT', self, 'BOTTOMRIGHT', 0, -3)

  self.AlternativePower = AlternativePower

  local SecondaryName = self:CreateFontString(nil, 'ARTWORK')
  SecondaryName:SetFont(default_font, 12, 'OUTLINE')
  SecondaryName:SetPoint('CENTER')
  self:Tag(SecondaryName, '[Cinnabar:NameNameplate]')
  SecondaryName:Hide()
  local SecondaryNameTitle = self:CreateFontString(nil, 'ARTWORK')
  SecondaryNameTitle:SetFont(default_font, 10, 'OUTLINE')
  SecondaryNameTitle:SetPoint('TOP', SecondaryName, 'BOTTOM', 0, -2)


  local name = self.Health:CreateFontString(nil, 'ARTWORK')
  name:SetFont(default_font, 10, 'OUTLINE')
  name:SetPoint('BOTTOM', self, 'TOP', 0, 0)
  self:Tag(name, '[name]')

  local level = self.Health:CreateFontString(nil, 'ARTWORK')
  level:SetFont(default_font, 12, 'OUTLINE')
  level:SetPoint('LEFT', self.Health, 'LEFT', 0, -1)
  self:Tag(level, '[Cinnabar:smartlevel]')

  local perhp = self.Health:CreateFontString(nil, 'ARTWORK')
  perhp:SetFont(default_font, 12, 'OUTLINE')
  perhp:SetPoint('RIGHT', self.Health, 'RIGHT', 0, -1)
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

  -- Create the backdrop
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

  -- Add quest marker
  local qMarker = self:CreateTexture(nil, 'ARTWORK')
  qMarker:SetTexture('Interface\\QUESTFRAME\\QuestTypeIcons')
  qMarker:SetTexCoord(1 / 7, 2 / 7, 0, 1 / 3.5)
  qMarker:SetPoint('RIGHT', self, 'LEFT', 0, 0)
  qMarker:SetSize(16,16)
  self.qMarker = qMarker

  function self:ChangeToNameOnly()

    self.Backdrop:Hide()
    self.Health:Hide()
    self:DisableElement('Castbar')
    self:SetScript('OnEnter', nil)
    SecondaryName:Show()
    SecondaryNameTitle:Show()

  end

  function self:Reset()

    self.Backdrop:Show()
    self.Health:Show()
    self:EnableElement('Castbar')
    self:SetScript('OnEnter', function() self.Highlight:Show() end)
    SecondaryName:Hide()
    SecondaryNameTitle:Hide()

  end

end

function Nameplate:OnInitialize()

  oUF:RegisterStyle("CinnabarNameplate", CreateNameplate)

  oUF:Factory(function(self)

    local cvars = {
      ['nameplateShowAll']        = 1,      -- Shows all Nameplates
      ['nameplateGlobalScale']    = 1,      -- Controls Size of Nameplates
      ['nameplateSelectedScale']  = 1.2,    -- Controls Size of Target's Nameplate
      ['nameplateMotion']         = 1,      -- Whether to stack or overlap nameplates
      ["nameplateMotionSpeed"]    = 0.01,   -- How fast it moves
    }

    self:SetActiveStyle("CinnabarNameplate")
    self:SpawnNamePlates("CinnabarUI_", NameplateCallback, cvars)

  end)

end