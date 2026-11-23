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
  _G.SlashCmdList = {}
  local frames, textures, texts = {}, {}, {}
  local noop = function() end
  _G.UIParent = {}
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
  _G.CreateFrame = function(kind, name)
    local frame = { kind = kind, name = name, scripts = {} }
    frame.RegisterEvent = function(_, ev)
      table.insert(registered, ev)
    end
    frame.UnregisterEvent = noop
    frame.SetScript = function(_, script, fn)
      scripts[script] = fn
      frame.scripts[script] = fn
    end
    frame.SetWidth = noop
    frame.SetHeight = noop
    frame.SetPoint = noop
    frame.SetMovable = noop
    frame.EnableMouse = noop
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
    frame.CreateTexture = function()
      local texture = {}
      texture.SetTexture = noop
      texture.SetWidth = noop
      texture.SetHeight = noop
      texture.SetPoint = noop
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
      text.SetWidth = noop
      text.SetJustifyH = noop
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
