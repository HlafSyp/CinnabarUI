local Cinnabar, Util, Cfg, Module = unpack(select(2,...))
local COLOR = Cinnabar.data.COLORS.UI_PRIMARY

local function RegisterMouseOptions(frame)

  -- Enable Dragging and closing with right click
  frame:EnableMouse(true)
  frame:SetMovable(true)
  frame:RegisterForDrag("LeftButton")
  frame:SetScript("OnMouseUp", function(self, button)

    if button == 'RightButton' then
      Cfg:Disable()
    end

  end)
  frame:SetScript("OnDragStart", function(self)

    self:StartMoving()
  end)
  frame:SetScript("OnDragStop", function(self)

    self:StopMovingOrSizing()

  end)

  return frame

end

function Cfg:CreateConfigMenu()

  -- Create the base of the Config Menu
  local container = CreateFrame("Frame", "CinnabarUIConfig", UIParent)
  container:SetPoint("CENTER")
  container:SetSize(905, 600)
  container.options = Cinnabar.Win:CreateContainer(container, 750, 600)
  container.tabs = Cinnabar.Win:CreateContainer(container, 150, 600)
  container.options:SetPoint("BOTTOMRIGHT")
  container.options:SetPoint("TOPRIGHT")
  container.tabs:SetPoint("TOPLEFT")
  container.tabs:SetPoint("BOTTOMRIGHT")
  container.tabs:SetPoint("RIGHT", container.options, "LEFT", -5, 0)
  container = RegisterMouseOptions(container)

  -- Add title bar to both windows
  container.options:AddTitle("Cinnabar Options")
  container.tabs:AddTitle("Sections")

  -- Add general options tabs
  container.tabs.general = Cinnabar.Win:CreateMenuButton(container.tabs)
  container.tabs.general:SetPoint("TOP", container.tabs.title, "BOTTOM", 0, -5)
  container.tabs.general:SetText("General")
  container.tabs.profile = Cinnabar.Win:CreateMenuButton(container.tabs)
  container.tabs.profile:SetPoint("TOP", container.tabs.general, "BOTTOM", 0, -5)
  container.tabs.profile:SetText("Profiles")

  return container

end