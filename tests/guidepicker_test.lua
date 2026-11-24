local env = dofile("tests/env.lua")

local function loadUI()
  env.reset()
  return env.load(
    "src/Core.lua",
    "src/compat/Runtime.lua",
    "src/core/Util.lua",
    "src/compat/Text.lua",
    "src/ui/State.lua",
    "src/ui/Theme.lua",
    "src/ui/TextWrap.lua",
    "src/ui/StepText.lua",
    "src/ui/Widgets.lua",
    "src/ui/MainWindow.lua",
    "src/ui/GuidePicker.lua"
  )
end

local function categories()
  return {
    {
      name = "Speedrun",
      guides = {
        { key = "g1", group = "Alliance", name = "Dun Morogh" },
        { key = "g2", group = "Horde", name = "Durotar" },
      },
    },
  }
end

return {
  test_show_picker_builds_rows = function()
    local TG = loadUI()
    TG.db = {}
    TG.GetGuidesForPicker = categories
    TG:ShowGuidePicker()
    env.eq(TG.UI.State.pickerFrame ~= nil, true)
    env.eq(table.getn(TG.UI.State.pickerFrame.rows) >= 3, true)
  end,

  test_search_filters_guides = function()
    local TG = loadUI()
    TG.db = {}
    TG.GetGuidesForPicker = categories
    TG:ShowGuidePicker()
    TG.UI.State.pickerFrame.searchBox:SetText("Durotar")
    TG:RefreshGuidePicker()
    local found = false
    for _, row in ipairs(TG.UI.State.pickerFrame.rows) do
      if row.text.value and string.find(row.text.value, "Durotar", 1, true) then
        found = true
      end
    end
    env.eq(found, true)
  end,
}
