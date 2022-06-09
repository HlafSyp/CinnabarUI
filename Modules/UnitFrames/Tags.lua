local Cinnabar, Util, Cfg, _ = unpack(select(2,...))
local oUF = select(2,...).oUF

-- Pulled out of oUF_AuraBars.lua
local function ShortenName(name, length)
	return string.len(name) > length and string.gsub(name, '%s?(.)%S+%s', '%1. ') or name
end

oUF.Tags.Methods['Cinnabar:curhp'] = function(unit, realUnit)

    local health = UnitHealth(unit)
    local Shorten = Cfg.config.UnitFrames[unit].HealthBar.ShortenHealthText
    local precision = Cfg.config.UnitFrames[unit].HealthBar.HealthTextPrecision
    -- Because Tags are held in strings, the type of precision is a string rather than a number
    -- This is regardless of what type you make it in the config file
    if precision then precision = tonumber(precision) end
    if Shorten == true and precision then
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

    local AbsOrPerc = Cfg.config.UnitFrames.PercentagePower
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

oUF.Tags.Methods['Cinnabar:smartname'] = function(unit, realUnit)

    local name = UnitName(unit)
    local ColorText = Cfg.config.UnitFrames[unit].HealthBar.ColorLevelText
    local Mirror    = Cfg.config.UnitFrames[unit].Mirror
    -- Forgot that names can be long as hell
    -- This bit shortens the name text
    name = ShortenName(name, 7)

    local level             = UnitLevel(unit)
    local effective_level   = UnitEffectiveLevel(unit)

    if unit == 'target' and ColorText == true and level ~= Cinnabar.data.MAX_LEVEL then

        local color = GetCreatureDifficultyColor(effective_level)
        if level == -1 or level == '-1' then
            level = '??'
        end
        color = ConvertRGBtoColorString(color)
        level = color .. level

    end

    -- If the level is capped, discard it, don't need to display shit that is assumed
    if level == Cinnabar.data.MAX_LEVEL then level = '' end

    if Mirror == true then
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
