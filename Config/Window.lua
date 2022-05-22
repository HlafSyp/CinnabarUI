local Cinnabar, Util, Cfg, Module = unpack(select(2,...))

local Win = {}
local COLOR = Cinnabar.data.COLORS.UI_FG


function Win:CreateConfigMenu()


end

function Win:CreateCheckButton(parent)

end

function Win:CreateEntryBox(parent)

  assert(type(parent) == 'table', "Function Win:CreateEntryBox(parent) not given valid argument for parameter #1")

  local entry = CreateFrame("EditBox", nil, parent, "InputBoxTemplate")

  return entry

end

function Win:CreateMenuButton(parent, height)

  -- Quick checks to make sure the argument given is valid
  assert(parent ~= nil, "Function Win:CreateMenuButton(parent) not given valid argument for parameter #1,")
  if not height then height = 15 end

  -- Create the button
  local btn = CreateFrame("Button", nil, parent, "TabButtonTemplate")
  -- I couldn't get the btn to be the correct size using SetSize so I'm using SetPoint instead
  btn:SetPoint("LEFT", parent, "LEFT", 6, 0)
  btn:SetPoint("RIGHT", parent, "RIGHT", -6, 0)
  btn:SetHeight(height)

  -- Get rid of unwanted textures
  btn.Left:Hide()
  btn.LeftDisabled:Hide()
  btn.Middle:Hide()
  btn.MiddleDisabled:Hide()
  btn.Right:Hide()
  btn.RightDisabled:Hide()

  -- Fix the font to fit in with the rest of the addon ui
  btn.Text:SetFont(Cinnabar.lsm:Fetch('font', 'BebasNeue-Regular'), 13, "OUTLINE")
  btn.Text:SetTextColor(COLOR.r, COLOR.g, COLOR.b)
  btn.Text:SetJustifyV("MIDDLE")
  btn.Text:SetAllPoints(btn)


  -- Create a better looking bg
  btn.bg = btn:CreateTexture()
  btn.bg:SetAllPoints(btn)
  btn.bg:SetColorTexture(0.15,0.15,0.15,0.2)

  -- Add a backdrop
  btn.backdrop = Win:AddBackdrop(btn, 2)
  btn.backdrop:SetBackdropColor(0,0,0,0.5)
  -- Fix Highlight texture
  btn.HighlightTexture:SetAllPoints(btn)
  btn.HighlightTexture:SetColorTexture(1,1,1,0.1)

  -- Set up some customization functions
  function btn:SetFontSize(size)
    if not size then size = 13 end
    btn.Text:SetFont(Cinnabar.lsm:Fetch('font', 'BebasNeue-Regular'), size, "OUTLINE")
  end

  function btn:SetText(text)
    assert(type(text) == 'string', 'Usage: btn:SetText(text) from Cinnabar.Win expected argument of type string got ' .. type(text))
    btn.Text:SetText(text)
  end

  return btn

end

function Win:CreateTitleBar(parent, height)

  if not height then height = 15 end

  local titlebar = CreateFrame("Frame", nil, parent)
  titlebar:SetPoint("TOPLEFT",  parent, "TOPLEFT",  5, -5)
  titlebar:SetPoint("TOPRIGHT", parent, "TOPRIGHT", -5, -5)
  titlebar:SetHeight(height)

  titlebar.bg = titlebar:CreateTexture()
  titlebar.bg:SetAllPoints(titlebar)
  titlebar.bg:SetColorTexture(0.15,0.15,0.15,1)

  titlebar.backdrop = Win:AddBackdrop(titlebar, 2)

  titlebar.title = titlebar:CreateFontString(nil, "ARTWORK")
  titlebar.title:SetFont(Cinnabar.lsm:Fetch('font', 'BebasNeue-Regular'), 15, 'OUTLINE')
  titlebar.title:SetText("Titlebar")
  titlebar.title:SetPoint("TOPRIGHT")
  titlebar.title:SetPoint("BOTTOMLEFT")
  titlebar.title:SetTextColor(COLOR.r, COLOR.g, COLOR.b)
  titlebar.title:SetJustifyV("MIDDLE")
  function parent:SetTitle(text)

    if not text then text = "Titlebar" end
    titlebar.title:SetText(text)

  end

  function titlebar:SetFontSize(size)

    if not size then size = 15 end
    titlebar.title:SetFont(Cinnabar.lsm:Fetch('font', 'BebasNeue-Regular'), size, 'OUTLINE')

  end

  return titlebar

end

function Win:CreateContainer(parent, width, height, name)

  if not parent then parent = UIParent end
  if not width then width = 500 end
  if not height then height = 500 end

  local Container = CreateFrame("Frame", name, parent)
  Container:SetSize(width, height)
  Container.bg = Container:CreateTexture()
  Container.bg:SetAllPoints(Container)
  Container.bg:SetColorTexture(0.085, 0.085, 0.085, 0.8)

  function Container:AddTitle(text)
    Container.title = Win:CreateTitleBar(self)
    Container:SetTitle(text)
  end

  return Container

end

function Win:AddBackdrop(parent, inset)

  assert(parent ~= nil, "Function Win:AddBackdrop(parent, inset) not given valid argument for parameter #1,")
  if parent == UIParent then return end
  if not inset then inset = 2 end

  Backdrop = CreateFrame("Frame", nil, parent, "BackdropTemplate")
  Backdrop:SetAllPoints(parent)
  Backdrop:SetFrameLevel(parent:GetFrameLevel() == 0 and 0 or parent:GetFrameLevel() - 1)

  Backdrop:SetBackdrop {
    bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
    tile = false,
    tileSize = 0,
    insets = {
      left = -inset,
      right = -inset,
      top = -inset,
      bottom = -inset,
    }
  }
  Backdrop:SetBackdropColor(0,0,0,1)

  return Backdrop

end

function Win:CreateDropdown()


end

Cinnabar.Win = Win