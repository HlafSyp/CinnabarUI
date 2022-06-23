local Cinnabar, Util, Cfg, Module = unpack(select(2,...))

local Actionbars = Module['ActionBars']

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

local trash = CreateFrame("Frame", nil, UIParent)
trash:Hide()

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

  frame:ClearAllPoints()
  frame:Hide()
  frame:SetParent(trash)

end

function Actionbars:RemoveBlizzard()

  for i,btnName in ipairs(BlizzardElements) do
    local button = _G[btnName]
    if button then
      StripEvents(button)
      Remove(button)
    end
  end
  StatusTrackingBarManager:UnregisterAllEvents()
  MainMenuBarArtFrameBackground:UnregisterAllEvents()
  for i, event in ipairs(events) do
    if StatusTrackingBarManager:HasScript(event) then
      StatusTrackingBarManager:SetScript(event, nil)
    end
    if MainMenuBarArtFrameBackground:HasScript(event) then
      MainMenuBarArtFrameBackground:SetScript(event, nil)
    end
  end
  MainMenuBarArtFrameBackground:Hide()
  StatusTrackingBarManager:SetAlpha(0)

  -- Hide the Artwork on the side of the action bars
  local leftArt = MainMenuBarArtFrame.LeftEndCap
  local rightArt = MainMenuBarArtFrame.RightEndCap
  local pageNum = MainMenuBarArtFrame.PageNumber
  Remove(leftArt)
  Remove(rightArt)
  Remove(pageNum)

end

Cinnabar.trash = trash