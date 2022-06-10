local Cinnabar, Util, Cfg, Module = unpack(select(2,...))

local MODULE_NAME = "UnitFrames"
local NAME = Cinnabar.data.NAME
local oUF = select(2,...).oUF

if false then return end

local function NameplateCallback(self, event, unit)
  if UnitIsUnit(unit, 'target') then
    print(unit)
    self:EnableElement('ClassPower')
    self.ClassPower:ForceUpdate()
  else
    self:DisableElement('ClassPower')
  end
end

local function CreateNameplate(self,  unit)

  local width, height = 85, 10

  self:SetSize(width, height)
  self:SetPoint('CENTER')
  local default_texture = Cinnabar.lsm:Fetch('statusbar', 'Simple')

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

  -- Add class powers (runes, combo points, soul shards, etc)
  local ClassPower = {}
  local max = 6
  for index = 1, max do
    local Bar = CreateFrame('StatusBar', nil, self)
    Bar:SetSize(width / max - 2, 3)
    Bar:SetPoint(
      'TOPLEFT',
      self,
      'BOTTOM',
      ((index - 1) * (Bar:GetWidth() + 2)) - ((Bar:GetWidth() + 2) * (max / 2)) + 1, -- essentially {(bar offset) - [(total width) / 2] + 1}
      -3
    )
    Bar:SetStatusBarTexture(default_texture)
    Bar.bg = Bar:CreateTexture(nil, 'BACKGROUND')
    Bar.bg:SetAllPoints(Bar)
    Bar.bg:SetTexture(default_texture)
    Bar.bg.multiplier = 0.3
    Bar.Backdrop = CreateFrame("Frame", nil, Bar, "BackdropTemplate")
    Bar.Backdrop:SetAllPoints(Bar)
    Bar.Backdrop:SetFrameLevel(Bar:GetFrameLevel() == 0 and 0 or Bar:GetFrameLevel() - 1)

    Bar.Backdrop:SetBackdrop {
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
    Bar.Backdrop:SetBackdropColor(0,0,0, 1)
    ClassPower[index] = Bar
  end

  -- Add all the text

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
  self.ClassPower = ClassPower
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
  self:SetActiveStyle("CinnabarNameplate")
  self:SpawnNamePlates("CinnabarUI_", NameplateCallback)

end)