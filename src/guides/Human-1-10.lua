-- human 1-10 starter route
-- luacheck: ignore 621
local TG = _G.TurtleGuides
TG:RegisterGuideText(
  [[
#classic
<< Alliance
#name 1-10 Elwynn Forest
#version 2
#group Turtle Guides (A)
#subgroup Elwynn Forest
#defaultfor Human
#next 10-16 Westfall

step
    >>Deputy Willem stands at the Abbey gate. Speak to him, then carry the report inside to Marshal McBride.
    .goto Elwynn Forest,48.2,42.9
    .target Deputy Willem
    .accept 783 >> Accept A Threat Within
    .goto Elwynn Forest,48.9,41.6
    .target Marshal McBride
    .turnin 783 >> Turn in A Threat Within
    .accept 7 >> Accept Kobold Camp Cleanup
    .accept 5261 >> Accept Eagan Peltskinner
    .accept 33 >> Accept Wolves Across the Border
    .accept 3100 >> Accept Simple Letter
    .accept 3101 >> Accept Consecrated Letter
    .accept 3102 >> Accept Encrypted Letter
    .accept 3103 >> Accept Hallowed Letter
    .accept 3104 >> Accept Glyphic Letter
    .accept 3105 >> Accept Tainted Letter

step
    >>Eagan waits outside the north-west corner. His wolves roam the fields north of the road.
    .goto Elwynn Forest,48.2,42.9
    .target Deputy Willem
    .turnin 5261 >> Turn in Eagan Peltskinner
    .goto Elwynn Forest,48.1,36.9,40,0
    .complete 7,1 --Kill Kobold Vermin (x10)
    .complete 33,1 --Kill Young Wolf (x8)
    .mob Kobold Vermin
    .mob Young Wolf

step
    >>Return to the Abbey. Willem has more work, and McBride wants Echo Ridge cleared.
    .goto Elwynn Forest,48.2,42.9
    .target Deputy Willem
    .turnin 33 >> Turn in Wolves Across the Border
    .accept 18 >> Accept Brotherhood of Thieves
    .accept 3903 >> Accept Milly Osworth
    .goto Elwynn Forest,48.9,41.6
    .target Marshal McBride
    .turnin 7 >> Turn in Kobold Camp Cleanup
    .accept 15 >> Accept Investigate Echo Ridge
    .accept 54 >> Accept Report to Goldshire
    .goto Elwynn Forest,45.6,47.7
    .target Falkhaan Isenstrider
    .accept 110 >> Accept Rest and Relaxation

step
    >>Turn in the class letters to the trainers inside the Abbey before leaving.
    .goto Elwynn Forest,50.2,42.3
    .target Llane Beshere
    .turnin 3100 >> Turn in Simple Letter
    .goto Elwynn Forest,50.4,42.1
    .target Brother Sammuel
    .turnin 3101 >> Turn in Consecrated Letter
    .goto Elwynn Forest,50.3,39.9
    .target Jorik Kerridan
    .turnin 3102 >> Turn in Encrypted Letter
    .goto Elwynn Forest,49.8,39.5
    .target Priestess Anetta
    .turnin 3103 >> Turn in Hallowed Letter
    .goto Elwynn Forest,49.7,39.4
    .target Khelden Bremen
    .turnin 3104 >> Turn in Glyphic Letter
    .goto Elwynn Forest,49.9,42.7
    .target Drusilla La Salle
    .turnin 3105 >> Turn in Tainted Letter

step
    >>The Defias hold the vineyards east of the Abbey. Take their bandanas, then clear the kobolds at Echo Ridge.
    .goto Elwynn Forest,51.8,47.4,40,0
    .complete 18,1 --Collect Red Burlap Bandana (x12)
    .mob Defias Thug
    .goto Elwynn Forest,48.9,28.3,35,0
    .complete 15,1 --Kill Kobold Worker (x12)
    .mob Kobold Worker

step
    >>Hand in the bandanas and the kobold report. McBride follows up with the mine labourers.
    .goto Elwynn Forest,48.2,42.9
    .target Deputy Willem
    .turnin 18 >> Turn in Brotherhood of Thieves
    .accept 6 >> Accept Bounty on Garrick Padfoot
    .goto Elwynn Forest,48.9,41.6
    .target Marshal McBride
    .turnin 15 >> Turn in Investigate Echo Ridge
    .accept 21 >> Accept Skirmish at Echo Ridge

step
    >>Garrick waits at the far end of the vineyards. The labourers are deeper inside Echo Ridge Mine.
    .goto Elwynn Forest,57.5,48.3
    .complete 6,1 --Kill Garrick Padfoot (x1)
    .mob Garrick Padfoot
    .goto Elwynn Forest,48.8,35.6,35,0
    .complete 21,1 --Kill Kobold Laborer (x12)
    .mob Kobold Laborer

step
    >>Finish the Northshire chain, then follow the road south toward Goldshire.
    .goto Elwynn Forest,48.2,42.9
    .target Deputy Willem
    .turnin 6 >> Turn in Bounty on Garrick Padfoot
    .goto Elwynn Forest,48.9,41.6
    .target Marshal McBride
    .turnin 21 >> Turn in Skirmish at Echo Ridge
    .turnin 54 >> Turn in Report to Goldshire
    .goto Elwynn Forest,42.1,65.9
    .target Marshal Dughan
    .accept 62 >> Accept The Fargodeep Mine
    .accept 40 >> Accept A Fishy Peril
    .accept 419 >> Accept Further Concerns

step
    >>Milly Osworth waits in the Northshire vineyards. Her chain leads through the Stonefield farm.
    .goto Elwynn Forest,50.7,39.4
    .target Milly Osworth
    .turnin 3903 >> Turn in Milly Osworth
    .accept 3904 >> Accept Milly's Harvest
    .goto Elwynn Forest,42.9,86.6,40,0
    .collect 4220,8 --Collect Millie's Harvest (x8)
    .goto Elwynn Forest,50.7,39.4
    .target Milly Osworth
    .turnin 3904 >> Turn in Milly's Harvest
    .accept 3905 >> Accept Grape Manifest

step
    >>Goldshire has the mine, candle and dust quests. Pick them all up before heading into Fargodeep.
    .goto Elwynn Forest,43.3,65.7
    .target William Pestle
    .accept 60 >> Accept Kobold Candles
    .accept 112 >> Accept Collecting Kelp
    .goto Elwynn Forest,42.1,67.3
    .target Remy Two Times
    .accept 47 >> Accept Gold Dust Exchange

step
    >>Work through Fargodeep Mine. Gold dust, candles, Goldtooth and the lost books all come from these kobolds.
    .goto Elwynn Forest,40.3,82.5,40,0
    .complete 62,1 --Explore Fargodeep Mine
    .collect 4306,10 --Collect Gold Dust (x10)
    .collect 1468,8 --Collect Large Candle (x8)
    .collect 1972,1 --Collect Westfall Deed (x1)
    .complete 87,1 --Kill Goldtooth (x1)
    .mob Kobold Miner
    .mob Kobold Tunneler
    .mob Goldtooth

step
    >>Hand the mine work in around Goldshire, then take William's shipment chain.
    .goto Elwynn Forest,42.1,65.9
    .target Marshal Dughan
    .turnin 62 >> Turn in The Fargodeep Mine
    .goto Elwynn Forest,42.1,67.3
    .target Remy Two Times
    .turnin 47 >> Turn in Gold Dust Exchange
    .turnin 40 >> Turn in A Fishy Peril
    .goto Elwynn Forest,43.3,65.7
    .target William Pestle
    .turnin 60 >> Turn in Kobold Candles
    .turnin 112 >> Turn in Collecting Kelp
    .accept 113 >> Accept The Escape
    .accept 61 >> Accept Shipment to Stormwind
    .turnin 3905 >> Turn in Grape Manifest

step
    >>The Escape is a short errand east of town. Shipment to Stormwind needs the city, so take the gryphon if you can.
    .goto Elwynn Forest,47.5,62.2,35,0
    .complete 113,1 --Escape the murloc ambush
    .goto Elwynn Forest,48.0,63.0
    .target Jason Mathers
    .turnin 113 >> Turn in The Escape

step
    >>The Stonefield and Maclure farms hold a long chain of easy errands and good XP.
    .goto Elwynn Forest,34.5,84.2
    .target Auntie Bernice Stonefield
    .accept 85 >> Accept Lost Necklace
    .goto Elwynn Forest,43.1,89.6
    .target Maybell Maclure
    .accept 106 >> Accept Young Lovers
    .goto Elwynn Forest,29.8,86.0
    .target Tommy Joe Stonefield
    .turnin 106 >> Turn in Young Lovers
    .accept 111 >> Accept Speak with Gramma
    .goto Elwynn Forest,34.9,83.9
    .target Gramma Stonefield
    .turnin 111 >> Turn in Speak with Gramma
    .accept 107 >> Accept Note to William

step
    >>Finish the farm chain and collect the Piedboar items.
    .goto Elwynn Forest,43.1,85.7
    .target Billy Maclure
    .turnin 85 >> Turn in Lost Necklace
    .accept 86 >> Accept Pie for Billy
    .goto Elwynn Forest,34.5,84.2
    .target Auntie Bernice Stonefield
    .turnin 86 >> Turn in Pie for Billy
    .accept 84 >> Accept Back to Billy
    .goto Elwynn Forest,43.1,85.7
    .target Billy Maclure
    .turnin 84 >> Turn in Back to Billy
    .accept 87 >> Accept Goldtooth

step
    >>Eastvale Logging Camp has the frontier quests and the lost guard chain. Collect everything in one pass.
    .goto Elwynn Forest,52.3,49.7
    .target Sara Timberlain
    .accept 365 >> Accept Red Linen Goods
    .target Supervisor Raelen
    .accept 5545 >> Accept A Bundle of Trouble
    .target Guard Thomas
    .accept 467 >> Accept Protect the Frontier
    .accept 422 >> Accept Find the Lost Guards
    .accept 419 >> Accept Further Concerns

step
    >>Work through the Eastvale chain while gathering linen and killing frontier mobs.
    .collect 4308,12 --Collect Red Linen (x12)
    .collect 4309,4 --Collect Fine Linen Bandage (x4)
    .complete 467,1 --Kill Riverpaw Runt (x10)
    .complete 422,1 --Find the Lost Guards
    .complete 423,1 --Discover Rolf's Fate
    .complete 424,1 --Deliver Thomas' Report
    .mob Riverpaw Runt

step
    >>Hand in the Eastvale chain and pick up the bounty follow-ups.
    .goto Elwynn Forest,52.3,49.7
    .target Guard Thomas
    .turnin 422 >> Turn in Find the Lost Guards
    .accept 423 >> Accept Discover Rolf's Fate
    .turnin 423 >> Turn in Discover Rolf's Fate
    .accept 424 >> Accept Deliver Thomas' Report
    .turnin 424 >> Turn in Deliver Thomas' Report
    .accept 207 >> Accept Bounty on Murlocs
    .turnin 467 >> Turn in Protect the Frontier

step
    >>Finish the Jasperlode and Westbrook chain around the eastern mines.
    .goto Elwynn Forest,42.1,65.9
    .target Marshal Dughan
    .turnin 419 >> Turn in Further Concerns
    .accept 76 >> Accept The Jasperlode Mine
    .goto Elwynn Forest,50.4,86.8,40,0
    .complete 76,1 --Explore Jasperlode Mine
    .goto Elwynn Forest,42.1,65.9
    .target Marshal Dughan
    .turnin 76 >> Turn in The Jasperlode Mine
    .accept 139 >> Accept Westbrook Garrison Needs Help
    .goto Elwynn Forest,51.5,82.0
    .target Deputy Rainer
    .turnin 139 >> Turn in Westbrook Garrison Needs Help
    .accept 133 >> Accept Riverpaw Gnoll Bounty

step
    >>Clear the gnolls around Westbrook and finish the collector hunt.
    .goto Elwynn Forest,49.5,78.0,45,0
    .complete 133,1 --Kill Riverpaw Gnoll (x12)
    .complete 242,1 --Collect Gold Pickup Schedule (x1)
    .mob Riverpaw Gnoll
    .goto Elwynn Forest,42.1,65.9
    .target Marshal Dughan
    .turnin 133 >> Turn in Riverpaw Gnoll Bounty
    .accept 244 >> Accept Manhunt

step
    >>Remaining errands around Goldshire before the final grind.
    .goto Elwynn Forest,43.3,65.7
    .target William Pestle
    .turnin 107 >> Turn in Note to William
    .goto Elwynn Forest,42.1,67.3
    .target Remy Two Times
    .turnin 61 >> Turn in Shipment to Stormwind
    .goto Elwynn Forest,42.1,65.9
    .target Marshal Dughan
    .turnin 244 >> Turn in Manhunt

step
    >>Grind the remaining mobs around Elwynn until level 10, then continue to Westfall.
    .goto Elwynn Forest,45.0,70.0,50,0
    .xp 10
]],
  "Human-1-10"
)
