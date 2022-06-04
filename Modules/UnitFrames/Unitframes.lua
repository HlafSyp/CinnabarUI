local Cinnabar, Util, Cfg, Module = unpack(select(2,...))

local MODULE_NAME = "UnitFrames"
local oUF = select(2,...).oUF
local uf = Module[MODULE_NAME]
uf.Frames = {}
local cfg = Cfg.config.UnitFrames

-- Creates a Statusbar frame, sets the neccessary oUF config options and returns the frame
-- This function will always be called first when it comes to creating Unitframes
---------------------------------------
-- @ARGUMENTS
-- self (table) : This is the frame created by oUF:Spawn(unit)
-- unit (string) : Stringified unit name (player, target, focus, etc)
-- @RETURNS
-- health (table) : Statusbar frame, to be used in driver function to register with oUF
local function CreateHealthBar(self, unit)

  local c = Cfg.config.UnitFrames[unit]

  -- Position and size
  local Health = CreateFrame('StatusBar', nil, self)
  Health:SetHeight(c.HealthBar.Height)
  Health:SetPoint('TOP')
  Health:SetPoint('LEFT')
  Health:SetPoint('RIGHT')
  Health:SetStatusBarTexture(Cinnabar.lsm:Fetch("statusbar", "Simple"))

  -- Add a background
  local Background = Health:CreateTexture(nil, 'BACKGROUND')
  Background:SetAllPoints(Health)
  Background:SetTexture(Cinnabar.lsm:Fetch("statusbar", "Simple"))

  -- Options
  Health.colorTapping = c.HealthBar.colorTapping
  Health.colorDisconnected = c.HealthBar.colorDisconnected
  Health.colorClass = c.HealthBar.colorClass
  Health.colorReaction = c.HealthBar.colorReaction
  Health.colorHealth = c.HealthBar.colorHealth
  Health.Smooth = true

  -- Make the background darker.
  Background.multiplier = c.HealthBar.BgBrightness

  -- Register it with oUF
  Health.bg = Background

  -- If the bar is disabled, hide it, so a reload  isn't needed when it is enabled again
  if not c.HealthBar.Enabled then Health:Hide() end

  return Health

end

-- Creates a Statusbar frame, sets the neccessary oUF config options and returns the frame
-- Pretty much the same thing is CreateHealthBar(self, unit)
---------------------------------------
-- @ARGUMENTS
-- self (table) : This is the frame created by oUF:Spawn(unit)
-- unit (string) : Stringified unit name (player, target, focus, etc)
-- @RETURNS
-- power (table) : Statusbar frame, to be used in driver function to register with oUF
local function CreatePowerBar(self, unit)

  local c = Cfg.config.UnitFrames[unit]


  -- Position and size
  local Power = CreateFrame('StatusBar', nil, self)
  Power:SetHeight(c.PowerBar.Height)
  Power:SetPoint("TOP", self.Health, "BOTTOM", 0, -c.PowerBar.Padding)
  Power:SetPoint("LEFT")
  Power:SetPoint("RIGHT")
  Power:SetStatusBarTexture(Cinnabar.lsm:Fetch("statusbar", "Simple"))

  -- Add a background
  local Background = Power:CreateTexture(nil, 'BACKGROUND')
  Background:SetAllPoints(Power)
  Background:SetTexture(Cinnabar.lsm:Fetch("statusbar", "Simple"))

  -- Options
  Power.frequentUpdates = c.PowerBar.frequentUpdates
  Power.colorTapping = c.PowerBar.colorTapping
  Power.colorDisconnected = c.PowerBar.colorDisconnected
  Power.colorPower = c.PowerBar.colorPower
  Power.colorClass = c.PowerBar.colorClass
  Power.colorReaction = c.PowerBar.colorReaction
  Power.Smooth = true
  -- Make the background darker.
  Background.multiplier = c.PowerBar.BgBrightness

  Power.bg = Background

  -- If user doesn't want the bar, hide it so no reload is needed when they do
  if not c.PowerBar.Enabled then Power:Hide() end

  -- Return it so that the driver function can handle the assignments
  return Power

end

-- Creates a frame, and makes it a backdrop
-- Only serves as aesthetics, but is practically required to have a usable unitframea
---------------------------------------
-- @ARGUMENTS
-- self (table) : Frame to attach backdrop to
-- unit (string) : Stringified unit name (player, target, focus, etc)
-- @RETURNS
-- Backdrop (table) : A black box place behind the given frame
local function CreateBackdrop(self, unit)

  local c = Cfg.config.UnitFrames[unit]

  -- The following code is pretty much ripped from oUF_lumen
  -- It just looks so good, and is a nice base i would say
  local Padding = c.BackdropInset
  local Backdrop = CreateFrame("Frame", nil, self, "BackdropTemplate")
  Backdrop:SetAllPoints(self)
  Backdrop:SetFrameLevel(self:GetFrameLevel() == 0 and 0 or self:GetFrameLevel() - 1)

  Backdrop:SetBackdrop {
    bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
    tile = false,
    tileSize = 0,
    insets = {
      left = -Padding,
      right = -Padding,
      top = -Padding,
      bottom = -Padding,
    }
  }
  Backdrop:SetBackdropColor(0,0,0,c.BackdropOpacity)

  -- Hide the backdrop if it's not enabled
  -- Though, For the backdrop, I don't know why they would
  if not c.EnableBackdrop then Backdrop:Hide() end

  return Backdrop

end

-- Makes the aura bar smaller while keeping the icon the same height
-- Take a look at the oUF_lumen layout for an idea of what this looks like
-- or turn the option to true you dumb dumb
---------------------------------------
-- @ARGUMENTS
-- unit (string) : Stringified unitID (player, target, focus, etc)
-- bar (table) : the bar given to PostCreate(bar) from oUF_AuraBars
local function MakeSmallBar(unit, bar)

  local c = Cfg.config.UnitFrames[unit]

  local pad = c.BackdropInset
  local IsMirrored = c.Mirror
  local p, rT, rP, xO, yO = bar:GetPoint(1)
  bar:ClearAllPoints()
  bar:SetWidth(bar:GetWidth() - (3 * pad))
  bar:SetHeight(c.AuraBar.Height * (3/11))
  bar:SetPoint(p, rT, rP, xO, yO)

  if IsMirrored then
    bar.spelltime:ClearAllPoints()
    bar.spelltime:SetPoint('BOTTOMLEFT', bar, "TOPLEFT", 2, bar.icon:GetHeight() - (bar:GetHeight() * 3 + 2))
    bar.spelltime:SetJustifyH("LEFT")
    bar.spellname:ClearAllPoints()
    bar.spellname:SetPoint("BOTTOMRIGHT", bar, "TOPRIGHT", -2,bar.icon:GetHeight() - (bar:GetHeight() * 3 + 2))
    bar.spellname:SetPoint('LEFT', bar.spelltime, 'RIGHT')
    bar.spellname:SetJustifyH("RIGHT")
  else
    bar.spelltime:ClearAllPoints()
    bar.spelltime:SetPoint('BOTTOMRIGHT', bar, "TOPRIGHT", -2, bar.icon:GetHeight() - (bar:GetHeight() * 3 + 2))
    bar.spelltime:SetJustifyH("RIGHT")
    bar.spellname:ClearAllPoints()
    bar.spellname:SetPoint("BOTTOMLEFT", bar, "TOPLEFT", 2, bar.icon:GetHeight() - (bar:GetHeight() * 3 + 2))
    bar.spellname:SetPoint('RIGHT', bar.spelltime, 'LEFT')
    bar.spellname:SetJustifyH("LEFT")
  end

end

-- Exported to seperate function to keep the PostCreate(unit, bar) function short
-- This is the mirrored section of the PostCreate function
---------------------------------------
-- @ARGUMENTS
-- unit (string) : Stringified unitID (player, target, focus, etc)
-- bar (table) : the bar given to PostCreate(bar)
local function MirroredPostCreate(_, bar)

  -- Have to change the side of every element in the status individually....
  local _, anchor, _, xO, yO = bar:GetPoint(1)
  bar:SetPoint('BOTTOMLEFT', anchor, 'TOPLEFT', xO, yO)
  bar.icon:ClearAllPoints()
  bar.icon:SetPoint("BOTTOM")
  bar.icon:SetPoint("RIGHT", bar:GetParent())
  bar.spelltime:ClearAllPoints()
  bar.spelltime:SetPoint('LEFT', bar, "LEFT", 2, 0)
  bar.spelltime:SetJustifyH("LEFT")
  bar.spellname:ClearAllPoints()
  bar.spellname:SetPoint("RIGHT", bar, "RIGHT", -2, 0)
  bar.spellname:SetPoint('LEFT', bar.spelltime, 'RIGHT')
  bar.spellname:SetJustifyH("RIGHT")

  -- lasty, change orientation of statusbar so it drains left-right
  -- instead of draining right-left
  bar:SetReverseFill(true)

end

-- The main part of the PostCreate(bar) function
-- Became it's own function because of how large it is
-- Takes an extra unit parameter to access the unit specific config
---------------------------------------
-- @ARGUMENTS
-- unit (string) : Stringified unitID (player, target, focus, etc)
-- bar (table) : the bar given to PostCreate(bar)
local function PostCreate(unit, bar)

  local c = Cfg.config.UnitFrames[unit]

  local IsMirrored = c.Mirror
  local IsSmall = c.AuraBar.SmallBar

  -- Set up the stuff for the backdrop
  bar.backdrop = CreateFrame("Frame", nil, bar, "BackdropTemplate")
  bar.backdrop:SetAllPoints(bar)
  bar.backdrop:SetFrameLevel(bar:GetFrameLevel() == 0 and 0 or bar:GetFrameLevel() - 1)
  local pad = c.BackdropInset

  -- Set the backdrop for the main bar
  bar.backdrop:SetBackdrop {
    bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
    tile = false,
    tileSize = 0,
    insets = {
      left = -pad,
      right = -pad,
      top = -pad,
      bottom = -pad,
    }
  }
  -- Make the backdrop black to match the rest of the frame
  bar.backdrop:SetBackdropColor(0,0,0,c.BackdropOpacity)

  -- Create a backdrop for the icon now,
  -- the backdrop is seperated into two so that small bar can be supported
  bar.icon.backdrop = CreateFrame("Frame", nil, bar, "BackdropTemplate")
  bar.icon.backdrop:SetAllPoints(bar.icon)
  bar.icon.backdrop:SetFrameLevel(bar:GetFrameLevel() == 0 and 0 or bar:GetFrameLevel() - 1)
  bar.icon.backdrop:SetBackdrop {
    bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
    tile = false,
    tileSize = 0,
    insets = {
      left = -pad,
      right = -pad,
      top = -pad,
      bottom = -pad,
    }
  }
  bar.icon.backdrop:SetBackdropColor(0,0,0,c.BackdropOpacity)

  -- Reanchor the icon to be on the left edge and bottom edge instead of the left and top by default
  -- this is to allow small bar to function correctly
  bar.icon:ClearAllPoints()
  bar.icon:SetPoint('BOTTOM')
	bar.icon:SetPoint('LEFT', bar:GetParent())
  -- Check if the bars need to be mirrored
  if IsMirrored then

    -- Exported to seperate function cause its a long boi
    MirroredPostCreate(unit, bar)

  end

  if IsSmall then
    MakeSmallBar(unit, bar)
    local p, rT, rP, xO, yO = bar:GetPoint(1)
    bar:ClearAllPoints()
    if rT == bar:GetParent() then
      bar:SetPoint(p, rT, rP, xO, yO)
    else
      bar:SetPoint(p, rT, rP, xO, yO + bar.icon:GetHeight())
    end

  else
    -- Add a gap between the main bar and the icon
    -- This is done in post create cause AuraBars.gap looks like shit
    local p, rT, rP, xO, yO = bar:GetPoint(1)
    bar:ClearAllPoints()
    bar:SetWidth(bar:GetWidth() - (c.BackdropInset * 3))
    bar:SetPoint(p, rT, rP, xO, yO)

  end

  bar.classColored = c.AuraBar.ClassColoredBars


  -- Setup the tooltip for hovering over auras
  bar.cover = CreateFrame("Frame", nil, bar)
  bar.cover:SetPoint("TOPLEFT", bar.icon)
  bar.cover:SetPoint("BOTTOMRIGHT")
  if IsMirrored then
    bar.cover:ClearAllPoints()
    bar.cover:SetPoint("TOPRIGHT", bar.icon)
    bar.cover:SetPoint("BOTTOMLEFT")
  end
  bar.cover:EnableMouse(true)
  bar.cover:SetScript("OnEnter", function(_)
    GameTooltip:SetOwner(bar, "ANCHOR_CURSOR")
    if bar.aura.IsBuff then
      GameTooltip:SetUnitAura(unit, bar.aura.index, 'HELPFUL')
    else
      GameTooltip:SetUnitAura(unit, bar.aura.index, 'HARMFUL')
    end
    GameTooltip:Show()
  end)

  bar.cover:SetScript("OnLeave", function(_)
    GameTooltip:Hide()
  end)

  bar.cover:SetScript("OnMouseUp", function(self, button)
    if unit ~= 'player' then return end
    if button == 'RightButton' then
      CancelUnitBuff(unit, bar.aura.index)
    end
  end)

end
-- 194310 191587
-- Exported to seperate function to keep the PostCreate(unit, bar) function short
-- This is the mirrored section of the PostCreate function
---------------------------------------
-- @ARGUMENTS
-- self (table) : Stringified unitID (player, target, focus, etc)
-- bar (string) : the bar given to PostCreate(bar)
local function CreateAuraBars(self, unit)

  local c = Cfg.config.UnitFrames

  -- Setup AuraBars element
  local AuraBars = CreateFrame("Frame", nil, self)
  AuraBars:SetHeight(6)
  AuraBars:SetWidth(c[unit].Width)
  AuraBars:SetPoint("BOTTOM", self, "TOP")
  -- Set properties
  AuraBars.auraBarHeight = c[unit].AuraBar.Height
  AuraBars.auraBarTexture = Cinnabar.lsm:Fetch("statusbar", "Simple")
  AuraBars.spellTimeFont = Cinnabar.lsm:Fetch("font", "BebasNeue-Regular")
  AuraBars.spellTimeSize = Round(c[unit].AuraBar.Height * 0.7, 0)
  AuraBars.spellNameFont = Cinnabar.lsm:Fetch("font", "BebasNeue-Regular")
  AuraBars.spellNameSize = Round(c[unit].AuraBar.Height * 0.7, 0)
  AuraBars.spacing = c[unit].AuraBar.Spacing
  AuraBars.PostCreateBar = function(bar)
    PostCreate(unit, bar)
  end
  AuraBars.filter = function(name, icon, count, debuffType, duration, expirationTime, unitCaster, isStealable, spellId)

    -- Checks the aura lists that the user has set in their config
    -- Takes the unit it's checking for, and the
    local function CheckLists(unit, ...)
      if c[unit].AuraBar.BypassFilter then
        if not c[unit].AuraBar.ShowNoTimeAuras and expirationTime == 0 then
          return false
        else
          return true
        end
      end
      local name, icon, count, debuffType, duration, expirationTime, unitCaster, isStealable, spellId = ...
      local lists = Cfg.config.UnitFrames[unit].AuraBar.AuraList
      -- Run through all the lists checking to see if the spell ID is in any of them
      for index, val in ipairs(lists) do
        -- Incase the list is actually a function, run the function
        if type(c.Auras[val]) == 'function' then
          return c.Auras[val](...)
        elseif c.Auras[val][spellId] then
          return true
        end
      end

      return false
    end

    return CheckLists(unit, name, icon, count, debuffType, duration, expirationTime, unitCaster, isStealable, spellId)


  end

  return AuraBars

end

-- I really dislike oUF's tag system
-- Like it makes sense but is really cumbersome
-- Anyways, this function Creates a health text which can be assigned to oUF's Tag system
-- in the caller function, I want to keep that functional approach
---------------------------------------
-- @ARGUMENTS
-- healthbar (table)  : The thing which to attach the text to
-- unit      (string) : Stringified version of the unitID (player, target, etc)
-- @RETURNS
-- health   (FontString) : WoW's Fontstring object which is properly aligned
local function AddHealthText(healthbar, unit)

  local c = Cfg.config.UnitFrames[unit]
  local text = healthbar:CreateFontString(nil, 'ARTWORK')
  text:SetFont(Cinnabar.lsm:Fetch('font', 'BebasNeue-Regular'), c.HealthBar.FontSize or Round((c.Width * c.Height) *  (3/1000), 0), 'OUTLINE')

  if healthbar:GetFillStyle() == 'REVERSE' then
    text:SetPoint('LEFT', healthbar, 'LEFT', 2, 0)
  else
    text:SetPoint('RIGHT', healthbar, 'RIGHT', -2, 0)
  end

  function text:SetFontSize(size)

    self:SetFont(Cinnabar.lsm:Fetch('font','BebasNeue-Regular'), size, 'OUTLINE')

  end

  return text

end

-- Creates and aligns the units name and level (if not max level) on the bar
---------------------------------------
-- @ARGUMENTS
-- healthbar (table)  : The thing which to attach the text to
-- unit      (string) : Stringified version of the unitID (player, target, etc)
-- @RETURNS
-- name   (FontString) : WoW's Fontstring object which is properly aligned
local function AddNameText(healthbar, unit)

  local c = Cfg.config.UnitFrames[unit]
  -- local maxlevel = Cinnabar.data.MAX_LEVEL
  local name = healthbar:CreateFontString(nil, 'ARTWORK')
  name:SetFont(Cinnabar.lsm:Fetch('font','BebasNeue-Regular'), c.HealthBar.FontSize or Round((c.Width * c.Height) *  (3/1000), 0), 'OUTLINE')

  -- I hoped this would better align the text with the center of the bar
  -- but it doesn't seem to do anything,
  -- However, because it doesn't do anything, I'll leave it here
  name:SetPoint('BOTTOM')
  name:SetPoint('TOP')
  name:SetJustifyV("CENTER")

  function name:SetFontSize(size)

    self:SetFont(Cinnabar.lsm:Fetch('font','BebasNeue-Regular'), size, 'OUTLINE')

  end

  if c.Mirror then
    name:SetPoint('RIGHT')
  else
    name:SetPoint('LEFT')
  end

  return name

end

-- Creates and aligns the units name and level (if not max level) on the bar
---------------------------------------
-- @ARGUMENTS
-- powerbar (table)  : The thing which to attach the text to
-- unit      (string) : Stringified version of the unitID (player, target, etc)
-- @RETURNS
-- power   (FontString) : WoW's Fontstring object which is properly aligned
local function AddPowerText(powerbar, unit)

  local c = Cfg.config.UnitFrames[unit]
  local power = powerbar:CreateFontString(nil, "ARTWORK")
  power:SetFont(Cinnabar.lsm:Fetch('font', 'BebasNeue-Regular'),  c.PowerBar.FontSize or 13, 'OUTLINE')

  -- Use the long version of SetPoint so I can change alignment correctly cause I know
  -- it will be fucked up guaranteed later
  power:SetPoint("CENTER", powerbar, 'CENTER', 0, 0)

  function power:SetFontSize(size)

    self:SetFont(Cinnabar.lsm:Fetch('font','BebasNeue-Regular'), size, 'OUTLINE')

  end

  return power

end

-- Creates and aligns the units name and level (if not max level) on the bar
---------------------------------------
-- @ARGUMENTS
-- self       (table)  : The thing which to attach the text to
-- unit       (string) : Stringified version of the unitID (player, target, etc)
-- @RETURNS
-- self   (FontString) : This returns the table passed in to the function, modified
local function AddText(self, unit)

  local c = Cfg.config.UnitFrames[unit]

  self.Health.NameText = AddNameText(self.Health, unit)
  self.Health.healthText = AddHealthText(self.Health, unit)

  function self.Health:SetFontSize(size)
    self.NameText:SetFontSize(size)
    self.healthText:SetFontSize(size)
  end
  self:Tag(self.Health.healthText, '[Cinnabar:curhp]')
  self:Tag(self.Health.NameText, "[Cinnabar:smartname]")

  self.Power.PowerText = AddPowerText(self.Power, unit)
  function self.Power:SetFontSize(size)
    self.PowerText:SetFontSize(size)
  end
  self:Tag(self.Power.PowerText, '[Cinnabar:smartpower]')

  -- This return is so unnecessary because lua is modifying the table directly and not a copy of the table
  -- But to keep with the similarity of the other Unit Frame functions
  -- I'll return it anyways
  return self

end

local function SetCastbarsColor(castbar, unit)

  local Class = select(2, UnitClass(unit))
  local BgBrightness = Cfg.config.UnitFrames[unit].CastBar.BgBrightness
  if Class == nil then Class = select(2, UnitClass('player')) end
  local colors = oUF.colors.class[Class]
  castbar:SetStatusBarColor(colors[1], colors[2], colors[3], 1)
  castbar.bg:SetVertexColor(colors[1] * BgBrightness, colors[2] * BgBrightness, colors[3] * BgBrightness, 1)
  return castbar

end

local function CreateCastBar(self, unit)

  local c = Cfg.config.UnitFrames[unit]
  local Castbar = CreateFrame('StatusBar', nil, self)
  Castbar:SetSize(c.CastBar.Width, c.CastBar.Height)
  Castbar:SetPoint(c.CastBar.Point,
                _G[c.CastBar.relativeTo],
                   c.CastBar.relativePoint,
                   c.CastBar.xOffset,
                   c.CastBar.yOffset)

  Castbar:SetStatusBarTexture(Cinnabar.lsm:Fetch('statusbar', 'Simple'))

  -- Create Castbar background
  Castbar.bg = Castbar:CreateTexture(nil, 'BACKGROUND')
  Castbar.bg:SetAllPoints(Castbar)
  Castbar.bg:SetTexture(Cinnabar.lsm:Fetch('statusbar', 'Simple'))


  -- Because oUF doesn't set the color of the cast bar automatically, I have to do myself
  Castbar = SetCastbarsColor(Castbar, unit)

  -- Add a spark
  Castbar.Spark = Castbar:CreateTexture(nil, 'OVERLAY')
  Castbar.Spark:SetSize(c.CastBar.Height, c.CastBar.Height)
  Castbar.Spark:SetBlendMode('ADD')
  Castbar.Spark:SetPoint('CENTER', Castbar:GetStatusBarTexture(), 'RIGHT', 0, 0)

  -- Add spell icon
  Castbar.Icon = Castbar:CreateTexture(nil, 'OVERLAY')
  Castbar.Icon:SetSize(c.CastBar.Height, c.CastBar.Height)
  Castbar.Icon:SetPoint('TOPLEFT', Castbar, 'TOPLEFT')
  Castbar.Icon:SetPoint('BOTTOMLEFT', Castbar, 'BOTTOMLEFT')

  -- Add Shield
  Castbar.Shield = Castbar:CreateTexture(nil, 'OVERLAY')
  Castbar.Shield:SetSize(c.CastBar.Height, c.CastBar.Height)
  Castbar.Shield:SetPoint('CENTER', Castbar)

  -- Add a timer
  Castbar.Time = Castbar:CreateFontString(nil, 'OVERLAY')
  Castbar.Time:SetFont(Cinnabar.lsm:Fetch('font', 'BebasNeue-Regular'), 13, 'OUTLINE')
  Castbar.Time:SetPoint('RIGHT', Castbar)

  -- Add spell text
  Castbar.Text = Castbar:CreateFontString(nil, 'OVERLAY')
  Castbar.Text:SetFont(Cinnabar.lsm:Fetch('font', 'BebasNeue-Regular'), 13, 'OUTLINE')
  Castbar.Text:SetPoint('LEFT', Castbar.Icon, 'RIGHT', 2, 0)

  -- Add safezone
  Castbar.SafeZone = Castbar:CreateTexture(nil, 'OVERLAY')
  Castbar.SafeZone:SetColorTexture(1,0.5,0.5) -- Make it a light red so it isn't so intense to look at

  Castbar.backdrop = CreateBackdrop(Castbar, unit)
  Castbar.PostCastStart = function(_)
    if c.CastBar.Enabled then Castbar:Hide() end
    if Castbar.notInterruptible == true then
      local rgb =  {c.CastBar.UninteruptibleColors[1],
                    c.CastBar.UninteruptibleColors[2],
                    c.CastBar.UninteruptibleColors[3]}
      local BgBrightness = c.CastBar.BgBrightness
      Castbar:SetStatusBarColor(rgb[1], rgb[2], rgb[3], 1)
      Castbar.bg:SetVertexColor(rgb[1] * BgBrightness, rgb[2] * BgBrightness, rgb[3] * BgBrightness, 1)
    else
      Castbar = SetCastbarsColor(Castbar, unit)
    end
  end

  -- if not c.CastBar.Enabled then Castbar:Hide() end
  return Castbar

end

function uf.SetFrameMovable(self)

  if type(self) == 'string' then self = uf.Frames[self] end

  self:SetMovable(true)
  self:RegisterForDrag("LeftButton")
  self:SetClampedToScreen(true)
  self:HookScript("OnDragStart", function()
    self:StartMoving()
  end)
  self:HookScript("OnDragStop", function()
    self:StopMovingOrSizing()
    local p, rT, rP, xO, yO = self:GetPoint()
    Cfg.config.UnitFrames[self.unit].Anchor = p
    Cfg.config.UnitFrames[self.unit].ParentAnchor = rP
    Cfg.config.UnitFrames[self.unit].OffsetX = xO
    Cfg.config.UnitFrames[self.unit].OffsetY = yO
    Cfg:SaveProfile(Cfg.current_profile)
  end)

  return self

end

function uf:Refresh()


end

-- The main call used by core to register all the units
-- Used more as a wrapper function to easily break apart each part of the unit frame
---------------------------------------
-- @ARGUMENTS
-- unit (string) : Stringified version of the unit
--                 eg.) player, target, focus, etc
-- @RETURNS
-- unit (table) : Returns the frame the unit's frame is built upon
function uf:RegisterUnit(self, unit)


  local c = Cfg.config.UnitFrames[unit]

  self:EnableMouse(true)
  self:SetSize(c.Width, c.Height)
  self:SetPoint(c.Anchor, _G[c.ParentFrame], c.ParentAnchor, c.OffsetX, c.OffsetY)
  self.Health = CreateHealthBar(self, unit)
  self.Power = CreatePowerBar(self, unit)
  self.Castbar = CreateCastBar(self, unit)
  self.Backdrop = CreateBackdrop(self, unit)
  self.AuraBars = CreateAuraBars(self, unit)
  self.unit = unit
-- Mirror the bars before adding text so the text can be properly alligned in their respective functions
  if c.Mirror then
    self.Health:SetReverseFill(true)
    self.Power:SetReverseFill(true)
  end

  if not c.Lock then
    self = uf.SetFrameMovable(self)
  end

  -- Create the text elements
  self = AddText(self, unit)

  -- Setup mouseover highlight stuff
  self.Highlight = CreateFrame("Frame", nil, self)
  self.Highlight:SetAllPoints(self)
  self.Highlight.tex = self.Highlight:CreateTexture(nil, "OVERLAY")
  self.Highlight.tex:SetAllPoints(self.Highlight)
  self.Highlight.tex:SetColorTexture(1,1,1,c.HighlightOpacity)

  self:HookScript("OnEnter", function ()
      self.Highlight:Show()

      -- Need to default to UIParent in case the Tooltip Module is disabled
      local anchor = UIParent
      if Cinnabar:GetModule("Tooltip"):IsEnabled() then anchor = CinnabarTooltipAnchor end
      GameTooltip_SetDefaultAnchor(GameTooltip, anchor)
      GameTooltip:SetUnit(unit)
      GameTooltip:Show()
  end)
  self:HookScript("OnLeave", function ()
      self.Highlight:Hide()
      GameTooltip:Hide()
  end)
  self.Highlight:Hide()

  -- Hide the unitframe if user doesn't want frame to be created
  if not Cfg.config.UnitFrames.Units[unit] then self:Hide() end


end

---------------------------------------
-- oUF Stuff
-- Essentially Starts up oUF and creates the unit frames
---------------------------------------
local Shared = function(self, unit)
	-- Shared layout code.
    uf:RegisterUnit(self, unit)


end

function uf:OnInitialize()

  oUF:RegisterStyle("Cinnabar", Shared)
  Cfg:RegisterModuleWithCinnabar(
    {
      [string.lower(MODULE_NAME)] = uf.CreateUnitFrameMenu,
      ['units'] = uf.CreateUnitsMenu,
      ['percentagepower'] = uf.CreatePercPowerMenu,
      ['auras'] = uf.CreateAurasMenu
    },
    uf.Refresh,
    MODULE_NAME,
    {
      value = "unitframes",
      text = "UnitFrames",
      children = {
        {
          value = 'units',
          text = 'Units',
        },
        {
          value = 'percentagepower',
          text = 'Power as Percentage',
        },
        {
          value = 'auras',
          text = 'Buffs/Debuffs',
        }
      }
    }
  )

  -- If user doesn't want this module enabled then return early
  if Cfg.config.Modules["UnitFrames"] == false then uf:Disable() end

end

function uf:OnEnable()

  -- If user doesn't want this module enabled then return early
  if not Cfg.config.Modules["UnitFrames"] then return end

  -- For some reason, I can't just place uf.RegisterUnit as the shared function
  -- So I'll keep using the wrapper function and just route the call to the  proper function

  oUF:Factory(function(self)

      self:SetActiveStyle("Cinnabar")

      local SingleUnits = {
        "player",
        "target",
        "targettarget",
        "focus",
        "focustarget",
        "pet",
    }

      for i, v in ipairs(SingleUnits) do
          -- Because I'm Still developing this stuff, I need to check to make sure the config stuff is actually there lol
          -- And you bet I'm leaving this in during release
          if Cfg.config.UnitFrames.Units[v] and Cfg.config.UnitFrames[v].Width ~= nil then
              uf.Frames[v] = self:Spawn(v)
          end
      end

  end)

end