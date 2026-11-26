-- saved variable defaults, player context, and guide state helpers
local TG = _G.TurtleGuides
local copyDefaults = TG.Util.copyDefaults

local defaults = {
  profile = {
    locked = false,
    showArrow = true,
    arrowColor = "royal",
    arrowScale = 1.0,
    disableAutoSkip = false,
    autoTurnIn = false,
    autoSellJunk = false,
    autoUseQuestItems = false,
    autoTakeFlight = false,
    autoBuyVendor = false,
    hardcoreMode = false,
    theme = "modern",
    uiScale = 1.0,
    textScale = 1.0,
    fontScale = 1.0,
    frameOrientation = "below",
    showMinimap = true,
    minimapPos = 220,
    frame = { point = "RIGHT", relPoint = "RIGHT", x = -40, y = 0, w = 200, h = 230 },
    settingsFrame = { point = "CENTER", relPoint = "CENTER", x = 60, y = 40 },
    arrowFrame = { point = "TOP", relPoint = "TOP", x = 0, y = -110 },
  },
  char = {
    currentGuideKey = nil,
    stepIndex = 1,
    completedSteps = {},
    turnedIn = {},
    junk = {},
  },
}

function TG:InitDB()
  TurtleGuidesDB = copyDefaults(defaults.profile, TurtleGuidesDB or {})
  if TurtleGuidesDB.uiScale == nil then
    TurtleGuidesDB.uiScale = TurtleGuidesDB.fontScale or 1.0
  end
  TurtleGuidesCharDB = copyDefaults(defaults.char, TurtleGuidesCharDB or {})
  self.db = TurtleGuidesDB
  self.cdb = TurtleGuidesCharDB
end

function TG:PlayerInfo()
  local _, class = UnitClass("player")
  local _, race = UnitRace("player")
  local faction = UnitFactionGroup("player") or "Neutral"
  local level = UnitLevel("player") or 1
  return { class = class, race = race, faction = faction, level = level, name = UnitName("player") or "" }
end

function TG:ResetGuide()
  if not self.currentGuide then
    self:Print("No guide loaded.")
    return
  end
  self.currentStepIndex = 1
  if self.cdb then
    self.cdb.stepIndex = 1
  end
  if self.UpdateUI then
    self:UpdateUI()
  end
  if self.UpdateStepWaypoint then
    self:UpdateStepWaypoint()
  end
  self:Print("Guide reset to step 1.")
end
