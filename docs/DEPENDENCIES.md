# Dependencies

TurtleGuides targets the stock 1.12.1 client. Two add-ons supply APIs that the stock client does not have.

## pfQuest

pfQuest is a required dependency. It supplies the game data and the stable player map position that the addon uses for step logic and the arrow.

- Quest titles, ids, and prerequisites come from `pfDB.quests` and `pfDatabase` in [`src/compat/QuestLog.lua`](../src/compat/QuestLog.lua) and [`src/engine/Prereqs.lua`](../src/engine/Prereqs.lua).
- Zone ids, zone names, and zone centers come from `pfDB.zones` in [`src/compat/Zone.lua`](../src/compat/Zone.lua).
- Item names come from `pfDB.items` in [`src/compat/Item.lua`](../src/compat/Item.lua).
- NPC names and spawn coordinates come from `pfDB.units` and `pfDatabase.GetIDByName` in [`src/compat/Npc.lua`](../src/compat/Npc.lua).
- Account quest history comes from `pfQuest_history` in [`src/engine/Quests.lua`](../src/engine/Quests.lua). It is a weak signal because it can include other characters.
- The player zone and map position come from `pfMap:GetPlayerMapID()`, `pfMap.minimapPlayerX`, and `pfMap.minimapPlayerY` in [`src/waypoint/State.lua`](../src/waypoint/State.lua). This is preferred over raw map reads because it does not depend on which map the World Map window shows.

The `.toc` lists pfQuest and pfQuest-turtle as optional dependencies so the add-on can still load for diagnosis without them. Behavior is incomplete without pfQuest.

## ClassicAPI

ClassicAPI is a required dependency for full waypoint and marker behavior. It is a client DLL that adds modern APIs to the 1.12.1 Lua environment.

- `UnitPosition` supplies unit world positions in [`src/compat/Zone.lua`](../src/compat/Zone.lua).
- `C_Map.GetWorldPosFromMapPos` converts guide map coordinates to world coordinates in [`src/compat/Zone.lua`](../src/compat/Zone.lua).
- `C_Map.GetPlayerMapPosition` and `C_Map.GetBestMapForUnit` are map-position fallbacks in [`src/waypoint/State.lua`](../src/waypoint/State.lua).
- `CreateVector2D` is used for those map conversions when present in [`src/compat/Zone.lua`](../src/compat/Zone.lua).
- `C_NamePlate.GetNamePlates` supplies visible nameplate tokens for NPC markers in [`src/engine/TargetMarker.lua`](../src/engine/TargetMarker.lua).
- `GetPlayerFacing` drives the arrow sprite in [`src/ui/Arrow.lua`](../src/ui/Arrow.lua).
- Lua 5.1 helpers such as `string.match`, `string.gmatch`, and `table.wipe` are used throughout the parser and engine. [`src/compat/Runtime.lua`](../src/compat/Runtime.lua) installs the small set of shims the stock client needs.

Several calls are guarded so the add-on still loads without ClassicAPI, but waypoint direction, unit markers, and world positions are reduced or unavailable. See [`docs/WAYPOINTS.md`](WAYPOINTS.md) for the coordinate caveats and `/tg waypoint` for live diagnostics.

## Version links

- [pfQuest source](https://github.com/shagu/pfQuest)
- [ClassicAPI source](https://github.com/brues-code/ClassicAPI)
