local Cinnabar, _, Cfg, Module = unpack(select(2,...))

-- If user doesn't want this module enabled then return early
if not true--[[Cfg.config.Modules["UnitFrames"]--]] then return end

local oUF = select(2,...).oUF
local uf = Module["UnitFrames"]
uf.Frames = {}
local cfg = Cfg:GetValue("UnitFrames")


-- Local Declarations
-- luacheck: push ignore
local CreateFrame, UnitClass = CreateFrame, UnitClass
local GameTooltip_SetDefaultAnchor, GameTooltip = GameTooltip_SetDefaultAnchor, GameTooltip
local UIParent = UIParent
local Round = Round
--luacheck: pop

-- Creates a Statusbar frame, sets the neccessary oUF config options and returns the frame
-- This function will always be called first when it comes to creating Unitframes

-- @ARGUMENTS
-- self (table) : This is the frame created by oUF:Spawn(unit)
-- unit (string) : Stringified unit name (player, target, focus, etc)
-- @RETURNS
-- health (table) : Statusbar frame, to be used in driver function to register with oUF
local function CreateHealthBar(self, unit)

  local c = cfg[unit].HealthBar

  -- Position and size
  local Health = CreateFrame('StatusBar', nil, self)
  Health:SetHeight(c.Height)
  Health:SetPoint('TOP')
  Health:SetPoint('LEFT')
  Health:SetPoint('RIGHT')
  Health:SetStatusBarTexture(Cinnabar.lsm:Fetch("statusbar", "Simple"))

  -- Add a background
  local Background = Health:CreateTexture(nil, 'BACKGROUND')
  Background:SetAllPoints(Health)
  Background:SetTexture(Cinnabar.lsm:Fetch("statusbar", "Simple"))

  -- Options
  Health.colorTapping = c.colorTapping
  Health.colorDisconnected = c.colorDisconnected
  Health.colorClass = c.colorClass
  Health.colorReaction = c.colorReaction
  Health.colorHealth = c.colorHealth
  Health.Smooth = true

  -- Make the background darker.
  Background.multiplier = c.BgBrightness

  -- Register it with oUF
  Health.bg = Background

  -- If the bar is disabled, hide it, so a reload  isn't needed when it is enabled again
  if not c.Enabled then Health:Hide() end

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

  local c = cfg[unit].PowerBar


  -- Position and size
  local Power = CreateFrame('StatusBar', nil, self)
  Power:SetHeight(c.Height)
  Power:SetPoint("TOP", self.Health, "BOTTOM", 0, -c.Padding)
  Power:SetPoint("LEFT")
  Power:SetPoint("RIGHT")
  Power:SetStatusBarTexture(Cinnabar.lsm:Fetch("statusbar", "Simple"))

  -- Add a background
  local Background = Power:CreateTexture(nil, 'BACKGROUND')
  Background:SetAllPoints(Power)
  Background:SetTexture(Cinnabar.lsm:Fetch("statusbar", "Simple"))

  -- Options
  Power.frequentUpdates = c.frequentUpdates
  Power.colorTapping = c.colorTapping
  Power.colorDisconnected = c.colorDisconnected
  Power.colorPower = c.colorPower
  Power.colorClass = c.colorClass
  Power.colorReaction = c.colorReaction
  Power.Smooth = true
  -- Make the background darker.
  Background.multiplier = c.BgBrightness

  Power.bg = Background

  -- If user doesn't want the bar, hide it so no reload is needed when they do
  if not c.Enabled then Power:Hide() end

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

  -- The following code is pretty much ripped from oUF_lumen
  -- It just looks so good, and is a nice base i would say
  local c = cfg[unit]
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

  local pad = cfg[unit].BackdropInset
  local IsMirrored = cfg[unit].Mirror
  local p, rT, rP, xO, yO = bar:GetPoint(1)
  bar:ClearAllPoints()
  bar:SetWidth(bar:GetWidth() - (3 * pad))
  bar:SetHeight(cfg[unit].AuraBar.Height * (3/11))
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

  local IsMirrored = cfg[unit].Mirror
  local IsSmall = cfg[unit].AuraBar.SmallBar

  -- Set up the stuff for the backdrop
  bar.backdrop = CreateFrame("Frame", nil, bar, "BackdropTemplate")
  bar.backdrop:SetAllPoints(bar)
  bar.backdrop:SetFrameLevel(bar:GetFrameLevel() == 0 and 0 or bar:GetFrameLevel() - 1)
  local pad = cfg[unit].BackdropInset

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
  bar.backdrop:SetBackdropColor(0,0,0,cfg.BackdropOpacity)

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
  bar.icon.backdrop:SetBackdropColor(0,0,0,cfg.BackdropOpacity)

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
    bar:SetWidth(bar:GetWidth() - (cfg.BackdropInset * 3))
    bar:SetPoint(p, rT, rP, xO, yO)

  end

  bar.classColored = cfg[unit].AuraBar.ClassColoredBars


  -- Setup the tooltip for hovering over auras
  bar:EnableMouse()
  bar:SetScript("OnEnter", function(_)
    GameTooltip:SetUnitAura(unit, bar.aura.index)
    GameTooltip:SetOwner(bar, "ANCHOR_TOP")
  end)

  bar:SetScript("OnLeave", function(_)
    GameTooltip:Hide()
  end)

end

-- Exported to seperate function to keep the PostCreate(unit, bar) function short
-- This is the mirrored section of the PostCreate function
---------------------------------------
-- @ARGUMENTS
-- self (table) : Stringified unitID (player, target, focus, etc)
-- bar (string) : the bar given to PostCreate(bar)
local function CreateAuraBars(self, unit)

  local c = cfg[unit]

  -- Setup AuraBars element
  local AuraBars = CreateFrame("Frame", nil, self)
  AuraBars:SetHeight(6)
  AuraBars:SetWidth(c.Width)
  AuraBars:SetPoint("BOTTOM", self, "TOP")
  -- Set properties
  AuraBars.auraBarHeight = c.AuraBar.Height
  AuraBars.auraBarTexture = Cinnabar.lsm:Fetch("statusbar", "Simple")
  AuraBars.spellTimeFont = Cinnabar.lsm:Fetch("font", "BebasNeue-Regular")
  AuraBars.spellTimeSize = Round(c.AuraBar.Height * 0.7, 0)
  AuraBars.spellNameFont = Cinnabar.lsm:Fetch("font", "BebasNeue-Regular")
  AuraBars.spellNameSize = Round(c.AuraBar.Height * 0.7, 0)
  AuraBars.spacing = c.AuraBar.Spacing
  AuraBars.PostCreateBar = function(bar)
    PostCreate(unit, bar)
  end
  AuraBars.filter = function(_,_,_, _, _, _, _, _, spellId)

    local Auras = cfg.Auras
    -- I turn  unit into a lowercase string cause I want to make 100% sure the string will match my condition
    -- I'm pretty sure oUF gives me an all lowercase string anyways but can never be to safe
    if string.lower(unit) == 'player' then
      return (Auras.CB[spellId] or Auras.B[spellId] or Auras.D[spellId]) and true
    elseif string.lower(unit) == 'target' then
      return  (Auras.CB[spellId]
            or Auras.CD[spellId]
            or Auras.B[spellId]
            or Auras.D[spellId]
            or Auras.RD[spellId])
            and true
    end


  end

  if not c.AuraBar.Enabled then AuraBars:Hide() end

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

  local c = cfg[unit]
  local text = healthbar:CreateFontString(nil, 'ARTWORK')
  text:SetFont(Cinnabar.lsm:Fetch('font', 'BebasNeue-Regular'), Round((c.Width * c.Height) *  (3/1000), 0), 'OUTLINE')

  if healthbar:GetFillStyle() == 'REVERSE' then
    text:SetPoint('LEFT', healthbar, 'LEFT', 2, 0)
  else
    text:SetPoint('RIGHT', healthbar, 'RIGHT', -2, 0)
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

  local c = cfg[unit]
  -- local maxlevel = Cinnabar.data.MAX_LEVEL
  local name = healthbar:CreateFontString(nil, 'ARTWORK')
  name:SetFont(Cinnabar.lsm:Fetch('font','BebasNeue-Regular'), Round((c.Width * c.Height) *  (3/1000), 0), 'OUTLINE')

  -- I hoped this would better align the text with the center of the bar
  -- but it doesn't seem to do anything,
  -- However, because it doesn't do anything, I'll leave it here
  name:SetPoint('BOTTOM')
  name:SetPoint('TOP')
  name:SetJustifyV("CENTER")

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
local function AddPowerText(powerbar, _)

  -- local c = cfg[unit]
  local power = powerbar:CreateFontString(nil, "ARTWORK")
  power:SetFont(Cinnabar.lsm:Fetch('font', 'BebasNeue-Regular'), 13, 'OUTLINE')

  -- Use the long version of SetPoint so I can change alignment correctly cause I know
  -- it will be fucked up guaranteed later
  power:SetPoint("CENTER", powerbar, 'CENTER', 0, 0)

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

  local c = cfg[unit]

  self.Health.NameText = AddNameText(self.Health, unit)
  self.Health.healthText = AddHealthText(self.Health, unit)
  local Shorten, precision = c.HealthBar.ShortenHealthText, c.HealthBar.HealthTextPrecision
  local Mirror, ColorText = c.Mirror, c.HealthBar.ColorLevelText
  -- This is a shit work around to not being able to concatenate boolean values to strings
  if Shorten then Shorten = 'true'
  else Shorten = 'false' end
  if ColorText then ColorText = 'true'
  else ColorText = 'false' end
  if Mirror then Mirror = 'true'
  else Mirror = 'false' end

  self:Tag(self.Health.healthText, '[Cinnabar:curhp(' .. Shorten .. ', ' .. precision .. ')]')
  self:Tag(self.Health.NameText, string.format("[Cinnabar:smartname(%s,%s)]", ColorText, Mirror))

  self.Power.PowerText = AddPowerText(self.Power, unit)
  self:Tag(self.Power.PowerText, '[Cinnabar:smartpower]')

  -- This return is so unnecessary because lua is modifying the table directly and not a copy of the table
  -- But to keep with the similarity of the other Unit Frame functions
  -- I'll return it anyways
  return self

end

local function SetCastbarsColor(castbar, unit)

  local Class = select(2, UnitClass(unit))
  local BgBrightness = cfg[unit].CastBar.BgBrightness
  if Class == nil then Class = select(2, UnitClass('player')) end
  local colors = oUF.colors.class[Class]
  castbar:SetStatusBarColor(colors[1], colors[2], colors[3], 1)
  castbar.bg:SetVertexColor(colors[1] * BgBrightness, colors[2] * BgBrightness, colors[3] * BgBrightness, 1)
  return castbar

end

local function CreateCastBar(self, unit)

  local c = cfg[unit]
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

  if not c.CastBar.Enabled then Castbar:Hide() end
  return Castbar

end

-- The main call used by core to register all the units
-- Used more as a wrapper function to easily break apart each part of the unit frame
---------------------------------------
-- @ARGUMENTS
-- unit (string) : Stringified version of the unit
--                 eg.) player, target, focus, etc
-- @RETURNS
-- unit (table) : Returns the frame the unit's frame is built upon
-- luacheck: ignore self
function uf:RegisterUnit(self, unit)


  local c = cfg[unit]

  self:EnableMouse(true)
  self:SetSize(c.Width, c.Height)
  self:SetPoint(c.Anchor, _G[c.ParentFrame], c.ParentAnchor, c.OffsetX, c.OffsetY)
  self.Health = CreateHealthBar(self, unit)
  self.Power = CreatePowerBar(self, unit)
  self.Castbar = CreateCastBar(self, unit)
  self.Backdrop = CreateBackdrop(self, unit)
  self.AuraBars = CreateAuraBars(self, unit)
-- Mirror the bars before adding text so the text can be properly alligned in their respective functions
  if c.Mirror then
    self.Health:SetReverseFill(true)
    self.Power:SetReverseFill(true)
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
      GameTooltip_SetDefaultAnchor(GameTooltip, UIParent)
      GameTooltip:SetUnit(unit)
      GameTooltip:Show()
  end)
  self:HookScript("OnLeave", function ()
      self.Highlight:Hide()
      GameTooltip:Hide()
  end)
  self.Highlight:Hide()


  -- Hide the unitframe if user doesn't want frame to be created
  if not cfg.Units[unit] then self:Hide() end


end

---------------------------------------
-- oUF Stuff
-- Essentially Starts up oUF and creates the unit frames
---------------------------------------
local Shared = function(self, unit)
	-- Shared layout code.
    uf:RegisterUnit(self, unit)


end

-- For some reason, I can't just place uf.RegisterUnit as the shared function
-- So I'll keep using the wrapper function and just route the call to the  proper function
oUF:RegisterStyle("Blu", Shared)
oUF:Factory(function(self)

    self:SetActiveStyle("Blu")

    local SingleUnits = {
      "player",
      "target",
      "targettarget",
      "focus",
      "focustarget",
      "pet",
  }

    for i=1, #SingleUnits do
        -- Because I'm Still developing this stuff, I need to check to make sure the config stuff is actually there lol
        -- And you bet I'm leaving this in during release
        if cfg.Units[SingleUnits[i]] and cfg[SingleUnits[i]].Width ~= nil then
            uf.Frames[SingleUnits[i]] = self:Spawn(SingleUnits[i])
        end
    end

end)