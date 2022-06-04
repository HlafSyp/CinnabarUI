--[[-----------------------------------------------------------------------------
Aura Widget
Icon and label of an aura with Tooltips
-------------------------------------------------------------------------------]]
local  Type, Version = 'Aura', 1
local AceGUI = LibStub and LibStub("AceGUI-3.0", true)
if not AceGUI or (AceGUI:GetWidgetVersion(Type) or 0) >= Version then return end

local function Constructor()

  local frame = CreateFrame('Button', nil, UIParent)
  frame:Hide()

  frame:EnableMouse(true)
  frame:SetScript('OnClick', Button_OnClick)
  frame:SetScript('OnEnter', Control_OnEnter)
  frame:SetScript('OnLeave', Control_OnLeave)

  local label = frame:CreateFontString(nil, "BACKGROUND", "GameFontHighlightSmall")
	label:SetPoint("BOTTOMLEFT")
	label:SetPoint("BOTTOMRIGHT")
	label:SetJustifyH("CENTER")
	label:SetJustifyV("TOP")
	label:SetHeight(18)

	local image = frame:CreateTexture(nil, "BACKGROUND")
	image:SetWidth(64)
	image:SetHeight(64)
	image:SetPoint("TOP", 0, -5)

	local highlight = frame:CreateTexture(nil, "HIGHLIGHT")
	highlight:SetAllPoints(image)
	highlight:SetTexture(136580) -- Interface\\PaperDollInfoFrame\\UI-Character-Tab-Highlight
	highlight:SetTexCoord(0, 1, 0.23, 0.77)
	highlight:SetBlendMode("ADD")

  local widget = {
		label = label,
		image = image,
		frame = frame,
		type  = Type
	}
	for method, func in pairs(methods) do
		widget[method] = func
	end

end

AceGUI:RegisterWidgetType(Type, Constructor, Version)