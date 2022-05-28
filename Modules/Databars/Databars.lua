local Cinnabar, Util, Cfg, Module = unpack(select(2,...))

-- Store the bars locally so that I can assign the proper values when the player logs in
local Bars = Module["Databar"]

-- [TODO] (HlafSyp) 5/28/22 : Add a system to allow databars to track any info
--                            so users can custom make any number of databars
-- [TODO] (HlafSyp) 5/28/22 : Add the reputation bar databar

-- Creates a basic status bar styled in the UI's style
-- with min/max values of [0,1]
---------------------------------------
-- @RETURNS
-- bar  (table) : The status bar created
local function CreateStatusBar(enableBackdrop, parent)

  local bar = CreateFrame("StatusBar", nil, parent)
  bar:SetStatusBarTexture(Cinnabar.lsm:Fetch("statusbar", "Simple"))
  bar:SetMinMaxValues(0, 1)
  bar:SetValue(0)
  bar:SetFillStyle('STANDARD_NO_RANGE_FILL')
  bar:SetFrameLevel(1)

  -- Add a background
  bar.background = bar:CreateTexture(nil, 'BACKGROUND')
  bar.background:SetAllPoints(bar)
  bar.background:SetTexture(Cinnabar.lsm:Fetch("statusbar", "Simple"))

  -- If no backdrop is wanted, return the bar before it is created
  if enableBackdrop == false then return bar end

  bar.backdrop = CreateFrame("Frame", nil, bar, "BackdropTemplate")
  bar.backdrop:SetAllPoints(bar)
  bar.backdrop:SetFrameLevel(bar:GetFrameLevel() == 0 and 0 or bar:GetFrameLevel() - 1)
  bar.backdrop:SetBackdrop {
    bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
    tile = false,
    tileSize = 0,
    insets = {
      left = -2,
      right = -2,
      top = -2,
      bottom = -2,
    }
  }
  bar.backdrop:SetBackdropColor(0,0,0,1)

  return bar

end

-- Creates a Status bar which tracks the honor level of the character
---------------------------------------
-- @RETURNS
-- honor  (table) : A status bar tracking honor level
local function CreateHonorBar()

  -- Create a wrapper for the honor bar that holds a few helper functions
  -- for the functionality of the databar
  local cfg = Cfg.config.Databar.HonorBar
  local honor = {}
  honor.bar = CreateStatusBar()

  -- Setup the initial values of the honor bar
  honor.bar:SetStatusBarColor(cfg.Colors.r, cfg.Colors.g, cfg.Colors.b)
  honor.bar.background:SetVertexColor(
    cfg.Colors.r * cfg.BgBrightness,
    cfg.Colors.g * cfg.BgBrightness,
    cfg.Colors.b * cfg.BgBrightness,
    1
  )
  honor.bar:SetMinMaxValues(0, UnitHonorMax('player'))
  honor.bar:SetValue(UnitHonor('player'))
  honor.bar:SetSize(cfg.Width, cfg.Height)
  honor.bar:SetPoint(cfg.Point, cfg.relativeTo, cfg.relativePoint, cfg.xOffset, cfg.yOffset)

  -- Enable the honor bar to track the changes to Honor
  honor.bar:RegisterEvent("HONOR_LEVEL_UPDATE") -- Fires when honor level is changed
  honor.bar:RegisterEvent("HONOR_XP_UPDATE")    -- Fires when the amount of honor is changed
  honor.bar:SetScript("OnEvent", function(self, event, ...)
  honor.bar:SetMinMaxValue(0, UnitHonorMax('player'))
  honor.bar:SetValue(UnitHonor('player'))
  end)

  honor.bar:EnableMouse(true)

  -- Register Tooltip Function
  function honor.ShowTooltip()
    local xpCur, xpMax, level = UnitHonor('player'), UnitHonorMax('player'), UnitHonorLevel('player')
    local nL = C_PvP.GetNextHonorLevelForReward(level)
    GameTooltip:SetOwner(honor.bar, 'ANCHOR_CURSOR')
    GameTooltip:AddLine("Honor Level " .. level)
    GameTooltip:AddDoubleLine(
      "Honor:",                                                       -- Left
      Util:FormatNumber(xpCur) .. '/' .. Util:FormatNumber(xpMax),    -- Right
      nil, nil, nil,                                                  -- Left  Text Color
      1, 1, 1                                                         -- Right Text Color
    )
    if nL ~= nil then
      GameTooltip:AddLine(" ")
      GameTooltip:AddLine("Next Reward at Honor Level " .. nL)
    end
      GameTooltip:Show()

  end

  -- Setup OnEnter/OnLeave script handlers
  honor.bar:SetScript("OnEnter", honor.ShowTooltip)
  honor.bar:SetScript("OnLeave", function() GameTooltip:Hide() end)

end

-- Creates a Status bar which tracks the experience level of the character
---------------------------------------
-- @RETURNS
-- xp     (table) : A status bar tracking xp of a character
local function CreateXPBar()

  local level = UnitLevel('player')
  -- if the player is max level, no reason to display the bar
  if level == Cinnabar.data.MAX_LEVEL then return end

  -- Create a wrapper for the xp bar that holds a few helper functions
  -- for the functionality of the databar
  local cfg = Cfg.config.Databar.XPBar
  local xp = {}
  xp.bar = CreateStatusBar()

  -- Setup the rested XP portion of the bar
  xp.rested = CreateStatusBar(false, xp.bar)
  xp.rested:SetPoint("LEFT", xp.bar:GetStatusBarTexture(), "RIGHT")
  xp.rested:SetPoint("RIGHT", xp.bar)
  xp.rested:SetPoint("TOP", xp.bar)
  xp.rested:SetPoint("BOTTOM", xp.bar)
  xp.rested:SetMinMaxValues(0, UnitXPMax('player') - UnitXP('player'))
  xp.rested:SetValue(GetXPExhaustion() or 0)
  xp.rested:SetStatusBarColor(0, 0.39, 0.88)
  xp.rested.background:SetVertexColor(1,1,1,0) -- The helper function I created adds a background so just hide it

  -- Setup the initial values of the xp bar
  xp.bar:SetStatusBarColor(cfg.Colors.r, cfg.Colors.g, cfg.Colors.b)
  xp.bar.background:SetVertexColor(
    cfg.Colors.r * cfg.BgBrightness,
    cfg.Colors.g * cfg.BgBrightness,
    cfg.Colors.b * cfg.BgBrightness,
    1
  )
  xp.bar:SetMinMaxValues(0, UnitXPMax('player'))
  xp.bar:SetValue(UnitXP('player'))
  xp.bar:SetSize(cfg.Width, cfg.Height)
  xp.bar:SetPoint(cfg.Point, cfg.relativeTo, cfg.relativePoint, cfg.xOffset, cfg.yOffset)

  -- Enable the xp bar to track the changes to xp and level
  xp.bar:RegisterEvent("PLAYER_LEVEL_UP")     -- Fires when the character levels up
  xp.bar:RegisterEvent("PLAYER_XP_UPDATE")    -- Fires when the player gains xp
  xp.bar:RegisterEvent("PLAYER_UPDATE_RESTING")
  xp.bar:SetScript("OnEvent", function(self, event, ...)
    if UnitLevel('player') == Cinnabar.data.MAX_LEVEL then xp.bar:Hide() end
    xp.bar:SetMinMaxValues(0, UnitXPMax('player'))
    xp.bar:SetValue(UnitXP('player'))
    xp.rested:SetMinMaxValues(0, UnitXPMax('player') - UnitXP('player'))
    xp.rested:SetValue(GetXPExhaustion() or 0)
  end)

  xp.bar:EnableMouse(true)

  -- Register Tooltip Function
  function xp.ShowTooltip()
    local xpCur, xpMax, level = UnitXP('player'), UnitXPMax('player'), UnitLevel('player')
    local rested = GetXPExhaustion()
    GameTooltip:SetOwner(xp.bar, 'ANCHOR_CURSOR')
    GameTooltip:AddLine("Level " .. level)
    GameTooltip:AddDoubleLine(
      "Experience:",                                                  -- Left
      Util:FormatNumber(xpCur) .. '/' .. Util:FormatNumber(xpMax),    -- Right
      nil, nil, nil,                                                  -- Left  Text Color
      1, 1, 1                                                         -- Right Text Color
    )
    if rested then
      GameTooltip:AddDoubleLine(
        "Rested XP:",
        Util:FormatNumber(GetXPExhaustion()),
        nil, nil, nil,
        1, 1, 1
      )
  end
    GameTooltip:Show()

  end

  xp.bar:SetScript("OnEnter", xp.ShowTooltip)
  xp.bar:SetScript("OnLeave", function() GameTooltip:Hide() end)


end

-- Creates a Status bar which tracks the tracked reputation
---------------------------------------
-- @RETURNS
-- rep    (table) : A status bar tracking reputation
local function CreateReputationBar()



end

function Bars:OnInitialize()



end

function Bars:OnEnable()

  CreateHonorBar()
  CreateXPBar()

end
