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
    env.eq(picker.rows[1].text.value, "Alliance - Human 1-10")
    picker.rows[1].scripts.OnClick()
    env.eq(loaded, "human")
    env.eq(picker:IsShown(), false)
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
