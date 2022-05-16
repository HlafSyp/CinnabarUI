local Cinnabar, Util, Cfg, Module = unpack(select(2,...))

function Cinnabar:OnInitialize()



end

function Cinnabar:OnEnable()

  CompileMountJournal()

end


function Cinnabar:OnDisable()




end

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

  Cinnabar.Mount.IDs = mj
  Cinnabar.Mount.SpellIDs = ms

end
