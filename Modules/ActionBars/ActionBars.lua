local Cinnabar, Util, Cfg, Module = unpack(select(2,...))
local Actionbar = Module['ActionBars']

local Pages = {

}

function Actionbar:OnEnable()

  -- Forcefully enable All the action bars
  -- I can handle hiding them in my config
  SHOW_MULTI_ACTIONBAR_1 = true
  SHOW_MULTI_ACTIONBAR_2 = true
  SHOW_MULTI_ACTIONBAR_3 = true
  SHOW_MULTI_ACTIONBAR_4 = true
  InterfaceOptionsActionBarsPanelBottomLeft.value = 1
  InterfaceOptionsActionBarsPanelBottomRight.value = 1
  InterfaceOptionsActionBarsPanelRight.value = 1
  InterfaceOptionsActionBarsPanelRightTwo.value = 1
  MultiActionBar_Update()

  -- Remove all the useless crap blizzard throws onto the screen
  Actionbar:RemoveBlizzard()

end

