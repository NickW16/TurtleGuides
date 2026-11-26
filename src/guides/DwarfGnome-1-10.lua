-- guide data adapted from RestedXP Guides by RestedXP (RXPGuides).
-- source: https://github.com/RestedXP/RXPGuides
-- licensed under CC BY-NC-SA 4.0: https://creativecommons.org/licenses/by-nc-sa/4.0/
-- modified for Turtle WoW 1.12.1, with syntax and route adjustments.
-- dwarf and gnome 1-10 starter route
-- luacheck: ignore 621
local TG = _G.TurtleGuides
TG:RegisterGuideText(
  [[
#classic
<< Alliance
#name 1-10 Dun Morogh
#version 1
#group Turtle Guides (A)
#subgroup Dun Morogh
#defaultfor Dwarf/Gnome
#next 10-16 Loch Modan

step
    >>Talk to Sten Stoutarm, Balir Frosthammer and Felix Whindlebolt
    .goto Dun Morogh,29.9,71.2,25,0
    .target Sten Stoutarm
    .accept 179 >> Accept Dwarven Outfitters
    .accept 233 >> Accept Coldridge Valley Mail Delivery
    .goto Dun Morogh,29.7,71.3,20,0
    .target Balir Frosthammer
    .accept 170 >> Accept A New Threat
    .goto Dun Morogh,28.5,67.6,20,0
    .target Felix Whindlebolt
    .accept 3361 >> Accept A Refugee's Quandary

step
    >>Kill wolves, troggs and trolls
    .goto Dun Morogh,28.1,75.1,55,0
    .complete 179,1 --Collect Tough Wolf Meat (x8)
    .mob Ragged Young Wolf
    .goto Dun Morogh,25.7,75.4,55,0
    .complete 170,1 --Kill Rockjaw Trogg (x6)
    .complete 170,2 --Kill Burly Rockjaw Trogg (x6)
    .mob Rockjaw Trogg
    .mob Burly Rockjaw Trogg
    .complete 3361,1 --Collect Felix's Box (x1)
    .complete 3361,2 --Collect Felix's Chest (x1)
    .complete 3361,3 --Collect Felix's Bucket of Bolts (x1)
    .mob Frostmane Troll Whelp

step
    >>Turn in the valley quests
    .goto Dun Morogh,29.9,71.2,25,0
    .target Sten Stoutarm
    .turnin 179 >> Turn in Dwarven Outfitters
    .goto Dun Morogh,29.7,71.3,20,0
    .target Balir Frosthammer
    .turnin 170 >> Turn in A New Threat
    .goto Dun Morogh,28.5,67.6,20,0
    .target Felix Whindlebolt
    .turnin 3361 >> Turn in A Refugee's Quandary

step
    >>Turn in the mail delivery and kill 12 Small Crag Boars
    .goto Dun Morogh,22.6,71.4,20,0
    .target Talin Keeneye
    .turnin 233 >> Turn in Coldridge Valley Mail Delivery
    .accept 234 >> Accept Coldridge Valley Mail Delivery
    .accept 183 >> Accept The Boar Hunter
    .goto Dun Morogh,22.3,70.0,45,0
    .complete 183,1 --Kill Small Crag Boar (x12)
    .mob Small Crag Boar
    .goto Dun Morogh,22.6,71.4
    .target Talin Keeneye
    .turnin 183 >> Turn in The Boar Hunter

step
    >>Clear the troll cave and kill Grik'nir the Cold
    .goto Dun Morogh,25.1,75.7,20,0
    .target Grelin Whitebeard
    .turnin 234 >> Turn in Coldridge Valley Mail Delivery
    .accept 182 >> Accept The Troll Cave
    .goto Dun Morogh,24.2,80.6,45,0
    .complete 182,1 --Kill Frostmane Troll Whelp (x14)
    .mob Frostmane Troll Whelp
    .goto Dun Morogh,25.1,75.7
    .target Grelin Whitebeard
    .turnin 182 >> Turn in The Troll Cave
    .accept 218 >> Accept The Stolen Journal
    .goto Dun Morogh,27.4,81.2,30,0
    .complete 218,1 --Collect Grelin Whitebeard's Journal (x1)
    .mob Grik'nir the Cold
    .goto Dun Morogh,25.1,75.7
    .target Grelin Whitebeard
    .turnin 218 >> Turn in The Stolen Journal
    .accept 282 >> Accept Senir's Observations

step
    >>Turn in Senir's Observations
    .goto Dun Morogh,33.5,71.8,20,0
    .target Mountaineer Thalos
    .turnin 282 >> Turn in Senir's Observations
    .accept 420 >> Accept Senir's Observations
    .accept 2160 >> Accept Supplies to Tannok
    .goto Dun Morogh,35.7,65.8,20,0
    .goto Dun Morogh,47.2,52.2,15,0
    .target Tannok Frosthammer
    .turnin 2160 >> Turn in Supplies to Tannok

step
    >>Turn in Senir's Observations in Kharanos
    .goto Dun Morogh,46.7,53.8,20,0
    .target Senir Whitebeard
    .turnin 420 >> Turn in Senir's Observations
    .accept 287 >> Accept Frostmane Hold
    .goto Dun Morogh,45.8,49.4,15,0
    .target Razzle Sprysprocket
    .accept 412 >> Accept Operation Recombobulation

step
    >>Turn in Tools for Steelgrill
    .goto Dun Morogh,46.0,51.7,15,0
    .target Tharek Blackstone
    .accept 400 >> Accept Tools for Steelgrill
    .goto Dun Morogh,50.4,49.1,15,0
    .target Beldin Steelgrill
    .turnin 400 >> Turn in Tools for Steelgrill
    .goto Dun Morogh,50.1,49.4,15,0
    .target Loslor Rudge
    .accept 5541 >> Accept Ammo for Rumbleshot
    .collect 2901,1 --Buy a Mining Pick (x1)

step
    >>Accept the depot quests
    .goto Dun Morogh,49.4,48.4,15,0
    .target Pilot Bellowfiz
    .accept 317 >> Accept Stocking Jetsteam
    .accept 318 >> Accept Evershine
    .goto Dun Morogh,49.6,48.6,15,0
    .target Pilot Stonegear
    .accept 313 >> Accept The Grizzled Den

step
    >>Collect boar meat, bear fur and Wendigo Manes
    .goto Dun Morogh,52.0,50.1,70,0
    .complete 317,1 --Collect Chunk of Boar Meat (x4)
    .collect 2886,6 --Collect Crag Boar Rib (x6)
    .mob Crag Boar
    .mob Large Crag Boar
    .complete 317,2 --Collect Thick Bear Fur (x2)
    .mob Young Black Bear
    .goto Dun Morogh,42.0,54.8,60,0
    .complete 313,1 --Collect Wendigo Mane (x8)
    .mob Wendigo
    .mob Young Wendigo

step
    >>Turn in the depot quests
    .goto Dun Morogh,49.4,48.4,15,0
    .target Pilot Bellowfiz
    .turnin 317 >> Turn in Stocking Jetsteam
    .goto Dun Morogh,49.6,48.6,15,0
    .target Pilot Stonegear
    .turnin 313 >> Turn in The Grizzled Den
    .goto Dun Morogh,49.4,48.4,15,0
    .target Pilot Bellowfiz
    .goto Dun Morogh,30.2,45.7,20,0
    .target Rejold Barleybrew
    .turnin 318 >> Turn in Evershine

step
    >>Accept the cellar quests
    .goto Dun Morogh,30.2,45.7,15,0
    .target Rejold Barleybrew
    .accept 319 >> Accept A Favor for Evershine
    .accept 320 >> Accept Return to Bellowfiz
    .accept 315 >> Accept The Perfect Stout
    .goto Dun Morogh,30.2,45.5,15,0
    .target Marleth Barleybrew
    .accept 310 >> Accept Bitter Rivals
    .goto Dun Morogh,47.7,52.7,15,0
    .accept 311 >> Accept Return to Marleth
    .goto Dun Morogh,30.2,45.5,15,0
    .target Marleth Barleybrew
    .turnin 310 >> Turn in Bitter Rivals
    .turnin 311 >> Turn in Return to Marleth

step
    >>Turn in the cellar quests
    .goto Dun Morogh,30.2,45.7,15,0
    .target Rejold Barleybrew
    .turnin 319 >> Turn in A Favor for Evershine
    .turnin 315 >> Turn in The Perfect Stout
    .goto Dun Morogh,49.4,48.4,15,0
    .target Pilot Bellowfiz
    .turnin 320 >> Turn in Return to Bellowfiz

step
    >>Turn in Ammo for Rumbleshot
    .goto Dun Morogh,40.7,65.1,20,0
    .target Hegnar Rumbleshot
    .turnin 5541 >> Turn in Ammo for Rumbleshot

step
    >>Kill 12 Frostmane Trolls
    .goto Dun Morogh,46.7,53.8,15,0
    .target Senir Whitebeard
    .complete 287,1 --Kill Frostmane Troll (x12)
    .mob Frostmane Troll
    .turnin 287 >> Turn in Frostmane Hold

step
    >>Complete Operation Recombobulation
    .goto Dun Morogh,45.8,49.4,15,0
    .target Razzle Sprysprocket
    .complete 412,1 --Collect the first test component (x1)
    .complete 412,2 --Collect the second test component (x1)
    .turnin 412 >> Turn in Operation Recombobulation

step
    >>Accept Tundra MacGrann's quests
    .goto Dun Morogh,34.6,51.7,20,0
    .target Tundra MacGrann
    .accept 312 >> Accept Tundra MacGrann's Stolen Stash
    .accept 60114 >> Accept The Terror of Chill Breeze

step
    >>Kill Old Icebeard and recover the stash
    .goto Dun Morogh,36.2,58.4,55,0
    .complete 312,1 --Recover Tundra MacGrann's Stolen Stash
    .complete 60114,1 --Collect Old Icebeard's Beard (x1)
    .complete 60114,2 --Kill Old Icebeard (x1)
    .mob Old Icebeard
    .goto Dun Morogh,34.6,51.7
    .target Tundra MacGrann
    .turnin 312 >> Turn in Tundra MacGrann's Stolen Stash
    .turnin 60114 >> Turn in The Terror of Chill Breeze

step
    >>Talk to Durmir Rugford
    * Group quest
    * Group quest
    * Group quest
    .goto Dun Morogh,86.0,50.0,20,0
    .target Durmir Rugford
    .accept 41640 >> Accept Restless

step
    >>Recover Durmir's Belongings
    .complete 41640,1 --Recover Durmir's Belongings (x1)
    .goto Dun Morogh,86.0,50.0,20,0
    .target Durmir Rugford
    .turnin 41640 >> Turn in Restless

step
    >>Grind to level 10
    .goto Dun Morogh,43.5,56.3,55,0
    .mob Crag Boar
    .mob Rockjaw Trogg
    .xp 10
  ]],
  "DwarfGnome-1-10"
)
