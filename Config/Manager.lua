local Cinnabar, Util, Cfg, Module = unpack(select(2,...))

Cfg.config = {}

local COLOR = Cinnabar.data.COLORS.UI_PRIMARY

local tinsert = table.insert

Cfg.ModuleFrames = {}
Cfg.RefreshFunction = {}

-- Gets the profile table associated to
-- the currently logged on character
---------------------------------------
-- @RETURNS
-- Profile (table) : The table associated to the
--                   Current character
local function GetProfileForCurrentCharacter()

  local charName = UnitName("player")
  local realmName = GetRealmName()
  local name = charName .. " - " .. realmName
  local key = Cfg.profilekeys[name]

  return Cfg.profiles[key]

end

-- After changes to the defaults config layout
-- Some functions return errors where there shouldn't be
-- because entries were renamed
-- This converts the old key to the new key
-- To remain compatible with future changes
-- All config breaking changes need to be listed in here
---------------------------------------
-- @ARGUMENTS
-- key  (string)  : The key in question
-- @RETURNS
-- Key  (string)  : The new key in the defaults config
local function LegacyCompat(key)
  if key == 'CB' then return 'Class Buffs'
  elseif key == 'CD' then return 'Class Debuffs'
  elseif key == 'B' then return 'Buffs'
  elseif key == 'D' then return 'Debuffs'
  elseif key == 'RD' then return 'Raid/Dungeon'
  else return key
  end
end

-- Copies missing members of the defaults table into the
-- Given table
---------------------------------------
-- @ARGUMENTS
-- target       (table)   : The target table to be populated
-- defaults ?   (table)   : The default config table, this is copied into the target
-- @RETURNS
-- target       (table) : Returns the table the defaults were copied into
local function LoadDefaultsIntoTable(target, defaults)

  assert(type(target) == 'table', "Usage: LoadDefaultsIntoTable(target,defaults), expected table for argument #1, got " .. type(target))
  if type(defaults) ~= 'table' then defaults = Cfg.defaults end

  local cpy
  cpy = function(dst, src)
    for key, val in pairs(src) do

      if type(val) == 'table' then
        dst[key] = {}
        cpy(dst[key], val)
      else
        dst[key] = val
      end

    end

    return dst

  end

  return cpy(target, defaults)

end

-- copies the profile table into the target table
---------------------------------------
-- @ARGUMENTS
-- target   ?   (table)   : The target table to be populated
-- profile  ?   (table)   : The profile table to copy
-- @RETURNS
-- target (table) : The table the profile was copied into
local function LoadProfileIntoTable(target, profile)

  -- Set some defaults for the optional variables
  if type(target) ~= "table" then target = Cfg.config end
  if type(profile) ~= "table" then
    profile = GetProfileForCurrentCharacter()
    -- If this doesn't return anything then character's
    -- profile doesn't exist
    if not profile then return target end
  end

  local cpy
  cpy = function(dst, src)
    for key, val in pairs(src) do

      if type(val) == 'table' then
        dst[key] = dst[key] or {}
        cpy(dst[key], val)
      else
        dst[key] = val
      end

    end
    return dst

  end

  target = cpy(target,profile)

  return target

end

-- Removes any default values from the target table
-- Used to reduce the size of the Saved Variables table
---------------------------------------
-- @ARGUMENTS
-- target       (table)   : The target table to be pruned
-- defaults ?   (table)   : The defaults table to be compared against
-- @RETURNS
-- target (table) : The table that was pruned
local function PruneTableOfDefaults(target, defaults)

  assert(type(target) == 'table', "Usage: PruneTableOfDefaults(target,defaults), expected table for argument #1, got " .. type(target))
  if type(defaults) ~= 'table' then defaults = Cfg.defaults end

  local prune
  prune = function(dst,src)

    for key, val in pairs(dst) do
      -- If val is a table, prune it
      if type(val) == 'table' then
        prune(val, src[LegacyCompat(key)])
        -- Check if table is empty
        if next(val) == nil then
          dst[key] = nil
        end
      elseif val == src[LegacyCompat(key)] then
        dst[key] = nil
      end
    end

    return dst
  end

  return prune(target, defaults)

end

-- Creates a profile name in the form
-- "[Character Name] - [Realm]"
---------------------------------------
-- @RETURNS
-- name (string)          : Returns a string
--                          of "[Character Name] - [Realm]"
local function CreateProfileNameByCharacterName()

  local name = UnitName('player')
  local realm = GetRealmName()
  return (name .. ' - ' .. realm)

end

-- Shallow copies a table into a new table
-- Doesn't copy metatables
---------------------------------------
-- @ARGUMENTS
-- source       (table)   : The table to copy
-- @RETURNS
-- copy         (table) : The copy of the source
local function CopyTable(source)

  local a
  a = function(dst, src)

    for key, val in pairs(src) do
      if type(val) == 'table' then
        dst[key] = {}
        a(dst[key], val)
      else
        dst[key] = val
      end
    end

    return dst

  end

  local tbl = {}
  return a(tbl, source)

end

-- Recursively sets all entries in the table
-- to nil, to hard delete a table
---------------------------------------
-- @ARGUMENTS
-- target           (table)     : The table to delete
local function DeleteTable(target)

  if not target then return end

  local a
  a = function(dst)

    for key, val in pairs(dst) do
      if type(val) == 'table' then
        a(dst[key])
        dst[key] = nil
      else
        dst[key] = nil
      end
    end
    return dst
  end

  a(target)

  return true

end

-- Simply copies the members of the SV
-- Into the Cfg Table
---------------------------------------
local function LoadSavedVariableIntoCfg()
  -- If CinnabarDB doesn't exist set them to empty tables
  if not CinnabarDB then
    CinnabarDB              = {}
    CinnabarDB.profiles     = {}
    CinnabarDB.profilekeys  = {}
    CinnabarDB.globals      = {}
  end
  Cfg.profiles    = CopyTable(CinnabarDB.profiles)
  Cfg.profilekeys = CopyTable(CinnabarDB.profilekeys)
  Cfg.globals     = CopyTable(CinnabarDB.globals)
end

function Cfg:GetNumberOfProfiles()

  local count = 0
  for key, _ in pairs(Cfg.profiles) do
    count = count + 1
  end

  return count

end

function Cfg:CreateAceGUITable()

  local tbl = {}
  for key, _ in pairs(Cfg.profiles) do
    tbl[key] = key
  end

  return tbl

end

-- Creates a new profile of the given or default name
-- Default Name is in the form of "[Character Name] - [Realm]"
---------------------------------------
-- @ARGUMENTS
-- name           ? (string)    : The defaults table to be compared against
-- profile_table  ? (table)     : The current profile table
-- @RETURNS
-- profile (table) : The table that was created
function Cfg:CreateNewProfile(name, profile_table)

  -- Setup some defaults
  if type(profile_table) ~= 'table' then
    profile_table = CopyTable(Cfg.config)
  end
  if type(name) ~= 'string' then name = CreateProfileNameByCharacterName() end

  -- In case the table has default values still in it or
  -- The default value for profile_table is used,
  -- Some defualts may still be in the table
  -- And need to be removed
  profile_table = PruneTableOfDefaults(profile_table)

  Cfg.profiles[name] = profile_table or {}
  Cfg:LoadProfile(name)

  return Cfg.profiles[name]

end

function Cfg:ResetProfile(profile_key)

  DeleteTable(Cfg.profiles[profile_key])
  Cfg.profiles[profile_key] = {}
  Cfg:LoadProfile(profile_key)

end

-- Deletes the profile at the given key
---------------------------------------
-- @ARGUMENTS
-- profile_key     (table)     : The key of the profile to delete
function Cfg:DeleteProfile(profile_key)

  local a
  a = function(tbl)

    for key, val in pairs(tbl) do
      if type(val) == 'table' then
        a(tbl[key])
        tbl[key] = nil
      else
        tbl[key] = nil
      end
    end

  end

  a(Cfg.profiles[profile_key])
  Cfg.profiles[profile_key] = nil

  if profile_key == Cfg.current_profile then
    local key, _ = next(Cfg.profiles)
    Cfg:LoadProfile(key)
  end

end

-- Copys the profile at the given key
-- to the current profile
---------------------------------------
-- @ARGUMENTS
-- profile_key    (table)     : The key of the profile to copy
function Cfg:CopyProfile(profile_key)

  -- Check if the profile_key actually exists
  if type(Cfg.profiles[profile_key]) ~= 'table' then return nil end
  local tbl = CopyTable(Cfg.profiles[profile_key])
  Cfg.profiles[Cfg.current_profile] = tbl
  Cfg:LoadProfile(Cfg.current_profile)
end

-- Loads the profile of the given key to the config
---------------------------------------
-- @ARGUMENTS
-- profile_key    (table)     : The key of the profile to load
function Cfg:LoadProfile(profile_key)

  -- Check if the profile_key actually exists
  if type(Cfg.profiles[profile_key]) ~= 'table' then return nil end
  -- Wipe the config table so no lingering options persist
  DeleteTable(Cfg.config)

  -- Load the defaults into the table
  Cfg.config = CopyTable(Cfg.defaults)

  -- Load the new profile into the table
  Cfg.config = LoadProfileIntoTable(Cfg.config, Cfg.profiles[profile_key])
  Cfg:Refresh()

  Cfg.profilekeys[CreateProfileNameByCharacterName()] = profile_key
  Cfg.current_profile = profile_key

end

-- Saves the current config to the selected profile
---------------------------------------
-- @ARGUMENTS
-- profile_key    (table)     : The key of the profile to save
function Cfg:SaveProfile(profile_key)

  -- If the profile exists already, delete it so that no options are accidentally left behind
  if type(Cfg.profiles[profile_key]) == 'table' then DeleteTable(Cfg.profiles[profile_key]) end

  local tbl = CopyTable(Cfg.config)
  tbl = PruneTableOfDefaults(tbl)

  -- If the table is empty, aka no difference from the defaults table,
  -- don't save it
  -- if not tbl or next(tbl) == nil then
  --   Cfg.profiles[profile_key] = nil
  -- end
  Cfg.profiles[profile_key] = tbl or {}

end

function Cfg:PruneEmptyProfiles()

  for key, val in pairs(Cfg.profiles) do
    if next(val) == nil then
      Cfg.profiles[key] = nil
    end
  end

end

-- Registers the function that creates a modules config page
-- Modules are responsible for creating their own config pages
-- This function registers it with Cinnabar to be loaded in the
-- config menu
---------------------------------------
-- @ARGUMENTS
-- frame_function   (function)    : The function that creates the config frame
-- module           (string)      : The name of the module
local function RegisterModuleConfigFrame(frame_function, module)

  assert(type(frame_function) == "function" and frame_function, "Function Cfg:RegisterModuleConfigFrame(frame_function, module) not given valid argument for parameter #1")
  assert(type(module) == "string" and module, "Function Cfg:RegisterModuleConfigFrame(frame_function, module) not given valid argument for parameter #2")

  Cfg.ModuleFrames[module] = frame_function


end

-- Registers the function that reloads the module
-- Updating and applying the changes to the  settings of the module
---------------------------------------
-- @ARGUMENTS
-- refresh_function   (function)    : The function that reloads the module
-- module             (string)      : The name of the module
local function RegisterRefreshFunction(refresh_function, module)

  -- Some error checking to make sure nothing wrong gets added to the RefreshFunction
  assert(type(refresh_function) == 'function', "Usage: Cfg:RegisterRefreshFunction(refresh_function, module), expected type 'function' for argument #1 got " .. type(refresh_function))
  assert(type(module) == 'string', "Usage: Cfg:RegisterRefreshFunction(refresh_function, module), expected type 'string' for argument #2 got " .. type(module))

  Cfg.RefreshFunction[module] = refresh_function

end

function Cfg:RegisterModuleWithCinnabar(frame_func, refresh_func, module_name, tree_group)



  if type(frame_func) == 'table' then
    for k, v in pairs(frame_func) do
      RegisterModuleConfigFrame(v, k)
    end
  else
    RegisterModuleConfigFrame(frame_func, module_name)
  end

  RegisterRefreshFunction(refresh_func, module_name)
  if type(tree_group) == 'table' then
    table.insert(Cfg.MainGroup[3].children, tree_group)
  else
    table.insert(Cfg.MainGroup[3].children, {value = module_name:lower(),  text = module_name})
  end

end

-- Calls all the refresh functions
-- that were registered with the config module
-- through Cfg:RegisterRefreshFunction
-- This is called on any Profile Loads and when config options are applied
---------------------------------------
function Cfg:Refresh()

  for _, val in pairs(RefreshFunction or {}) do
    val()
  end

end

-- Copies the profiles, profilekeys, and globals
-- tables into the CinnabarDB saved variable
-- to allow them to persist after restarts
---------------------------------------
function Cfg:SaveConfigToSV()

  local profile_key = Cfg.current_profile
  Cfg:SaveProfile(profile_key)
  -- Copy Database entries into Saved Variable
  DeleteTable(CinnabarDB.profiles)
  DeleteTable(CinnabarDB.profilekeys)
  DeleteTable(CinnabarDB.globals)
  CinnabarDB.profiles     = CopyTable(Cfg.profiles)
  CinnabarDB.profilekeys  = CopyTable(Cfg.profilekeys)
  CinnabarDB.globals      = CopyTable(Cfg.globals)

end

function Cfg:ImportProfileString(profile_string)

  local success, table = Cfg:Deserialize(profile_string)
  for key, val in pairs(table) do
    print(val)
  end

end

function Cfg:CreateProfileString()

  return Cfg:Serialize(Cfg.profiles[Cfg.current_profile])

end

function Cfg:OnInitialize()

  -- Initialize the config table and load the defaults into it
  LoadSavedVariableIntoCfg()
  LoadDefaultsIntoTable(Cfg.config)

  -- Get the character's selected profile
  local key = CreateProfileNameByCharacterName()
  local profile_key = Cfg.profilekeys[key]

  -- If the key doesn't exist, set the character to the default key
  if type(profile_key) ~= 'string' or Cfg.profiles[profile_key] == nil then
    Cfg.profilekeys[key] = 'Default'
    profile_key = 'Default'
  end

  -- Check if default profile even exists just to ensure it always does
  if type(Cfg.profiles['Default']) == 'nil' then
    Cfg.profiles['Default'] = {}
  end

  Cfg:LoadProfile(profile_key)
  Cfg.current_profile = profile_key

  Cfg:Disable()

end

function Cfg:OnEnable()

  Cfg:CreateConfigMenu()

end

function Cfg:UnLoad()
  Cfg:SaveConfigToSV()
end

function Cfg:OnDisable()

  Cfg:UnLoad()

end
