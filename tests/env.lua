-- in-memory stand-ins for client globals used while loading modules
local env = {}

function env.reset()
  local messages = {}
  local scripts = {}
  local registered = {}
  _G.TurtleGuides = nil
  _G.TurtleGuidesDB = nil
  _G.TurtleGuidesCharDB = nil
  _G.event = nil
  _G.arg1 = nil
  _G.GetTime = nil
  env.bindings = { ESCAPE = "TOGGLEGAMEMENU" }
  _G.GetBindingAction = function(key)
    return env.bindings[key]
  end
  _G.SetBinding = function(key, action)
    env.bindings[key] = action
    return true
  end
  _G.pfDB = nil
  _G.GetZoneText = nil
  _G.GetSubZoneText = nil
  _G.GetMapInfo = nil
  _G.GetLocale = function()
    return "enUS"
  end
  _G.WorldMapFrame = nil
  _G.C_Map = nil
  _G.CreateVector2D = nil
  _G.UnitPosition = nil
  _G.GetNumQuestLogEntries = function()
    return 0
  end
  _G.GetQuestLogTitle = function() end
  _G.GetQuestLink = nil
  _G.GetQuestLinkForLogIndex = nil
  _G.C_QuestLog = nil
  _G.pfDatabase = nil
  _G.pfQuest_history = nil
  _G.GetNumQuestLeaderBoards = function()
    return 0
  end
  _G.GetQuestLogLeaderBoard = function() end
  _G.GetContainerNumSlots = function()
    return 0
  end
  _G.GetContainerItemLink = function() end
  _G.GetContainerItemInfo = function() end
  _G.GetInventoryItemID = function() end
  _G.GetInventoryItemLink = function() end
  _G.GetItemInfo = function() end
  _G.UnitSex = function()
    return 2
  end
  _G.RXPGuides = nil
  _G.DEFAULT_CHAT_FRAME = {
    AddMessage = function(_, msg)
      table.insert(messages, msg)
    end,
  }
  local noop = function() end
  _G.SlashCmdList = {}
  _G.GameTooltip = {
    SetOwner = noop,
    SetText = noop,
    AddLine = noop,
    Show = noop,
    Hide = noop,
  }
  local dropdownButtons = {}
  _G.UIDropDownMenu_CreateInfo = function()
    return {}
  end
  _G.UIDropDownMenu_AddButton = function(info)
    table.insert(dropdownButtons, info)
  end
  _G.UIDropDownMenu_SetText = function(text)
    env.dropdownText = text
  end
  _G.UIDropDownMenu_SetWidth = noop
  _G.UIDropDownMenu_Initialize = function(_, init)
    dropdownButtons = {}
    env.dropdownButtons = dropdownButtons
    if init then
      init(1)
    end
  end
  _G.ToggleDropDownMenu = noop
  local frames, textures, texts = {}, {}, {}
  _G.UIParent = {}
  _G.Minimap = {
    GetCenter = function()
      return 0, 0
    end,
    GetEffectiveScale = function()
      return 1
    end,
  }
  _G.GetCursorPosition = function()
    return 100, 100
  end
  _G.STANDARD_TEXT_FONT = "Fonts\\ARIALN.TTF"
  _G.SetMapToCurrentZone = noop
  _G.GetPlayerMapPosition = function()
    return 0, 0
  end
  _G.GetPlayerFacing = function()
    return 0
  end
  _G.GetBindLocation = function()
    return "Dun Morogh"
  end
  _G.GetTitleText = function()
    return nil
  end
  _G.UnitXP = function()
    return 0
  end
  _G.UnitXPMax = function()
    return 100
  end
  _G.UnitLevel = function()
    return 42
  end
  _G.AcceptQuest = noop
  _G.CompleteQuest = noop
  _G.GetNumQuestChoices = function()
    return 0
  end
  _G.GetQuestItemLink = function() end
  _G.GetQuestReward = noop
  _G.IsQuestCompletable = function()
    return false
  end
  _G.GetGossipActiveQuests = function() end
  _G.GetGossipAvailableQuests = function() end
  _G.SelectGossipActiveQuest = noop
  _G.SelectGossipAvailableQuest = noop
  _G.GetNumActiveQuests = function()
    return 0
  end
  _G.GetNumAvailableQuests = function()
    return 0
  end
  _G.GetActiveTitle = function() end
  _G.SelectActiveQuest = noop
  _G.SelectAvailableQuest = noop
  _G.TaxiFrame = {
    IsShown = function()
      return false
    end,
  }
  _G.MerchantFrame = {
    IsShown = function()
      return true
    end,
    IsVisible = function()
      return true
    end,
    selectedTab = 1,
  }
  _G.BuyMerchantItem = noop
  _G.GetMerchantNumItems = function()
    return 0
  end
  _G.GetMerchantItemInfo = function() end
  _G.GetCursorInfo = function() end
  _G.ClearCursor = noop
  _G.UseContainerItem = noop
  _G.ContainerFrame_GetFrameID = function(frame)
    return frame and frame.bag or 0
  end
  _G.ContainerFrameItemButton_OnClick = function() end
  _G.IsControlKeyDown = function()
    return false
  end
  _G.IsAltKeyDown = function()
    return false
  end
  _G.CreateFrame = function(kind, name, parent, template)
    local frame = { kind = kind, name = name, template = template, scripts = {}, parent = parent }
    if template == "UIPanelScrollFrameTemplate" then
      local scrollBar = {
        value = 0,
        minValue = 0,
        maxValue = 100,
      }
      scrollBar.GetMinMaxValues = function()
        return scrollBar.minValue, scrollBar.maxValue
      end
      scrollBar.GetValue = function()
        return scrollBar.value
      end
      scrollBar.SetValue = function(_, value)
        scrollBar.value = value
      end
      scrollBar.SetThumbTexture = noop
      scrollBar.Show = noop
      scrollBar.Hide = noop
      frame.ScrollBar = scrollBar
    end
    frame.RegisterEvent = function(_, ev)
      table.insert(registered, ev)
    end
    frame.UnregisterEvent = noop
    frame.SetScript = function(_, script, fn)
      scripts[script] = fn
      frame.scripts[script] = fn
    end
    frame.SetWidth = function(_, value)
      frame.width = value
    end
    frame.GetWidth = function()
      return frame.width or 300
    end
    frame.SetHeight = function(_, value)
      frame.height = value
    end
    frame.GetHeight = function()
      return frame.height or 250
    end
    frame.SetResizable = noop
    frame.SetMinResize = noop
    frame.StartSizing = noop
    frame.StopMovingOrSizing = noop
    frame.SetScrollChild = noop
    frame.EnableMouseWheel = noop
    frame.SetAlpha = noop
    frame.SetPoint = noop
    frame.SetMovable = noop
    frame.EnableMouse = noop
    frame.EnableKeyboard = function(_, enabled)
      frame.keyboardEnabled = enabled == true
    end
    frame.RegisterForDrag = noop
    frame.SetFrameStrata = noop
    frame.SetClampedToScreen = noop
    frame.Hide = function()
      frame.visible = false
    end
    frame.Show = function()
      frame.visible = true
    end
    frame.StartMoving = noop
    frame.StopMovingOrSizing = noop
    frame.GetPoint = function()
      return "TOP", nil, "TOP", 0, -110
    end
    frame.GetName = function()
      return frame.name
    end
    frame.SetText = function(_, text)
      frame.text = text
    end
    frame.GetText = function()
      return frame.text
    end
    frame.SetMultiLine = noop
    frame.SetTextInsets = noop
    frame.SetFontObject = noop
    frame.SetFocus = noop
    frame.ClearFocus = noop
    frame.HighlightText = noop
    frame.SetAutoFocus = noop
    frame.SetScrollChild = noop
    frame.LockHighlight = noop
    frame.UnlockHighlight = noop
    frame.GetChecked = function()
      return frame.checked
    end
    frame.SetChecked = function(_, value)
      frame.checked = value
    end
    frame.SetOrientation = noop
    frame.SetMinMaxValues = noop
    frame.SetValueStep = noop
    frame.SetBackdrop = noop
    frame.SetBackdropColor = noop
    frame.SetBackdropBorderColor = noop
    frame.SetValue = function(_, value)
      frame.value = value
    end
    frame.GetValue = function()
      return frame.value or 0
    end
    frame.SetThumbTexture = noop
    frame.RegisterForClicks = noop
    frame.SetHighlightTexture = noop
    frame.ClearAllPoints = noop
    frame.IsVisible = function()
      return frame.visible == true
    end
    frame.GetCenter = function()
      return 0, 0
    end
    frame.GetEffectiveScale = function()
      return 1
    end
    frame.SetNormalTexture = noop
    frame.SetPushedTexture = noop
    frame.SetDisabledTexture = noop
    frame.SetAllPoints = noop
    frame.SetBlendMode = noop
    frame.SetFrameLevel = noop
    frame.GetFrameLevel = function()
      return 1
    end
    frame.GetParent = function()
      return frame.parent
    end
    frame.SetScale = function(_, value)
      frame.scale = value
    end
    frame.GetScale = function()
      return frame.scale or 1
    end
    frame.IsShown = function()
      return frame.visible == true
    end
    frame.CreateTexture = function()
      local texture = {}
      texture.SetTexture = function(_, path)
        texture.path = path
      end
      texture.SetWidth = noop
      texture.SetHeight = noop
      texture.SetPoint = noop
      texture.ClearAllPoints = noop
      texture.SetAllPoints = noop
      texture.SetBlendMode = noop
      texture.SetAlpha = noop
      texture.IsShown = function()
        return true
      end
      texture.GetHeight = function()
        return 16
      end
      texture.SetTexCoord = function(_, ...)
        texture.coords = { ... }
      end
      texture.SetVertexColor = function(_, ...)
        texture.color = { ... }
      end
      texture.Show = noop
      texture.Hide = noop
      table.insert(textures, texture)
      return texture
    end
    frame.CreateFontString = function()
      local text = {}
      text.SetPoint = noop
      text.ClearAllPoints = noop
      text.SetWidth = function(_, value)
        text.width = value
      end
      text.SetJustifyH = noop
      text.SetJustifyV = noop
      text.SetNonSpaceWrap = noop
      text.SetAlpha = noop
      text.SetTextColor = function(_, r, g, b)
        text.color = { r, g, b }
      end
      text.SetShadowColor = noop
      text.SetShadowOffset = noop
      text.SetDrawLayer = noop
      text.Hide = noop
      text.Show = noop
      text.GetStringHeight = function()
        local lines = 1
        for _ in string.gmatch(text.value or "", "\n") do
          lines = lines + 1
        end
        return lines * ((text.font and text.font.size or 12) + 4)
      end
      text.GetStringWidth = function()
        local value = string.gsub(text.value or "", "|c%x%x%x%x%x%x%x%x", "")
        value = string.gsub(value, "|r", "")
        return string.len(value) * ((text.font and text.font.size or 12) * 0.5)
      end
      text.SetFont = function(_, path, size, flags)
        text.font = { path = path, size = size, flags = flags }
      end
      text.GetFont = function()
        local font = text.font or { path = "Font", size = 12, flags = "" }
        return font.path, font.size, font.flags
      end
      text.SetText = function(_, value)
        text.value = value
      end
      table.insert(texts, text)
      return text
    end
    table.insert(frames, frame)
    return frame
  end
  _G.UnitClass = function()
    return "Mage", "MAGE"
  end
  _G.UnitRace = function()
    return "Undead", "Undead"
  end
  _G.UnitFactionGroup = function()
    return "Horde"
  end
  _G.UnitLevel = function()
    return 42
  end
  _G.UnitName = function()
    return "Tester"
  end
  env.messages = messages
  env.scripts = scripts
  env.registered = registered
  env.frames = frames
  env.textures = textures
  env.texts = texts
  env.dropdownButtons = dropdownButtons
end

function env.load(...)
  for _, file in ipairs({ ... }) do
    dofile(file)
  end
  return _G.TurtleGuides
end

function env.eq(actual, expected, label)
  if actual ~= expected then
    error((label or "value") .. ": expected " .. tostring(expected) .. ", got " .. tostring(actual), 2)
  end
end

return env
