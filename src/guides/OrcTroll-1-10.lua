-- orc and troll 1-10 starter route
-- luacheck: ignore 621
local TG = _G.TurtleGuides
TG:RegisterGuideText(
  [[
#classic
<< Horde
#name 1-10 Durotar
#version 1
#group Turtle Guides (H)
#subgroup Durotar
#defaultfor Orc/Troll
#next 10-16 The Barrens

step
    >>Talk to Kaltunk and Gornek
    .goto Durotar,43.3,68.5
    .target Kaltunk
    .accept 4641 >> Accept Your Place In The World
    .goto Durotar,42.1,68.3
    .target Gornek
    .turnin 4641 >> Turn in Your Place In The World
    .accept 788 >> Accept Cutting Teeth

step
    >>Talk to Galgar, Gornek, Foreman Thazz'ril and Ukor
    .goto Durotar,42.7,67.2
    .target Galgar
    .accept 4402 >> Accept Galgar's Cactus Apple Surprise
    .goto Durotar,42.1,68.3
    .target Gornek
    .accept 789 >> Accept Sting of the Scorpid
    .goto Durotar,44.6,68.7
    .target Foreman Thazz'ril
    .accept 5441 >> Accept Lazy Peons
    .accept 6394 >> Accept Thazz'ril's Pick
    .goto Durotar,52.1,68.3
    .target Ukor
    .accept 2161 >> Accept A Peon's Burden

step
    >>Talk to Hana'zua
    .goto Durotar,40.6,62.6
    .target Hana'zua
    .accept 790 >> Accept Sarkoth

step
    >>Kill 10 Mottled Boars, 10 Scorpid Workers and Sarkoth
    .goto Durotar,44.0,65.0,45,0
    .complete 788,1 --Kill Mottled Boar (x10)
    .complete 789,1 --Collect Scorpid Worker Tail (x10)
    .complete 4402,1 --Collect Cactus Apple (x10)
    .complete 790,1 --Collect Sarkoth's Mangled Claw (x1)
    .collect 159,5 --Collect Refreshing Spring Water (x5)
    .mob Mottled Boar
    .mob Scorpid Worker
    .target Sarkoth

step
    >>Turn in the valley quests to Gornek, Galgar, Foreman Thazz'ril, Ukor and Hana'zua
    .goto Durotar,42.1,68.3
    .target Gornek
    .turnin 788 >> Turn in Cutting Teeth
    .goto Durotar,42.7,67.2
    .target Galgar
    .turnin 4402 >> Turn in Galgar's Cactus Apple Surprise
    .goto Durotar,44.6,68.7
    .target Foreman Thazz'ril
    .turnin 5441 >> Turn in Lazy Peons
    .turnin 6394 >> Turn in Thazz'ril's Pick
    .goto Durotar,52.1,68.3
    .target Ukor
    .turnin 2161 >> Turn in A Peon's Burden
    .goto Durotar,40.6,62.6
    .target Hana'zua
    .turnin 790 >> Turn in Sarkoth
    .accept 804 >> Accept Sarkoth

step
    >>Turn in Sarkoth and talk to Zureetha Fargaze
    .goto Durotar,42.9,69.2
    .target Zureetha Fargaze
    .turnin 804 >> Turn in Sarkoth
    .accept 794 >> Accept Burning Blade Medallion
    .accept 805 >> Accept Report to Sen'jin Village

step
    >>Kill Burning Blade cultists and collect the Burning Blade Medallion
    .goto Durotar,41.5,59.0,40,0
    .complete 794,1 --Collect Burning Blade Medallion (x1)
    .mob Burning Blade Fanatic
    .mob Burning Blade Adept

step
    >>Talk to the Sen'jin Village leaders
    .goto Durotar,55.9,74.4
    .target Master Gadrin
    .turnin 805 >> Turn in Report to Sen'jin Village
    .accept 808 >> Accept Minshina's Skull
    .accept 826 >> Accept Zalazane
    .accept 823 >> Accept Report to Orgnil
    .goto Durotar,56.0,73.9
    .target Vel'rin Fang
    .accept 817 >> Accept Practical Prey
    .goto Durotar,55.9,74.4
    .target Master Vornal
    .accept 818 >> Accept A Solvent Spirit
    .goto Durotar,54.2,73.4
    .target Lar Prowltusk
    .accept 786 >> Accept Thwarting Kolkar Aggression

step
    >>Kill 10 Raptors, 10 Kolkar Centaurs and 12 Zalazane Trolls
    .goto Durotar,59.0,72.0,45,0
    .complete 818,1 --Collect Venom Sac (x8)
    .complete 817,1 --Kill Raptor (x10)
    .complete 786,1 --Kill Kolkar Centaur (x10)
    .complete 826,1 --Kill Zalazane Troll (x12)
    .complete 808,1 --Collect Minshina's Skull (x1)
    .collect 117,5 --Collect Tough Jerky (x5)
    .mob Scorpid Worker
    .mob Raptor
    .mob Kolkar Wrangler
    .mob Zalazane

step
    >>Turn in the coastal quests at Sen'jin Village
    .goto Durotar,55.9,74.4
    .target Master Gadrin
    .turnin 808 >> Turn in Minshina's Skull
    .turnin 826 >> Turn in Zalazane
    .goto Durotar,56.0,73.9
    .target Vel'rin Fang
    .turnin 817 >> Turn in Practical Prey
    .goto Durotar,55.9,74.4
    .target Master Vornal
    .turnin 818 >> Turn in A Solvent Spirit
    .goto Durotar,54.2,73.4
    .target Lar Prowltusk
    .turnin 786 >> Turn in Thwarting Kolkar Aggression

step
    >>Turn in Report to Orgnil and talk to Orgnil Soulscar and Rezlak
    .goto Durotar,52.2,43.1
    .target Orgnil Soulscar
    .turnin 823 >> Turn in Report to Orgnil
    .accept 806 >> Accept Dark Storms
    .goto Durotar,46.4,22.9
    .target Rezlak
    .accept 834 >> Accept Winds in the Desert

step
    >>Talk to Gar'thok
    .goto Durotar,52.0,43.5
    .target Gar'thok
    .accept 784 >> Accept Vanquish the Betrayers
    .accept 831 >> Accept The Admiral's Orders
    .accept 837 >> Accept Encroachment
    .accept 825 >> Accept From The Wreckage....

step
    >>Talk to Cook Torka and Furl Scornbrow
    .goto Durotar,51.1,42.5
    .target Cook Torka
    .accept 815 >> Accept Break a Few Eggs
    .goto Durotar,49.9,40.4
    .target Furl Scornbrow
    .accept 791 >> Accept Carry Your Weight

step
    >>Kill 10 Kul Tiras Sailors, 10 Brackenwall Quilboars and Kvoldir
    .goto Durotar,50.0,36.0,50,0
    .complete 784,1 --Kill Kul Tiras Sailor (x10)
    .complete 831,1 --Collect Aged Envelope (x1)
    .complete 837,1 --Kill Brackenwall Quilboar (x10)
    .complete 825,1 --Collect Wreckage Parts (x1)
    .complete 815,1 --Collect Kvoldir Egg (x8)
    .complete 791,1 --Collect Heavy Kvoldir Club (x1)
    .complete 834,1 --Investigate the dust storm
    .mob Kul Tiras Sailor
    .mob Brackenwall Quilboar
    .mob Kvoldir

step
    >>Turn in the southern quests at Gar'thok, Cook Torka, Furl Scornbrow and Rezlak
    .goto Durotar,52.0,43.5
    .target Gar'thok
    .turnin 784 >> Turn in Vanquish the Betrayers
    .turnin 831 >> Turn in The Admiral's Orders
    .turnin 837 >> Turn in Encroachment
    .turnin 825 >> Turn in From The Wreckage....
    .goto Durotar,51.1,42.5
    .target Cook Torka
    .turnin 815 >> Turn in Break a Few Eggs
    .goto Durotar,49.9,40.4
    .target Furl Scornbrow
    .turnin 791 >> Turn in Carry Your Weight
    .goto Durotar,46.4,22.9
    .target Rezlak
    .turnin 834 >> Turn in Winds in the Desert
    .accept 835 >> Accept Securing the Lines

step
    >>Talk to Rhinag, Rezlak and Orgnil Soulscar
    .goto Durotar,41.5,18.6
    .target Rhinag
    .accept 812 >> Accept Need for a Cure
    .goto Durotar,46.4,22.9
    .target Rezlak
    .turnin 835 >> Turn in Securing the Lines
    .goto Durotar,52.2,43.1
    .target Orgnil Soulscar
    .turnin 806 >> Turn in Dark Storms

step
    >>Talk to Margoz
    .goto Durotar,56.4,20.0
    .target Margoz
    .accept 827 >> Accept Skull Rock
    .accept 829 >> Accept Neeru Fireblade

step
    >>Kill 10 Skull Rock Trolls and collect the Eye of Burning Shadow
    .goto Durotar,58.0,17.0,40,0
    .complete 827,1 --Kill Skull Rock Troll (x10)
    .collect 4903,1 --Collect Eye of Burning Shadow (x1)
    .mob Skull Rock Troll

step
    >>Turn in Skull Rock and Neeru Fireblade to Margoz
    .goto Durotar,56.4,20.0
    .target Margoz
    .turnin 827 >> Turn in Skull Rock
    .turnin 829 >> Turn in Neeru Fireblade
    .accept 832 >> Accept Burning Shadows

step
    >>Talk to Technician Spuzzle and collect 6 Energized Scales
    .goto Durotar,57.4,25.9
    .target Technician Spuzzle
    .accept 55003 >> Accept A New Power Source
    .goto Durotar,52.0,20.0,40,0
    .complete 55003,1 --Collect Energized Scale (x6)
    .mob Lightning Hide
    .mob Thunder Lizard
    .goto Durotar,57.4,25.9
    .target Technician Spuzzle
    .turnin 55003 >> Turn in A New Power Source

step
    >>Collect Warlord Kolkanis' Head and turn in Aggression's End
    .goto Durotar,56.0,70.0,40,0
    .complete 40390,1 --Collect Warlord Kolkanis' Head (x1)
    .accept 40390 >> Accept Aggression's End
    .goto Durotar,55.9,74.4
    .target Master Gadrin
    .turnin 40390 >> Turn in Aggression's End
    .accept 40391 >> Accept A Hunt for Honor
    +The final hand-in for A Hunt for Honor is Cairne Bloodhoof in Thunder Bluff, so save it for your next trip north.

step
    >>Kill Burning Shadow and turn in Burning Shadows
    .goto Durotar,50.0,30.0,50,0
    .complete 832,1 --Kill Burning Shadow (x1)
    .complete 812,1 --Collect Antidote Ingredients (x1)
    .mob Burning Shadow
    .goto Durotar,52.0,43.5
    .target Gar'thok
    .turnin 832 >> Turn in Burning Shadows

step
    >>Talk to Takrin Pathseeker, then grind to level 10
    .goto Durotar,50.8,43.6
    .target Takrin Pathseeker
    .accept 840 >> Accept Conscript of the Horde
    .goto Durotar,48.0,40.0,50,0
    .xp 10
]],
  "OrcTroll-1-10"
)
