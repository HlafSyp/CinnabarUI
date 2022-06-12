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
local function CreateStatusBar(enableBackdrop, parent, name)

  -- Setup defaults
  enableBackdrop = enableBackdrop or true
  parent = parent or UIParent

  local bar = CreateFrame("StatusBar", name, parent)
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
  honor.bar = CreateStatusBar(nil, nil, 'CinnabarUIHonorBar')

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
    honor.bar:SetMinMaxValues(0, UnitHonorMax('player'))
    honor.bar:SetValue(UnitHonor('player'))
  end)

  honor.bar:EnableMouse(true)

  -- Register Tooltip Function
  function honor.ShowTooltip()

    if not honor.bar:IsVisible() then return end

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
  xp.bar = CreateStatusBar(nil, nil, 'CinnabarUIExpBar')

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
  function xp:ShowTooltip()
    if not xp.bar:IsVisible() then return end
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

  -- Create a wrapper for the reputation bar that holds a few helper functions
  -- for the functionality of the databar
  local cfg = Cfg.config.Databar.RepBar
  local rep = {}
  rep.bar = CreateStatusBar(nil, nil, 'CinnabarUIRepBar')

  function rep.GetStanding()
    -- Simple lookup table to convert the standing saved in the metadata
    -- to a string
    local standings = {
      [0] = 'Unknown',
      [1] = 'Hated',
      [2] = 'Hostile',
      [3] = 'Unfriendly',
      [4] = 'Neutral',
      [5] = 'Friendly',
      [6] = 'Honored',
      [7] = 'Revered',
      [8] = 'Exalted',
    }

    return standings[rep.standing]

  end

  function rep.ShowTooltip()

    if rep.bar:GetAlpha() ~= 1 then return end
    GameTooltip:SetOwner(rep.bar, 'ANCHOR_CURSOR')
    GameTooltip:AddLine(rep.name)
    GameTooltip:AddDoubleLine(
      rep:GetStanding(),
      Util:FormatNumber(rep.value or 0) .. '/' .. Util:FormatNumber(rep.max or 0),
      nil, nil, nil,
      1,1,1
    )
    GameTooltip:Show()

  end

  -- This entire function is literally ripped directly from
  -- FrameXML/ReputationBar.lua
  -- I only added/changed a few things to work better for my specific case
  function rep.Update()

    local name, reaction, minBar, maxBar, value, factionID = GetWatchedFactionInfo();
    if name == nil then
      rep.bar:SetAlpha(0)
      return
    else
      rep.bar:SetAlpha(1)
    end
    local colorIndex = reaction;
    local isCapped;
    local friendshipID = GetFriendshipReputation(factionID);

    if ( rep.factionID ~= factionID ) then
        rep.factionID = factionID;
        rep.friendshipID = GetFriendshipReputation(factionID);
      end

    -- do something different for friendships
    local level;

    if ( C_Reputation.IsFactionParagon(factionID) ) then
      local currentValue, threshold, _, hasRewardPending = C_Reputation.GetFactionParagonInfo(factionID);
      minBar, maxBar  = 0, threshold;
      value = currentValue % threshold;
      if ( hasRewardPending ) then
        value = value + threshold;
      end
    elseif ( friendshipID ) then
      local friendID, friendRep, friendMaxRep, friendName, friendText, friendTexture, friendTextLevel, friendThreshold, nextFriendThreshold = GetFriendshipReputation(factionID);
      level = GetFriendshipReputationRanks(factionID);
      if ( nextFriendThreshold ) then
        minBar, maxBar, value = friendThreshold, nextFriendThreshold, friendRep;
      else
        -- max rank, make it look like a full bar
        minBar, maxBar, value = 0, 1, 1;
        isCapped = true;
      end
      colorIndex = 5;   -- always color friendships green
    else
      level = reaction;
      if ( reaction == MAX_REPUTATION_REACTION ) then
        isCapped = true;
      end
    end

    -- Normalize values
    maxBar = maxBar - minBar;
    value = value - minBar;
    if ( isCapped and maxBar == 0 ) then
      maxBar = 1;
      value = 1;
    end
    minBar = 0;

    rep.bar:SetValue(value);
    rep.bar:SetMinMaxValues(minBar, maxBar)

    local color = FACTION_BAR_COLORS[colorIndex];

    rep.bar:SetStatusBarColor(color.r, color.g, color.b, 1);
    rep.bar.background:SetVertexColor(
      color.r * cfg.BgBrightness,
      color.g * cfg.BgBrightness,
      color.b * cfg.BgBrightness,
      1
    )
    rep.isCapped = isCapped;
    rep.name = name;
    rep.value = value;
    rep.max = maxBar;
    rep.standing = select(3, GetFactionInfoByID(factionID))

  end

  rep.bar:SetPoint(cfg.Point, cfg.relativeTo, cfg.relativePoint, cfg.xOffset, cfg.yOffset)
  rep.bar:SetSize(cfg.Width, cfg.Height)
  rep.bar:EnableMouse(true)
  rep.bar:HookScript("OnUpdate", rep.Update)
  rep.bar:SetScript("OnEnter", rep.ShowTooltip)
  rep.bar:SetScript("OnLeave", function() GameTooltip:Hide() end)
  rep.bar:SetAlpha(1)
  if not cfg.Enabled then
    rep.bar:SetAlpha(0)
  end

end

function Bars:OnInitialize()



end

function Bars:OnEnable()

  CreateHonorBar()
  CreateXPBar()
  CreateReputationBar()

end
