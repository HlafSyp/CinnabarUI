local Cinnabar, Util, Cfg, Module = unpack(select(2,...))

Cfg.config = {}

local COLOR = Cinnabar.data.COLORS.UI_PRIMARY

local tinsert = table.insert

local Container
local ModuleFrames = {}
local RefreshFunction = {}

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

-- Simply copies the members of the SV
-- Into the Cfg Table
---------------------------------------
-- @RETURNS
-- Success (boolean)  : Returns false if the Saved Variable table didn't exist
--                      Returns true if it did
local function LoadSavedVariableIntoCfg()
  -- If CinnabarDB doesn't exist set them to empty tables
  if not CinnabarDB then
    Cfg.profiles = {}
    Cfg.profilekeys = {}
    Cfg.globals = {}
    return false
  else
    Cfg.profiles = CinnabarDB.profiles
    Cfg.profilekeys = CinnabarDB.profileKeys
    Cfg.globals =  CinnabarDB.globals
    return true
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
    local t = dst
    for key, val in pairs(src) do

      if type(val) == 'table' then
        t[key] = {}
        cpy(t[key], val)
      else
        t[key] = val
      end

    end

    return t

  end

  return cpy(target, defaults)

end

-- Copies missing members of the defaults table into the
-- Given table
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

  local cpy = function(dst, src)
    for key, val in pairs(profile) do

      if type(val) == 'table' then
        dst[key] = {}
        cpy(dst[key], val)
      else
        dst[key] = val
      end

    end

  end

  cpy(target,profile)

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

  local prune = function(dst,src)

    for key, val in pairs(dst) do
      -- If val is a nested table, prune it
      if type(val) == 'table' then
        prune(dst[key], src[key])
        -- Check if table is empty
        if next(val) == nil then
          dst[key] = nil
        end
      elseif val == src[key] then
        dst[key] = nil
      end
    end
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

  local a = function(dst, src)

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

  local a = function(dst)

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

-- Creates a new profile of the given or default name
-- Default Name is in the form of "[Character Name] - [Realm]"
---------------------------------------
-- @ARGUMENTS
-- profile_table  ? (table)     : The current profile table
-- name           ? (string)    : The defaults table to be compared against
-- @RETURNS
-- profile (table) : The table that was created
function Cfg:CreateNewProfile(profile_table, name)

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

  Cfg.profiles[name] = profile_table

  return Cfg.profiles[name]

end

-- Deletes the profile at the given key
---------------------------------------
-- @ARGUMENTS
-- profile_key     (table)     : The key of the profile to delete
function Cfg:DeleteProfile(profile_key)

  local a = function(tbl)

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

end

-- Copys the profile at the given key
-- to a new profile of name
-- "[profile_key] - Copy"
-- and loads it into the config
---------------------------------------
-- @ARGUMENTS
-- profile_key    (table)     : The key of the profile to copy
function Cfg:CopyProfile(profile_key)

  -- Check if the profile_key actually exists
  if type(Cfg.profiles[profile_key]) ~= 'table' then return nil end

  local tbl = CopyTable(Cfg.profiles[profile_key])
  local new_key = profile_key .. ' - Copy'
  tbl = CreateNewProfile(tbl, new_key)
  Cfg:LoadProfile(new_key)

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

  -- Load the new profile into the table
  Cfg.config = LoadProfileIntoTable(Cfg.config, Cfg.profiles[profile_key])

  Cfg.config = LoadDefaultsIntoTable(Cfg.config)
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
  Cfg.profiles[profile_key] = tbl

end

-- Registers the function that creates a modules config page
-- Modules are responsible for creating their own config pages
-- This function registers it with Cinnabar to be loaded in the
-- config menu
---------------------------------------
-- @ARGUMENTS
-- frame_function   (function)    : The function that creates the config frame
-- module           (string)      : The name of the module
function Cfg:RegisterModuleConfigFrame(frame_function, module)

  assert(type(frame_function) == "function" and frame_function, "Function Cfg:RegisterModuleConfigFrame(frame_function, module) not given valid argument for parameter #1")
  assert(type(module) == "string" and module, "Function Cfg:RegisterModuleConfigFrame(frame_function, module) not given valid argument for parameter #2")

  ModuleFrames[module] = frame_function


end

-- Registers the function that reloads the module
-- Updating and applying the changes to the  settings of the module
---------------------------------------
-- @ARGUMENTS
-- refresh_function   (function)    : The function that reloads the module
-- module             (string)      : The name of the module
function Cfg:RegisterRefreshFunction(refresh_function, module)

  -- Some error checking to make sure nothing wrong gets added to the RefreshFunction
  assert(type(refresh_function) == 'function', "Usage: Cfg:RegisterRefreshFunction(refresh_function, module), expected type 'function' for argument #1 got " .. type(refresh_function))
  assert(type(module) == 'string', "Usage: Cfg:RegisterRefreshFunction(refresh_function, module), expected type 'string' for argument #2 got " .. type(module))

  RefreshFunction[module] = refresh_function

end

-- Calls all the refresh functions
-- that were registered with the config module
-- through Cfg:RegisterRefreshFunction
-- This is called on any Profile Loads and when config options are applied
---------------------------------------
function Cfg:Refresh()

  for _, val in pairs(RefreshFunction) do
    val()
  end

end

function Cfg:SaveConfigToSV()

  local profile_key = Cfg.current_profile
  SaveProfile(profile_key)

  CinnabarDB.profiles = Cfg.profiles
  CinnabarDB.profilekeys= Cfg.profilekeys
  CinnabarDB.globals = Cfg.globals

end

function Cfg:OnInitialize()

  -- Initialize the config table and load the defaults into it
  local success = LoadSavedVariableIntoCfg()
  LoadDefaultsIntoTable(Cfg.config)

  -- Get the character's selected profile
  local key = CreateProfileNameByCharacterName()
  local profile_key = Cfg.profilekeys[key]

  -- If the key doesn't exist, set the character to the default key
  if type(profile_key) ~= 'string' then
    Cfg.profilekeys[key] = 'default'
    profile_key = 'default'

    -- Check if default profile even exists
    if type(Cfg.profiles[profile_key]) == 'nil' then
      Cfg.profiles[profile_key] = {}
    end
  end

  for key, val in pairs(Cfg.profiles) do
    Util:Print(key)
  end

  -- Load the profile into the config table
  LoadProfileIntoTable(Cfg.config, Cfg.profiles[profile_key])

  Cfg:Disable()

end

function Cfg:OnEnable()


end

function Cfg:OnDisable()


end
