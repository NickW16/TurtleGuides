-- removes color, hyperlink, and texture markup from text
local TG = _G.TurtleGuides

function TG.stripCodes(s)
  if not s then
    return ""
  end
  s = string.gsub(s, "|cRXP_%w+_", "")
  s = string.gsub(s, "|c%x%x%x%x%x%x%x%x", "")
  s = string.gsub(s, "|r", "")
  s = string.gsub(s, "|H.-|h(.-)|h", "%1")
  s = string.gsub(s, "|T.-|t", "")
  return s
end

function TG.cleanRxpColors(s)
  if not s then
    return ""
  end
  s = string.gsub(s, "|cRXP_FRIENDLY_", "|cff00ff00")
  s = string.gsub(s, "|cRXP_ENEMY_", "|cffff0000")
  s = string.gsub(s, "|cRXP_WARN_", "|cffffff00")
  s = string.gsub(s, "|cRXP_LOG_", "|cff00ccff")
  s = string.gsub(s, "|cRXP_ITEM_", "|cffffd100")
  s = string.gsub(s, "|cRXP_LOOT_", "|cffffd100")
  s = string.gsub(s, "|cRXP_%w+_", "")
  s = string.gsub(s, "|T.-|t", "")
  return s
end
