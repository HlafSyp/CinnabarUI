local Cinnabar, Util, Cfg, Module = unpack(select(2,...))

local MODULE_NAME = "UnitFrames"
local oUF = select(2,...).oUF
local uf = Module[MODULE_NAME]

local COLOR = Cinnabar.data.COLORS.UI_FG
local PRIMCOL = Cinnabar.data.COLORS.UI_PRIMARY

-- Section to modify Auras Lists
-- Section to Enable/Disable Various Units
-- Section to change what specs have percentage power
-- Section for each unit to control size/pos of frame

-- For mapping Locale independent class identifiers to class id numbers
local CLASSID = {
  ['DEATHKNIGHT'] = 6,
  ['DEMONHUNTER'] = 12,
  ['DRUID'] = 11,
  ['HUNTER'] = 3,
  ['MAGE'] = 8,
  ['MONK'] = 10,
  ['PALADIN'] = 2,
  ['PRIEST'] = 5,
  ['ROGUE'] = 4,
  ['SHAMAN'] = 7,
  ['WARLOCK'] = 9,
  ['WARRIOR'] = 1,
}

local pointTable = {
  ["TOPLEFT"] = "TOPLEFT",
  ["TOP"] = "TOP",
  ["TOPRIGHT"] = "TOPRIGHT",
  ["LEFT"] = "LEFT",
  ["CENTER"] = "CENTER",
  ["RIGHT"] = "RIGHT",
  ["BOTTOMLEFT"] = "BOTTOMLEFT",
  ["BOTTOM"] = "BOTTOM",
  ["BOTTOMRIGHT"] = "BOTTOMRIGHT",
}

local AceGUI = LibStub("AceGUI-3.0")

-- (HlafSyp)
-- I Genuinely hate making GUIs
-- This code base for the UnitFrames Config is an absolute mess
-- And I am dreading having to write the rest of it - May 24th, 2022

function uf.CreateUnitsMenu(panel)

  -- Creates the menus for the Player, Target, Target Target, Focus, Focus Target, and pet configs
  local function CreateSingleUnitMenu(parent, unit)

    parent:SetAutoAdjustHeight(true)

    -- Top Checkbox Section
    do
      -- Enable Box
      local enable = AceGUI:Create("CheckBox")
      enable:SetLabel("Enable Unitframe")
      enable:SetValue(Cfg.config.UnitFrames.Units[unit])
      enable:SetRelativeWidth(0.33)
      enable:SetCallback("OnValueChanged", function(widget, event, value)

        Cfg.config.UnitFrames.Units[unit] = value
        uf:Refresh()

      end)
      parent:AddChild(enable)


      -- Lock Box
      local lock = AceGUI:Create("CheckBox")
      lock:SetLabel("Lock Frame Position")
      lock:SetRelativeWidth(0.33)
      lock:SetCallback("OnValueChanged", function(widget, event, value)
        Cfg.config.UnitFrames[unit].Lock = value
        uf.Frames[unit]:SetMovable(not value)
        if value == false then
          uf.SetFrameMovable(unit)
        else
          uf.Frames[unit]:RegisterForDrag(nil)
        end
      end)
      lock:SetValue(Cfg.config.UnitFrames[unit].Lock)
      parent:AddChild(lock)


      -- Mirror Box

      local mirror = AceGUI:Create("CheckBox")
      mirror:SetLabel("Mirror Frame")
      mirror:SetRelativeWidth(0.33)
      mirror:SetCallback("OnValueChanged", function(widget, event, value)
        Cfg.config.UnitFrames[unit].Mirror = value
        uf.Frames[unit].Health:SetReverseFill(value)
        uf.Frames[unit].Health.healthText:ClearAllPoints()
          uf.Frames[unit].Health.NameText:ClearAllPoints()
        if value == true then
          uf.Frames[unit].Health.healthText:SetPoint('LEFT', uf.Frames[unit].Health, 'LEFT', 2, 0)
          uf.Frames[unit].Health.NameText:SetPoint('RIGHT', uf.Frames[unit].Health, 'RIGHT', -2, 0)

        else
          uf.Frames[unit].Health.healthText:SetPoint('RIGHT', uf.Frames[unit].Health, 'RIGHT', -2, 0)
          uf.Frames[unit].Health.NameText:SetPoint('LEFT', uf.Frames[unit].Health, 'LEFT', 2, 0)
        end
        uf.Frames[unit]:Tag(uf.Frames[unit].Health.healthText, '[Cinnabar:curhp]')
        uf.Frames[unit]:Tag(uf.Frames[unit].Health.NameText, "[Cinnabar:smartname]")
        uf.Frames[unit].Power:SetReverseFill(value)
      end)
      mirror:SetValue(Cfg.config.UnitFrames[unit].Mirror)
      parent:AddChild(mirror)
    end

    -- Position Section
    do
      local posGroup = AceGUI:Create("InlineGroup")
      posGroup:SetTitle("Position")
      posGroup:SetFullWidth(true)
      parent:AddChild(posGroup)

      -- Anchor on the Frame
      local point = AceGUI:Create("Dropdown")
      point:SetList(pointTable)
      point:SetValue(Cfg.config.UnitFrames[unit].Anchor)
      point:SetRelativeWidth(0.5)
      point:SetLabel("Point")
      point:SetCallback("OnValueChanged", function(widget, event, key)

        Cfg.config.UnitFrames[unit].Anchor = key
        local c = Cfg.config.UnitFrames[unit]
        uf.Frames[unit]:ClearAllPoints()
        uf.Frames[unit]:SetPoint(
          c.Anchor,
          _G['UIParent'],
          c.ParentAnchor,
          c.OffsetX,
          c.OffsetY
        )

      end)

      -- Anchor on the Parent
      local relpoint = AceGUI:Create("Dropdown")
      relpoint:SetList(pointTable)
      relpoint:SetValue(Cfg.config.UnitFrames[unit].ParentAnchor)
      relpoint:SetLabel("Relative Point")
      relpoint:SetRelativeWidth(0.5)
      relpoint:SetCallback("OnValueChanged", function(widget, event, key)

        Cfg.config.UnitFrames[unit].ParentAnchor = key
        local c = Cfg.config.UnitFrames[unit]
        uf.Frames[unit]:ClearAllPoints()
        uf.Frames[unit]:SetPoint(
          c.Anchor,
          _G['UIParent'],
          c.ParentAnchor,
          c.OffsetX,
          c.OffsetY
        )

      end)

      -- Offset on the X-Axis
      local offset = GetScreenWidth() / 2
      local sliderX = AceGUI:Create("Slider")
      sliderX:SetRelativeWidth(0.5)
      sliderX:SetSliderValues(Round(-offset), Round((offset * 2) - offset), 1)
      sliderX:SetValue(Cfg.config.UnitFrames[unit].OffsetX)
      sliderX:SetLabel("X Offset")
      sliderX:SetCallback("OnValueChanged", function(widget, event, value)

        Cfg.config.UnitFrames[unit].OffsetX = value
        local c = Cfg.config.UnitFrames[unit]
        uf.Frames[unit]:ClearAllPoints()
        uf.Frames[unit]:SetPoint(
          c.Anchor,
          _G['UIParent'],
          c.ParentAnchor,
          c.OffsetX,
          c.OffsetY
        )

      end)

      -- Offset on the Y-Axis
      local offset = GetScreenHeight() / 2
      local sliderY = AceGUI:Create("Slider")
      sliderY:SetRelativeWidth(0.5)
      sliderY:SetSliderValues(Round(-offset), Round((offset * 2) - offset), 1)
      sliderY:SetValue(Cfg.config.UnitFrames[unit].OffsetY)
      sliderY:SetLabel("Y Offset")
      sliderY:SetCallback("OnValueChanged", function(widget, event, value)

        Cfg.config.UnitFrames[unit].OffsetY = value
        local c = Cfg.config.UnitFrames[unit]
        uf.Frames[unit]:ClearAllPoints()
        uf.Frames[unit]:SetPoint(
          c.Anchor,
          _G['UIParent'],
          c.ParentAnchor,
          c.OffsetX,
          c.OffsetY
        )

      end)

      -- Add Widgets to the group
      posGroup:SetLayout("Flow")
      posGroup:AddChild(point)
      posGroup:AddChild(relpoint)
      posGroup:AddChild(sliderX)
      posGroup:AddChild(sliderY)

      -- This is defined under all the other position widgets
      -- because it modifies the other widgets
      -- This is for updating the config menu in real time as the frame
      -- is being dragged around
      uf.Frames[unit]:HookScript("OnDragStop", function()

        local p, rT, rP, xO, yO = uf.Frames[unit]:GetPoint()
        point:SetValue(p)
        relpoint:SetValue(rP)
        sliderX:SetValue(Round(xO))
        sliderY:SetValue(Round(yO))

      end)
    end

    -- Bar Options
    -- There is a lot that happens in here
    do
      local tg = AceGUI:Create("TabGroup")
      local list = {
        {value = "HealthBar", text = "Health"},
        {value = "PowerBar", text = "Power"},
        {value = "CastBar", text = "Castbar"},
      }

      -- Since only the Player and Target Frames support aura bars
      -- Check if the unit is player or target and add the tab
      -- to the tab group if it is
      if unit == 'player' or unit == 'target' then
        list[4] = {value = "AuraBar", text = "Auras"}
      end
      tg:SetTitle("Bar Options")
      tg:SetLayout("Flow")
      tg:SetCallback("OnGroupSelected", function(widget, event, group)
        tg:ReleaseChildren()

        -- Remaps the group to the member name of the bar in the Frame
        -- Frame.Health not Frame.HealthBar for instance
        local key
        if group == 'HealthBar' then key = 'Health'
        elseif group == 'PowerBar' then key = 'Power'
        elseif group == 'CastBar' then key = 'Castbar'
        elseif group == 'AuraBar' then key = 'AuraBars' end

        local enable = AceGUI:Create("CheckBox")
        do
          enable:SetLabel("Enable")
          enable:SetRelativeWidth(0.33)
          enable:SetValue(Cfg.config.UnitFrames[unit][group].Enabled)
          enable:SetCallback("OnValueChanged", function(widget, event, value)

            Cfg.config.UnitFrames[unit][group].Enabled = value
            uf:Refresh()
            Cfg:SaveProfile(Cfg.current_profile)

          end)
          tg:AddChild(enable)
        end

        local fontSize = AceGUI:Create("Slider")
        do
          fontSize:SetRelativeWidth(0.50)
          fontSize:SetSliderValues(10, 40, 1)
          fontSize:SetLabel("Font Size")
          fontSize:SetCallback("OnValueChanged", function(widget, event, value)

            Cfg.config.UnitFrames[unit][group].FontSize = value
            uf.Frames[unit][key]:SetFontSize(value)
            Cfg:SaveProfile(Cfg.current_profile)

          end)
          fontSize:SetValue(
            Cfg.config.UnitFrames[unit][group].FontSize or
            Round((Cfg.config.UnitFrames[unit].Width * Cfg.config.UnitFrames[unit].Height) *  (3/1000), 0)
          )
          tg:AddChild(fontSize)
        end

        local height = AceGUI:Create("Slider")
        do
          height:SetRelativeWidth(0.50)
          height:SetSliderValues(20, 100, 1)
          height:SetValue(Cfg.config.UnitFrames[unit][group].Height)
          height:SetLabel("Height")
          height:SetCallback("OnValueChanged", function(widget, event, value)

            local prevHeight = Cfg.config.UnitFrames[unit][group].Height
            local difference = value - prevHeight
            local FrameHeight = uf.Frames[unit]:GetHeight()
            Cfg.config.UnitFrames[unit][group].Height = value
            uf.Frames[unit]:SetHeight(FrameHeight + difference)
            Cfg.config.UnitFrames[unit].Height = FrameHeight + difference
            uf.Frames[unit][key]:SetHeight(value)
            Cfg:SaveProfile(Cfg.current_profile)

          end)
          tg:AddChild(height)
        end

        -- Bar Specific Config Options
        if group == 'HealthBar' then
          -- TODO: Add options for
            -- colorTapping
            -- colorDisconnected
            -- colorClass
            -- colorReaction
            -- colorHealth
            -- BgBrightness
            -- ShortenHealthText
            -- HealthTextPrecision (? IDK if I wan't this customizable easily)
            -- ColorLevelText
          enable:SetFullWidth(true)
        elseif group == 'PowerBar' then
          -- TODO: Add options for
            -- frequentUpdatas
            -- colorTapping
            -- colorDisconnected
            -- colorPower
            -- colorClass
            -- colorReaction
            -- BgBrightness
          height:SetSliderValues(3,100, 1)
          fontSize:SetValue(Cfg.config.UnitFrames[unit][group].FontSize or 13)
          enable:SetFullWidth(true)
        elseif group == 'CastBar' then
          -- Because the CastBar isn't draggable unless something is being cast
          -- A burner mover frame needs to be created and affixed to the Castbar
          -- This is what moves the actual castbar
          local show = AceGUI:Create("CheckBox")
          show:SetValue(false)

          -- Because the mover might have been left visible when the config was closed
          -- have to check if it exists first, but also if it is visible
          if uf.Frames[unit].Castbar.mover then
            show:SetValue(uf.Frames[unit].Castbar.mover:IsVisible())
          end
          show:SetLabel("Show Castbar")
          show:SetRelativeWidth(0.33)
          -- I changed this from an anonymous function to
          -- a named function but I don't remember why
          local function show_OnValueChanged(widget, event, value)
            if value == true then
              local mover = uf.Frames[unit].Castbar.mover
              if not mover then
                -- If the mover doesn't exist yet, create it
                mover = CreateFrame("Frame", nil, UIParent)
                mover:ClearAllPoints()
                -- Set the size of the mover to match the cast bar
                mover:SetSize(uf.Frames[unit].Castbar:GetWidth(), uf.Frames[unit].Castbar:GetHeight())
                mover:SetPoint(uf.Frames[unit].Castbar:GetPoint())

                -- Make the frame visible by giving it a texture
                mover.tex = mover:CreateTexture(nil, 'OVERLAY')
                mover.tex:SetAllPoints(mover)
                mover.tex:SetColorTexture(PRIMCOL.r, PRIMCOL.g, PRIMCOL.b, 0.7)
                mover.label = mover:CreateFontString(nil, 'OVERLAY')
                mover.label:SetFont(Cinnabar.lsm:Fetch('font', 'BebasNeue-Regular'), 17, 'OUTLINE')
                mover.label:SetPoint("CENTER")
                mover.label:SetText(unit)

                -- This is defined as a function on the frame itself
                -- When called and given a boolean value
                -- Will either make the frame movable or not
                function mover:SetFrameMovable(set)
                  mover:EnableMouse(set)
                  mover:SetMovable(set)
                  mover:RegisterForDrag("LeftButton")
                  if not set then mover:RegisterForDrag(nil) end
                  mover:SetScript("OnDragStart", function(self)
                    mover:StartMoving()

                  end)
                  mover:SetScript("OnDragStop", function(self)
                    -- Once the frame is done being dragged around
                    -- Update the position of the cast bar
                    -- To the position of the mover frame
                    -- And update it in the config
                    mover:StopMovingOrSizing()
                    local p, rT, rP, xO, yO = mover:GetPoint()
                    Cfg.config.UnitFrames[unit].CastBar.Point = p
                    Cfg.config.UnitFrames[unit].CastBar.relativePoint = rP
                    Cfg.config.UnitFrames[unit].CastBar.xOffset = xO
                    Cfg.config.UnitFrames[unit].CastBar.yOffset = yO
                    uf.Frames[unit].Castbar:ClearAllPoints()
                    uf.Frames[unit].Castbar:SetPoint(p, 'UIParent', rP, xO, yO)

                  end)
                end

                -- Lastly, create a reference to mover so that
                -- It can be referenced by other callback functions
                uf.Frames[unit].Castbar.mover = mover
              else
                mover:Show()
              end
            else
              local mover  = uf.Frames[unit].Castbar.mover
              if mover then mover:Hide() end
            end
          end
          show:SetCallback("OnValueChanged", show_OnValueChanged)
          tg:AddChild(show, fontSize)
          local width = AceGUI:Create("Slider")
          width:SetSliderValues(50, Round(GetScreenWidth()), 10)
          width:SetValue(Cfg.config.UnitFrames[unit][group].Width)
          width:SetRelativeWidth(0.5)
          width:SetLabel("Width")
          width:SetCallback("OnValueChanged", function(widget, event, value)

            uf.Frames[unit].Castbar:SetWidth(value)
            Cfg.config.UnitFrames[unit].CastBar.Width = value
            if uf.Frames[unit].Castbar.mover then
              uf.Frames[unit].Castbar.mover:SetWidth(value)
            end
            Cfg:SaveProfile(Cfg.current_profile)

          end)
          height:SetCallback("OnValueChanged", function(widget, event, value)
            uf.Frames[unit].Castbar:SetHeight(value)
            Cfg.config.UnitFrames[unit].CastBar.Height = value
            uf.Frames[unit].Castbar.Icon:SetSize(value, value)
            uf.Frames[unit].Castbar.Shield:SetSize(value, value)
            uf.Frames[unit].Castbar.Spark:SetSize(value,value)
            if uf.Frames[unit].Castbar.mover then
              uf.Frames[unit].Castbar.mover:SetHeight(value)
            end
            Cfg:SaveProfile(Cfg.current_profile)
          end)
          tg:AddChild(width)

          -- Position Section
          do

            local posGroup = AceGUI:Create("InlineGroup")
            posGroup:SetTitle("Position")
            posGroup:SetFullWidth(true)
            tg:AddChild(posGroup)

            local point = AceGUI:Create("Dropdown")
            point:SetList(pointTable)
            point:SetValue(Cfg.config.UnitFrames[unit].CastBar.Point)
            point:SetCallback("OnValueChanged", function(widget, event, key)

              Cfg.config.UnitFrames[unit].CastBar.Point = key
              local c = Cfg.config.UnitFrames[unit].CastBar
              uf.Frames[unit].Castbar:ClearAllPoints()
              uf.Frames[unit].Castbar:SetPoint(
                c.Point,
                _G['UIParent'],
                c.relativePoint,
                c.xOffset,
                c.yOffset
              )
              local mover = uf.Frames[unit].Castbar.mover
              if mover then
                mover:ClearAllPoints()
                mover:SetPoint(
                  c.Point,
                  _G['UIParent'],
                  c.relativePoint,
                  c.xOffset,
                  c.yOffset
                )
              end

            end)
            point:SetLabel("Point")

            local relpoint = AceGUI:Create("Dropdown")
            relpoint:SetList(pointTable)
            relpoint:SetValue(Cfg.config.UnitFrames[unit].CastBar.relativePoint)
            relpoint:SetCallback("OnValueChanged", function(widget, event, key)

              Cfg.config.UnitFrames[unit].CastBar.relativePoint = key
              local c = Cfg.config.UnitFrames[unit].CastBar
              uf.Frames[unit].Castbar:ClearAllPoints()
              uf.Frames[unit].Castbar:SetPoint(
                c.Point,
                _G['UIParent'],
                c.relativePoint,
                c.xOffset,
                c.yOffset
              )
              local mover = uf.Frames[unit].Castbar.mover
              if mover then
                mover:ClearAllPoints()
                mover:SetPoint(
                  c.Point,
                  _G['UIParent'],
                  c.relativePoint,
                  c.xOffset,
                  c.yOffset
                )
              end

            end)
            relpoint:SetLabel("Relative Point")

            relpoint:SetRelativeWidth(0.5)
            point:SetRelativeWidth(0.5)

            local offset = GetScreenWidth() / 2
            local sliderX = AceGUI:Create("Slider")
            sliderX:SetRelativeWidth(0.5)
            sliderX:SetSliderValues(Round(-offset), Round((offset * 2) - offset), 1)
            sliderX:SetValue(Cfg.config.UnitFrames[unit].CastBar.xOffset)
            sliderX:SetLabel("X Offset")
            sliderX:SetCallback("OnValueChanged", function(widget, event, value)

              Cfg.config.UnitFrames[unit].CastBar.xOffset = value
              local c = Cfg.config.UnitFrames[unit].CastBar
              uf.Frames[unit].Castbar:ClearAllPoints()
              uf.Frames[unit].Castbar:SetPoint(
                c.Point,
                _G['UIParent'],
                c.relativePoint,
                c.xOffset,
                c.yOffset
              )
              local mover = uf.Frames[unit].Castbar.mover
              if mover then
                mover:ClearAllPoints()
                mover:SetPoint(
                  c.Point,
                  _G['UIParent'],
                  c.relativePoint,
                  c.xOffset,
                  c.yOffset
                )
              end

            end)

            local offset = GetScreenHeight() / 2
            local sliderY = AceGUI:Create("Slider")
            sliderY:SetRelativeWidth(0.5)
            sliderY:SetSliderValues(Round(-offset), Round((offset * 2) - offset), 1)
            sliderY:SetValue(Cfg.config.UnitFrames[unit].CastBar.yOffset)
            sliderY:SetLabel("Y Offset")
            sliderY:SetCallback("OnValueChanged", function(widget, event, value)

              Cfg.config.UnitFrames[unit].CastBar.yOffset = value
              local c = Cfg.config.UnitFrames[unit].CastBar
              uf.Frames[unit].Castbar:ClearAllPoints()
              uf.Frames[unit].Castbar:SetPoint(
                c.Point,
                _G['UIParent'],
                c.relativePoint,
                c.xOffset,
                c.yOffset
              )
              local mover = uf.Frames[unit].Castbar.mover
              if mover then
                mover:ClearAllPoints()
                mover:SetPoint(
                  c.Point,
                  _G['UIParent'],
                  c.relativePoint,
                  c.xOffset,
                  c.yOffset
                )
              end

            end)

            local Lock = AceGUI:Create("CheckBox")
            Lock:SetLabel("Lock")
            Lock:SetRelativeWidth(0.33)
            Lock:SetValue(Cfg.config.UnitFrames[unit].CastBar.Lock)
            Lock:SetCallback("OnValueChanged", function(widget, event, value)

              show:SetValue((not value and true) or false)
              show_OnValueChanged(show, "OnValueChanged", (not value and true) or false)
              local mover = uf.Frames[unit].Castbar.mover
              if mover then mover:SetFrameMovable(not value) end

            end)

            tg:AddChild(Lock, fontSize)

            posGroup:SetLayout("Flow")
            posGroup:AddChild(point)
            posGroup:AddChild(relpoint)

            posGroup:AddChild(sliderX)
            posGroup:AddChild(sliderY)

            -- This is defined under all the other position widgets
            -- because it modifies the other widgets
            local mover = uf.Frames[unit].Castbar.mover
            if mover ~= nil then
              mover:HookScript("OnDragStop", function()

                local p, rT, rP, xO, yO = uf.Frames[unit]:GetPoint()
                point:SetValue(p)
                relpoint:SetValue(rP)
                sliderX:SetValue(Round(xO))
                sliderY:SetValue(Round(yO))

              end)
            end
          end

          -- Color Picker
          local colors = AceGUI:Create("ColorPicker")
          local c = Cfg.config.UnitFrames[unit].CastBar.UninteruptibleColors
          colors:SetColor(c[1], c[2], c[3], c[4] or 1)
          colors:SetRelativeWidth(0.5)
          colors:SetLabel("Uninteruptible Castbar Color")
          colors:SetCallback("OnValueConfirmed", function(widget, event, r,g,b,a)

            Cfg.config.UnitFrames[unit].CastBar.UninteruptibleColors[1] = r
            Cfg.config.UnitFrames[unit].CastBar.UninteruptibleColors[2] = g
            Cfg.config.UnitFrames[unit].CastBar.UninteruptibleColors[3] = b
            Cfg.config.UnitFrames[unit].CastBar.UninteruptibleColors[4] = a
            Cfg:SaveProfile(Cfg.current_profile)

          end)
          tg:AddChild(colors, fontSize)

        elseif group == 'AuraBar' then
          local bypass = AceGUI:Create("CheckBox")
          enable:SetRelativeWidth(0.25)
          bypass:SetRelativeWidth(0.75)
          bypass:SetLabel("Bypass Filters")
          bypass:SetValue(Cfg.config.UnitFrames[unit].AuraBar.BypassFilter)
          bypass:SetCallback("OnValueChanged", function(widget, event, value)

            Cfg.config.UnitFrames[unit].AuraBar.BypassFilter = value
            Cfg:SaveProfile(Cfg.current_profile)

          end)
          tg:AddChild(bypass, fontSize)
        end

      end)
      tg:SetTabs(list)
      tg:SetFullWidth(true)
      tg:SelectTab("HealthBar")
      parent:AddChild(tg)

    end

  end

  -- Creates the Individual Units Tab Group and routes to the CreateSingleUnitMenu Function
  local function CreateSubUnitMenu(parent)

    local tg = AceGUI:Create("TabGroup")
    tg:SetTabs({
      {value = "player", text = "Player"},
      {value = "target", text = "Target"},
      {value = "targettarget", text = "Target Target", disabled = true},
      {value = "focus", text = "Focus", disabled = true},
      {value = "focustarget", text = "Focus Target", disabled = true},
      {value = "pet", text = "Pet", disabled = true},
    })
    tg:SetCallback("OnGroupSelected", function(widget, event, group)

      tg:ReleaseChildren()
      local simple = AceGUI:Create("SimpleGroup")
      simple:SetFullWidth(true)
      simple:SetFullHeight(true)
      simple:SetLayout("Fill")
      widget:AddChild(simple)

      local scroll = AceGUI:Create("ScrollFrame")
      scroll:SetFullWidth(true)
      scroll:SetFullHeight(true)
      scroll:SetLayout("Flow")
      simple:AddChild(scroll)
      CreateSingleUnitMenu(scroll, group)

    end)
    tg:SetLayout("Flow")
    tg:SelectTab("player")
    tg:SetFullWidth(true)
    tg:SetFullHeight(true)
    parent:AddChild(tg)

  end

  -- Creates the Party/Raid Tab Group and routes to the CreatePnRMenu Function (TBD)
  local function CreatePnRMenu(parent)

    local tg = AceGUI:Create("TabGroup")
    tg:SetTabs({
      {value = "group", text = "Group"},
      {value = "party", text = "Party"},
      {value = "raid10", text = "Raid 10"},
      {value = "raid20", text = "Raid 20"},
      {value = "raid40", text = "Raid 40"},
    })
    tg:SelectTab("group")
    tg:SetFullWidth(true)
    parent:AddChild(tg)


  end

  panel:SetLayout("Fill")
  -- local disclaimer = AceGUI:Create("Label")
  -- disclaimer:SetText("Currently, only the single-unit unit frames work, party/raid frames are yet to be implemented")
  -- disclaimer:SetFullWidth(true)
  -- disclaimer:SetHeight(50)
  -- disclaimer:SetFont([[Fonts\FRIZQT__.TTF]], 13, 'NORMAL')
  -- panel:AddChild(disclaimer)

  -- Create the main Tab Group
  local tabGroup = AceGUI:Create("TabGroup")
  tabGroup:SetTabs({{value = "pnr", text = "Party/Raid", disabled = true}, {value =  "single", text = "Units"}})
  tabGroup:SetFullWidth(true)
  tabGroup:SetFullHeight(true)
  tabGroup:SetLayout("Fill")
  tabGroup:SetCallback("OnGroupSelected", function(widget, event, group)

    tabGroup:ReleaseChildren()
    -- Route to the respective Categories, Party/Raid or Individual
    if group == 'pnr' then
      CreatePnRMenu(widget)
    elseif group == 'single' then
      CreateSubUnitMenu(widget)
    end

  end)
  tabGroup:SelectTab("single")
  panel:AddChild(tabGroup)

end

function uf.CreatePercPowerMenu(panel)

  panel:SetLayout("Fill")
  local container = AceGUI:Create("ScrollFrame")
  container:SetLayout("Flow")
  panel:AddChild(container)

  local disclaimer = AceGUI:Create("Label")
  disclaimer:SetText("This determines whether to show the power on the unit frame as a percentage or a number")
  disclaimer:SetFullWidth(true)
  disclaimer:SetHeight(50)
  disclaimer:SetFont([[Fonts\FRIZQT__.TTF]], 13, 'NORMAL')
  container:AddChild(disclaimer)
  disclaimer = AceGUI:Create("Label")
  disclaimer:SetText("This is determined by specialization and not by unit")
  disclaimer:SetFullWidth(true)
  disclaimer:SetHeight(50)
  disclaimer:SetFont([[Fonts\FRIZQT__.TTF]], 13, 'NORMAL')
  container:AddChild(disclaimer)

  for name, class in pairs(Cfg.config.UnitFrames.PercentagePower) do
    local class_name = GetClassInfo(CLASSID[name])
    local header = AceGUI:Create("Heading")
    header:SetText(class_name)
    header:SetFullWidth(true)
    container:AddChild(header)
    for index, val in ipairs(class) do
      local button = AceGUI:Create("CheckBox")
      button:SetValue(val)
      button:SetLabel(select(2,GetSpecializationInfoForClassID(CLASSID[name],index)))
      button:SetCallback("OnValueChanged", function(widget, event, value)
        Cfg.config.UnitFrames.PercentagePower[name][index] = value
        Cfg:SaveProfile(Cfg.current_profile)
        uf:Refresh()
      end)
      container:AddChild(button)
    end
  end


end

function uf.CreateAurasMenu(panel)

  panel:SetLayout("Fill")
  local tg = AceGUI:Create("TabGroup")
  -- Might add custom lists but for now, these 5 are the only aura lists available
  tg:SetTabs({
    {value = 'Class Buffs', text = 'Class Buffs'},
    {value = 'Class Debuffs', text = 'Class Debuffs'},
    {value = 'Buffs',  text = 'Buffs'},
    {value = 'Debuffs',  text = 'Debuffs'},
    {value = 'Raid/Dungeon', text = 'Raid/Dungeon Auras'},
  })
  panel:AddChild(tg)
  tg:SetCallback("OnGroupSelected", function(widget, event, group)

    -- selected is used to keep track of the spell that was selected
    -- for the delete button to properly delete the selected aura
    local selected
    local spell = AceGUI:Create("InlineGroup")
    local spellGroup = AceGUI:Create("ScrollFrame")
    local cont = AceGUI:Create("InlineGroup")
    local delete = AceGUI:Create("Button")

    -- This was pushed out into its own function
    -- because the create widget needed to create and aura entry
    -- and I didn't want to duplicate code
    -- But now that I know I can't release a single widget from a group
    -- With fucking everything up, CreateAuraList  is the only function I use
    local auralist = {}
    local function CreateAuraEntry(parent, spellId)

      local n, _, icon = GetSpellInfo(spellId)
      local i = AceGUI:Create("Icon")
      i:SetImage(icon)
      i:SetImageSize(20,20)
      i:SetRelativeWidth(0.25)
      local aura = AceGUI:Create("InteractiveLabel")

      local function ShowTooltip()
        GameTooltip:SetOwner(aura.frame, 'ANCHOR_CURSOR')
        -- Weird thing happens where the name and cast time/duration of the spell
        -- gets duplicated, IDK why it happens, but Clear the tooltip didn't fix it
        -- I assume it has to do with how AddSpellByID works, but IDK
        GameTooltip:ClearLines()
        GameTooltip:AddSpellByID(aura:GetUserData('spellID'))
        GameTooltip:Show()
      end

      i:SetCallback("OnEnter", function(widget, event)

        aura:SetColor(PRIMCOL.r, PRIMCOL.g, PRIMCOL.b)
        ShowTooltip()

      end)
      i:SetCallback("OnLeave", function(widget, event)

        if not selected or aura ~= selected.text then
          aura:SetColor(1,1,1)
        end

        if GameTooltip:IsVisible() then GameTooltip:Hide() end

      end)
      i:SetCallback("OnClick", function(widget, event, button)

        if button == 'LeftButton' then
          if selected and selected.text.SetColor then selected.text:SetColor(1,1,1) end
          aura:SetColor(PRIMCOL.r, PRIMCOL.g, PRIMCOL.b)
          selected = {icon = i,text = aura}
          delete:SetDisabled(false)
        end

      end)

      -- aura:SetImage(icon)
      aura:SetText(n .. ' (' .. spellId .. ')')
      aura:SetHeight(20)
      -- aura:SetImageSize(20,20)
      aura:SetCallback("OnEnter", function(widget, event)

        widget:SetColor(PRIMCOL.r, PRIMCOL.g, PRIMCOL.b)
        ShowTooltip()

      end)
      aura:SetCallback("OnLeave", function(widget, event)

        if not selected or widget ~= selected.text then
          widget:SetColor(1,1,1)
        end

        if GameTooltip:IsVisible() then GameTooltip:Hide() end

      end)
      aura:SetCallback("OnClick", function(widget, event, button)

        if button == 'LeftButton' then
          if selected and selected.text.SetColor then selected.text:SetColor(1,1,1) end
          widget:SetColor(PRIMCOL.r, PRIMCOL.g, PRIMCOL.b)
          selected = {icon = i,text = aura}
          delete:SetDisabled(false)
        end

      end)
      aura:SetColor(1,1,1)
      aura:SetUserData("spellID", spellId)
      aura:SetUserData("spellName", n)
      aura:SetRelativeWidth(0.75)

      return i, aura

    end

    -- Recreates the whole list
    local function CreateAuraList(parent)
      local auraslist = {}
      local sortedlist = {}
      parent:ReleaseChildren()
      for k, v in pairs(Cfg.config.UnitFrames.Auras[group]) do
        -- Since the menu sets it to false when changed, have to check if it is anything but nil and false
        if v then
          local i, aura = CreateAuraEntry(parent, k)
          auraslist[aura:GetUserData('spellName')] = {i, aura}
          table.insert(sortedlist, aura:GetUserData('spellName'))
        end
      end

      table.sort(sortedlist)
      for k,v in ipairs(sortedlist) do

        local i, aura = unpack(auraslist[v])
        parent:AddChild(i)
        parent:AddChild(aura)

      end

    end

    tg:ReleaseChildren()
    tg:SetLayout("Flow")

    spell:SetFullHeight(true)
    spell:SetRelativeWidth(0.5)
    spell:SetLayout("Fill")

    spellGroup:SetLayout("Flow")
    spell:AddChild(spellGroup)

    cont:SetFullHeight(true)
    cont:SetRelativeWidth(0.5)
    cont:SetLayout("List")


    delete:SetText("Delete")
    delete:SetDisabled(true)
    delete:SetRelativeWidth(0.5)
    delete:SetCallback("OnClick", function(widget, event)

      local id = selected.text:GetUserData("spellID")
      if Cfg.defaults.UnitFrames.Auras[group][id] then
        Cfg.config.UnitFrames.Auras[group][id] = false
      else
        Cfg.config.UnitFrames.Auras[group][id] = nil
      end
      Cfg:SaveProfile(Cfg.current_profile)
      spellGroup:ReleaseChildren()
      CreateAuraList(spellGroup)

    end)
    local create = AceGUI:Create("EditBox")
    create:SetLabel("Enter Spell ID to add to the list")
    create:SetCallback("OnEnterPressed", function(widget, event, text)

      widget:SetText("")
      local name = GetSpellInfo(tonumber(text))
      -- Check if it's a valid spell
      if name == nil then return end

      Cfg.config.UnitFrames.Auras[group][tonumber(text)] = name
      Cfg:SaveProfile(Cfg.current_profile)
      spellGroup:ReleaseChildren()
      CreateAuraList(spellGroup)

    end)
    create:SetRelativeWidth(0.5)

    CreateAuraList(spellGroup)

    tg:AddChild(spell)
    tg:AddChild(cont)
    cont:AddChild(delete)
    cont:AddChild(create)

  end)
  tg:SelectTab("Class Buffs")


end

function uf.CreateUnitFrameMenu(panel)



end