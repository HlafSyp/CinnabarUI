local Cinnabar, Util, Cfg, Module = unpack(select(2,...))
local Actionbar = Module['ActionBars']

function Actionbar:GetButton(id)
  if id <= 12 then
      return _G[('ActionButton%d'):format(id)]
  elseif id <= 24 then
      return Actionbar:CreateButton(id - 12)
  elseif id <= 36 then
      return _G[('MultiBarRightButton%d'):format(id - 24)]
  elseif id <= 48 then
      return _G[('MultiBarLeftButton%d'):format(id - 36)]
  elseif id <= 60 then
      return _G[('MultiBarBottomRightButton%d'):format(id - 48)]
  elseif id <= 72 then
      return _G[('MultiBarBottomLeftButton%d'):format(id - 60)]
  else
      return Actionbar:CreateButton(id - 60)
  end
end

function Actionbar:CreateButton(id)


end