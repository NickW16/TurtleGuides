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
    "src/ui/Settings.lua"
  )
end

return {
  test_show_settings_builds_tabs = function()
    local TG = loadUI()
    TG.db = { theme = "dark", uiScale = 1.0 }
    TG:ShowSettings()
    env.eq(TG.UI.State.settingsFrame ~= nil, true)
    env.eq(table.getn(TG.UI.State.settingsFrame.cbs) > 0, true)
    env.eq(TG.UI.State.settingsFrame.activeTab, "General")
  end,

  test_suggestions_status = function()
    local TG = loadUI()
    TG.db = { theme = "dark", uiScale = 1.0 }
    TG.SuggestGuides = function()
      return { { guide = { key = "g1", group = "Alliance", name = "Dun Morogh" }, lo = 1, hi = 12 } }
    end
    TG:ShowSettings("Guides")
    env.eq(string.find(TG.UI.State.settingsFrame.suggestStatus.value, "Suggested guides", 1, true) ~= nil, true)
    env.eq(TG.UI.State.settingsFrame.suggestRows[1].title.value, "Alliance - Dun Morogh")
  end,
}
