local Cinnabar, Util, Cfg, Module = unpack(select(2,...))

Cfg.config = {}

local tinsert = table.insert

local Container
local ModuleFrames = {}

local function CreateTabButtons(parent)

  local tabs = {}
  for name, module in Cinnabar:IterateModules() do

    if module ~= Cfg then
      local btn = Cinnabar.Win:CreateMenuButton(parent)
      if #tabs ~= 0 then
        btn:SetPoint("TOP", tabs[#tabs], "BOTTOM", 0, -10)
      end
      btn:SetText(name)
      tinsert(tabs,btn)
    end

  end

  return tabs

end

local function CreateConfigMenu()

  -- Util:Print("Container Created")
  Container         = CreateFrame("Frame", "CinnabarUiConfig", UIParent)
  Container.Options = Cinnabar.Win:CreateContainer(Container, 600, 500)
  Container.Tabs    = Cinnabar.Win:CreateContainer(Container, 150, 500)

  Container:SetSize(752, 500)
  Container:SetPoint("CENTER")
  Container.Options:SetPoint("TOPRIGHT")
  Container.Tabs:SetPoint("RIGHT", Container.Options, "LEFT", -2, 0)

  Container.Options.Titlebar = Cinnabar.Win:CreateTitleBar(Container.Options)
  Container.Options.Titlebar:SetTitle("Cinnabar Config Menu")

  Container.Tabs.Titlebar = Cinnabar.Win:CreateTitleBar(Container.Tabs)
  Container.Tabs.Titlebar:SetTitle("Modules")
  Container.Tabs.tabs = CreateTabButtons(Container.Tabs)
  Container.Tabs.tabs[1]:SetPoint("TOP", Container.Tabs.Titlebar, "BOTTOM", 0, -10)

  -- Enable right-click to close function
  -- and dragging
  Container:SetMouseClickEnabled(true)
  Container:SetMovable(true)
  Container:RegisterForDrag("LeftButton")
  Container:SetScript("OnDragStart", function(self)
    self:StartMoving()
  end)
  Container:SetScript("OnDragStop", function(self)
    self:StopMovingOrSizing()
  end)
  Container:SetScript("OnMouseDown", function(self, button)

    if button == "RightButton" then
      Cfg:Disable()
    end

  end)

end

function Cfg:RegisterModuleConfigFrame()

end

function Cfg:OnInitialize()
  --Cfg:Disable()
end

function Cfg:OnEnable()

  if not Container then
    CreateConfigMenu()
  else
    Container:Show()
  end

end

function Cfg:OnDisable()

  -- Util:Print("Config Menu Closed")
  Container:Hide()

end

function Cfg:GetValue(key_path)

  local keys = {}
  for str in key_path:gmatch("%P+") do
    tinsert(keys, str)
  end
  local a = function(tbl)
    local t = tbl
    for _, key in ipairs(keys) do
      if t[key] == nil then return end
      t = t[key]
    end
    return t
  end
  return a(Cfg.config) or a(Cfg.defaults)

end
