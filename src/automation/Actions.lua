-- automatic quest, vendor, flight, and item actions
local TG = _G.TurtleGuides
local strtrim = TG.Util.strtrim
local Actions = {}
TG.Automation = TG.Automation or {}
TG.Automation.Actions = Actions

TG._lastAutoTurnin = TG._lastAutoTurnin or 0
TG._lastAutoTurninQuest = TG._lastAutoTurninQuest or nil
TG._autoTurninCooldown = 3

local function autoOn()
  return TG.db and TG.db.autoTurnIn
end

local function canAutoTurnin(questId)
  local now = GetTime and GetTime() or 0
  if TG._lastAutoTurninQuest == questId and (now - TG._lastAutoTurnin) < TG._autoTurninCooldown then
    return false
  end
  return true
end

local function recordAutoTurnin(questId)
  TG._lastAutoTurnin = GetTime and GetTime() or 0
  TG._lastAutoTurninQuest = questId
end

local function hasBagSpace()
  for bag = 0, 4 do
    local slots = GetContainerNumSlots(bag) or 0
    for slot = 1, slots do
      local _, count = GetContainerItemInfo(bag, slot)
      if not count then
        return true
      end
    end
  end
  return false
end

function TG:OnQuestDetail()
  if not autoOn() then
    return
  end
  if AcceptQuest then
    AcceptQuest()
  end
end

function TG:OnQuestProgress()
  if not autoOn() then
    return
  end
  if IsQuestCompletable and IsQuestCompletable() then
    CompleteQuest()
  end
end

function TG:OnQuestComplete()
  if not autoOn() then
    return
  end
  local choices = GetNumQuestChoices and GetNumQuestChoices() or 0
  local questTitle = GetTitleText and GetTitleText() or nil
  if choices <= 1 then
    if choices == 1 then
      local link = GetQuestItemLink and GetQuestItemLink("reward", 1)
      if link and not hasBagSpace() then
        self:Print("Bag full - cannot auto-turnin quest reward. Free up space.")
        return
      end
    end
    if questTitle and not canAutoTurnin(questTitle) then
      self:Print("Auto-turnin on cooldown for: " .. tostring(questTitle))
      return
    end
    if GetQuestReward then
      GetQuestReward(choices == 1 and 1 or 1)
      if questTitle then
        recordAutoTurnin(questTitle)
      end
    end
  else
    self:Print("Multiple quest rewards - please choose manually.")
  end
end

function TG:OnGossipShow()
  if not autoOn() then
    return
  end
  local active = {}
  if GetGossipActiveQuests then
    active = { GetGossipActiveQuests() }
  end
  local i, idx = 1, 1
  while active[i] do
    local title = active[i]
    local isComplete = active[i + 3]
    if isComplete then
      if not (title and not canAutoTurnin(title)) and SelectGossipActiveQuest then
        SelectGossipActiveQuest(idx)
        if title then
          recordAutoTurnin(title)
        end
        return
      end
    end
    i = i + 5
    idx = idx + 1
  end
  local available = {}
  if GetGossipAvailableQuests then
    available = { GetGossipAvailableQuests() }
  end
  i, idx = 1, 1
  while available[i] do
    if SelectGossipAvailableQuest then
      SelectGossipAvailableQuest(idx)
      return
    end
    i = i + 6
    idx = idx + 1
  end
end

function TG:OnQuestGreeting()
  if not autoOn() then
    return
  end
  local numActive = GetNumActiveQuests and GetNumActiveQuests() or 0
  local numAvailable = GetNumAvailableQuests and GetNumAvailableQuests() or 0
  for i = 1, numActive do
    local title, isComplete = GetActiveTitle(i)
    if isComplete and SelectActiveQuest then
      if not (title and not canAutoTurnin(title)) then
        SelectActiveQuest(i)
        if title then
          recordAutoTurnin(title)
        end
        return
      end
    end
  end
  for i = 1, numAvailable do
    if SelectAvailableQuest then
      SelectAvailableQuest(i)
      return
    end
  end
end

function TG:AutoTakeFlight()
  if not (TG.db and TG.db.autoTakeFlight) then
    return
  end
  if not TaxiFrame or not TaxiFrame:IsShown() then
    return
  end
  local step = TG.CurrentStep and TG:CurrentStep()
  if not step then
    return
  end
  for _, el in ipairs(step.elements or {}) do
    if el.t == "cmd" and (el.tag == "fly" or el.tag == "f") then
      local dest = el.text or (el.args and table.concat(el.args, " "))
      if dest and dest ~= "" then
        for i = 1, NUM_TAXI_BUTTONS or 20 do
          local button = _G["TaxiButton" .. i]
          if button and button:IsShown() then
            local name = button:GetName()
            if name and string.find(string.lower(name), string.lower(dest)) then
              button:Click()
              return
            end
          end
        end
      end
    end
  end
end

local function currentStepUseItemIds()
  local ids = {}
  local step = TG.CurrentStep and TG:CurrentStep()
  if not step then
    return ids
  end
  for _, el in ipairs(step.elements or {}) do
    if el.t == "cmd" and el.tag == "use" then
      local args = table.concat(el.args or {}, " ")
      local id = tonumber(string.match(args, "%d+"))
      if id then
        ids[id] = true
      end
    end
  end
  return ids
end

function TG:AutoUseQuestItems()
  if not (TG.db and TG.db.autoUseQuestItems) then
    return
  end
  local ids = currentStepUseItemIds()
  if not next(ids) then
    return
  end
  for bag = 0, 4 do
    local slots = GetContainerNumSlots(bag) or 0
    for slot = 1, slots do
      local link = GetContainerItemLink(bag, slot)
      if link then
        local id = tonumber(string.match(link, "item:(%d+)"))
        if id and ids[id] then
          if TG._autoUseStep == TG.currentStepIndex and TG._autoUseItem == id then
            return
          end
          TG._autoUseStep = TG.currentStepIndex
          TG._autoUseItem = id
          UseContainerItem(bag, slot)
          if TG.SignalManualAction then
            TG:SignalManualAction("use")
          end
          return
        end
      end
    end
  end
end

function TG:AutoBuyVendor()
  if not (TG.db and TG.db.autoBuyVendor) then
    return
  end
  if not MerchantFrame or not MerchantFrame:IsShown() then
    return
  end
  local step = TG.CurrentStep and TG:CurrentStep()
  if not step then
    return
  end
  for _, el in ipairs(step.elements or {}) do
    if el.t == "cmd" and (el.tag == "vendor" or el.tag == "buy") then
      local itemName = strtrim(string.gsub(el.text or "", "|T.-|t", ""))
      for i = 1, GetMerchantNumItems() do
        local name = GetMerchantItemInfo(i)
        if name and itemName ~= "" and string.find(string.lower(name), string.lower(itemName), 1, true) then
          BuyMerchantItem(i, 1)
          self:Print("Auto-bought: " .. name)
          return
        end
      end
    end
  end
end

Actions.canAutoTurnin = canAutoTurnin
Actions.hasBagSpace = hasBagSpace
Actions.currentStepUseItemIds = currentStepUseItemIds
