local env = dofile("tests/env.lua")

local function fresh()
  env.reset()
  return env.load(
    "src/Core.lua",
    "src/core/Util.lua",
    "src/ui/State.lua",
    "src/ui/Text.lua",
    "src/ui/Scrollbar.lua",
    "src/ui/Picker.lua"
  )
end

return {
  test_picker_lists_and_loads_guides = function()
    local TG = fresh()
    TG.GetGuidesForPicker = function()
      return { { name = "Starter", guides = { { key = "human", group = "Alliance", name = "Human 1-10" } } } }
    end
    local loaded
    TG.SetGuide = function(_, key)
      loaded = key
    end
    TG:ShowGuidePicker()
    local picker = TG.UI.State.picker
    env.eq(picker:IsShown(), true)
    env.eq(picker.rows[1]:IsShown(), true)
    env.eq(picker.rows[1].text.value, "Starter (1)")
    env.eq(picker.rows[2].text.value, "Alliance - Human 1-10")
    picker.rows[2].scripts.OnClick()
    env.eq(loaded, "human")
    env.eq(picker:IsShown(), false)
  end,

  test_picker_header_collapses_category = function()
    local TG = fresh()
    TG.GetGuidesForPicker = function()
      return { { name = "Starter", guides = { { key = "human", group = "Alliance", name = "Human 1-10" } } } }
    end
    TG:ShowGuidePicker()
    local picker = TG.UI.State.picker
    env.eq(picker.rows[2]:IsShown(), true)
    picker.rows[1].scripts.OnClick()
    env.eq(picker.rows[2]:IsShown(), false)
    env.eq(picker.rows[1].chevron ~= nil, true)
    picker.rows[1].scripts.OnClick()
    env.eq(picker.rows[2]:IsShown(), true)
  end,

  test_picker_grows_rows_for_all_guides = function()
    local TG = fresh()
    local guides = {}
    for i = 1, 40 do
      table.insert(guides, { key = "g" .. i, group = "Alliance", name = "Guide " .. i })
    end
    TG.GetGuidesForPicker = function()
      return { { name = "Speedrun", guides = guides } }
    end
    TG:ShowGuidePicker()
    local picker = TG.UI.State.picker
    env.eq(table.getn(picker.rows) >= 41, true)
    env.eq(picker.rows[41]:IsShown(), true)
    env.eq(picker.rows[41].text.value, "Fast Route - Guide 40")
  end,

  test_picker_search_filters_results = function()
    local TG = fresh()
    TG.GetGuidesForPicker = function()
      return { { name = "Starter", guides = { { key = "human", group = "Alliance", name = "Human 1-10" } } } }
    end
    TG:ShowGuidePicker()
    local picker = TG.UI.State.picker
    picker.search:SetText("does not match")
    TG:RefreshGuidePicker()
    env.eq(picker.rows[1]:IsShown(), false)
    env.eq(string.find(picker.placeholder.value or "", "Search", 1, true) ~= nil, false)
  end,
}
