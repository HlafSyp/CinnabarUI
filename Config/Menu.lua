local Cinnabar, Util, Cfg, Module = unpack(select(2,...))
local COLOR = Cinnabar.data.COLORS.UI_PRIMARY
local TEXT_HIGHLIGHT = Cinnabar.data.COLORS.UI_FG

local AceGUI = LibStub("AceGUI-3.0")
local MainGroup = {
  {
    value = 'general',
    text = 'General'
  },
  {
    value = 'profiles',
    text = 'Profiles'
  },
  {
    value = 'modules',
    text = 'Modules',
    children = {
    }
  }
}

local function AddModulesToTreeGroup()

  for key, _ in pairs(Cfg.ModuleFrames) do

    MainGroup[3].children:insert({value = key:lower(), text = key})

  end

end

local function CreateProfilesMenu(panel)

  local label = AceGUI:Create("Label")
  label:SetText("You can change the active database profile, so you can have different settings for every character.")
  label:SetFullWidth(true)
  label:SetHeight(30)
  label:SetFont([[Fonts\FRIZQT__.TTF]], 13, 'NORMAL')
  panel:AddChild(label)

  local current_profile_label = AceGUI:Create("Label")
  current_profile_label:SetText("Current Profile:")
  current_profile_label:SetHeight(30)
  current_profile_label:SetWidth(115)
  current_profile_label:SetColor(TEXT_HIGHLIGHT.r, TEXT_HIGHLIGHT.g, TEXT_HIGHLIGHT.b)
  current_profile_label:SetFont([[Fonts\FRIZQT__.TTF]], 13, 'NORMAL')
  panel:AddChild(current_profile_label)

  local profileSelect = AceGUI:Create("Dropdown")
  profileSelect:SetList(Cfg:CreateAceGUITable())
  profileSelect:SetValue(Cfg.current_profile)
  profileSelect:SetWidth(200)
  panel:AddChild(profileSelect)

  local profileReset = AceGUI:Create("Button")
  profileReset:SetText("Reset")
  profileReset:SetWidth(150)
  profileReset:SetCallback("OnClick", function()

    Cfg:ResetProfile(Cfg.current_profile)

  end)
  panel:AddChild(profileReset)

  local new_label = AceGUI:Create("Label")
  new_label:SetText("Create a new empty profile by entering a name in the editbox")
  new_label:SetHeight(50)
  new_label:SetFullWidth(true)
  new_label:SetFont([[Fonts\FRIZQT__.TTF]], 13, 'NORMAL')
  panel:AddChild(new_label)

  local new_label2 = AceGUI:Create("Label")
  new_label2:SetText("New Profile: ")
  new_label2:SetHeight(30)
  new_label2:SetWidth(115)
  new_label2:SetColor(TEXT_HIGHLIGHT.r, TEXT_HIGHLIGHT.g, TEXT_HIGHLIGHT.b)
  new_label2:SetFont([[Fonts\FRIZQT__.TTF]], 13, 'NORMAL')
  panel:AddChild(new_label2)

  local nameEdit = AceGUI:Create("EditBox")
  nameEdit:SetHeight(30)
  nameEdit:SetWidth(200)
  panel:AddChild(nameEdit)

  local delete_label = AceGUI:Create("Label")
  delete_label:SetText("Delete existing and unused profiles from the database")
  delete_label:SetHeight(50)
  delete_label:SetFullWidth(true)
  delete_label:SetFont([[Fonts\FRIZQT__.TTF]], 13, 'NORMAL')
  panel:AddChild(delete_label)

  local delete_label2 = AceGUI:Create("Label")
  delete_label2:SetText("Delete Profile: ")
  delete_label2:SetHeight(30)
  delete_label2:SetWidth(115)
  delete_label2:SetColor(TEXT_HIGHLIGHT.r, TEXT_HIGHLIGHT.g, TEXT_HIGHLIGHT.b)
  delete_label2:SetFont([[Fonts\FRIZQT__.TTF]], 13, 'NORMAL')
  panel:AddChild(delete_label2)

  local profileDelete = AceGUI:Create("Dropdown")
  profileDelete:SetList(Cfg:CreateAceGUITable())
  profileDelete:SetWidth(200)
  panel:AddChild(profileDelete)

  local copy_label = AceGUI:Create("Label")
  copy_label:SetText("Copy the settings from one existing profile into the currently active profile")
  copy_label:SetHeight(50)
  copy_label:SetFullWidth(true)
  copy_label:SetFont([[Fonts\FRIZQT__.TTF]], 13, 'NORMAL')
  panel:AddChild(copy_label)

  local copy_label2 = AceGUI:Create("Label")
  copy_label2:SetText("Copy Profile: ")
  copy_label2:SetHeight(30)
  copy_label2:SetWidth(115)
  copy_label2:SetColor(TEXT_HIGHLIGHT.r, TEXT_HIGHLIGHT.g, TEXT_HIGHLIGHT.b)
  copy_label2:SetFont([[Fonts\FRIZQT__.TTF]], 13, 'NORMAL')
  panel:AddChild(copy_label2)

  local profileCopy = AceGUI:Create("Dropdown")
  profileCopy:SetList(Cfg:CreateAceGUITable())
  profileCopy:SetWidth(200)
  panel:AddChild(profileCopy)

  if Cfg:GetNumberOfProfiles() == 1 then
    profileDelete:SetDisabled(true)
    profileCopy:SetDisabled(true)
  end

  local function UpdateSelects()

    local tbl = Cfg:CreateAceGUITable()

    -- Update the list
    profileSelect:SetList(tbl)
    profileDelete:SetList(tbl)
    profileCopy:SetList(tbl)

    -- Disable the current profile
    profileSelect:SetItemDisabled(Cfg.current_profile, true)
    profileDelete:SetItemDisabled(Cfg.current_profile, true)
    profileDelete:SetItemDisabled('Default', true)
    profileCopy:SetItemDisabled(Cfg.current_profile, true)

    -- Update the values
    profileSelect:SetValue(Cfg.current_profile)
    profileDelete:SetDisabled(false)
    profileCopy:SetDisabled(false)
    if Cfg:GetNumberOfProfiles() == 1 then
      profileDelete:SetDisabled(true)
      profileCopy:SetDisabled(true)
    end

  end

  profileSelect:SetCallback("OnValueChanged", function(widget, event, key)

    Cfg:LoadProfile(key)
    UpdateSelects()

  end)

  profileDelete:SetCallback("OnValueChanged", function(widget, event, key)

    StaticPopupDialogs["CINNABAR_DELETE_CONFIRM"] = {
      text = "Are you sure you want to delete the selected profile?",
      button1 = "Yes",
      button2 = "No",
      OnAccept = function()
        Cfg:DeleteProfile(key)
        widget:SetValue("")
        UpdateSelects()
      end,
      OnCancel = function()
        widget:SetValue("")
      end,
      timeout = 0,
      whileDead = true,
      hideOnEscape = true,
      preferredIndex = 3,
    }

    StaticPopup_Show("CINNABAR_DELETE_CONFIRM")

  end)

  profileCopy:SetCallback("OnValueChanged", function(widget, event, key)

    StaticPopupDialogs["CINNABAR_COPY_CONFIRM"] = {
      text = "Are you sure you want to overwrite current profile values?",
      button1 = "Yes",
      button2 = "No",
      OnAccept = function()
        Cfg.CopyProfile(key)
        widget:SetValue("")
        UpdateSelects()
      end,
      OnCancel = function()
        widget:SetValue("")
      end,
      timeout = 0,
      whileDead = true,
      hideOnEscape = true,
      preferredIndex = 3,
    }

    StaticPopup_Show("CINNABAR_COPY_CONFIRM")

  end)

  nameEdit:SetCallback("OnEnterPressed", function(widget, event, key)

    -- Check if profile already exists
    if Cfg.profiles[key] ~= nil then
      StaticPopupDialogs["CINNABAR_EXISTS_CONFIRM"] = {
        text = "Profile %s already exists",
        button1 = "Okay",
        OnAccept = function() end,
        OnCancel = function() end,
        timeout = 0,
        whileDead = true,
        hideOnEscape = true,
        preferredIndex = 3,
      }

      StaticPopup_Show("CINNABAR_EXISTS_CONFIRM", key)

    else
      Cfg:CreateNewProfile(key)
      UpdateSelects()
    end
    widget:SetText("")

  end)

  UpdateSelects()

end

local function CreateGeneralMenu(panel)

  local label = AceGUI:Create("Label")
  label:SetText("General Options")
  label:SetFullWidth(true)
  label:SetHeight(25)
  panel:AddChild(label)

end

local function CreateModuleMenu(panel)

  local Reload = AceGUI:Create("Button")
  Reload:SetText("Reload UI")
  panel:AddChild(Reload)
  Reload:SetRelativeWidth(0.25)
  Reload:ClearAllPoints()
  Reload:SetPoint("BOTTOMRIGHT")

  local note =  AceGUI:Create("Label")
  note:SetText("        All Changes in this section will require a reload of the UI currently")
  note:SetRelativeWidth(0.75)
  panel:AddChild(note)

  for key, val in pairs(Cfg.config.Modules) do
    local Checkbox = AceGUI:Create("CheckBox")
    Checkbox:SetValue(val)
    Checkbox:SetLabel(key)
    Checkbox:SetCallback("OnValueChanged", function(widget, event, value)

      Cfg.config.Modules[key] = value
      Cfg:SaveProfile(Cfg.current_profile)
      if value then
        Cinnabar:EnableModule(key)
      else
        Cinnabar:DisableModule(key)
      end

    end)
    panel:AddChild(Checkbox)
  end



end

local CurrentPanel
function Cfg:CreateConfigMenu()

  AddModulesToTreeGroup()

  Cfg.ModuleFrames['general'] = CreateGeneralMenu
  Cfg.ModuleFrames['profiles'] = CreateProfilesMenu
  Cfg.ModuleFrames['modules'] = CreateModuleMenu

  local menu = AceGUI:Create("Window")
  menu:SetTitle("CinnabarUI")
  menu:SetCallback("OnClose", function(widget)

    Cfg:Disable()
    AceGUI:Release(widget)

  end)
  menu:SetLayout("Flow")
  menu:SetWidth(900)
  menu:SetHeight(600)

  local treeGroup = AceGUI:Create("TreeGroup")
  treeGroup:SetTree(MainGroup)
  treeGroup:SetFullHeight(true)
  treeGroup:SetCallback("OnTreeResize", function(width)

    return

  end)
  treeGroup:SetCallback("OnGroupSelected", function(widget, event, group)

    widget:ResumeLayout()
    widget:ReleaseChildren()
    local module_func = Cfg.ModuleFrames[group]
    module_func(widget)

  end)
  treeGroup:SelectByValue('profiles')
  treeGroup:SetLayout("Flow")

  menu:AddChild(treeGroup)

end