-- human 1-10 starter route
-- luacheck: ignore 621
local TG = _G.TurtleGuides
TG:RegisterGuideText(
  [[
#classic
<< Alliance
#name 1-10 Elwynn Forest
#version 1
#group Turtle Guides (A)
#subgroup Elwynn Forest
#defaultfor Human
#next 10-16 Westfall

step
    >>Talk to Deputy Willem at the Abbey gate.
    .goto Elwynn Forest,48.2,42.9
    .target Deputy Willem
    .accept 783 >> Accept A Threat Within

step
    >>Carry the report inside to Marshal McBride.
    .goto Elwynn Forest,48.9,41.6
    .target Marshal McBride
    .turnin 783 >> Turn in A Threat Within
    .accept 7 >> Accept Kobold Camp Cleanup
    .accept 5261 >> Accept Eagan Peltskinner
    .accept 33 >> Accept Wolves Across the Border

step
    >>Eagan waits outside the north-west corner of the Abbey.
    .goto Elwynn Forest,48.2,42.9
    .target Deputy Willem
    .turnin 5261 >> Turn in Eagan Peltskinner

step
    >>Clear the kobolds in the field north of the road and collect bear meat from the wolves.
    .goto Elwynn Forest,48.1,36.9,40,0
    .complete 7,1 --Kill Kobold Vermin (x10)
    .mob Kobold Vermin
    .collect 750,8 --Collect Chunk of Boar Meat (x8)
    .mob Young Wolf

step
    >>Return to the Abbey steps.
    .goto Elwynn Forest,48.9,41.6
    .target Marshal McBride
    .turnin 7 >> Turn in Kobold Camp Cleanup
    .turnin 33 >> Turn in Wolves Across the Border
    .accept 18 >> Accept Brotherhood of Thieves
    .accept 15 >> Accept Investigate Echo Ridge
    .accept 54 >> Accept Report to Goldshire

step
    >>Clear the miners in Echo Ridge, then follow the road south to Goldshire.
    .goto Elwynn Forest,48.9,28.3,35,0
    .complete 15,1 --Kill Kobold Worker (x12)
    .mob Kobold Worker
    .goto Elwynn Forest,42.1,65.9
    .target Marshal Dughan
    .turnin 54 >> Turn in Report to Goldshire
    .accept 62 >> Accept The Fargodeep Mine

step
    >>Collect the bounty items around the vineyards, then speak to Remy Two Times.
    .goto Elwynn Forest,51.8,47.4,40,0
    .complete 18,1 --Collect Red Burlap Bandana (x12)
    .mob Defias Thug
    .goto Elwynn Forest,42.1,67.3
    .target Remy Two Times
    .accept 47 >> Accept Gold Dust Exchange

step
    >>William Pestle in the inn needs candles from the mine.
    .goto Elwynn Forest,43.3,65.7
    .target William Pestle
    .accept 60 >> Accept Kobold Candles

step
    >>Work through Fargodeep Mine for the gold dust and candles, then head back to town.
    .goto Elwynn Forest,40.3,82.5,40,0
    .complete 62,1 --Explore Fargodeep Mine
    .collect 4306,10 --Collect Gold Dust (x10)
    .mob Kobold Miner
    .collect 1468,8 --Collect Large Candle (x8)
    .mob Kobold Tunneler

step
    >>Hand in the mine quests in Goldshire.
    .goto Elwynn Forest,42.1,65.9
    .target Marshal Dughan
    .turnin 62 >> Turn in The Fargodeep Mine
    .goto Elwynn Forest,42.1,67.3
    .target Remy Two Times
    .turnin 47 >> Turn in Gold Dust Exchange
    .goto Elwynn Forest,43.3,65.7
    .target William Pestle
    .turnin 60 >> Turn in Kobold Candles

step
    >>Grind the forest around Goldshire until level 10, then continue to Westfall.
    .goto Elwynn Forest,45.0,70.0,50,0
    .xp 10
]],
  "Human-1-10"
)
