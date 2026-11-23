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
  _G.DEFAULT_CHAT_FRAME = {
    AddMessage = function(_, msg)
      table.insert(messages, msg)
    end,
  }
  _G.SlashCmdList = {}
  _G.CreateFrame = function()
    local frame = {}
    frame.RegisterEvent = function(_, ev)
      table.insert(registered, ev)
    end
    frame.UnregisterEvent = function() end
    frame.SetScript = function(_, name, fn)
      scripts[name] = fn
    end
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
