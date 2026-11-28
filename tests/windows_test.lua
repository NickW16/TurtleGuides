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

  test_loot_name_shows_builtin_content_icon = function()
    local TG = fresh()
    withGuide(TG)
    local path = "Interface\\ICONS\\INV_Misc_Food_14"
    TG.OctoWowIcons = { names = { ["Boar Meat"] = path } }
    TG.currentGuide.steps[2].elements = { { t = "text", text = "Loot |cRXP_LOOT_Boar Meat|r" } }
    TG:InitUI()
    env.eq(TG.UI.State.smalls[1].rows[1].contentIcon.path, path)
  end,

  test_multiple_content_icons_on_one_row = function()
    local TG = fresh()
    withGuide(TG)
    TG.OctoWowIcons = {
      names = {
        ["Recruit's Shirt"] = "P1",
        ["Recruit's Pants"] = "P2",
        ["Recruit's Boots"] = "P3",
      },
    }
    TG.currentGuide.steps[2].elements = {
      { t = "text", text = "Unequip your [Recruit's Shirt], [Recruit's Pants], and [Recruit's Boots]" },
    }
    TG:InitUI()
    local row = TG.UI.State.smalls[1].rows[1]
    env.eq(row.contentIcons[1].path, "P1")
    env.eq(row.contentIcons[2].path, "P2")
    env.eq(row.contentIcons[3].path, "P3")
    env.eq(string.find(row.text.value, "\001", 1, true) == nil, true)
  end,

  test_aux_window_uses_step_number_and_objective_rows = function()
    local TG = fresh()
    withGuide(TG)
    TG.IsElementTrackable = function(_, el)
      return el.t == "cmd" and (el.tag == "collect" or el.tag == "accept")
    end
    TG.GetActiveAuxSteps = function()
      return {
        {
          index = 1,
          elements = {
            { t = "text", text = "Kill boars. Loot them for their meat." },
            { t = "cmd", tag = "collect", args = { "769", "10" } },
          },
        },
      }
    end
    TG:InitUI()
    local window = TG.UI.State.smalls[2]
    env.eq(window.title.value, "Step 1")
    env.eq(string.find(window.rows[1].text.value, "Kill boars", 1, true) ~= nil, true)
    env.eq(window.rows[1].el.tag, "collect")
    env.eq(window.rows[2]:IsShown(), false)
    env.eq(window.title.color[1], 0.55)
    env.eq(window.title.color[2], 0.66)
    env.eq(window.title.color[3], 0.82)
    env.eq(TG.UI.State.smalls[1].title.color[1], 0.85)
  end,

  test_class_icon_uses_vanilla_sheet = function()
    local TG = fresh()
    TG:InitUI()
    local icon = TG.UI.State.main.classIcon
    env.eq(icon.path, "Interface\\Glues\\CharacterCreate\\UI-CharacterCreate-Classes")
    env.eq(icon.coords[1], 0.25)
    env.eq(icon.coords[2], 0.49609375)
    env.eq(icon.coords[3], 0)
    env.eq(icon.coords[4], 0.25)
  end,

  test_small_window_shows_current_step = function()
    local TG = fresh()
    withGuide(TG)
    TG:InitUI()
    env.eq(TG.UI.State.main.guideName.value, "Fast Route")
    local small = TG.UI.State.smalls[1]
    env.eq(small:IsShown(), true)
    env.eq(small.title.value, "Step 2")
    env.eq(string.find(small.rows[1].text.value or "", "Accept Test", 1, true) ~= nil, true)
    env.eq(small.rows[1].text.font.size, 11)
    env.eq(TG.UI.State.smalls[2].rows[1].text.font.size, 10)
    env.eq(small.plaque ~= nil, true)
  end,

  test_main_window_shows_upcoming_steps = function()
    local TG = fresh()
    withGuide(TG)
    TG:InitUI()
    local joined = ""
    for _, row in ipairs(TG.UI.Windows.rows()) do
      if row:IsShown() then
        joined = joined .. "\n" .. (row.text.value or "")
      end
    end
    env.eq(string.find(joined, "Step 3", 1, true) ~= nil, true)
    env.eq(string.find(joined, "step 3", 1, true) ~= nil, true)
    env.eq(string.find(joined, "Step 2", 1, true), nil)
  end,

  test_main_rows_show_step_number_at_end_of_block = function()
    local TG = fresh()
    withGuide(TG)
    TG:InitUI()
    local rows = TG.UI.Windows.rows()
    env.eq(rows[1].kind, "header")
    env.eq(rows[1].text.value, "Step 3")
    env.eq(rows[2].kind, "task")
    env.eq(string.find(rows[2].text.value or "", "step 3", 1, true) ~= nil, true)
    env.eq(TG.UI.State.main.content:GetHeight() > 20, true)
  end,

  test_wrapped_row_height_fits_measured_text = function()
    local TG = fresh()
    withGuide(TG)
    TG.currentGuide.steps[3].elements = { { t = "text", text = string.rep("word ", 60) } }
    TG:InitUI()
    local row = TG.UI.Windows.rows()[2]
    env.eq(string.find(row.text.value or "", "\n") ~= nil, true)
    env.eq(row.height > row.text:GetStringHeight(), true)
  end,

  test_minimize_collapses_to_top_bar = function()
    local TG = fresh()
    withGuide(TG)
    TG:InitUI()
    local main = TG.UI.State.main
    TG:SetMainWindowMinimized(true)
    env.eq(main:GetHeight(), 40)
    env.eq(main.scroll:IsShown(), false)
    env.eq(string.find(main.progress.value or "", "/", 1, true) ~= nil, true)
    env.eq(TG.UI.State.smalls[1]:IsShown(), true)
    TG:SetMainWindowMinimized(false)
    env.eq(main:GetHeight() > 20, true)
    env.eq(main.scroll:IsShown(), true)
  end,

  test_minimize_state_persists_across_init = function()
    local TG = fresh()
    TG.db = { frame = { w = 200, h = 180, minimized = true } }
    TG:InitUI()
    local main = TG.UI.State.main
    env.eq(main:GetHeight(), 40)
    env.eq(main._tgMinimized, true)
    env.eq(main.scroll:IsShown(), false)
    env.eq(main.resizer:IsShown(), false)
  end,

  test_minimize_saves_and_restores_expanded_height = function()
    local TG = fresh()
    TG.db = { frame = { w = 200, h = 180, minimized = false } }
    TG:InitUI()
    local main = TG.UI.State.main
    TG:SetMainWindowMinimized(true)
    env.eq(TG.db.frame.minimized, true)
    env.eq(TG.db.frame.h, 180)
    env.eq(main:GetHeight(), 40)
    TG:SetMainWindowMinimized(false)
    env.eq(TG.db.frame.minimized, false)
    env.eq(main:GetHeight(), 180)
    env.eq(main.scroll:IsShown(), true)
  end,

  test_squeezed_window_auto_minimizes = function()
    local TG = fresh()
    TG.db = { frame = { w = 200, h = 180, minimized = false } }
    TG:InitUI()
    local main = TG.UI.State.main
    main.height = 44
    main.resizer.scripts.OnDragStop()
    env.eq(TG.db.frame.minimized, true)
    env.eq(main:GetHeight(), 40)
    env.eq(main.scroll:IsShown(), false)
  end,

  test_trackable_bullet_row_shows_checkbox = function()
    local TG = fresh()
    withGuide(TG)
    TG.IsElementTrackable = function()
      return true
    end
    TG.UI.Icons.forElement = function()
      return "Interface\\GossipFrame\\GossipGossipIcon"
    end
    TG.UI.Icons.isBullet = function()
      return true
    end
    TG.currentGuide.steps[2].elements = { { t = "text", text = "Talk to Einris Brightspear" } }
    TG:InitUI()
    local row = TG.UI.State.smalls[1].rows[1]
    env.eq(row.check:IsShown(), true)
    env.eq(row.itemIcon.path, "Interface\\GossipFrame\\GossipGossipIcon")
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
