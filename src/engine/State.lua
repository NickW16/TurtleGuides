-- shared engine constants and transient state
local TG = _G.TurtleGuides
local Shared = {}
TG.Engine = TG.Engine or {}
TG.Engine.Shared = Shared

Shared.RECENT_ACCEPT_WINDOW = 2
Shared.TURNIN_CONFIRM_WINDOW = 5
Shared.MANUAL_CHECK_VISIBLE_DELAY = 0.6
Shared.DEFAULT_GOTO_RADIUS = 8
Shared.UNKNOWN_STATE_TIMEOUT = 1.5
Shared.RESUME_DELAY = 0.5

Shared.UNKNOWN_QUEST_GATES = {
  isOnQuest = true,
  isNotOnQuest = true,
  isQuestTurnedIn = true,
  isQuestAvailable = true,
  isQuestComplete = true,
}

Shared.OBJECTIVE_TAGS = {
  accept = true,
  turnin = true,
  complete = true,
  collect = true,
  xp = true,
  zone = true,
  subzone = true,
}

Shared.MANUAL_ACTION_TAGS = {
  hs = true,
  hearth = true,
  home = true,
  fly = true,
  f = true,
  fp = true,
  use = true,
  vendor = true,
  trainer = true,
  train = true,
  cast = true,
  emote = true,
  abandon = true,
  repair = true,
  mail = true,
  timer = true,
  skipgossip = true,
}

Shared.CONDITION_TAGS = {
  itemcount = true,
  cooldown = true,
  isOnQuest = true,
  isNotOnQuest = true,
  isQuestTurnedIn = true,
  isQuestAvailable = true,
  isQuestComplete = true,
}

function Shared.isObjectiveElement(el)
  return el ~= nil and el.t == "cmd" and Shared.OBJECTIVE_TAGS[el.tag] == true
end

function Shared.stepHasObjective(step)
  for _, el in ipairs(step.elements or {}) do
    if Shared.isObjectiveElement(el) then
      return true
    end
  end
  return false
end

function Shared.stepHasItemCountCondition(step)
  for _, el in ipairs(step.elements or {}) do
    if el.t == "cmd" and el.tag == "itemcount" then
      return true
    end
  end
  return false
end

TG._seenComplete = TG._seenComplete or {}
TG._turnedInTitles = TG._turnedInTitles or {}
TG._pendingTurnin = TG._pendingTurnin or {}
TG._turninCandidates = TG._turninCandidates or {}
TG._recentAccept = TG._recentAccept or {}
