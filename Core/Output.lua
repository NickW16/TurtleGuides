-- sends addon messages to the default chat frame
local TG = _G.TurtleGuides

function TG:Print(msg)
  DEFAULT_CHAT_FRAME:AddMessage(self.C.gold .. "TurtleGuides:|r " .. tostring(msg))
end
