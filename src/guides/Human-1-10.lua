-- guide data adapted from RestedXP Guides by RestedXP (RXPGuides).
-- source: https://github.com/RestedXP/RXPGuides
-- licensed under CC BY-NC-SA 4.0: https://creativecommons.org/licenses/by-nc-sa/4.0/
-- modified for Turtle WoW 1.12.1, with syntax and route adjustments.
-- Human 1-10 Elwynn Forest, written for Turtle WoW 1.12.1.
-- luacheck: ignore 621
local TG = _G.TurtleGuides
TG:RegisterGuideText(
  [[
#classic
<< Alliance
#name 1-10 Elwynn Forest
#version 4
#group Turtle Guides (A)
#subgroup Elwynn Forest
#defaultfor Human
#next 10-16 Westfall

step << !Human
    #sticky
    #completewith next
    .goto Elwynn Forest,48.171,42.943
    +This route is for Humans. Choose your race's starter guide instead.

step
    #label Northshire
    .goto Elwynn Forest,48.171,42.943
    >>Deputy Willem stands at the foot of the abbey steps.
    .target Deputy Willem
    .accept 783 >> Accept A Threat Within

step
    .goto Elwynn Forest,48.923,41.606
    >>Marshal McBride is inside the abbey hall.
    .target Marshal McBride
    .turnin 783 >> Turn in A Threat Within

step
    .goto Elwynn Forest,48.923,41.606
    .target Marshal McBride
    .accept 7 >> Accept Kobold Camp Cleanup

step
    .goto Elwynn Forest,48.171,42.943
    .target Deputy Willem
    .accept 5261 >> Accept Eagan Peltskinner

step
    .goto Elwynn Forest,48.941,40.166
    >>Eagan waits just outside the abbey.
    .target Eagan Peltskinner
    .accept 33 >> Accept Wolves Across the Border

step
    .goto Elwynn Forest,48.941,40.166
    .target Eagan Peltskinner
    .turnin 5261 >> Turn in Eagan Peltskinner

step
    .goto Elwynn Forest,46.70,37.78,45,0
    >>Kill young wolves west of the abbey. Loot the meat for vendoring later.
    .complete 33,1 --Kill Young Wolf (x8)
    .mob Young Wolf

step
    .goto Elwynn Forest,49.05,35.33,40,0
    >>Clear the Kobold Vermin camp.
    .complete 7,1 --Kill Kobold Vermin (x10)
    .mob Kobold Vermin

step
    .goto Elwynn Forest,48.941,40.166
    .target Eagan Peltskinner
    .turnin 33 >> Turn in Wolves Across the Border

step
    .goto Elwynn Forest,48.923,41.606
    .target Marshal McBride
    .turnin 7 >> Turn in Kobold Camp Cleanup

step
    .goto Elwynn Forest,48.923,41.606
    .target Marshal McBride
    .accept 15 >> Accept Investigate Echo Ridge

step
    .goto Elwynn Forest,48.923,41.606
    >>Take every letter on offer; you will hand in only your class's letter.
    .target Marshal McBride
    .accept 3100 >> Accept Simple Letter
    .accept 3101 >> Accept Consecrated Letter
    .accept 3102 >> Accept Encrypted Letter
    .accept 3103 >> Accept Hallowed Letter
    .accept 3104 >> Accept Glyphic Letter
    .accept 3105 >> Accept Tainted Letter

step
    .goto Elwynn Forest,47.42,32.68,45,0
    >>Follow the path south into Echo Ridge.
    .complete 15,1 --Kill Kobold Worker (x12)
    .mob Kobold Worker

step
    .goto Elwynn Forest,48.923,41.606
    .target Marshal McBride
    .turnin 15 >> Turn in Investigate Echo Ridge

step
    .goto Elwynn Forest,48.923,41.606
    .target Marshal McBride
    .accept 21 >> Accept Skirmish at Echo Ridge

step
    .goto Elwynn Forest,47.63,32.07,20
    >>Laborers sit deeper in the mine than the Workers.
    .complete 21,1 --Kill Kobold Laborer (x12)
    .mob Kobold Laborer

step
    .goto Elwynn Forest,48.923,41.606
    .target Marshal McBride
    .turnin 21 >> Turn in Skirmish at Echo Ridge

step
    .goto Elwynn Forest,48.923,41.606
    .target Marshal McBride
    .accept 54 >> Accept Report to Goldshire

step
    .goto Elwynn Forest,48.171,42.943
    .target Deputy Willem
    .accept 18 >> Accept Brotherhood of Thieves

step
    .goto Elwynn Forest,54.57,49.03,45,0
    >>Defias Thugs east of the abbey carry the bandanas.
    .complete 18,1 --Collect Red Burlap Bandana (x12)
    .mob Defias Thug

step
    .goto Elwynn Forest,48.171,42.943
    .target Deputy Willem
    .turnin 18 >> Turn in Brotherhood of Thieves

step
    .goto Elwynn Forest,48.171,42.943
    .target Deputy Willem
    .accept 6 >> Accept Bounty on Garrick Padfoot

step
    .goto Elwynn Forest,48.171,42.943
    .target Deputy Willem
    .accept 3903 >> Accept Milly Osworth

step
    .goto Elwynn Forest,50.7,39.2
    >>Milly stands near the abbey entrance.
    .target Milly Osworth
    .turnin 3903 >> Turn in Milly Osworth

step
    .goto Elwynn Forest,50.7,39.2
    .target Milly Osworth
    .accept 3904 >> Accept Milly's Harvest

step
    .goto Elwynn Forest,54.5,49.4,45,0
    >>Loot buckets of grapes in the field east of Northshire.
    .complete 3904,1 --Collect Millie's Harvest (x8)

step
    .goto Elwynn Forest,50.7,39.2
    .target Milly Osworth
    .turnin 3904 >> Turn in Milly's Harvest

step
    .goto Elwynn Forest,50.7,39.2
    .target Milly Osworth
    .accept 3905 >> Accept Grape Manifest

step
    .goto Elwynn Forest,49.6,41.6,15,0
    .goto Elwynn Forest,49.471,41.586
    >>Brother Neals is upstairs inside the abbey.
    .target Brother Neals
    .turnin 3905 >> Turn in Grape Manifest

step
    .goto Elwynn Forest,57.5,48.2,40,0
    >>Garrick Padfoot patrols the east road.
    .complete 6,1 --Kill Garrick Padfoot (x1)
    .mob Garrick Padfoot

step
    .goto Elwynn Forest,48.171,42.943
    .target Deputy Willem
    .turnin 6 >> Turn in Bounty on Garrick Padfoot

step << Warrior
    .goto Elwynn Forest,50.242,42.287
    .target Llane Beshere
    .turnin 3100 >> Turn in Simple Letter

step << Paladin
    .goto Elwynn Forest,50.433,42.124
    .target Brother Sammuel
    .turnin 3101 >> Turn in Consecrated Letter

step << Rogue
    .goto Elwynn Forest,50.314,39.916
    .target Jorik Kerridan
    .turnin 3102 >> Turn in Encrypted Letter

step << Priest
    .goto Elwynn Forest,49.808,39.489
    .target Priestess Anetta
    .turnin 3103 >> Turn in Hallowed Letter

step << Mage
    .goto Elwynn Forest,49.661,39.402
    >>Khelden Bremen is upstairs.
    .target Khelden Bremen
    .turnin 3104 >> Turn in Glyphic Letter

step << Warlock
    .goto Elwynn Forest,49.873,42.649
    .target Drusilla La Salle
    .turnin 3105 >> Turn in Tainted Letter

step
    .goto Elwynn Forest,45.6,47.7
    >>Falkhaan Isenstrider is on the south road. This quest rewards a hearthstone.
    .target Falkhaan Isenstrider
    .accept 110 >> Accept Rest and Relaxation

step
    #label Goldshire
    .goto Elwynn Forest,42.105,65.927
    >>Marshal Dughan is outside the Goldshire inn.
    .target Marshal Dughan
    .turnin 54 >> Turn in Report to Goldshire

step
    .goto Elwynn Forest,42.105,65.927
    .target Marshal Dughan
    .accept 62 >> Accept The Fargodeep Mine

step
    .goto Elwynn Forest,42.105,65.927
    .target Marshal Dughan
    .accept 40 >> Accept A Fishy Peril

step
    .goto Elwynn Forest,42.105,65.927
    .target Marshal Dughan
    .accept 419 >> Accept Further Concerns

step
    .goto Elwynn Forest,42.105,65.927
    .home >> Set your hearthstone to Goldshire

step
    .goto Elwynn Forest,43.283,65.721
    >>William Pestle is just inside the inn.
    .target William Pestle
    .accept 60 >> Accept Kobold Candles

step
    .goto Elwynn Forest,43.283,65.721
    .target William Pestle
    .accept 112 >> Accept Collecting Kelp

step
    .goto Elwynn Forest,42.1,67.3
    .target Remy Two Times
    .accept 47 >> Accept Gold Dust Exchange

step
    .goto Elwynn Forest,34.5,84.2
    >>Start the farm chain before entering the mine.
    .target Auntie Bernice Stonefield
    .accept 85 >> Accept Lost Necklace

step
    .goto Elwynn Forest,43.1,89.6
    .target Maybell Maclure
    .accept 106 >> Accept Young Lovers

step
    .goto Elwynn Forest,29.8,86.0
    .target Tommy Joe Stonefield
    .turnin 106 >> Turn in Young Lovers

step
    .goto Elwynn Forest,29.8,86.0
    .target Tommy Joe Stonefield
    .accept 111 >> Accept Speak with Gramma

step
    .goto Elwynn Forest,34.9,83.9
    .target Gramma Stonefield
    .turnin 111 >> Turn in Speak with Gramma

step
    .goto Elwynn Forest,34.9,83.9
    .target Gramma Stonefield
    .accept 107 >> Accept Note to William

step
    .goto Elwynn Forest,43.1,85.7
    .target Billy Maclure
    .turnin 85 >> Turn in Lost Necklace

step
    .goto Elwynn Forest,43.1,85.7
    .target Billy Maclure
    .accept 86 >> Accept Pie for Billy

step
    .goto Elwynn Forest,34.5,84.2
    .target Auntie Bernice Stonefield
    .turnin 86 >> Turn in Pie for Billy

step
    .goto Elwynn Forest,34.5,84.2
    .target Auntie Bernice Stonefield
    .accept 84 >> Accept Back to Billy

step
    .goto Elwynn Forest,43.1,85.7
    .target Billy Maclure
    .turnin 84 >> Turn in Back to Billy

step
    .goto Elwynn Forest,43.1,85.7
    .target Billy Maclure
    .accept 87 >> Accept Goldtooth

step
    #label Fargodeep
    .goto Elwynn Forest,40.3,82.5,45,0
    >>Explore the mine before breaking off to collect drops.
    .complete 62,1 --Explore Fargodeep Mine

step
    .goto Elwynn Forest,40.3,82.5,45,0
    >>Kobold Miners drop the Gold Dust.
    .collect 4306,10 --Gold Dust (x10)
    .mob Kobold Miner

step
    .goto Elwynn Forest,40.3,82.5,45,0
    >>Collect the candles for William Pestle.
    .collect 1468,8 --Large Candle (x8)
    .mob Kobold Tunneler

step
    .goto Elwynn Forest,40.3,82.5,45,0
    >>The Westfall Deed is a rare mine drop. Keep it.
    .collect 1972,1 --Westfall Deed (x1)
    .mob Kobold Miner

step
    .goto Elwynn Forest,40.3,82.5,45,0
    >>Goldtooth is at the back of the mine.
    .complete 87,1 --Kill Goldtooth (x1)
    .mob Goldtooth

step
    .goto Elwynn Forest,34.5,84.2
    .target Auntie Bernice Stonefield
    .turnin 87 >> Turn in Goldtooth

step
    .goto Elwynn Forest,42.105,65.927
    .target Marshal Dughan
    .turnin 62 >> Turn in The Fargodeep Mine

step
    .goto Elwynn Forest,42.105,65.927
    .target Marshal Dughan
    .turnin 40 >> Turn in A Fishy Peril

step
    .goto Elwynn Forest,42.1,67.3
    .target Remy Two Times
    .turnin 47 >> Turn in Gold Dust Exchange

step
    .goto Elwynn Forest,43.283,65.721
    .target William Pestle
    .turnin 60 >> Turn in Kobold Candles

step
    .goto Elwynn Forest,43.283,65.721
    .target William Pestle
    .turnin 112 >> Turn in Collecting Kelp

step
    .goto Elwynn Forest,43.283,65.721
    .target William Pestle
    .turnin 107 >> Turn in Note to William

step
    .goto Elwynn Forest,43.283,65.721
    .target William Pestle
    .accept 113 >> Accept The Escape

step
    .goto Elwynn Forest,43.283,65.721
    .target William Pestle
    .accept 61 >> Accept Shipment to Stormwind

step
    .goto Elwynn Forest,47.5,62.2,35,0
    >>Step into the scripted murloc ambush on the lake road.
    .complete 113,1 --Escape the murloc ambush

step
    .goto Elwynn Forest,48.0,63.0
    .target Jason Mathers
    .turnin 113 >> Turn in The Escape

step
    #label Eastvale
    .goto Elwynn Forest,52.3,49.7
    >>Guard Thomas is the hub for the Eastvale chain.
    .target Guard Thomas
    .accept 467 >> Accept Protect the Frontier

step
    .goto Elwynn Forest,52.3,49.7
    .target Guard Thomas
    .accept 422 >> Accept Find the Lost Guards

step
    .goto Elwynn Forest,52.3,49.7
    .target Guard Thomas
    .accept 242 >> Accept The Collector

step
    .goto Elwynn Forest,52.3,49.7
    .target Supervisor Raelen
    .accept 5545 >> Accept A Bundle of Trouble

step
    .goto Elwynn Forest,52.3,49.7
    .target Sara Timberlain
    .accept 365 >> Accept Red Linen Goods

step
    .goto Elwynn Forest,52.3,49.7,45,0
    >>Defias in Eastvale carry the linen.
    .collect 4308,12 --Red Linen (x12)
    .mob Defias Thug

step
    .goto Elwynn Forest,52.3,49.7,45,0
    >>Bundle the bandages from the same Defias drops.
    .collect 4309,4 --Fine Linen Bandage (x4)
    .mob Defias Thug

step
    .goto Elwynn Forest,52.3,49.7,45,0
    .complete 467,1 --Kill Riverpaw Runt (x10)
    .mob Riverpaw Runt

step
    .goto Elwynn Forest,52.3,49.7,45,0
    >>The lost guards are along the Eastvale road.
    .complete 422,1 --Find the Lost Guards

step
    .goto Elwynn Forest,52.3,49.7,45,0
    >>Riverpaw Gnolls drop the pickup schedule.
    .complete 242,1 --Collect Gold Pickup Schedule (x1)
    .mob Riverpaw Gnoll

step
    .goto Elwynn Forest,52.3,49.7
    .target Guard Thomas
    .turnin 422 >> Turn in Find the Lost Guards

step
    .goto Elwynn Forest,52.3,49.7
    .target Guard Thomas
    .accept 423 >> Accept Discover Rolf's Fate

step
    .goto Elwynn Forest,52.3,49.7
    >>Inspect Rolf's remains east of Guard Thomas.
    .complete 423,1 --Discover Rolf's Fate

step
    .goto Elwynn Forest,52.3,49.7
    .target Guard Thomas
    .turnin 423 >> Turn in Discover Rolf's Fate

step
    .goto Elwynn Forest,52.3,49.7
    .target Guard Thomas
    .accept 424 >> Accept Deliver Thomas' Report

step
    .goto Elwynn Forest,52.3,49.7
    >>Use the report from your bag once the quest is active.
    .complete 424,1 --Deliver Thomas' Report

step
    .goto Elwynn Forest,52.3,49.7
    .target Guard Thomas
    .turnin 424 >> Turn in Deliver Thomas' Report

step
    .goto Elwynn Forest,52.3,49.7
    .target Guard Thomas
    .accept 207 >> Accept Bounty on Murlocs

step
    .goto Elwynn Forest,52.3,49.7
    .target Guard Thomas
    .turnin 467 >> Turn in Protect the Frontier

step
    .goto Elwynn Forest,52.3,49.7
    .target Guard Thomas
    .turnin 242 >> Turn in The Collector

step
    .goto Elwynn Forest,52.3,49.7
    .target Sara Timberlain
    .turnin 365 >> Turn in Red Linen Goods

step
    .goto Elwynn Forest,52.3,49.7
    .target Supervisor Raelen
    .turnin 5545 >> Turn in A Bundle of Trouble

step
    #label Jasperlode
    .goto Elwynn Forest,42.105,65.927
    .target Marshal Dughan
    .turnin 419 >> Turn in Further Concerns

step
    .goto Elwynn Forest,42.105,65.927
    .target Marshal Dughan
    .accept 76 >> Accept The Jasperlode Mine

step
    .goto Elwynn Forest,50.4,86.8,45,0
    >>Explore Jasperlode Mine.
    .complete 76,1 --Explore Jasperlode Mine

step
    .goto Elwynn Forest,42.105,65.927
    .target Marshal Dughan
    .turnin 76 >> Turn in The Jasperlode Mine

step
    .goto Elwynn Forest,42.105,65.927
    .target Marshal Dughan
    .accept 139 >> Accept Westbrook Garrison Needs Help

step
    .goto Elwynn Forest,51.5,82.0
    .target Deputy Rainer
    .turnin 139 >> Turn in Westbrook Garrison Needs Help

step
    .goto Elwynn Forest,51.5,82.0
    .target Deputy Rainer
    .accept 133 >> Accept Riverpaw Gnoll Bounty

step
    .goto Elwynn Forest,49.5,78.0,45,0
    >>Clear the Riverpaw camp west of Westbrook.
    .complete 133,1 --Kill Riverpaw Gnoll (x12)
    .mob Riverpaw Gnoll

step
    .goto Elwynn Forest,51.5,82.0
    .target Deputy Rainer
    .turnin 133 >> Turn in Riverpaw Gnoll Bounty

step
    .goto Elwynn Forest,51.5,82.0
    .target Deputy Rainer
    .accept 244 >> Accept Manhunt

step
    .goto Elwynn Forest,46.0,62.0,50,0
    >>Finish the murloc bounty along the lake road.
    .complete 207,1 --Kill Murloc (x14)
    .mob Murloc

step
    .goto Elwynn Forest,52.3,49.7
    .target Guard Thomas
    .turnin 207 >> Turn in Bounty on Murlocs

step
    .goto Elwynn Forest,42.105,65.927
    .target Marshal Dughan
    .turnin 244 >> Turn in Manhunt

step
    .goto Elwynn Forest,42.1,67.3
    .target Remy Two Times
    .turnin 61 >> Turn in Shipment to Stormwind

step
    .goto Elwynn Forest,41.5,65.9
    >>Repair before the last grind; the inn vendors take wolf meat and linen.
    .vendor >> Repair at Corina
    .trainer >> Train any missed spells

step
    .goto Elwynn Forest,45.0,70.0,50,0
    >>Clear any leftover quests, then grind along the Goldshire road.
    +Use your hearthstone to return here after banking or training.
    .xp 10
  ]],
  "Human-1-10"
)
