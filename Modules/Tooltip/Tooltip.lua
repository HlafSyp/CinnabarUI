local Cinnabar, Util, Cfg, Module = unpack(select(2,...))
local TT = Module["Tooltip"]

-- Local Functions
local hooksecurefunc, GameTooltip, UIParent = hooksecurefunc, GameTooltip, UIParent
local GetActionInfo, UnitIsPlayer, UnitAura = GetActionInfo, UnitIsPlayer, UnitAura
local C_MountJournal, GetSpellBookItemInfo = C_MountJournal, GetSpellBookItemInfo
local CreateFrame = CreateFrame
local TooltipAnchor = CreateFrame("Frame", "CinnabarTooltipAnchor", UIParent)
-- local MountIDs = Cinnabar.data.Mount.IDs
local MountSpellIDs = Cinnabar.data.Mount.SpellIDs


-- I honestly don't know why this would be needed as everything will be done through the config
-- So I'm not going to properly document this function as I don't think it will ever be used
-- AND it's pretty simple to easily look at and see what it does
function TT:SetTooltipAnchorLocation(point, relativeTo, relativePoint, xOffset, yOffset)

  TooltipAnchor:SetPoint(point, relativeTo, relativePoint, xOffset, yOffset)

end

local function AppendMountToTooltip(mountID)

  local _, _, source = C_MountJournal.GetMountInfoExtraByID(mountID)
  local mountName = C_MountJournal.GetMountInfoByID(mountID)
  -- Setup the tooltip
  GameTooltip:AddLine(" ")
  GameTooltip:AddDoubleLine("Mount:", mountName, nil, nil, nil, 1,1,1)
  -- Count how many new line characters there are plus 1 to figure out how many lines there are
  local _, Lines = string.gsub(source, '|n', '|n')
  -- Add a new line character to the end so that the regex functions work
  source =  source .. '|n'

  -- ElvUI does a more complicated regex search, it's been a while since i've looked at their code for this
  -- But writing my own, made me wonder why the complicated regex, it's hard to maintain and doesn't
  -- Seem any more efficient than what i'm doing here

  -- Add 1 to lines otherwise the for loop never runs or doesn't catch the last line
  for i=1, Lines + 1 do

    -- Some sources give an empty line at the end,
    -- this circumvents that as the shortest line possible is like 6 characters
    -- not counting the characters giving the gold icon
    if string.len(source) < 5 then break end

    -- Break the string into two, assume the wanted entry is at the start of the line
    local left = string.sub(source, string.find(source, '|c.-|r'))
    local right = string.sub(source, string.find(source, '|r.-|n'))

    -- Add the broken text into the tooltip
    GameTooltip:AddDoubleLine(left, right, nil, nil, nil, 1, 1, 1)

    -- Remove the newly added line from the source string
    source = string.sub(source, string.len(left .. right) - 1, string.len(source))

  end

end


-- This is an overide to the default function GameTooltip_SetDefaultAnchor
-- Because this is defined as a global function and I don't need the original functionality,
-- I can just override it and discard the original function
---------------------------------------
-- @ARGUMENTS
-- tooltip (frame) : This is given when SetDefaultAnchor is called, it is the GameTooltip Object
-- parent (Frame)  : This the frame the tooltip will have its owner set to
local function AnchorTooltip(tooltip, parent)
  tooltip:SetOwner(parent, "ANCHOR_NONE")
  tooltip:SetPoint("BOTTOMRIGHT", TooltipAnchor, "BOTTOMRIGHT", 0, 0)
end

-- This is suppose to act as an overide for the secure WoW function
-- GameTooltip_SetSpellBookItem
-- I didn't know what this was called on
-- but it is called for the tooltips for the spells in your spellbook
-- which, makes perfect sense, and I'm an idiot
---------------------------------------
-- @ARGUMENTS
-- These are passed in from SetSpellBookItem
function TT:SetSpellBookItem(spellBookId, bookType)

  -- If the Tooltip Module is disabled then return early
  if not TT:IsEnabled() then
    GameTooltip:Show()
    return
  end

  -- Have to convert the given id into the proper spell id
  local _, spellId = GetSpellBookItemInfo(spellBookId, bookType)


  GameTooltip:AddLine("")
  GameTooltip:AddDoubleLine("Spell ID:", spellId, nil, nil, nil, 1, 1, 1)
  GameTooltip:Show()

end

-- This is suppose to act as an overide for the secure WoW function
-- GameTooltip_SetUnitAura
---------------------------------------
-- @ARGUMENTS
-- These are passed in from SetUnitAura
function TT:SetUnitAura(unitID, auraIndex, filter)

  -- If the Tooltip Module is disabled then return early
  if not TT:IsEnabled() then return GameTooltip:Show() end

  local AuraSpellId = select(10, UnitAura(unitID, auraIndex, filter))
  GameTooltip:AddDoubleLine("Aura ID:", tostring(AuraSpellId), nil, nil, nil, 1, 1, 1)

  for i=1, #MountSpellIDs do
    if MountSpellIDs[i] == AuraSpellId then
      local mountID = C_MountJournal.GetMountFromSpell(AuraSpellId)
      AppendMountToTooltip(mountID)
      break
    end
  end

  GameTooltip:Show()

end

function TT:SetUnit(unit)

  -- If the Tooltip Module is disabled then return early
  if not TT:IsEnabled() then
    GameTooltip:Show()
    return
  end

  -- Some local variables
  local IsPlayer = UnitIsPlayer(unit)
  -- Do the mount stuff for player riding a mount
  -- Stuck it inside a do block so that the variables maintained proper scope
  -- No point in keeping them around
  do
    -- I only care for player units, since they are the only ones capable of riding mounts
    -- and also have aura's for them
    if IsPlayer then

      -- This function is found in Utilities.lua
      -- Pretty self-explanatory from the name
      -- But gets a mount id from the units auras, making use of the buff id
      local mountID = Util:GetMountIDFromUnitAura(unit)

      --  Make sure mountID isn't nil
      if mountID then

        -- Bumped this into a seperate function, thing was getting to long
        -- Function can be found near top of this file, Tooltip.lua
        AppendMountToTooltip(mountID)

      end
    end
  end

end

function TT:SetAction(slot)

  -- If the Tooltip Module is disabled then return early
  if not TT:IsEnabled() then return GameTooltip:Show() end

  local actionType, id = GetActionInfo(slot)
  if actionType == 'spell' then
    GameTooltip:AddDoubleLine('Spell ID:', id, nil, nil, nil, 1, 1, 1)
  elseif actionType == 'item' then
    GameTooltip:AddDoubleLine('Item ID:', id, nil, nil, nil, 1, 1, 1)
  end
  GameTooltip:Show()

end

-- This is the initialization function for the Tooltip Module
-- Essentially, this is the entry point for the module and will be the first thing run for the module
-- Aside from any frame creations as that has to be done before the PLAYER_LOGIN event is fired
function TT:OnInitialize()

  TooltipAnchor:SetSize(50, 10)
  TooltipAnchor:SetPoint(Cfg.config.Tooltip.Anchor.point,
                         "UIParent",
                         Cfg.config.Tooltip.Anchor.relativePoint,
                         Cfg.config.Tooltip.Anchor.OffsetX,
                         Cfg.config.Tooltip.Anchor.OffsetY)
  -- Have to do this to get the tooltips to add the stuff i want
  hooksecurefunc(GameTooltip, "SetUnitAura", TT.SetUnitAura)
  hooksecurefunc(GameTooltip, "SetUnit", TT.SetUnit)
  --hooksecurefunc(GameTooltip, "SetSpellByID", TT.SetSpellByID)
  hooksecurefunc(GameTooltip, "SetSpellBookItem", TT.SetSpellBookItem)
  hooksecurefunc(GameTooltip, "SetAction", TT.SetAction)

  GameTooltip:RegisterEvent('UPDATE_MOUSEOVER_UNIT')

  -- I guarantee there is an easier way of doing this but this works so wtf
  -- I primarily did this so that all unit tootltips can be modified within the same function
  -- SetUnit, but it seems this part is a tad bit more complicated
  GameTooltip:HookScript('OnEvent', function(_, event, _)

    -- Make sure it's my event
    if event ~= 'UPDATE_MOUSEOVER_UNIT' then return end

    -- I get a weird double call when this event fires and I hover over a unit frame
    -- So I check it to make sure it isn't a unit frame
    -- The api says it shouldn't fire but it does so meh
    local GTUnitID = select(2,GameTooltip:GetUnit())
    -- string.find was throwing a bunch of errors if GTUnitID was already nil, so
    -- just check to make sure GTUnitID is actually equal to something before doing the  other checks
    if GTUnitID then
      if string.find(GTUnitID, "nameplate") == nil and GTUnitID ~= 'mouseover' then return end
    end
    GameTooltip:SetUnit('mouseover')
    GameTooltip:Show()

  end)
  GameTooltip_SetDefaultAnchor(GameTooltip, UIParent)

end

function TT:OnEnable()

  GameTooltip_SetDefaultAnchor = AnchorTooltip

end

function TT:OnDisable()
  GameTooltip_SetDefaultAnchor = function(tooltip, parent)
    tooltip:SetOwner(parent, "ANCHOR_NONE");
	  tooltip:SetPoint("BOTTOMRIGHT", UIParent, "BOTTOMRIGHT", -CONTAINER_OFFSET_X - 13, CONTAINER_OFFSET_Y);
  end
end

