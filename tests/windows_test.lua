local env = dofile("tests/env.lua")

local function fresh()
  env.reset()
  local TG = env.load(
    "src/Core.lua",
    "src/compat/Runtime.lua",
    "src/core/Util.lua",
    "src/compat/Text.lua",
    "src/ui/State.lua",
    "src/ui/Icons.lua",
    "src/ui/Text.lua",
    "src/ui/Scrollbar.lua",
    "src/ui/Windows.lua"
  )
  TG.db = {}
  TG.IsElementTrackable = function(_, el)
    return el.t == "cmd" and el.tag == "accept"
  end
  TG.IsElementDone = function()
    return false
  end
  TG.GetActiveAuxSteps = function()
    return {}
  end
  return TG
end

local function withGuide(TG)
  TG.currentGuide = { key = "k", name = "Guide", category = "Speedrun", steps = {} }
  for i = 1, 8 do
    TG.currentGuide.steps[i] = { elements = { { t = "text", text = "step " .. i } } }
  end
  TG.currentGuide.steps[2].elements = { { t = "cmd", tag = "accept", args = { "1" }, text = "Accept Test" } }
  TG.currentStepIndex = 2
end

return {
  test_init_creates_main_and_small_windows = function()
    local TG = fresh()
    TG:InitUI()
    env.eq(TG.mainFrame ~= nil, true)
    env.eq(table.getn(TG.UI.State.smalls), 3)
    env.eq(TG.UI.State.main:IsShown(), true)
  end,

  test_small_window_shows_current_step = function()
    local TG = fresh()
    withGuide(TG)
    TG:InitUI()
    env.eq(TG.UI.State.main.title.value, "Guide")
    env.eq(TG.UI.State.main.version.value, "tg 0.1.0")
    env.eq(TG.UI.State.main.guideName.value, "Fast Route")
    local small = TG.UI.State.smalls[1]
    env.eq(small:IsShown(), true)
    env.eq(small.title.value, "Step 2")
    env.eq(string.find(small.body.value or "", "Accept: Test", 1, true) ~= nil, true)
  end,

  test_main_window_shows_upcoming_steps = function()
    local TG = fresh()
    withGuide(TG)
    TG:InitUI()
    local joined = ""
    for _, row in ipairs(TG.UI.Windows.rows()) do
      joined = joined .. "\n" .. (row.text.value or "")
    end
    env.eq(string.find(joined, "Step 3", 1, true) ~= nil, true)
    env.eq(string.find(joined, "step 3", 1, true) ~= nil, true)
    env.eq(string.find(joined, "step 2", 1, true), nil)
  end,

  test_main_rows_indent_tasks_below_headers = function()
    local TG = fresh()
    withGuide(TG)
    TG:InitUI()
    local rows = TG.UI.Windows.rows()
    env.eq(rows[1].kind, "header")
    env.eq(rows[2].kind, "task")
    env.eq(rows[1].text.width > rows[2].text.width, true)
    env.eq(TG.UI.State.main.content:GetHeight() > 20, true)
  end,

  test_minimize_collapses_to_top_bar = function()
    local TG = fresh()
    withGuide(TG)
    TG:InitUI()
    local main = TG.UI.State.main
    TG:SetMainWindowMinimized(true)
    env.eq(main:GetHeight(), 36)
    env.eq(main.scroll:IsShown(), false)
    env.eq(string.find(main.progress.value or "", "/", 1, true) ~= nil, true)
    env.eq(TG.UI.State.smalls[1]:IsShown(), true)
    TG:SetMainWindowMinimized(false)
    env.eq(main:GetHeight() > 20, true)
    env.eq(main.scroll:IsShown(), true)
  end,

  test_checkbox_click_marks_manual_done = function()
    local TG = fresh()
    withGuide(TG)
    local marked
    TG.SetElementManualDone = function(_, el, value)
      marked = { el = el, value = value }
    end
    TG.currentGuide.steps[3].elements = { { t = "cmd", tag = "accept", args = { "1" }, text = "Accept Test" } }
    TG:InitUI()
    for _, row in ipairs(TG.UI.Windows.rows()) do
      if row.el and row.el.tag == "accept" then
        row.check.scripts.OnClick()
        break
      end
    end
    env.eq(marked.value, true)
    env.eq(marked.el.tag, "accept")
  end,
}
