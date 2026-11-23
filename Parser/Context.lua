-- builds applicability context from player info
local TG = _G.TurtleGuides
local Context = {}
TG.Parser = TG.Parser or {}
TG.Parser.Context = Context

function Context.player()
  local player = TG:PlayerInfo()
  local race2 = player.race
  if race2 == "Undead" then
    race2 = "Scourge"
  end
  return {
    class = player.class,
    race = player.race,
    race2 = race2,
    faction = player.faction,
    level = player.level,
    sex = UnitSex and UnitSex("player") or nil,
    game = "CLASSIC",
  }
end
