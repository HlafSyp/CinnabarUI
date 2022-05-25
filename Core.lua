local Cinnabar, Util, Cfg, Module = unpack(select(2,...))

-- Creates a table of every mount and their id
-- I pulled this out from the Tooltip file as is,
-- and modified it to work in this file instead,
-- Mainly so that I could pull the mountID from unit aura function out from Tooltip.lua
-- and into Utilities.lua
---------------------------------------
-- @ARGUMENTS
-- none
-- @RETURNS
-- mj (table) : The Compiled Mount Journal
-- ms (table) : The Compiled Spell ID's of the mounts
local function CompileMountJournal()

  local ms = {} -- This table holds the spell ID's of the mounts
  local mj = {} -- This table holds the mount ID's of the mounts
  mj = C_MountJournal.GetMountIDs() -- WoW thankfully gives us a function which can compile the ids for me

  -- Gather a list of the spell ID's so that I can pull it from the buffs, which mount it is
  for i=1, #mj do
    local spellID = select( 2, C_MountJournal.GetMountInfoByID( mj[i] ) )
    table.insert(ms,  spellID)
  end

  Cinnabar.data.Mount.IDs = mj
  Cinnabar.data.Mount.SpellIDs = ms

end


function Cinnabar:OnInitialize()

  -- Register the slash commands to open the config menu
  SLASH_CINNABAR1 = "/cinnabar"
  SlashCmdList["CINNABAR"] = function(msg)

    if Cfg:IsEnabled() then
      Cfg:Disable()
    else
      Cfg:Enable()
    end

  end

  -- Steal a Game Menu Button to make it our addon's
  local btn = CreateFrame("Button", "GameMenuButtonCinnabarUI", GameMenuFrame, "GameMenuButtonTemplate")
  GameMenuButtonQuit:SetPoint("TOP", GameMenuButtonLogout, "BOTTOM", 0, -1)
  GameMenuButtonContinue:SetPoint("TOP", GameMenuButtonQuit, "BOTTOM", 0, -16)
  btn.Text:SetText(string.format("|c%sCinnabarUI|r ", Cinnabar.data.COLORS.UI_FG.hex))
  btn:SetScript("OnClick", function()
    Cfg:Enable()
    ToggleGameMenu()
  end)
  GameMenuFrame:HookScript("OnShow", function()
    local height = 359
    if GameMenuButtonRatings:IsShown() then
      btn:SetPoint("TOP", GameMenuButtonRatings, "BOTTOM", 0, -1)
      height = height + 20
    else
      btn:SetPoint("TOP", GameMenuButtonAddons, "BOTTOM", 0, -1)
    end

    if GameMenuFrame.ElvUI ~= nil then
      btn:SetPoint("TOP", GameMenuFrame.ElvUI, "BOTTOM", 0, -1)
      height = height + 20
    end

    GameMenuButtonLogout:ClearAllPoints()
    GameMenuButtonLogout:SetPoint("TOP", btn, "BOTTOM", 0, -16)
    GameMenuFrame:SetHeight(height)

  end)

  btn:RegisterEvent("PLAYER_LOGOUT")
  btn:HookScript("OnEvent", function(self, event)
    if event == 'PLAYER_LOGOUT' then
      Cfg:UnLoad()
    end
  end)

end

function Cinnabar:OnEnable()

  CompileMountJournal()

end


function Cinnabar:OnDisable()

  Cfg:Disable()


end

