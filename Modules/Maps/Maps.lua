local Cinnabar, Util, Cfg, Module = unpack(select(2,...))

local Maps = Module['Maps']

local BlizzardElements = {
  'MicroButtonAndBagsBar',
  --'MainMenuBarArtFrameBackground',
  'CharacterMicroButton',
  'CollectionsMicroButton',
  'EJMicroButton',
  'AchievementMicroButton',
  'GuildMicroButton',
  'HelpMicroButton',
  'LFDMicroButton',
  'MainMenuMicroButton',
  'QuestLogMicroButton',
  'SpellbookMicroButton',
  'StoreMicroButton',
  'TalentMicroButton',
  'ActionBarDownButton',
  'ActionBarUpButton',
}

local events = {
  'OnClick',
  'OnUpdate',
  'OnLoad',
  'OnEnter',
  'OnLeave',
  'OnHide',
  'OnShow',
  'OnEvent',
  'OnUpdate',
}

local function StripEvents(frame)

  if frame.UnregisterAllEvents then
    frame:UnregisterAllEvents()
  end
  if frame.HasScript then
    for _, event in ipairs(events) do
      if frame:HasScript(event) then
        frame:SetScript(event, nil)
      end
    end
  end

end

local function Remove(frame)

  StripEvents(frame)
  if frame.ClearAllPoints then
    frame:ClearAllPoints()
  end
  if frame.Hide then
    frame:Hide()
  end
  if frame.SetParent then
    frame:SetParent(Cinnabar.trash)
  end

end

local function Minimap_OnMouseWheel(Minimap, direction)

  local newZoomLevel = Minimap:GetZoom() + direction
  Minimap:SetZoom(newZoomLevel >= 0 and newZoomLevel or 0)

end

local function Minimap_OnMouseDown(Minimap, button)

  if button == 'MiddleButton' then
    ToggleDropDownMenu(1, nil, MiniMapTrackingDropDown, "Minimap", 8, 5);
  end

end

function GetMinimapShape()

  return 'SQUARE'

end

local function InitializeMinimap()

  Minimap:SetMaskTexture("Interface\\ChatFrame\\ChatFrameBackground")
  Minimap:EnableMouse(true)
  Minimap:EnableMouseWheel(1)
  Minimap:SetScript('OnMouseWheel', Minimap_OnMouseWheel)
  Minimap:HookScript('OnMouseDown', Minimap_OnMouseDown)

  -- Hide all the random stuff on the minimap

  local list = {
    'MiniMapTrackingIcon',
    'MiniMapTrackingBackground',
    'MiniMapTrackingButton',
    'MiniMapWorldMapButton',
    'MinimapZoneTextButton',
    'MinimapBorderTop',
    'MinimapZoomIn',
    'MinimapZoomOut',
    'MinimapBorder',
    'GameTimeFrame',
    'TimeManagerClockButton'
  }

  for i, v in ipairs(list) do
    Remove(_G[v])
  end

  -- Add a backdrop
  Minimap.Backdrop   = CreateFrame("Frame", nil, Minimap, "BackdropTemplate")
  Minimap.Backdrop:SetAllPoints(Minimap)
  Minimap.Backdrop:SetFrameLevel(Minimap:GetFrameLevel() == 0 and 0 or Minimap:GetFrameLevel() - 1)

  Minimap.Backdrop:SetBackdrop {
    bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
    tile = false,
    tileSize = 0,
    insets = {
      left = -3,
      right = -3,
      top = -3,
      bottom = -3,
    }
  }
  Minimap.Backdrop:SetBackdropColor(0,0,0, 1)

  -- Setup the positioning of the minimap
  Minimap:ClearAllPoints()
  Minimap:SetSize(160, 160)
  Minimap:SetPoint('TOPRIGHT', UIParent, 'TOPRIGHT', -15, -15)

end

function Maps:OnEnable()

  InitializeMinimap()

end