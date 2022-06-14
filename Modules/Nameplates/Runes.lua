local Cinnabar, Util, Cfg, Module = unpack(select(2,...))

-- If the player isn't on a death knight
-- Don't Run this file
local _, PlayerClass = UnitClass('player')
if PlayerClass ~= 'DEATHKNIGHT' then
    return
end

local MODULE_NAME = "Nameplates"
local NAME = Cinnabar.data.NAME
local Nameplate = Module[MODULE_NAME]
local TargetInfo = Nameplate.TargetInfo
local default_texture = Cinnabar.lsm:Fetch('statusbar', 'Simple')
local default_font = Cinnabar.lsm:Fetch('font', 'BebasNeue-Regular')
local Colors = {
  {247 / 255,  65 / 255,  57 / 255},  -- blood
  {148 / 255, 203 / 255, 247 / 255},  -- frost
  {173 / 255, 235 / 255,  66 / 255},  -- unholy
}

local Runes = {}

local height = 3

-- Create the runes
do
  local w = TargetInfo:GetWidth()
  for i = 1, 6 do
    local bar = CreateFrame('StatusBar', nil, TargetInfo)
    local Width = w / 6 - 3
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
    Runes[i] = bar
  end
end

function Runes:Map(func)

  assert(type(func) == 'function', 'Usage: Runes:Map(func) expected type \'function\' for argument #1, got ' .. type(func))
  for i = 1, 6 do
    func(Runes[i])
  end

end

function Runes:UpdateColor()

  local Spec = GetSpecialization()
  local r,g,b = unpack(Colors[Spec] or colors.power.RUNES)
  Runes:Map(function(rune)

    rune:SetStatusBarColor(r,g,b, 1)
    rune.bg:SetVertexColor(r * 0.7,g * 0.7,b * 0.7, 1)

  end)

end

function Runes:Update()

  local rune, start, dur, runeReady
  for i = 1, 6 do
    rune = Runes[i]
    if not rune then break end
    if(UnitHasVehicleUI('player')) then
      rune:Hide()
    else
      start, dur, runeReady = GetRuneCooldown(i)
      if(runeReady) then
        rune:SetMinMaxValues(0, 1)
        rune:SetValue(1)
        rune:SetScript('OnUpdate', nil)
      elseif(start) then
        rune.duration = GetTime() - start
        rune:SetMinMaxValues(0, dur)
        rune:SetValue(0)
        rune:SetScript('OnUpdate', function(self, elapsed)
          local duration = self.duration + elapsed
          self.duration = duration
          self:SetValue(duration)
        end)
      end
      rune:Show()
    end
  end

end

Runes:UpdateColor()
TargetInfo:RegisterEvent('PLAYER_SPECIALIZATION_CHANGED')
TargetInfo:RegisterEvent('RUNE_POWER_UPDATE')
TargetInfo:HookScript('OnEvent', function(self, event)
  if event == 'PLAYER_SPECIALIZATION_CHANGED' then
    Runes:UpdateColor()
  elseif event == 'RUNE_POWER_UPDATE' then
    Runes:Update()
  end
end)
TargetInfo.Runes = Runes