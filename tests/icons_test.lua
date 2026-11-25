local env = dofile("tests/env.lua")

local function fresh()
  env.reset()
  return env.load(
    "src/Core.lua",
    "src/core/Util.lua",
    "src/compat/Text.lua",
    "src/ui/State.lua",
    "src/ui/Icons.lua",
    "src/ui/Text.lua"
  )
end

return {
  test_inline_textures_are_stripped_from_text = function()
    local TG = fresh()
    local icons = TG.UI.Icons
    env.eq(icons.clean("Train |T132333:0|t[Battle Shout]"), "Train [Battle Shout]")
    env.eq(icons.measure("Train |T132333:0|t[Battle Shout]"), "Train [Battle Shout]")
  end,

  test_train_step_resolves_spell_icon = function()
    local TG = fresh()
    _G.GetSpellInfo = function()
      return "Battle Shout", "", "Interface\\Icons\\Ability_Warrior_BattleShout"
    end
    local step = { elements = { { t = "cmd", tag = "train", args = { "6673" }, text = "" } } }
    local entries = TG.UI.Text.entries(step)
    env.eq(entries[1].icon, "Interface\\Icons\\Ability_Warrior_BattleShout")
    env.eq(entries[1].text, "Train: Battle Shout")
  end,

  test_train_step_with_inline_token_has_clean_text = function()
    local TG = fresh()
    local text =
      TG.UI.Text.element({ t = "cmd", tag = "train", args = { "6673" }, text = "Train |T132333:0|t[Battle Shout]" })
    env.eq(text, "Train [Battle Shout]")
  end,

  test_quest_vendor_mob_and_talk_icons = function()
    local TG = fresh()
    local function iconFor(element)
      local entries = TG.UI.Text.entries({ elements = { element } })
      return entries[1].icon
    end
    env.eq(
      iconFor({ t = "cmd", tag = "accept", args = { "1" }, text = "" }),
      "Interface\\GossipFrame\\AvailableQuestIcon"
    )
    env.eq(
      iconFor({ t = "cmd", tag = "turnin", args = { "1" }, text = "" }),
      "Interface\\GossipFrame\\IncompleteQuestIcon"
    )
    env.eq(iconFor({ t = "cmd", tag = "vendor", args = {}, text = "" }), "Interface\\Cursor\\Buy")
    env.eq(iconFor({ t = "cmd", tag = "mob", args = {}, text = "Ragged Young Wolf" }), "Interface\\Cursor\\Attack")
    env.eq(iconFor({ t = "text", text = "Talk to Thran Khorman" }), "Interface\\Cursor\\Speak")
    local available = TG.UI.Text.entries({ elements = { { t = "cmd", tag = "accept", args = { "1" }, text = "" } } })
    local pending = TG.UI.Text.entries({ elements = { { t = "cmd", tag = "turnin", args = { "1" }, text = "" } } })
    local entriesForTrain =
      TG.UI.Text.entries({ elements = { { t = "cmd", tag = "train", args = { "6673" }, text = "" } } })
    env.eq(available[1].bulletIcon, true)
    env.eq(pending[1].bulletIcon, true)
    env.eq(entriesForTrain[1].bulletIcon, false)

    TG.IsElementTrackable = function()
      return true
    end
    TG.IsElementDone = function()
      return true
    end
    env.eq(
      iconFor({ t = "cmd", tag = "accept", args = { "1" }, text = "" }),
      "Interface\\GossipFrame\\IncompleteQuestIcon"
    )
    env.eq(iconFor({ t = "cmd", tag = "turnin", args = { "1" }, text = "" }), "Interface\\GossipFrame\\ActiveQuestIcon")
  end,

  test_collect_step_resolves_item_icon = function()
    local TG = fresh()
    TG.GetItemCount = function()
      return 2
    end
    _G.GetItemInfo = function()
      return "Refreshing Spring Water", nil, nil, nil, nil, nil, nil, nil, nil, "Interface\\Icons\\INV_Drink_05"
    end
    local step = { elements = { { t = "cmd", tag = "collect", args = { "159", "15" }, text = "" } } }
    local entries = TG.UI.Text.entries(step)
    env.eq(entries[1].icon, "Interface\\Icons\\INV_Drink_05")
  end,
}
