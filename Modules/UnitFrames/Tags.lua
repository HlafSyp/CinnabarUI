local Cinnabar, Util, Cfg, _ = unpack(select(2,...))
local oUF = select(2,...).oUF
-- luacheck: ignore
oUF.Tags.Methods['Cinnabar:curhp'] = function(unit, realUnit, Shorten, precision)

    local health = UnitHealth(unit)

    -- Because Tags are held in strings, the type of precision is a string rather than a number
    -- This is regardless of what type you make it in the config file
    if precision then precision = tonumber(precision) end
    if Shorten == 'true' and precision then
        assert(type(precision) == "number", "Type given to oUF Tag function, ['Cinnabar:curhp'] parameter, precision invalid (expected number, got " .. type(precision) .. ")")
        if health < 10000 then
            return health
        else
            health = Util:ShortenNumber(3,1,health)
        end
    end

    return health

end

oUF.Tags.Methods['Cinnabar:smartpower'] = function(unit, realUnit)

    local AbsOrPerc = Cfg.defaults.UnitFrames.PercentagePower
    local class = select(2,UnitClass(unit))
    local spec = GetSpecialization()

    if spec and unit == 'player' and AbsOrPerc[class][spec] then
        local MaxPower, CurPower = UnitPowerMax(unit), UnitPower(unit)
        local percpower = CurPower / MaxPower
        return string.format("%d%%", percpower * 100)
    else
        return UnitPower(unit)
    end
end

oUF.Tags.Methods['Cinnabar:smartname'] = function(unit, realUnit, ColorText, Mirror)

    local name = UnitName(unit)

    -- Forgot that names can be long as hell
    -- This bit shortens the name text to a max of 7 Characters
    name = string.sub(name, 1, 7)

    local level = UnitLevel(unit)

    if unit == 'target' and ColorText == 'true' and level ~= Cinnabar.data.MAX_LEVEL then
        -- These are substitute strings for use in string.format
        local easyTarget =  '|cFF00FF00%s|r' -- Colors the text green
        local mediumTarget = '|cFF00FFFF%s|r' -- Colors the text yellow
        local hardTarget = '|cFFFF5555%s|r' -- Colors the text a light red

        -- Define the players's level in a seperate variable
        -- cause it's gonna be used in a few checks
        local playerLevel = UnitLevel('player')
        if level == -1 then
            if level == -1 then level = '??' end
            level = string.format(hardTarget, level)
        elseif level + 5 < playerLevel then
            level = string.format(easyTarget, level)
        elseif level > playerLevel + 15 then
            level = string.format(hardTarget ,level)
        elseif level > playerLevel + 10 then
            level = string.format(mediumTarget ,level)
        end

    end

    -- If the level is capped, discard it, don't need to display shit that is assumed
    if level == Cinnabar.data.MAX_LEVEL then level = '' end

    if Mirror == 'true' then
        return string.format("%s %s", name, level)
    else
        return string.format("%s %s", level, name)
    end
end

-- oUF tag event register
oUF.Tags.Events['Cinnabar:curhp'] = 'UNIT_HEALTH UNIT_MAXHEALTH'
oUF.Tags.Events['Cinnabar:smartname'] = 'UNIT_LEVEL PLAYER_LEVEL_UP UNIT_NAME_UPDATE'


oUF.Tags.Events['Cinnabar:smartpower'] = 'UNIT_MAXPOWER UNIT_POWER_FREQUENT UNIT_POWER_UPDATE'
oUF.colors.power[0] = {46 / 255, 140 / 255, 250 / 255}
oUF.colors.power.MANA = oUF.colors.power[0]
