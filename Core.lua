-- shared namespace and state for the addon
local TG = {}
_G.TurtleGuides = TG

TG.name = "TurtleGuides"
TG.version = "0.1.0"

TG.C = {
  gold = "|cffffd100",
  grey = "|cff9d9d9d",
  white = "|cffffffff",
  red = "|cffff4040",
  green = "|cff40ff40",
  orange = "|cffff8000",
  blue = "|cff00ccff",
  reset = "|r",
}

TG.guides = {}
TG.guideByKey = {}
TG.groups = {}
TG.currentGuide = nil
TG.currentStepIndex = 1
