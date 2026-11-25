-- stores raw guide texts and accepts external registrations
local TG = _G.TurtleGuides
TG.rawGuides = TG.rawGuides or {}

function TG:RegisterGuideText(text, source)
  table.insert(TG.rawGuides, { text = text, source = source })
end

if not _G.RXPGuides then
  _G.RXPGuides = {}
end
_G.RXPGuides.RegisterGuide = function(text, group)
  TG:RegisterGuideText(text, group or "Imported")
end
