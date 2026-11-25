-- resolves item, spell, and step icons for guide rows
local TG = _G.TurtleGuides
local Icons = {}
TG.UI = TG.UI or {}
TG.UI.Icons = Icons

local SIZE = 10
local AVAILABLE_ICON = "Interface\\GossipFrame\\AvailableQuestIcon"
local ACTIVE_ICON = "Interface\\GossipFrame\\ActiveQuestIcon"
local INCOMPLETE_ICON = "Interface\\GossipFrame\\IncompleteQuestIcon"
local COMPLETE_ICON = "Interface\\Buttons\\UI-CheckBox-Check"
local FLY_ICON = "Interface\\GossipFrame\\TaxiGossipIcon"
local HS_ICON = "Interface\\Cursor\\Innkeeper"
local TRAIN_ICON = "Interface\\GossipFrame\\TrainerGossipIcon"
local TALK_ICON = "Interface\\GossipFrame\\GossipGossipIcon"
local MOB_ICON = "Interface\\Cursor\\Attack"
local BAG_ICON = "Interface\\Icons\\INV_Misc_Bag_01"
local BUY_ICON = "Interface\\Cursor\\Buy"

Icons.QUEST_ICON = AVAILABLE_ICON
Icons.TURNIN_ICON = ACTIVE_ICON
Icons.COMPLETE_ICON = COMPLETE_ICON
Icons.COMPLETE_COLOR = { 0.85, 0.85, 0.88 }
Icons.CHAT_ICON = TALK_ICON

function Icons.isBullet(texture)
  return texture == AVAILABLE_ICON
    or texture == ACTIVE_ICON
    or texture == INCOMPLETE_ICON
    or texture == COMPLETE_ICON
    or texture == FLY_ICON
    or texture == HS_ICON
    or texture == TRAIN_ICON
    or texture == TALK_ICON
    or texture == MOB_ICON
    or texture == BAG_ICON
    or texture == BUY_ICON
end

function Icons.token(texture)
  if not texture or texture == "" then
    return ""
  end
  return "|T" .. texture .. ":" .. SIZE .. "|t"
end

function Icons.hasToken(text)
  return string.find(text or "", "|T", 1, true) ~= nil
end

function Icons.clean(text)
  if not text or text == "" then
    return ""
  end
  text = string.gsub(text, "|cRXP_%w+_", "")
  text = string.gsub(text, "|c%x%x%x%x%x%x%x%x", "")
  text = string.gsub(text, "|r", "")
  text = string.gsub(text, "|T.-|t", "")
  return TG.Util.strtrim(text)
end

function Icons.measure(text)
  return Icons.clean(text)
end

function Icons.fromText(text)
  if not text then
    return nil
  end
  local token = string.match(text, "|T(%d+):")
  if token and TG.ItemIcons then
    return TG.ItemIcons[tonumber(token)]
  end
  return nil
end

function Icons.spell(id)
  local num = tonumber(id)
  if not num or not GetSpellInfo then
    return nil
  end
  local _, _, texture = GetSpellInfo(num)
  return texture
end

function Icons.item(id)
  local num = tonumber(id)
  if not num or not GetItemInfo then
    return nil
  end
  local _, _, _, _, _, _, _, _, _, texture = GetItemInfo(num)
  return texture
end

function Icons.itemByName(name)
  if not name or name == "" or not TG.GetItemIdByName then
    return nil
  end
  local id = TG:GetItemIdByName(name)
  return id and Icons.item(id) or nil
end

function Icons.prepend(text, texture)
  if not Icons.hasToken(text) then
    return Icons.token(texture) .. text
  end
  return text
end

function Icons.addBracketIcons(text)
  if not text or text == "" then
    return text
  end
  return string.gsub(text, "%[([^]]+)%]", function(name)
    if Icons.hasToken(name) then
      return "[" .. name .. "]"
    end
    local texture = Icons.itemByName(name)
    if texture then
      return Icons.token(texture) .. "[" .. name .. "]"
    end
    return "[" .. name .. "]"
  end)
end

function Icons.content(text)
  if not text or text == "" then
    return nil
  end
  local icon = Icons.fromText(text)
  if icon then
    return icon
  end
  string.gsub(text, "%[([^]]+)%]", function(name)
    if not icon then
      local plain = string.gsub(string.gsub(name, "|c%x%x%x%x%x%x%x%x", ""), "|r", "")
      icon = TG.ItemIconNames and TG.ItemIconNames[plain] or nil
    end
  end)
  return icon
end

function Icons.forText(text)
  if not text or text == "" then
    return nil
  end
  local lower = string.lower(text)
  if string.find(lower, "talk", 1, true) or string.find(lower, "speak", 1, true) then
    return TALK_ICON
  end
  if string.find(lower, "kill", 1, true) or string.find(lower, "slay", 1, true) then
    return MOB_ICON
  end
  return nil
end

function Icons.forElement(el)
  if not el or el.t ~= "cmd" then
    return nil
  end
  local tag = el.tag or ""
  local id = el.args and el.args[1]
  if tag == "accept" then
    return AVAILABLE_ICON
  end
  if tag == "turnin" then
    return ACTIVE_ICON
  end
  if tag == "complete" then
    return COMPLETE_ICON
  end
  if tag == "vendor" or tag == "sell" then
    return BUY_ICON
  end
  if tag == "bankwithdraw" or tag == "bankdeposit" then
    return BAG_ICON
  end
  if tag == "mob" or tag == "kill" then
    return MOB_ICON
  end
  if tag == "fly" or tag == "f" then
    return FLY_ICON
  end
  if tag == "hs" or tag == "hearth" then
    return HS_ICON
  end
  if tag == "train" or tag == "trainer" then
    return TRAIN_ICON
  end
  if tag == "cast" or tag == "link" then
    return Icons.spell(id)
  end
  if tag == "collect" or tag == "use" or tag == "destroy" or tag == "itemcount" then
    return BAG_ICON
  end
  return nil
end

function Icons.decorate(text, texture)
  if not text or text == "" then
    return text
  end
  local result = Icons.prepend(text, texture)
  result = Icons.addBracketIcons(result)
  return result
end
