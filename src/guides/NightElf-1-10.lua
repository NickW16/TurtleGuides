-- night elf 1-10 starter route
-- luacheck: ignore 621
local TG = _G.TurtleGuides
TG:RegisterGuideText(
  [[
#classic
<< Alliance
#name 1-10 Teldrassil
#version 1
#group Turtle Guides (A)
#subgroup Teldrassil
#defaultfor NightElf
#next 10-16 Darkshore

step
    >>Talk to Conservator Ilthalaine, Melithar Staghelm and Dirania Silvershine
    .goto Teldrassil,58.7,44.3,20,0
    .target Conservator Ilthalaine
    .accept 456 >> Accept The Balance of Nature
    .goto Teldrassil,59.9,42.5,15,0
    .target Melithar Staghelm
    .accept 458 >> Accept The Woodland Protector
    .goto Teldrassil,60.9,42.0,15,0
    .target Dirania Silvershine
    .accept 4495 >> Accept A Good Friend

step
    >>Kill 7 Young Nightsabers and 4 Young Thistle Boars
    .goto Teldrassil,62.0,42.6,55,0
    .complete 456,1 --Kill Young Nightsaber (x7)
    .complete 456,2 --Kill Young Thistle Boar (x4)
    .mob Young Nightsaber
    .mob Young Thistle Boar
    .collect 3418,8 --Collect Fel Moss (x8)
    .mob Grell
    .mob Grellkin

step
    >>Turn in The Balance of Nature and The Woodland Protector
    .goto Teldrassil,58.7,44.3,20,0
    .target Conservator Ilthalaine
    .turnin 456 >> Turn in The Balance of Nature
    .accept 457 >> Accept The Balance of Nature
    .goto Teldrassil,57.8,45.2,15,0
    .target Tarindrella
    .turnin 458 >> Turn in The Woodland Protector
    .accept 459 >> Accept The Woodland Protector

step
    >>Turn in A Good Friend and kill 7 Mangy Nightsabers
    .goto Teldrassil,54.6,33.0,20,0
    .target Iverron
    .turnin 4495 >> Turn in A Good Friend
    .accept 3519 >> Accept A Friend in Need
    .goto Teldrassil,59.8,34.1,55,0
    .complete 457,1 --Kill Mangy Nightsaber (x7)
    .complete 457,2 --Kill Thistle Boar (x7)
    .mob Mangy Nightsaber
    .mob Thistle Boar

step
    >>Collect the antidote ingredients and Webwood Venom Sacs
    .goto Teldrassil,60.9,42.0,15,0
    .target Dirania Silvershine
    .turnin 3519 >> Turn in A Friend in Need
    .accept 3521 >> Accept Iverron's Antidote
    .goto Teldrassil,57.8,41.6,15,0
    .target Gilshalan Windwalker
    .accept 916 >> Accept Webwood Venom
    .goto Teldrassil,57.9,38.2,40,0
    .complete 3521,2 --Collect Moonpetal Lily (x4)
    .complete 3521,1 --Collect Hyacinth Mushroom (x7)
    .complete 3521,3 --Collect Webwood Ichor (x1)
    .complete 916,1 --Collect Webwood Venom Sac (x10)
    .complete 459,1 --Collect Fel Moss (x8)
    .mob Webwood Spider

step
    >>Turn in the Shadowglen quests
    .goto Teldrassil,58.7,44.3,20,0
    .target Conservator Ilthalaine
    .turnin 457 >> Turn in The Balance of Nature
    .goto Teldrassil,57.8,45.2,15,0
    .target Tarindrella
    .turnin 459 >> Turn in The Woodland Protector
    .goto Teldrassil,60.9,42.0,15,0
    .target Dirania Silvershine
    .turnin 3521 >> Turn in Iverron's Antidote
    .accept 3522 >> Accept Iverron's Antidote
    .goto Teldrassil,57.8,41.6,15,0
    .target Gilshalan Windwalker
    .turnin 916 >> Turn in Webwood Venom
    .accept 917 >> Accept Webwood Egg

step
    >>Collect the Webwood Egg
    .goto Teldrassil,56.7,31.2,25,0
    .goto Teldrassil,57.0,26.4,25,0
    .complete 917,1 --Collect Webwood Egg (x1)
    .goto Teldrassil,57.8,41.6,20,0
    .target Gilshalan Windwalker
    .turnin 917 >> Turn in Webwood Egg
    .accept 920 >> Accept Tenaron's Summons

step
    >>Complete Crown of the Earth
    .goto Teldrassil,58.2,40.5,20,0
    .goto Teldrassil,59.1,39.4,10,0
    .target Tenaron Stormgrip
    .turnin 920 >> Turn in Tenaron's Summons
    .accept 921 >> Accept Crown of the Earth
    .goto Teldrassil,59.9,33.0,20,0
    .complete 921,1 --Collect Filled Crystal Phial (x1)
    .goto Teldrassil,59.1,39.4,10,0
    .target Tenaron Stormgrip
    .turnin 921 >> Turn in Crown of the Earth
    .accept 928 >> Accept Crown of the Earth

step
    >>Turn in Iverron's Antidote and Dolanaar Delivery
    .goto Teldrassil,54.6,33.0,20,0
    .target Iverron
    .turnin 3522 >> Turn in Iverron's Antidote
    .goto Teldrassil,61.2,47.6,20,0
    .target Porthannius
    .accept 2159 >> Accept Dolanaar Delivery
    .goto Teldrassil,55.6,59.8,20,0
    .target Innkeeper Keldamyr
    .turnin 2159 >> Turn in Dolanaar Delivery

step
    >>Turn in Crown of the Earth in Dolanaar
    .goto Teldrassil,56.1,61.7,15,0
    .target Corithras Moonrage
    .turnin 928 >> Turn in Crown of the Earth
    .accept 929 >> Accept Crown of the Earth
    .goto Teldrassil,56.1,57.7,15,0
    .target Syral Bladeleaf
    .accept 997 >> Accept Denalan's Earth
    .goto Teldrassil,56.0,57.3,15,0
    .target Athridas Bearmantle
    .accept 475 >> Accept A Troubling Breeze
    .goto Teldrassil,60.5,56.3,20,0
    .target Zenn Foulhoof
    .accept 488 >> Accept Zenn's Bidding

step
    >>Accept Tallonkai's quests
    .goto Teldrassil,55.6,57.0,15,0
    .target Tallonkai Swiftroot
    .accept 932 >> Accept Twisted Hatred
    .accept 2438 >> Accept The Emerald Dreamcatcher

step
    >>Collect fangs, feathers and silk
    .goto Teldrassil,60.0,60.9,60,0
    .complete 488,1 --Collect Nightsaber Fang (x3)
    .mob Nightsaber
    .complete 488,2 --Collect Strigid Owl Feather (x3)
    .mob Strigid Owl
    .complete 488,3 --Collect Webwood Spider Silk (x3)
    .mob Webwood Lurker

step
    >>Turn in Denalan's Earth
    .goto Teldrassil,60.9,68.5,20,0
    .target Denalan
    .turnin 997 >> Turn in Denalan's Earth
    .accept 918 >> Accept Timberling Seeds
    .accept 919 >> Accept Timberling Sprouts
    .goto Teldrassil,59.0,70.5,55,0
    .complete 918,1 --Collect Timberling Seed (x8)
    .complete 919,1 --Collect Timberling Sprout (x12)
    .mob Timberling
    .goto Teldrassil,60.9,68.5,20,0
    .target Denalan
    .turnin 918 >> Turn in Timberling Seeds
    .accept 922 >> Accept Rellian Greenspyre
    .turnin 919 >> Turn in Timberling Sprouts

step
    >>Complete the Starbreeze errands
    .goto Teldrassil,68.0,59.7,20,0
    .complete 2438,1 --Collect Emerald Dreamcatcher (x1)
    .goto Teldrassil,66.3,58.5,15,0
    .target Gaerolas Talvethren
    .turnin 475 >> Turn in A Troubling Breeze
    .accept 476 >> Accept Gnarlpine Corruption
    .goto Teldrassil,63.4,58.1,20,0
    .complete 929,1 --Collect Filled Jade Phial (x1)
    .goto Teldrassil,56.1,61.7,15,0
    .target Corithras Moonrage
    .turnin 929 >> Turn in Crown of the Earth
    .accept 933 >> Accept Crown of the Earth

step
    >>Turn in Zenn's Bidding and kill Ferocitas
    .goto Teldrassil,60.5,56.3,20,0
    .target Zenn Foulhoof
    .turnin 488 >> Turn in Zenn's Bidding
    .goto Teldrassil,55.6,57.0,15,0
    .target Tallonkai Swiftroot
    .turnin 2438 >> Turn in The Emerald Dreamcatcher
    .accept 2459 >> Accept Ferocitas the Dream Eater
    .goto Teldrassil,68.4,53.4,55,0
    .complete 2459,1 --Kill Gnarlpine Mystic (x7)
    .mob Gnarlpine Mystic
    .complete 2459,2 --Collect Tallonkai's Jewel (x1)
    .mob Ferocitas the Dream Eater

step
    >>Collect 3 Fel Cones
    .goto Teldrassil,56.1,57.7,15,0
    .target Syral Bladeleaf
    .accept 489 >> Accept Seek Redemption!
    .goto Teldrassil,59.0,56.1,50,0
    .complete 489,1 --Collect Fel Cone (x3)
    .goto Teldrassil,60.5,56.3,20,0
    .target Zenn Foulhoof
    .turnin 489 >> Turn in Seek Redemption!

step
    >>Turn in Gnarlpine Corruption and kill Lord Melenas
    .goto Teldrassil,66.3,58.5,15,0
    .target Gaerolas Talvethren
    .turnin 476 >> Turn in Gnarlpine Corruption
    .goto Teldrassil,51.2,50.6,25,0
    .complete 932,1 --Collect Melenas' Head (x1)
    .mob Lord Melenas
    .goto Teldrassil,55.6,57.0,15,0
    .target Tallonkai Swiftroot
    .turnin 932 >> Turn in Twisted Hatred
    .turnin 2459 >> Turn in Ferocitas the Dream Eater

step
    >>Kill 6 Gnarlpine Ambusher
    .goto Teldrassil,55.9,58.8,20,0
    .target Moon Priestess Amara
    .accept 487 >> Accept The Road to Darnassus
    .goto Teldrassil,46.6,53.0,55,0
    .complete 487,1 --Kill Gnarlpine Ambusher (x6)
    .mob Gnarlpine Ambusher
    .goto Teldrassil,55.9,58.8,20,0
    .target Moon Priestess Amara
    .turnin 487 >> Turn in The Road to Darnassus
    .accept 60111 >> Accept A Decisive Blow

step
    >>Kill Greenpaw and Agal
    * Group quest
    .complete 60111,1 --Kill Greenpaw (x1)
    .complete 60111,2 --Kill Agal (x1)
    .mob Agal
    .mob Greenpaw
    .goto Teldrassil,55.9,58.8,20,0
    .target Moon Priestess Amara
    .turnin 60111 >> Turn in A Decisive Blow

step
    >>Turn in Rellian Greenspyre
    .goto Darnassus,38.2,21.6,20,0
    .target Rellian Greenspyre
    .turnin 922 >> Turn in Rellian Greenspyre

step
    >>Talk to Malos Lunarspear
    .goto Teldrassil,51.3,45.7,20,0
    .target Malos Lunarspear
    .accept 40201 >> Accept Unforeseen Consequences
    .goto Teldrassil,48.4,37.2,20,0
    .target Tesala Whitefeather
    .turnin 40201 >> Turn in Unforeseen Consequences
    .accept 40202 >> Accept Tesala's Word
    .goto Teldrassil,51.3,45.7,20,0
    .target Malos Lunarspear
    .turnin 40202 >> Turn in Tesala's Word
    .accept 40203 >> Accept Rooting Out Corruption

step
    >>Kill the Distorted Treant
    .goto Teldrassil,46.1,33.8,25,0
    .complete 40203,1 --Collect Withered Roots (x1)
    .mob Distorted Treant
    .goto Teldrassil,51.3,45.7,20,0
    .target Malos Lunarspear
    .turnin 40203 >> Turn in Rooting Out Corruption
    .goto Teldrassil,36.8,54.1,20,0
    .target Sentinel Danala
    .accept 40204 >> Accept A Meeting With Adaena
    .goto Teldrassil,35.3,54.4,15,0
    .target Adaena Oakleaf
    .turnin 40204 >> Turn in A Meeting With Adaena
    .accept 40205 >> Accept Securing Darnassus

step
    >>Kill Gnarlpine Pathfinders and Avengers
    .goto Teldrassil,42.6,76.2,55,0
    .complete 40205,1 --Kill Gnarlpine Pathfinder (x5)
    .complete 40205,2 --Kill Gnarlpine Avenger (x10)
    .mob Gnarlpine Avenger
    .mob Gnarlpine Pathfinder
    .goto Teldrassil,35.3,54.4,20,0
    .target Adaena Oakleaf
    .turnin 40205 >> Turn in Securing Darnassus

step
    >>Grind to level 10
    .goto Teldrassil,42.4,67.1,20,0
    .complete 933,1 --Collect Filled Tourmaline Phial (x1)
    .goto Teldrassil,56.1,61.7,15,0
    .target Corithras Moonrage
    .turnin 933 >> Turn in Crown of the Earth
    .goto Teldrassil,58.0,62.0,50,0
    .mob Timberling
    .mob Gnarlpine Warrior
    .xp 10
  ]],
  "NightElf-1-10"
)
