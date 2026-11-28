local env = dofile("tests/env.lua")

local function fresh()
  env.reset()
  return env.load(
    "src/Core.lua",
    "src/core/Util.lua",
    "src/compat/Text.lua",
    "src/ui/State.lua",
    "src/guides/ItemIcons.lua",
    "src/guides/OctoWowIcons.lua",
    "src/ui/Icons.lua",
    "src/ui/Text.lua"
  )
end

return {
  test_item_icon_prefers_generated_database = function()
    local TG = fresh()
    _G.GetItemInfo = function()
      error("GetItemInfo should not be needed for a known item")
    end
    env.eq(TG.UI.Icons.item(132090), "Interface\\ICONS\\Ability_BackStab")
  end,

  test_item_icon_uses_ninth_return_on_stock_client = function()
    local TG = fresh()
    _G.GetItemInfo = function()
      return "Unknown", nil, nil, nil, nil, nil, nil, nil, "Interface\\Icons\\INV_Misc_QuestionMark", 12
    end
    env.eq(TG.UI.Icons.item(999999), "Interface\\Icons\\INV_Misc_QuestionMark")
  end,

  test_item_icon_handles_pfui_getiteminfo_shape = function()
    local TG = fresh()
    _G.GetItemInfo = function()
      return "Unknown", "link", 1, nil, "Category", "Sub", 1
    end
    env.eq(TG.UI.Icons.item(999999), nil)
  end,

  test_inline_textures_are_stripped_and_resolved = function()
    local TG = fresh()
    local icons = TG.UI.Icons
    env.eq(icons.clean("Train |T132333:0|t[Battle Shout]"), "Train [Battle Shout]")
    env.eq(icons.measure("Train |T132333:0|t[Battle Shout]"), "Train [Battle Shout]")
    env.eq(icons.fromText("|T132333:0|t[Battle Shout]"), "Interface\\ICONS\\Ability_Warrior_BattleShout")
  end,

  test_textless_train_is_hidden = function()
    local TG = fresh()
    local step = { elements = { { t = "cmd", tag = "train", args = { "6673" }, text = "" } } }
    env.eq(table.getn(TG.UI.Text.entries(step)), 0)
  end,

  test_train_step_with_inline_token_has_clean_text = function()
    local TG = fresh()
    local text =
      TG.UI.Text.element({ t = "cmd", tag = "train", args = { "6673" }, text = "Train |T132333:0|t[Battle Shout]" })
    env.eq(text, "Train [|cffffd100Battle Shout|r]")
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
    env.eq(iconFor({ t = "cmd", tag = "turnin", args = { "1" }, text = "" }), "Interface\\GossipFrame\\ActiveQuestIcon")
    env.eq(iconFor({ t = "cmd", tag = "complete", args = { "1", "1" }, text = "" }), nil)
    env.eq(iconFor({ t = "cmd", tag = "vendor", args = {}, text = "" }), "Interface\\Cursor\\Buy")
    env.eq(iconFor({ t = "cmd", tag = "mob", args = {}, text = "Ragged Young Wolf" }), "Interface\\Cursor\\Attack")
    env.eq(iconFor({ t = "text", text = "Talk to Thran Khorman" }), "Interface\\GossipFrame\\GossipGossipIcon")
    env.eq(
      iconFor({ t = "cmd", tag = "fly", args = {}, text = "Fly to Westfall" }),
      "Interface\\GossipFrame\\TaxiGossipIcon"
    )
    local available = TG.UI.Text.entries({ elements = { { t = "cmd", tag = "accept", args = { "1" }, text = "" } } })
    local pending = TG.UI.Text.entries({ elements = { { t = "cmd", tag = "turnin", args = { "1" }, text = "" } } })
    local entriesForTrain = TG.UI.Text.entries({
      elements = { { t = "cmd", tag = "train", args = { "6673" }, text = "Train [Battle Shout]" } },
    })
    env.eq(available[1].bulletIcon, true)
    env.eq(pending[1].bulletIcon, true)
    env.eq(entriesForTrain[1].bulletIcon, true)

    TG.IsElementTrackable = function()
      return true
    end
    TG.IsElementDone = function()
      return true
    end
    local accepted = TG.UI.Text.entries({ elements = { { t = "cmd", tag = "accept", args = { "1" }, text = "" } } })
    env.eq(accepted[1].icon, "Interface\\GossipFrame\\AvailableQuestIcon")
    env.eq(accepted[1].iconColor, nil)
    env.eq(iconFor({ t = "cmd", tag = "turnin", args = { "1" }, text = "" }), "Interface\\GossipFrame\\ActiveQuestIcon")
  end,

  test_buy_text_uses_buy_icon = function()
    local TG = fresh()
    env.eq(TG.UI.Icons.forText("Buy the following items"), "Interface\\Cursor\\Buy")
    env.eq(TG.UI.Icons.forText("Talk to Auctioneer Jaxon"), "Interface\\GossipFrame\\GossipGossipIcon")
  end,

  test_hearth_text_uses_hearthstone_icon = function()
    local TG = fresh()
    env.eq(TG.UI.Icons.forText("Hearth to Colridge Valley"), "Interface\\Icons\\INV_Misc_Rune_01")
    env.eq(TG.UI.Icons.forText("Delete the [Hearthstone] from your bag"), nil)
  end,

  test_travel_icon_for_goto_and_travel_text = function()
    local TG = fresh()
    local icons = TG.UI.Icons
    local travel = "Interface\\GossipFrame\\TaxiGossipIcon"
    env.eq(icons.forElement({ t = "cmd", tag = "goto", args = { "Dun Morogh", "34", "51" } }), travel)
    env.eq(icons.forText("Travel toward Tundra MacGrann"), travel)
    env.eq(icons.forText("Travel toward Tundra MacGrann. Kill Boars en-route"), travel)
    env.eq(icons.forText("Kill Boars en-route"), "Interface\\Cursor\\Attack")
    env.eq(icons.isBullet(travel), true)
    local step = {
      completewith = true,
      elements = {
        {
          t = "cmd",
          tag = "goto",
          args = { "Dun Morogh", "34", "51" },
          text = "Travel toward Tundra MacGrann",
        },
        { t = "text", text = "Kill Boars, Bears and Wolves en-route" },
      },
    }
    local entries = TG.UI.Text.entries(step)
    env.eq(table.getn(entries), 2)
    env.eq(entries[1].icon, travel)
    env.eq(entries[1].bulletIcon, true)
    env.eq(entries[2].icon, "Interface\\Cursor\\Attack")
  end,

  test_generated_item_icon_table_resolves_names = function()
    local TG = fresh()
    env.eq(TG.ItemIcons[132090] ~= nil, true)
    env.eq(TG.UI.Icons.content("Use [Battle Shout]"), "Interface\\ICONS\\Ability_Warrior_BattleShout")
    env.eq(TG.UI.Icons.content("Loot [Tough Wolf Meat]"), "Interface\\ICONS\\INV_Misc_Food_16")
  end,

  test_octowow_list_resolves_item_and_spell_ids = function()
    local TG = fresh()
    env.eq(TG.OctoWowIcons.source, "octowow")
    env.eq(TG.UI.Icons.item(159), "Interface\\ICONS\\INV_Drink_07")
    env.eq(TG.UI.Icons.spell(6673), "Interface\\ICONS\\Ability_Warrior_BattleShout")
    env.eq(TG.UI.Icons.content("Use [Refreshing Spring Water]"), "Interface\\ICONS\\INV_Drink_07")
  end,

  test_path_tokens_resolve_without_a_numeric_id = function()
    local TG = fresh()
    local icons = TG.UI.Icons
    env.eq(
      icons.fromText("|TInterface/GossipFrame/HealerGossipIcon:0|tClick"),
      "Interface/GossipFrame/HealerGossipIcon"
    )
    env.eq(icons.fromText("|TInterface\\ICONS\\INV_Drink_07:0|tWater"), "Interface\\ICONS\\INV_Drink_07")
    env.eq(icons.fromText("|T132333:0|t[Battle Shout]"), "Interface\\ICONS\\Ability_Warrior_BattleShout")
  end,

  test_plural_item_name_falls_back_to_singular = function()
    local TG = fresh()
    TG.GetItemIdByName = function(_, name)
      if name == "Kobold Candle" then
        return 999998
      end
      return nil
    end
    _G.GetItemInfo = function()
      return "Kobold Candle", nil, nil, nil, nil, nil, nil, nil, "Interface\\ICONS\\INV_Misc_Candle_01"
    end
    env.eq(TG.UI.Icons.byName("Kobold Candles"), "Interface\\ICONS\\INV_Misc_Candle_01")
  end,

  test_unknown_name_does_not_use_question_mark_icon = function()
    local TG = fresh()
    env.eq(TG.UI.Icons.byName("Head"), nil)
  end,

  test_content_resolves_loot_names_with_octowow = function()
    local TG = fresh()
    local path = "Interface\\ICONS\\INV_Misc_Food_14"
    TG.OctoWowIcons.names["Chunks of Boar Meat"] = path
    env.eq(TG.UI.Icons.content("Loot |cRXP_LOOT_Chunks of Boar Meat|r"), path)
    env.eq(TG.UI.Icons.content("Loot [Chunks of Boar Meat]"), path)
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
    env.eq(entries[1].icon, "Interface\\Icons\\INV_Misc_Bag_08")
  end,
}
