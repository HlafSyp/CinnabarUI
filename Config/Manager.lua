local Cinnabar, Util, Cfg, Module = unpack(select(2,...))

Cfg.config = {}

local tinsert = table.insert

function Cfg:OnInitialize()

end

function Cfg:OnEnable()
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