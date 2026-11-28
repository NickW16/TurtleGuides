# Waypoints and coordinates

The arrow resolves each step from its own elements, not from the guide title. A step in a Redridge guide can point to an NPC in Stormwind.

## Coordinate sources

Guide `.goto` coordinates are map-relative percentages. The arrow prefers the player position captured by pfQuest, `pfMap.minimapPlayerX` and `pfMap.minimapPlayerY`, because that value is independent of the currently displayed World Map. The raw client API and ClassicAPI C_Map position are fallbacks.

The addon must not call `SetMapToCurrentZone()` from its own update loop. That changes the client's internal map context and makes repeated position reads disagree. pfQuest owns that transition on zone change.

## Stormwind conversion

Some bundled guides use a `StormwindClassic` coordinate space. The client's map APIs report Stormwind City in a different coordinate space, so those coordinates are converted before they are used:

```text
x = x * 0.7736810083183454 + 19.680298729766175
y = y * 0.7738299382700434 + 24.433158479564715
```

After conversion, `61.609, 15.269` becomes about `67.345, 36.244`, which matches the client's Stormwind City map. The conversion lives in `TG:GuideMapCoords` and is applied in `TG:GetStepGotos`.

Only `StormwindClassic` is converted. Other capitals with a similar Classic and current map split must be verified individually before adding a conversion. Do not infer a city from the guide name.

## Debugging

Use `/tg waypoint` while the step is active. It prints the target zone and coordinates, the pfQuest captured position, the raw map position, the C_Map position, and the selected sample status.

In the target zone, the label shows distance. Outside the target zone, it shows `Go to <zone>`.

## Verification

When adding a new city or guide with city coordinates:

1. Stand next to a known NPC from the guide.
2. Run `/tg waypoint`.
3. Compare the guide coordinates with `pfmap pos` after conversion.
4. Confirm the arrow shows a small distance beside the NPC.
5. Move to a different zone and confirm the label changes to `Go to <zone>`.
