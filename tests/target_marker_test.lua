local env, loadEngine = dofile("tests/engine_base.lua")

local function setup(step)
  local TG = loadEngine()
  _G.UnitExists = function()
    return true
  end
  _G.UnitName = function(token)
    if token == "plate1" then
      return "Rejold Barleybrew"
    elseif token == "plate2" then
      return "Frostmane Seer"
    end
    return "Someone Else"
  end
  _G.GetRaidTargetIndex = function()
    return nil
  end
  _G.UnitIsDead = function()
    return false
  end
  _G.UnitIsPlayer = function()
    return false
  end
  _G.UnitIsUnit = function()
    return false
  end
  _G.SetRaidTarget = function() end
  _G.C_NamePlate = {
    GetNamePlates = function()
      return {
        { namePlateUnitToken = "plate1" },
        { namePlateUnitToken = "plate2" },
        { namePlateUnitToken = "plate3" },
      }
    end,
  }
  TG.currentGuide = { steps = { step or { elements = {} } } }
  TG.currentStepIndex = 1
  env.load("src/engine/TargetMarker.lua")
  return TG
end

local function textStep(text, elements)
  local step = { elements = elements or {} }
  table.insert(step.elements, 1, { t = "text", text = text })
  return step
end

local function targetStep(name)
  return { elements = { { t = "cmd", tag = "mob", sourceTag = "target", args = { name } } } }
end

return {
  test_marks_target_npc_with_star = function()
    setup(targetStep("Rejold Barleybrew"))
    local calls = {}
    _G.SetRaidTarget = function(token, index)
      table.insert(calls, token .. ":" .. index)
    end
    _G.TurtleGuides.TargetMarker.scan()
    env.eq(table.concat(calls, ","), "plate1:1")
  end,

  test_marks_friendly_vendor_text_with_star = function()
    setup(textStep(">>Talk to |cRXP_FRIENDLY_Rejold Barleybrew|r", {
      { t = "cmd", tag = "vendor", args = {} },
    }))
    local calls = {}
    _G.SetRaidTarget = function(token, index)
      table.insert(calls, token .. ":" .. index)
    end
    _G.TurtleGuides.TargetMarker.scan()
    env.eq(table.concat(calls, ","), "plate1:1")
  end,

  test_marks_enemy_text_with_skull = function()
    setup(textStep(">>Kill |cRXP_ENEMY_Frostmane Seer|r", {
      { t = "cmd", tag = "mob", sourceTag = "kill", args = { "Frostmane Seer" } },
    }))
    local calls = {}
    _G.SetRaidTarget = function(token, index)
      table.insert(calls, token .. ":" .. index)
    end
    _G.TurtleGuides.TargetMarker.scan()
    env.eq(table.concat(calls, ","), "plate2:8")
  end,

  test_marks_friendly_and_enemy_in_same_step = function()
    setup(textStep(">>Talk to |cRXP_FRIENDLY_Rejold Barleybrew|r, then kill |cRXP_ENEMY_Frostmane Seer|r"))
    local calls = {}
    _G.SetRaidTarget = function(token, index)
      table.insert(calls, token .. ":" .. index)
    end
    _G.TurtleGuides.TargetMarker.scan()
    env.eq(table.concat(calls, ","), "plate1:1,plate2:8")
  end,

  test_does_not_override_existing_raid_icon = function()
    setup(targetStep("Rejold Barleybrew"))
    _G.GetRaidTargetIndex = function()
      return 8
    end
    local calls = 0
    _G.SetRaidTarget = function()
      calls = calls + 1
    end
    _G.TurtleGuides.TargetMarker.scan()
    env.eq(calls, 0)
  end,

  test_strips_secondary_target_prefix = function()
    setup(targetStep("+Rejold Barleybrew"))
    local calls = {}
    _G.SetRaidTarget = function(token, index)
      table.insert(calls, token .. ":" .. index)
    end
    _G.TurtleGuides.TargetMarker.scan()
    env.eq(table.concat(calls, ","), "plate1:1")
  end,

  test_ignores_mob_and_kill_without_enemy_text = function()
    setup({ elements = { { t = "cmd", tag = "mob", sourceTag = "kill", args = { "Frostmane Seer" } } } })
    local calls = 0
    _G.SetRaidTarget = function()
      calls = calls + 1
    end
    _G.TurtleGuides.TargetMarker.scan()
    env.eq(calls, 0)
  end,

  test_clears_marks_when_step_changes = function()
    local TG = setup(targetStep("Rejold Barleybrew"))
    local calls = {}
    local icons = {}
    _G.GetRaidTargetIndex = function(token)
      return icons[token]
    end
    _G.SetRaidTarget = function(token, index)
      icons[token] = index
      table.insert(calls, token .. ":" .. index)
    end
    TG.TargetMarker.scan()
    TG.currentGuide.steps[1] = { elements = {} }
    TG.TargetMarker.scan()
    env.eq(table.concat(calls, ","), "plate1:1,plate1:0")
  end,

  test_no_nameplate_api_is_safe = function()
    setup(targetStep("Rejold Barleybrew"))
    _G.C_NamePlate = nil
    local calls = 0
    _G.SetRaidTarget = function()
      calls = calls + 1
    end
    _G.TurtleGuides.TargetMarker.scan()
    env.eq(calls, 0)
  end,

  test_marks_targeted_npc_without_nameplates = function()
    setup(targetStep("Rejold Barleybrew"))
    _G.C_NamePlate = nil
    _G.UnitExists = function(token)
      return token == "target"
    end
    _G.UnitName = function(token)
      return token == "target" and "Rejold Barleybrew" or nil
    end
    local calls = {}
    _G.SetRaidTarget = function(token, index)
      table.insert(calls, token .. ":" .. index)
    end
    _G.TurtleGuides.TargetMarker.scan()
    env.eq(table.concat(calls, ","), "target:1")
  end,

  test_skips_dead_nameplate = function()
    setup(targetStep("Rejold Barleybrew"))
    _G.UnitIsDead = function(token)
      return token == "plate1"
    end
    local calls = 0
    _G.SetRaidTarget = function()
      calls = calls + 1
    end
    _G.TurtleGuides.TargetMarker.scan()
    env.eq(calls, 0)
  end,

  test_skips_player_nameplate = function()
    setup(targetStep("Rejold Barleybrew"))
    _G.UnitIsPlayer = function(token)
      return token == "plate1"
    end
    local calls = 0
    _G.SetRaidTarget = function()
      calls = calls + 1
    end
    _G.TurtleGuides.TargetMarker.scan()
    env.eq(calls, 0)
  end,

  test_skips_pet_nameplate = function()
    setup(targetStep("Rejold Barleybrew"))
    _G.UnitIsUnit = function(token, other)
      return token == "plate1" and other == "pet"
    end
    local calls = 0
    _G.SetRaidTarget = function()
      calls = calls + 1
    end
    _G.TurtleGuides.TargetMarker.scan()
    env.eq(calls, 0)
  end,

  test_does_not_clear_missing_marked_unit = function()
    local TG = setup(targetStep("Rejold Barleybrew"))
    local calls = {}
    _G.SetRaidTarget = function(token, index)
      table.insert(calls, token .. ":" .. index)
    end
    TG.TargetMarker.scan()
    _G.UnitExists = function(token)
      return token ~= "plate1"
    end
    TG.currentGuide.steps[1] = { elements = {} }
    TG.TargetMarker.scan()
    env.eq(table.concat(calls, ","), "plate1:1")
  end,

  test_does_not_clear_reassigned_raid_icon = function()
    local TG = setup(targetStep("Rejold Barleybrew"))
    local calls = {}
    local icon
    _G.GetRaidTargetIndex = function()
      return icon
    end
    _G.SetRaidTarget = function(token, index)
      icon = index
      table.insert(calls, token .. ":" .. index)
    end
    TG.TargetMarker.scan()
    icon = 8
    TG.currentGuide.steps[1] = { elements = {} }
    TG.TargetMarker.scan()
    env.eq(table.concat(calls, ","), "plate1:1")
  end,
}
