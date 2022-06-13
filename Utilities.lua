local Cinnabar, Util, Cfg, Module = unpack(select(2,...))

local ADDON_PREFIX_COLOR = Cinnabar.data.COLORS.UI_PRIMARY.hex

-- GLOBAL FUNCTIONS
local string_find = string.find
local type, assert, tostring, tonumber = type, assert, tostring, tonumber
local string_format = string.format
local string_sub = string.sub
local string_len = string.len
local string_match = string.match


-- Prints a message into the default chat frame
-- pretty *insert aggressive word* self explanatory
---------------------------------------
-- @ARGUMENTS
-- message (string) : The message to print to the chat frame
function Util:Print(message)

  if type(message) == "nil" then message = "nil" end
  if type(message) == 'boolean' then message = message and "true" or "false" end
  local msg_prefix = string_format("|c%sCinnabarUI|r: ", ADDON_PREFIX_COLOR)
  DEFAULT_CHAT_FRAME:AddMessage(string_format("%s %s", msg_prefix, message))

end

-- Looks through the unit's auras for a mount buff, then returns the mount id of that mount
---------------------------------------
-- @ARGUMENTS
-- unit (string) : The unitid of the unit (player,  target, etc)
-- @RETURNS
-- mountID (number) : The mountID of the mount the unit is currently riding
function Util:GetMountIDFromUnitAura(unit)

  assert(type(unit) == 'string', "Type of unit given to  GetMountIDFromSpellID(spellID) of wrong type (expected string, got " .. type(unit))

  -- Hard define it as nil just to make it more readable on what will happen if nothing is found
  local mountID = nil
  -- Get the mount id of the player's current mount
  for i=1, 40 do
  local spellID = select(10,UnitAura(unit, i))
  if not spellID then break end -- Break out early if there's no aura
    for j=1, #Cinnabar.data.Mount.SpellIDs do
      if Cinnabar.data.Mount.SpellIDs[j] == spellID then
      mountID = Cinnabar.data.Mount.IDs[j]
      end
    end
  end

  return mountID

end

-- Formats a number in the form, xxx,xxx,xxx, etc
-- credit http://richard.warburton.it
-- Obtained from http://lua-users.org/wiki/FormattingNumbers
-- Because I hate dealing with regex expressions
---------------------------------------
-- @ARGUMENTS
-- number    (number) : The number to format
-- @RETURNS
-- number    (string) : Returns the string form of the formated number
function Util:FormatNumber(number)
  assert(type(number) == 'number', "Usage: Util:FormatNumber(number) expected type 'number' for argument #1, got " .. type(number))
  local left,num,right = string_match(number,'^([^%d]*%d)(%d*)(.-)$')
  return left..(num:reverse():gsub('(%d%d%d)','%1,'):reverse())..right
end

function Util:SplitStringByPercent(str, perc)

  if perc > 1 then perc = perc / 100 end
  local length = string.len(str)
  local End = Round(length * perc)
  local front = string.sub(str, 1, End)
  local back = string.sub(str, End + 1, -1)

  return front, back

end

-- Shortens a number to the desired form and with the desired precision
-- This is extremely overly complicated but whatever, I like how it looks
-- 1 - No abbreviations but cut to correct precision
-- 2 - Shortened to the nearest million (I hope this never gets used)
-- 3 - Shortened to the nearest thousand
---------------------------------------
-- @ARGUMENTS
-- form      (number) : Detailed above, determines what rounding and abbreviation will be used
-- precision (number) : Determines the number of digits after the decimal will be present
-- @RETURNS
-- value (string) : Returns the string form of the formated number, with abbreviations
function Util:ShortenNumber(form, precision, value)

  -- Error checking
  assert(form <= 3 and form > 0, "Call to ShortenNumber(form, precision, value) given invalid parameter. Form must be 1, 2, 3. Given " .. form)
  assert(precision >= 0, "Call to ShortenNumber(form, precision, value) given invalid parameter. precision must be greater than 0. Given " .. precision)
  assert(type(form) == "number" and type(precision) == "number",
         "Call to ShortenNumber(form, precision, value) given invalid parameter. form and precision must be of type \"number\". Given " .. type(form) .. "," .. type(precision))
  assert(type(value) ==  "number" or type(value) == "string",
         "Call to ShortenNumber(form, precision, value) given invalid parameter. value must be of type \"number\" or \"string\". Given " .. type(value))
  local affix
  value = tonumber(value) -- Convert value to a number so it can be used in math equations
  if form == 2 then
    affix = 'M'
    value = value / 1000000
  elseif form == 3 then
    affix = 'K'
    value = value / 1000
  end

  value = tostring(value) -- Convert it to a string so the precision can be more easily controlled

  -- Find the decimal and any numbers after it
  local i, j = string_find(value, "%.%d+")

  if j == nil then return value end
  -- Have to cap precision to the number of decimals
  if precision > (j - i) then
    precision = (j - i)
  end
  -- If precision is 0, then simply leave it there since the decimal doesn't need to be preserved then
  if precision ~= 0 then
    precision = precision + 1
  end

  value = string_sub(value, 1, (i - 1) + precision)
  value = value .. affix
  return value

end
