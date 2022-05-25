local Cinnabar, Util, Cfg, Module = unpack(select(2,...))

-- Store the bars locally so that I can assign the proper values when the player logs in
local Bars = Module["Databar"]

-- I originally had the databars part of the code hidden in the unit frame parts of the code
-- However it was starting to make the file a little big and the function itself was starting to
-- become massive with the amount of edge cases I was having to implement
-- So i broke it off into its own file, however the config for the databars will still
-- remain in the UnitFrameCfg.lua file
local cfg = Cfg.config.Databar or Cfg.defaults.Databar
local TA = cfg.TopAnchor
local spacing = 2
local point = TA and "BOTTOM" or "TOP"
local rP = TA and "TOP" or "BOTTOM"
local xOfs = 0
local yOfs = TA and spacing or -spacing

-- Realigns the Rep bar and XP bar depending on if the bar needs to be visible or not
--  I pulled this out since it was starting to get a little big
-- Essentially, when the rep bar was hidden, it would still trigger the OnEnter event since I only changed the alpha
-- By moving it and unhooking the OnEnter script, i can avoid errors, and get the xp bar tooltip to show up again
---------------------------------------
-- @ARGUMENTS
-- original (boolenan) : Whether the rep bar should be placed in its original spot or
--                       if it needs to go underneath the xp bar and hidden away
-- local function RealignBars(original)

--   -- Some error checking in case it somehow ends up wrong
--   assert(type(original) == "boolean",
--           "Incorrect type given to RealignBars(original). Given " .. type(original) .. " expected boolean")

--   if original then

--   end

-- end

-- Pulled From ReputationBar.lua inside FrameXML
-- From what I could tell, this handles not only setting the appropriate values of the statusbar
-- But also coloring of the status bar
local function RepBarUpdate()
  local name, reaction, minBar, maxBar, value, factionID = GetWatchedFactionInfo();
  local colorIndex = reaction;
  local isCapped;
  local friendshipID, _, _, _, _, _, friendTextLevel = GetFriendshipReputation(factionID);
  if name and cfg.EnableReputation then

    -- Have to re-anchor and show the bars
    -- if Repbar wasn't already visible,
    -- but only if it wasn't already visible, not on every frame
    -- The xpbar doesn't always get positioned correctly if the user reloads the interface and has
    -- a faction watched, so The xpbar has to be repositioned then as well
    if Bars.XPBar and Bars.XPBar:IsVisible() then
      if Bars.Repbar:GetAlpha() == 0 or select(2,Bars.XPBar:GetPoint(3)) ~= Bars.Repbar then
        local anchor = Bars.Repbar
        Bars.XPBar:ClearAllPoints()
        Bars.XPBar:SetPoint("LEFT", anchor, "LEFT")
        Bars.XPBar:SetPoint("RIGHT", anchor, "RIGHT")
        Bars.XPBar:SetPoint(point, anchor, rP, xOfs, yOfs)
        Bars.Repbar:ClearAllPoints()
        anchor = Bars.Honorbar or Minimap
        Bars.Repbar:SetPoint(point, anchor, rP, xOfs, yOfs)
        Bars.Repbar:SetPoint("LEFT", Minimap)
        Bars.Repbar:SetPoint("RIGHT", Minimap)
        Bars.Repbar:SetAlpha(1)
        Bars.Repbar:SetScript("OnEnter", function()

          local fName, rC, rM = Bars.Repbar.name, Bars.Repbar.value, Bars.Repbar.max
          local sI = getglobal("FACTION_STANDING_LABEL" .. Bars.Repbar.reaction)

          GameTooltip:SetOwner(Bars.Repbar, 'ANCHOR_CURSOR')
          GameTooltip:AddLine(fName)
          GameTooltip:AddDoubleLine("Standing:", sI, nil, nil, nil, 1, 1, 1)
          GameTooltip:AddDoubleLine("Reputation: ", rC .. " / " .. rM, nil, nil, nil, 1, 1, 1)
          GameTooltip:Show()

        end)
      end
    end
    if ( Bars.Repbar.factionID ~= factionID ) then
      Bars.Repbar.factionID = factionID;
      Bars.Repbar.friendshipID, _, _, _, _, _, Bars.Repbar.friendTextLevel = GetFriendshipReputation(factionID);
    end

    -- do something different for friendships
    if ( friendshipID ) then
      local _, friendRep, _, _, _, _, _, friendThreshold, nextFriendThreshold = GetFriendshipReputation(factionID);
      if ( nextFriendThreshold ) then
        minBar, maxBar, value = friendThreshold, nextFriendThreshold, friendRep;
      else
        -- max rank, make it look like a full bar
        minBar, maxBar, value = 0, 1, 1;
        isCapped = true;
      end
      colorIndex = 5;   -- always color friendships green

    elseif ( C_Reputation.IsFactionParagon(factionID) ) then
      local currentValue, threshold, _, hasRewardPending = C_Reputation.GetFactionParagonInfo(factionID);
      minBar, maxBar  = 0, threshold;
      value = currentValue % threshold;
      if ( hasRewardPending ) then
        value = value + threshold;
      end
    else
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

    Bars.Repbar:SetMinMaxValues(minBar, maxBar)
    Bars.Repbar:SetValue(value)


    local color = FACTION_BAR_COLORS[colorIndex];

    Bars.Repbar:SetStatusBarColor(color.r, color.g, color.b, 1);
    local bgMult = Bars.Repbar.Background.mult
    Bars.Repbar.Background:SetVertexColor(color.r * bgMult, color.g * bgMult, color.b * bgMult, 1)

    Bars.Repbar.isCapped = isCapped;
    Bars.Repbar.name = name;
    Bars.Repbar.value = value;
    Bars.Repbar.max = maxBar;
    Bars.Repbar.reaction = reaction;

  elseif Bars.Repbar:GetAlpha() == 1 then
    Bars.Repbar:SetAlpha(0)
    if Bars.XPBar then
      Bars.XPBar:ClearAllPoints()
      local anchor = Minimap
      if Bars.Honorbar then
        anchor = Bars.Honorbar
      end
      Bars.XPBar:SetPoint("LEFT", anchor, "LEFT")
      Bars.XPBar:SetPoint("RIGHT", anchor, "RIGHT")
      Bars.XPBar:SetPoint(point, anchor, rP, xOfs, yOfs)
    end
  else
    Bars.Repbar:SetScript("OnEnter", nil)
    Bars.Repbar:ClearAllPoints()
    Bars.Repbar:SetPoint(point, Bars.XPBar, rP, xOfs, yOfs)
    Bars.Repbar:SetPoint("LEFT", Minimap)
    Bars.Repbar:SetPoint("RIGHT", Minimap)
  end

end

-- Updates the XPBar
-- Pulls info from UnitXP to get the current xp of the player
-- UnitXPMax to get the maximum xp the player can earn for that level
-- GetXPExhaustion to see how much rested xp the player has saved
local function XPBarUpdate()

  local xpCur, xpMax = UnitXP('player'), UnitXPMax('player')
  local rested = GetXPExhaustion()
  Bars.XPBar:SetMinMaxValues(0, xpMax)
  Bars.XPBar:SetValue(xpCur)

  if rested then
    -- Because the rested xp bar is attached to the right of the XPBar texture and the right of the XPBar frame
    -- the min max values are a bit weird in that they need to be the deficit of what the player's xp is for that level
    -- This allows the rested xp to not overflow from the bar,
    -- while still maintaining the proper ratio of bar lengths of xp to rested xp to required xp
    Bars.XPBar.rested:SetMinMaxValues(0, xpMax - xpCur)
    Bars.XPBar.rested:SetValue(rested)
  end

end

local function HonorBarUpdate()

  local hCur, hMax = UnitHonor('player'), UnitHonorMax('player')
  Bars.Honorbar:SetMinMaxValues(0, hMax)
  Bars.Honorbar:SetValue(hCur)

end

-- Creates a backdrop for a given frame
-- Typically, I would normally break this out into it's own Utility function, however,
-- I don't know how many times I will use it from here on out
---------------------------------------
-- @ARGUMENTS
-- bar (frame) : The bar that the backdrop is for
-- Padding (number) : The inset for the backdrop, how many pixels from the edge it will be,
--                    negative is away, positive is inside
--                    The number is negated inside the function, so the sign association is swapped
--                    So negative would be inwards to the middle of the bar, positive is outwards
-- @RETURNS
-- Backdrop  (frame) : The backdrop created
local function CreateDataBarBackdrop(bar, Padding)

  local Backdrop = CreateFrame("Frame", nil, bar, "BackdropTemplate")
  Backdrop:SetAllPoints(bar)
  Backdrop:SetFrameLevel(bar:GetFrameLevel() == 0 and 0 or bar:GetFrameLevel() - 1)

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
  Backdrop:SetBackdropColor(0,0,0,cfg.BackdropOpacity)

  return Backdrop

end

-- Creates a small statusbar that tracks the honor points a player has
---------------------------------------
-- @RETURNS
-- Honorbar (frame) : Returns the small bar created, so values and functions can be assigned to it
local function CreateHonorBar()

  local Honorbar = CreateFrame("Statusbar", "HonorDatabar", UIParent)
  Honorbar:SetHeight(5)
  Honorbar:SetPoint("LEFT", Minimap, "LEFT")
  Honorbar:SetPoint("RIGHT", Minimap, "RIGHT")
  Honorbar:SetPoint(point, Minimap, rP, xOfs, yOfs)
  Honorbar:SetStatusBarTexture(Cinnabar.lsm:Fetch('statusbar', 'Simple'))
  Honorbar:SetStatusBarColor(1.0, 0.24, 0)
  Honorbar.Background = Honorbar:CreateTexture(nil, 'BACKGROUND')
  Honorbar.Background:SetPoint("TOP", Honorbar, "TOP")
  Honorbar.Background:SetPoint("BOTTOM", Honorbar, "BOTTOM")
  Honorbar.Background:SetPoint("LEFT", Minimap, "LEFT")
  Honorbar.Background:SetPoint("RIGHT", Minimap, "RIGHT")
  Honorbar.Background:SetTexture(Cinnabar.lsm:Fetch("statusbar", "Simple"))
  Honorbar.Background.mult = 0.5
  Honorbar.Background:SetVertexColor(0.5, 0.24 *  0.5, 0)
  Honorbar.Backdrop = CreateDataBarBackdrop(Honorbar, 2)
  -- Add two to the y Offset so there is a two pixel  gap between each bar
  -- I don't want the backdrops to connect
  -- yOfs = yOfs + (spacing / 2 * U:Sign(yOfs))

  return Honorbar

end

-- Creates a small reputation tracking bar that tracks a watched factiosn rep
---------------------------------------
-- @RETURNS
-- RepBar (frame) : Returns the small bar created, so values and functions can be assigned to it
local function CreateRepBar()

  -- name, standing, min, max, value = GetWatchedFactionInfo()
  -- Register for CVAR_UPDATE
  -- Check if cvar == "XP_BAR_TEXT" then
  local anchor = Minimap
  -- I want the bars to be dynamically positioned
  if Bars.Honorbar ~= nil then
    anchor = Bars.Honorbar
  end

  local RepBar = CreateFrame("Statusbar", "ReputationDatabar", UIParent)
  RepBar:SetHeight(5)
  RepBar:SetPoint("LEFT", anchor, "LEFT")
  RepBar:SetPoint("RIGHT", anchor, "RIGHT")
  RepBar:SetPoint(point, anchor, rP, xOfs, yOfs)
  RepBar:SetStatusBarTexture(Cinnabar.lsm:Fetch('statusbar', 'Simple'))
  RepBar:SetStatusBarColor(1, 1, 1)
  RepBar.Background = RepBar:CreateTexture(nil, 'BACKGROUND')
  RepBar.Background:SetAllPoints(RepBar)
  RepBar.Background:SetTexture(Cinnabar.lsm:Fetch("statusbar", "Simple"))
  RepBar.Background.mult = 0.5
  RepBar.Backdrop = CreateDataBarBackdrop(RepBar, 2)

  RepBar:HookScript("OnUpdate", RepBarUpdate)

  return RepBar

end

-- Creates a small XP Bar that tracks the users xp, can hide at max level
---------------------------------------
-- @RETURNS
-- XPBar (frame) : Returns the small bar created, so values and functions can be assigned to it
local function CreateXPBar()

  local anchor = Minimap

  -- I want the bars to be dynamically positioned
  -- So I have to check if the other bars are available to mount to instead
  -- CHecking Honor before Rep since Rep is always made second, but may not always be present
  if Bars.Honorbar ~= nil then
    anchor = Bars.Honorbar
  end

  if Bars.Repbar ~= nil and Bars.Repbar.name then
    anchor = Bars.Repbar
    -- Because the bars are dynamically placed, the updated yOfs may not always be the correct
    -- value, say if the honor bar is hidden but not the rep bar
    -- I didn't need to do this in the Rep bar because it wouldve been mounted to the Minimap
    -- if the Honor bar wasn't there
    --[[
    if yOfs == spacing or yOfs == -spacing then
      yOfs = yOfs + (spacing / 2 * U:Sign(yOfs))
    end
    --]]
  end

  local XPBar = CreateFrame("Statusbar", "ExpDatabar", UIParent)
  XPBar:SetHeight(5)
  XPBar:SetPoint("LEFT", anchor, "LEFT")
  XPBar:SetPoint("RIGHT", anchor, "RIGHT")
  XPBar:SetPoint(point, anchor, rP, xOfs, yOfs)
  XPBar:SetStatusBarTexture(Cinnabar.lsm:Fetch('statusbar', 'Simple'))
  XPBar:SetStatusBarColor(0.58, 0.0, 0.55, 1.0)
  XPBar.Background = XPBar:CreateTexture(nil, 'BACKGROUND')
  XPBar.Background:SetAllPoints(XPBar)
  XPBar.Background:SetTexture(Cinnabar.lsm:Fetch("statusbar", "Simple"))
  XPBar.Background:SetVertexColor(0.29, 0.0, 0.275, 1.0)
  XPBar.Backdrop = CreateDataBarBackdrop(XPBar, 2)

  -- Create the rested XP portion of the bar
  XPBar.rested = CreateFrame("Statusbar", "Rested", XPBar)
  XPBar.rested:SetPoint('TOP')
  XPBar.rested:SetPoint('BOTTOM')
  XPBar.rested:SetPoint('LEFT', XPBar:GetStatusBarTexture(), 'RIGHT')
  XPBar.rested:SetPoint('RIGHT')
  XPBar.rested:SetStatusBarTexture(Cinnabar.lsm:Fetch('statusbar', 'Simple'))
  XPBar.rested:SetStatusBarColor(0.0, 0.39, 0.88, 1.0)
  return XPBar

end



-- Creates all the databars assuming they are allowed by the config
-- This includes the XP bar, reputation tracker bar, and honor bar
-- However, this doesn't create bars for azerite power and any other trackable things like covenant level,
-- or any of the shadowlands covenant stuff
-- TODO (Hlaf) : Create an extensible system that allows for more data bars aside from the ones already established
local function CreateDataBars()
  -- Creates a bar for the Honor
  if cfg.EnableHonor then

    Bars.Honorbar = CreateHonorBar()

  end

  -- Create a bar for the reputation
  local name = GetWatchedFactionInfo()
  if cfg.EnableReputation then

    Bars.Repbar = CreateRepBar()
    if not name then Bars.Repbar:SetAlpha(0) end

  end

  local IsMaxLevel = (UnitLevel('player') == Cinnabar.data.MAX_LEVEL) -- Is true if unit is level 60
  if cfg.EnableXP and (not IsMaxLevel and cfg.HideXPAtMaxLevel) then

    Bars.XPBar = CreateXPBar()

  end

end

-- Sets up the tooltips to show when a databar is entered as well as what info to show,
-- right now this info is hard coded in, but
-- a more extensible system is most likely to come in the future
local function SetTooltip()

  if Bars.Honorbar then
    Bars.Honorbar:SetScript("OnEnter", function()

      local hl, hc, hm = UnitHonorLevel('player'), UnitHonor('player'), UnitHonorMax('player')

      GameTooltip:SetOwner(Bars.Honorbar, 'ANCHOR_CURSOR')
      GameTooltip:AddDoubleLine("Honor Level:", hl, nil, nil, nil, 1, 1, 1)
      GameTooltip:AddDoubleLine("Honor Points: ", hc .. " / " .. hm, nil, nil, nil, 1, 1, 1)
      GameTooltip:Show()

    end)

    Bars.Honorbar:SetScript('OnLeave', function()

      GameTooltip:Hide()

    end)
  end

  if Bars.Repbar then
    Bars.Repbar:SetScript("OnEnter", function()

      local fName, rC, rM = Bars.Repbar.name, Bars.Repbar.value, Bars.Repbar.max
      local sI = getglobal("FACTION_STANDING_LABEL" .. Bars.Repbar.reaction)

      GameTooltip:SetOwner(Bars.Repbar, 'ANCHOR_CURSOR')
      GameTooltip:AddLine(fName)
      GameTooltip:AddDoubleLine("Standing:", sI, nil, nil, nil, 1, 1, 1)
      GameTooltip:AddDoubleLine("Reputation: ", rC .. " / " .. rM, nil, nil, nil, 1, 1, 1)
      GameTooltip:Show()

    end)

    Bars.Repbar:SetScript('OnLeave', function()

      GameTooltip:Hide()
      GameTooltip:SetOwner(UIParent)

    end)
  end

  if Bars.XPBar then
    Bars.XPBar:SetScript("OnEnter", function()

      local level, xpC, xpM = UnitLevel('player'), UnitXP('player'), UnitXPMax('player')
      local rested = GetXPExhaustion()

      GameTooltip:SetOwner(Bars.XPBar, 'ANCHOR_CURSOR')
      GameTooltip:AddLine("Level: " .. level)
      GameTooltip:AddDoubleLine("Rested XP:", rested, nil, nil, nil, 1, 1, 1)
      GameTooltip:AddDoubleLine("Experience: ", xpC .. " / " .. xpM, nil, nil, nil, 1, 1, 1)
      GameTooltip:Show()

    end)

    Bars.XPBar:SetScript('OnLeave', function()

      GameTooltip:Hide()

    end)
  end

end

-- This function is called during the PLAYER_LOGIN event
-- This was neccessary since not all information is available when the bars need to be created,
-- For instance ,the honor info I don't believe is available until the player logs in
-- Of course, I could just set it up to fire during the update function
-- however, like with the xp bar, it can sometimes create weird issues when at more extreme values
local function EnableDatabars()

  if cfg.EnableHonor then
    -- Currency ID = 1792
    local value, maximum = UnitHonor("player"), UnitHonorMax("player")
    Bars.Honorbar:SetMinMaxValues(0, maximum)
    Bars.Honorbar:SetValue(value)
    Bars.Honorbar:RegisterEvent("HONOR_XP_UPDATE")
    -- Hook script is completely unnecessary here but idgaf
    -- I know for a fact that there is no function attached to the OnEvent event so I don't need to use HookScript
    -- Same applies to the XPBar section
    Bars.Honorbar:HookScript("OnEvent", HonorBarUpdate)
  end

  if cfg.EnableXP then
    local xpCur, xpMax = UnitXP('player'), UnitXPMax('player')
    local rested = GetXPExhaustion()
    Bars.XPBar:SetMinMaxValues(0, xpMax)
    Bars.XPBar:SetValue(xpCur)

    Bars.XPBar.rested:SetMinMaxValues(0, xpMax - xpCur)
    Bars.XPBar.rested:SetValue(rested or 0)
    Bars.XPBar:RegisterEvent("UPDATE_EXHAUSTION")
    Bars.XPBar:RegisterEvent("PLAYER_XP_UPDATE")
    Bars.XPBar:HookScript("OnEvent", XPBarUpdate)
  end

  SetTooltip()

end

function Bars:OnInitialize()

  CreateDataBars()

end

function Bars:OnEnable()

  EnableDatabars()

end
