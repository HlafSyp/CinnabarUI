--[[

	oUF Element: .AuraBars

	Options regarding visual layout:
	 -	<element>.auraBarHeight
			Sets the height of the statusbars and icons.
	 -	<element>.auraBarWidth
			Sets the width of the statusbars (excluding icon). Will use the
			framewidth of <element> by default.
	 -	<element>.auraBarTexture
			Sets the statusbar texture.
	 -	<element>.fgalpha
			Foreground alpha.
	 -	<element>.bgalpha
			Background alpha.
	 -	<element>.spellTimeObject, <element>.spellNameObject
			Objects passed by CreateFontObject(). These will ignore the
			following options:
			<element>.spellTimeFont, <element>.spellTimeSize
			<element>.spellNameFont, <element>.spellNameSize
	 -	<element>.spellTimeFont, <element>.spellTimeSize,
		<element>.spellNameFont, <element>.spellNameSize
			Options to control the texts on the statusbars.
	 -	<element>.gap
			Will add space between the statusbars and icons by amount of .gap
			in pixels.
	 -	<element>.spacing
			Will add space between statusbars by amount of .spacing in pixels.

	Options regarding functionality:
	 -	<element>.down
			Will let the aurabars grow downwards.
	 -	<element>.filter(name, rank, icon, count, debuffType, duration, expirationTime, unitCaster, isStealable)
			Use this to filter out specific casts.
	 -	<element>.sort
			Will enable sorting if set to true or 1 (or whatever). See
			functions for info on how to override the sort function.
	 -	<element>.scaleTime
			Will add time-scaling (bar widths according to the total duration
			of the aura assigned to it). Will use the minimum of
			<element>.scaleTime and the total aura duration to determine the
			width in percent.

	Functions that can be overridden from within a layout:
	 -	<element>.PostCreateBar(bar)
			To do stuff to a bar once it has been created, such as set a
			backdrop, etc, use this function. Use bar:GetParent() to get the
			<element> object.
	 -	<element>.sort(a, b)
			Custom compare function to sort aura's before the bars are being
			updated. Is being called every UNIT_AURA for the <element>'s unit.
--]]

local _, ns = ...
local oUF = ns.oUF or oUF
assert(oUF, 'oUF_AuraBars was unable to locate oUF install.')

local HexLookup = {'0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'A', 'B', 'C', 'D', 'E', 'F'}
--[[
		Shortens an spell name to a given length
]]--
local function ShortenedSpellName(spellName, length)
	return string.len(spellName) > length and string.gsub(spellName, '%s?(.)%S+%s', '%1. ') or spellName
end

--[[
		Rounds a number to a given number of decimal places.
]]--
local function Round(number, decimalPlaces)
	if decimalPlaces and decimalPlaces > 0 then
		local mult = 10^decimalPlaces
		return math.floor(number * mult + .5) / mult
	end
	return math.floor(number+ .5)
end

--[[
		Formats time in seconds to either
		h:m
		m:s
		s
]]--
local function FormatTime(timeInSec)
	local h = math.floor(timeInSec / 3600)
	local m = math.floor((timeInSec - (3600 * h)) / 60)
	local s = math.floor(timeInSec - ((3600 * h) + (60 * m)))
	if h > 0 then
		return h .. ":" .. m .. "h"
	elseif m > 0 then
		return m .. "m"
	else
		return s .. "s"
	end
end

-- (HlafSyp, CinnabarUI Creator) Since I color the names of debuffs
-- Needed a function which could convert RGB to hex to be used in FontStrings
-- And I didn't want to modify my oUF library so I added it to  oUF_AuraBars.lua
-- It isn't perfect but fuck lua


--[[
		Creates a bar to represent an aura
]]--
local function CreateAuraBar(oUF, anchor)
	local auraBarParent = oUF.AuraBars

	-- the main bar
	local statusBar = CreateFrame("StatusBar", nil, auraBarParent)
	statusBar:SetHeight(auraBarParent.auraBarHeight or 20)
	statusBar:SetWidth((auraBarParent.auraBarWidth or auraBarParent:GetWidth()) - (statusBar:GetHeight() + (auraBarParent.gap or 0)))
	statusBar:SetStatusBarTexture(auraBarParent.auraBarTexture or [[Interface\TargetingFrame\UI-StatusBar]])
	statusBar:SetStatusBarColor(0, .5, 0)
	statusBar:SetAlpha(auraBarParent.fgalpha or 1)

	-- the background
	statusBar.bg = statusBar:CreateTexture(nil, "BORDER")
	statusBar.bg:SetAllPoints(statusBar)
	statusBar.bg:SetTexture(auraBarParent.auraBarTexture or [[Interface\TargetingFrame\UI-StatusBar]])
	statusBar.bg:SetVertexColor(.5, 1, .5)
	statusBar.bg:SetAlpha(auraBarParent.bgalpha or 1)

	if auraBarParent.down == true then
		if auraBarParent == anchor then -- Root frame so indent for icon
			statusBar:SetPoint('TOPLEFT', anchor, 'BOTTOMLEFT', (statusBar:GetHeight() + (auraBarParent.gap or 0) ), 0)
		else
			statusBar:SetPoint('TOPLEFT', anchor, 'BOTTOMLEFT', 0, (-auraBarParent.spacing or 0))
		end
	else
		if auraBarParent == anchor then -- Root frame so indent for icon
			-- (HlafSyp, BluUI Creator) Changed these from BOTTOMLEFT and TOPLEFT to BOTTOMRIGHT and TOPRIGHT
			-- This was done so that the smallBar part of my addon could work
			-- Since I don't give the option for downward growing aura bars, this change wasn't
			-- made to that part of the if statement,
			-- Anyone wanting downward growing aurabars, and small bars, would need to make the same changes
			-- To anchor to the right instead of the left, as well as a few other tweaks to my part of the
			-- post create function
			statusBar:SetPoint('BOTTOMRIGHT', anchor, 'TOPRIGHT', (auraBarParent.gap or 0), 0)
		else
			statusBar:SetPoint('BOTTOMRIGHT', anchor, 'TOPRIGHT', 0, (auraBarParent.spacing or 0))
		end
	end

	statusBar.icon = statusBar:CreateTexture(nil, 'BACKGROUND')
	statusBar.icon:SetHeight(statusBar:GetHeight())
	statusBar.icon:SetWidth(statusBar:GetHeight())
	statusBar.icon:SetTexCoord(.07, .93, .07, .93)
	statusBar.icon:SetPoint'TOP'
	statusBar.icon:SetPoint('LEFT', auraBarParent)

	statusBar.spelltime = statusBar:CreateFontString(nil, 'ARTWORK')
	if auraBarParent.spellTimeObject then
		statusBar.spelltime:SetFontObject(auraBarParent.spellTimeObject)
	else
		-- (HlafSyp, CinnabarUI Creator) Made it so that the text would have outlines to improve readability
		statusBar.spelltime:SetFont(auraBarParent.spellTimeFont or [[Fonts\FRIZQT__.TTF]], auraBarParent.spellTimeSize or 10, 'OUTLINE')
	end
	statusBar.spelltime:SetTextColor(1 ,1, 1)
	statusBar.spelltime:SetJustifyH'RIGHT'
	statusBar.spelltime:SetJustifyV'CENTER'
	statusBar.spelltime:SetPoint'RIGHT'

	statusBar.spellname = statusBar:CreateFontString(nil, 'ARTWORK')
	if auraBarParent.spellNameObject then
		statusBar.spellname:SetFontObject(auraBarParent.spellNameObject)
	else
		-- (HlafSyp, CinnabarUI Creator) Made it so that the text would have outlines to improve readability
		statusBar.spellname:SetFont(auraBarParent.spellNameFont or [[Fonts\FRIZQT__.TTF]], auraBarParent.spellNameSize or 10, 'OUTLINE')
	end
	statusBar.spellname:SetTextColor(1, 1, 1)
	statusBar.spellname:SetJustifyH'LEFT'
	statusBar.spellname:SetJustifyV'CENTER'
	statusBar.spellname:SetPoint'LEFT'
	statusBar.spellname:SetPoint('RIGHT', statusBar.spelltime, 'LEFT')

	-- Save the color option to the bar to be used in the update function (HlafSyp - BluUI)
	statusBar.classColored = auraBarParent.classColored

	if auraBarParent.PostCreateBar then
		auraBarParent.PostCreateBar(statusBar)
	end

	return statusBar
end

--[[
		Update all visable bars, if a bar's aura expires there is no need to remove expired
		auras, as the Update function will be triggered when the buff drops
]]--
local function UpdateBars(auraBars)
	local bars = auraBars.bars
	local timenow = GetTime()

	for index = 1, #bars do
		local bar = bars[index]
		if not bar:IsVisible() then
			break
		end
		if bar.aura.noTime then
			bar.spelltime:SetText()
		else
			local timeleft = bar.aura.expirationTime - timenow
			bar:SetValue(timeleft)
			bar.spelltime:SetText(FormatTime(timeleft))
		end
	end
end

--[[
		Default filter
]]--
local function DefaultFilter(name, icon, count, debuffType, duration, expirationTime, unitCaster, isStealable, spellId)
	if unitCaster == 'player' then
		return true
	end
end

local sort = function(a, b)
	local compa, compb = a.noTime and math.huge or a.expirationTime, b.noTime and math.huge or b.expirationTime
	return compa > compb
end

local function GatherAuras(self, auras, lastAuraIndex, unit,  helpOrHarm)

	for index = 1, 40 do
		-- (HLafSyp, CinnabarUI Creator) The returns of UnitAura() has changed
		-- rank is no longer returned as part of UnitAura() so it has been removed from all
		-- places referencing it
		-- and in it's place lie spellID
		local name, icon, count, debuffType, duration, expirationTime, unitCaster, isStealable, _, spellId = UnitAura(unit, index, helpOrHarm)
		if not name then break end
		if (self.AuraBars.filter or DefaultFilter)(name, icon, count, debuffType, duration, expirationTime, unitCaster, isStealable, spellId) then
			lastAuraIndex = lastAuraIndex + 1
			auras[lastAuraIndex] = {}
			auras[lastAuraIndex].index = index
			auras[lastAuraIndex].name = name
			auras[lastAuraIndex].icon = icon
			auras[lastAuraIndex].count = count
			auras[lastAuraIndex].debuffType = debuffType
			auras[lastAuraIndex].duration = duration
			auras[lastAuraIndex].expirationTime = expirationTime
			auras[lastAuraIndex].unitCaster = unitCaster
			auras[lastAuraIndex].isStealable = isStealable
			auras[lastAuraIndex].spellId = spellId -- (HlafSyp, CInnabarUI Creator) Made this addition to the filter list so that my config file can be used
			auras[lastAuraIndex].IsBuff = (helpOrHarm == 'HELPFUL') -- (HlafSyp, CinnabarUI Creator)  Added this for the coloring of debuffs
																	-- As it sat, debuffs looked exactly the same as buffs, which made it hard to see what was what at a glance
			auras[lastAuraIndex].noTime = (duration == 0 and expirationTime == 0)
		end
	end
	return auras, lastAuraIndex
end

--[[
		Main update function, gathers the buffs/debuffs base on a filter.  Then for each buff/debuff a status bar is shown
		monitoring it's remaining time.
]]--
local function Update(self, event, unit)
	if self.unit ~= unit then return end
	local helpOrHarm = UnitIsFriend('player', unit) and 'HELPFUL' or 'HARMFUL'

	-- Create a table of auras to display
	local auras = {}
	local lastAuraIndex = 0

	-- (HlafSyp, CinnabarUI Creator) Because of the way UnitAura() works, a new function to gather all the auras needs to be used
	-- So the for loop used to iterate over every aura slot is bumped to a function to allow  code to just be reused
	auras, lastAuraIndex = GatherAuras(self, auras, lastAuraIndex, unit, "HELPFUL")
	auras, lastAuraIndex = GatherAuras(self, auras, lastAuraIndex, unit, "HARMFUl")

	if self.AuraBars.sort then
		table.sort(auras, type(self.AuraBars.sort) == 'function' and self.AuraBars.sort or sort)
	end

	-- Show and configure bars for buffs/debuffs.
	local bars = self.AuraBars.bars
	for index = 1 , lastAuraIndex do
		local aura = auras[index]
		local bar = bars[index]

		if not bar then
			bar = CreateAuraBar(self, index == 1 and self.AuraBars or bars[index - 1])
			bars[index] = bar
		end

		-- Backup the details of the aura onto the bar, so the OnUpdate function can use it
		bar.aura = aura

		-- Configure
		if bar.aura.noTime then
			bar:SetMinMaxValues(0, 1)
			bar:SetValue(1)
		else
			if self.AuraBars.scaleTime then
				local maxvalue = math.min(self.AuraBars.scaleTime, bar.aura.duration)
				bar:SetMinMaxValues(0, maxvalue)
				bar:SetWidth(
					( maxvalue / self.AuraBars.scaleTime ) *
					(	( self.AuraBars.auraBarWidth or self.AuraBars:GetWidth() ) -
						( bar:GetHeight() + (self.AuraBars.gap or 0) ) ) ) 				-- icon size + gap
			else
				bar:SetMinMaxValues(0, bar.aura.duration)
			end
			bar:SetValue(bar.aura.expirationTime - GetTime())
		end

		bar.icon:SetTexture(bar.aura.icon)

		bar.spellname:SetText(bar.aura.count > 1 and string.format("%s [%d]", ShortenedSpellName(bar.aura.name, 20), bar.aura.count) or ShortenedSpellName(bar.aura.name, 20))
		bar.spelltime:SetText(not bar.noTime and FormatTime(bar.aura.expirationTime-GetTime()))
		-- Colour bars
		local r, g, b = .2, .6, 1 -- Colour for buffs (This is Magic Blue)
		local bgMod = 0.5
		if not bar.aura.IsBuff then
			local debuffType = bar.aura.debuffType and bar.aura.debuffType or 'none'
			r, g, b = DebuffTypeColor[debuffType].r, DebuffTypeColor[debuffType].g, DebuffTypeColor[debuffType].b
		end

		-- Check if the classColored option has been saved onto the bar
		-- Since annoyingly, the colors are updated every update call
		-- (HlafSyp, CinnabarUI Creator)
		if bar.classColored then
			local colors = oUF.colors.class[select(2,UnitClass(unit))]
			bar:SetStatusBarColor(colors[1], colors[2], colors[3])
			if not bar.aura.IsBuff then
				bar.icon.backdrop:SetBackdropColor(r,g,b, select(4, bar.icon.backdrop:GetBackdropColor()))
			else
				bar.icon.backdrop:SetBackdropColor(0,0,0, select(4, bar.icon.backdrop:GetBackdropColor()))
			end
		else
			bar:SetStatusBarColor(r, g, b)
		end
		local color = {bar:GetStatusBarColor()}
		bar.bg:SetVertexColor(color[1] * bgMod, color[2] * bgMod, color[3] * bgMod)
		bar:Show()
	end

	-- Hide unused bars.
	for index = lastAuraIndex + 1, #bars do
		bars[index]:Hide()
	end
end

--[[
	Enable function for oUF
]]--
local function Enable(self)
	if self.AuraBars then
		self:RegisterEvent('UNIT_AURA', Update)
		self.AuraBars.bars = self.AuraBars.bars or {}
		self.AuraBars:SetScript('OnUpdate', UpdateBars)
		return true -- Ensure we get an update when the parent frame is displayed
	end
end

--[[
	Disable function for oUF
]]--
local function Disable(self)
	local auraFrame = self.AuraBars
	if auraFrame then
		self:UnregisterEvent('UNIT_AURA', Update)
		auraFrame:SetScript'OnUpdate'
	end
end

oUF:AddElement('AuraBars', Update, Enable, Disable)