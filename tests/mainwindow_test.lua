local env = dofile("tests/env.lua")

local function fresh()
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
    "src/ui/MainWindow.lua",
    "src/ui/StepWindows.lua"
  )
end

return {
  test_init_creates_main_window = function()
    local TG = fresh()
    TG.db = {}
    TG:InitUI()
    env.eq(TG.mainFrame ~= nil, true)
    env.eq(table.getn(TG.UI.State.stepRows), 32)
  end,

  test_update_without_guide = function()
    local TG = fresh()
    TG.db = {}
    TG:InitUI()
    TG:UpdateUI()
    env.eq(TG.mainFrame.guideName.value, "No guide selected. Click Guides.")
  end,

  test_toggle_hides_and_shows = function()
    local TG = fresh()
    TG.db = {}
    TG:InitUI()
    TG:ToggleUI()
    env.eq(TG.mainFrame.visible, false)
    TG:ToggleUI()
    env.eq(TG.mainFrame.visible, true)
  end,

  test_modern_window_framing = function()
    local TG = fresh()
    TG.db = {}
    TG:InitUI()
    env.eq(TG.mainFrame.accentBar ~= nil, true)
    env.eq(TG.mainFrame.closeBtn ~= nil, true)
    env.eq(TG.mainFrame.title.value, "TurtleGuides")
  end,

  test_step_header_and_row_wrapping = function()
    local TG = fresh()
    TG.db = {}
    TG.currentGuide = { key = "k", name = "Guide", steps = {} }
    for i = 1, 21 do
      TG.currentGuide.steps[i] = { elements = { { t = "text", text = "step " .. i } } }
    end
    TG.currentStepIndex = 2
    TG.CurrentStep = function()
      return TG.currentGuide.steps[TG.currentStepIndex]
    end
    TG.GetActiveAuxSteps = function()
      return {}
    end
    TG:InitUI()
    env.eq(TG.mainFrame.stepHeader.value, "Current step 2 / 21")
    local body = TG.UI.State.stepLines[1].value or ""
    env.eq(string.find(body, "step 2", 1, true) ~= nil, true)
    env.eq(string.find(body, "step 3", 1, true), nil)
    local row = TG.UI.State.stepRows[1]
    env.eq(row:GetWidth() > 0, true)
    env.eq(row.text.width > 0, true)
    env.eq(row.text.width <= row:GetWidth(), true)
  end,

  test_width_ignores_stale_scroll_frame_width = function()
    local TG = fresh()
    TG.db = {}
    TG.currentGuide = { key = "k", name = "Guide", steps = {} }
    TG.currentGuide.steps[1] = { elements = { { t = "text", text = "start" } } }
    TG.currentGuide.steps[2] = { elements = { { t = "text", text = "next" } } }
    TG.currentStepIndex = 1
    TG.CurrentStep = function()
      return TG.currentGuide.steps[TG.currentStepIndex]
    end
    TG.GetActiveAuxSteps = function()
      return {}
    end
    TG:InitUI()
    TG.mainFrame.scrollFrame:SetWidth(0)
    TG.mainFrame.scrollContent:SetWidth(0)
    TG:UpdateUI()
    env.eq(TG.UI.State.stepRows[1].text.width, 320 - 104)
  end,

  test_wrapped_rows_grow_in_height = function()
    local TG = fresh()
    TG.db = {}
    TG.currentGuide = { key = "k", name = "Guide", steps = {} }
    TG.currentGuide.steps[1] = {
      elements = {
        { t = "text", text = "short" },
        { t = "text", text = string.rep("word ", 60) },
      },
    }
    TG.currentGuide.steps[2] = { elements = { { t = "text", text = "later" } } }
    TG.currentStepIndex = 1
    TG.CurrentStep = function()
      return TG.currentGuide.steps[TG.currentStepIndex]
    end
    TG.GetActiveAuxSteps = function()
      return {}
    end
    TG:InitUI()
    local rows = TG.UI.State.stepRows
    env.eq(rows[1]:GetHeight() < rows[2]:GetHeight(), true)
  end,

  test_mouse_wheel_uses_native_handler = function()
    local TG = fresh()
    TG.db = {}
    TG:InitUI()
    local scrollFrame = TG.mainFrame.scrollFrame
    env.eq(scrollFrame.scripts.OnMouseWheel, nil)
    env.eq(scrollFrame.kind, "ScrollFrame")
  end,
}
