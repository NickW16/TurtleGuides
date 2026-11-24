-- undead 1-10 starter route
-- luacheck: ignore 621
local TG = _G.TurtleGuides
TG:RegisterGuideText(
  [[
#classic
<< Horde
#name 1-10 Tirisfal Glades
#version 1
#group Turtle Guides (H)
#subgroup Tirisfal Glades
#defaultfor Undead/Scourge
#next 10-16 Silverpine Forest

step
    >>Talk to Undertaker Mordo
    .goto Tirisfal Glades,30.22,71.65,8,0
    .goto Tirisfal Glades,30.2,71.7
    .target Undertaker Mordo
    .accept 363 >> Accept Rude Awakening

step
    >>Turn in Rude Awakening
    .goto Tirisfal Glades,30.2,71.7
    .target Undertaker Mordo
    .turnin 363 >> Turn in Rude Awakening
    .goto Tirisfal Glades,30.8,66.2
    .target Shadow Priest Sarvis
    .accept 364 >> Accept The Mindless Ones
    .goto Tirisfal Glades,30.9,66.0
    .target Novice Elreth
    .accept 376 >> Accept The Damned

step
    >>Kill 8 Mindless Zombies and 8 Wretched Zombies, then collect 6 Scavenger Paws and 6 Duskbat Wings
    .goto Tirisfal Glades,31.7,63.5,40,0
    .complete 364,1 --Kill Mindless Zombie (x8)
    .complete 364,2 --Kill Wretched Zombie (x8)
    .mob Mindless Zombie
    .mob Wretched Zombie
    .goto Tirisfal Glades,32.0,58.0,40,0
    .complete 376,1 --Collect Scavenger Paw (x6)
    .complete 376,2 --Collect Duskbat Wing (x6)
    .mob Young Scavenger
    .mob Ragged Scavenger
    .mob Duskbat
    .mob Mangy Duskbat

step
    >>Turn in The Mindless Ones and The Damned
    .goto Tirisfal Glades,30.8,66.2
    .target Shadow Priest Sarvis
    .turnin 364 >> Turn in The Mindless Ones
    .accept 3901 >> Accept Rattling the Rattlecages
    .goto Tirisfal Glades,30.9,66.0
    .target Novice Elreth
    .turnin 376 >> Turn in The Damned
    .accept 6395 >> Accept Marla's Last Wish

step
    >>Talk to Deathguard Saltain and Executor Arren
    .goto Tirisfal Glades,31.6,65.6
    .target Deathguard Saltain
    .accept 3902 >> Accept Scavenging Deathknell
    .goto Tirisfal Glades,32.1,66.0
    .target Executor Arren
    .accept 380 >> Accept Night Web's Hollow

step
    >>Collect 6 Scavenged Goods, then kill 12 Rattlecage Skeletons
    .goto Tirisfal Glades,32.2,64.0,25,0
    .complete 3902,1 --Collect Scavenged Goods (x6)
    .goto Tirisfal Glades,31.8,61.5,30,0
    .complete 3901,1 --Kill Rattlecage Skeleton (x12)
    .mob Rattlecage Skeleton

step
    >>Kill 10 Young Night Web Spiders, then kill 8 Night Web Spiders
    .goto Tirisfal Glades,28.3,58.3,35,0
    .complete 380,1 --Kill Young Night Web Spider (x10)
    .mob Young Night Web Spider
    .goto Tirisfal Glades,25.6,59.5,20,0
    .complete 380,2 --Kill Night Web Spider (x8)
    .mob Night Web Spider

step
    >>Turn in Night Web's Hollow, Scavenging Deathknell and Rattling the Rattlecages
    .goto Tirisfal Glades,32.1,66.0
    .target Executor Arren
    .turnin 380 >> Turn in Night Web's Hollow
    .accept 381 >> Accept The Scarlet Crusade
    .goto Tirisfal Glades,31.6,65.6
    .target Deathguard Saltain
    .turnin 3902 >> Turn in Scavenging Deathknell
    .goto Tirisfal Glades,30.8,66.2
    .target Shadow Priest Sarvis
    .turnin 3901 >> Turn in Rattling the Rattlecages

step
    >>Collect 12 Scarlet Armbands
    .goto Tirisfal Glades,36.6,68.0,50,0
    .complete 381,1 --Collect Scarlet Armband (x12)
    .mob Scarlet Initiate
    .mob Scarlet Convert

step
    >>Turn in The Scarlet Crusade, then kill Meven Korgal
    .goto Tirisfal Glades,32.1,66.0
    .target Executor Arren
    .turnin 381 >> Turn in The Scarlet Crusade
    .accept 382 >> Accept The Red Messenger
    .goto Tirisfal Glades,36.5,68.8
    .complete 382,1 --Collect Scarlet Crusade Documents (x1)
    .mob Meven Korgal

step
    >>Turn in The Red Messenger
    .goto Tirisfal Glades,32.1,66.0
    .target Executor Arren
    .turnin 382 >> Turn in The Red Messenger
    .accept 383 >> Accept Vital Intelligence

step
    >>Kill Samuel Fipps, bury his remains, then turn in Marla's Last Wish
    .goto Tirisfal Glades,36.7,61.7
    .complete 6395,1 --Collect Samuel's Remains (x1)
    .mob Samuel Fipps
    .goto Tirisfal Glades,31.2,65.1
    .complete 6395,1 --Samuel's Remains Buried (x1)
    .goto Tirisfal Glades,30.9,66.0
    .target Novice Elreth
    .turnin 6395 >> Turn in Marla's Last Wish

step
    >>Talk to Calvin Montague
    .goto Tirisfal Glades,38.2,56.8
    .target Calvin Montague
    .accept 8 >> Accept A Rogue's Deal

step
    >>Talk to Gordo, then turn in Gordo's Task to Junior Apothecary Holland
    .goto Tirisfal Glades,43.1,54.7,40,0
    .target Gordo
    .accept 5481 >> Accept Gordo's Task
    .goto Tirisfal Glades,57.4,48.9,30,0
    .target Junior Apothecary Holland
    .turnin 5481 >> Turn in Gordo's Task
    .accept 5482 >> Accept Doom Weed

step
    >>Collect 10 Tirisfal Pumpkins and 3 Gloom Weed
    .goto Tirisfal Glades,40.9,54.2
    .target Deathguard Simmer
    .accept 365 >> Accept Fields of Grief
    .goto Tirisfal Glades,36.6,50.1,40,0
    .complete 365,1 --Collect Tirisfal Pumpkin (x10)
    .goto Tirisfal Glades,39.6,50.6,40,0
    .complete 5482,1 --Collect Gloom Weed (x3)

step
    >>Turn in Fields of Grief and Doom Weed
    .goto Tirisfal Glades,59.5,52.4
    .target Apothecary Johaan
    .turnin 365 >> Turn in Fields of Grief
    .accept 407 >> Accept Fields of Grief
    .goto Tirisfal Glades,61.97,51.29
    .target Captured Scarlet Zealot
    .turnin 407 >> Turn in Fields of Grief
    .goto Tirisfal Glades,57.4,48.9,30,0
    .target Junior Apothecary Holland
    .turnin 5482 >> Turn in Doom Weed

step
    >>Collect 7 Putrid Claws
    .goto Tirisfal Glades,58.2,51.5
    .target Deathguard Dillinger
    .accept 404 >> Accept A Putrid Task
    .goto Tirisfal Glades,52.6,57.0,50,0
    .complete 404,1 --Collect Putrid Claw (x7)
    .mob Rotting Dead
    .mob Ravaged Corpse
    .goto Tirisfal Glades,58.2,51.5
    .target Deathguard Dillinger
    .turnin 404 >> Turn in A Putrid Task

step
    >>Collect 5 Darkhound Blood and 5 Duskbat Pelts
    .goto Tirisfal Glades,59.5,52.4
    .target Apothecary Johaan
    .accept 367 >> Accept A New Plague
    .goto Tirisfal Glades,61.9,52.7
    .target Gretchen Dedmar
    .accept 375 >> Accept The Chill of Death
    .goto Tirisfal Glades,43.0,57.3,80,0
    .complete 367,1 --Collect Darkhound Blood (x5)
    .mob Decrepit Darkhound
    .mob Cursed Darkhound
    .goto Tirisfal Glades,48.0,53.4,50,0
    .complete 375,1 --Collect Duskbat Pelt (x5)
    .mob Greater Duskbat
    .mob Vampiric Duskbat

step
    >>Turn in A New Plague, The Chill of Death and A Rogue's Deal
    .goto Tirisfal Glades,59.5,52.4
    .target Apothecary Johaan
    .turnin 367 >> Turn in A New Plague
    .accept 368 >> Accept A New Plague
    .goto Tirisfal Glades,61.9,52.7
    .target Gretchen Dedmar
    .turnin 375 >> Turn in The Chill of Death
    .goto Tirisfal Glades,61.7,52.1
    .target Innkeeper Renee
    .turnin 8 >> Turn in A Rogue's Deal

step
    >>Turn in Vital Intelligence, then kill 10 Scarlet Warriors
    .goto Tirisfal Glades,60.6,51.8
    .target Executor Zygand
    .turnin 383 >> Turn in Vital Intelligence
    .accept 427 >> Accept At War With The Scarlet Crusade
    .goto Tirisfal Glades,32.0,49.0,55,0
    .complete 427,1 --Kill Scarlet Warrior (x10)
    .mob Scarlet Warrior
    .goto Tirisfal Glades,60.6,51.8
    .target Executor Zygand
    .turnin 427 >> Turn in At War With The Scarlet Crusade
    .accept 370 >> Accept At War With The Scarlet Crusade

step
    >>Kill 10 Scarlet Warriors, then turn in A New Plague
    .goto Tirisfal Glades,33.0,47.0,55,0
    .complete 370,1 --Kill Scarlet Warrior (x10)
    .mob Scarlet Warrior
    .goto Tirisfal Glades,60.6,51.8
    .target Executor Zygand
    .turnin 370 >> Turn in At War With The Scarlet Crusade
    .accept 372 >> Accept At War With The Scarlet Crusade
    .goto Tirisfal Glades,59.5,52.4
    .target Apothecary Johaan
    .turnin 368 >> Turn in A New Plague

step
    >>Kill Scarlet Warriors and Maggot Eye
    .goto Tirisfal Glades,60.9,52.0
    .target Deathguard Burgess
    .accept 374 >> Accept Proof of Demise
    .goto Tirisfal Glades,60.74,51.52
    .accept 398 >> Accept Wanted: Maggot Eye
    .goto Tirisfal Glades,61.26,50.84
    .target Magistrate Sevren
    .accept 358 >> Accept Graverobbers
    .accept 359 >> Accept Forsaken Duties
    .goto Tirisfal Glades,31.0,47.0,55,0
    .complete 372,1 --Kill Scarlet Warrior (x10)
    .complete 374,1 --Kill Scarlet Warrior (x10)
    .complete 358,1 --Kill Scarlet Warrior (x10)
    .mob Scarlet Warrior
    .goto Tirisfal Glades,35.0,51.0,35,0
    .complete 398,1 --Kill Maggot Eye (x1)
    .mob Maggot Eye

step
    >>Turn in the Brill bounties and At War With The Scarlet Crusade
    .goto Tirisfal Glades,60.6,51.8
    .target Executor Zygand
    .turnin 372 >> Turn in At War With The Scarlet Crusade
    .goto Tirisfal Glades,60.9,52.0
    .target Deathguard Burgess
    .turnin 374 >> Turn in Proof of Demise
    .goto Tirisfal Glades,60.74,51.52
    .turnin 398 >> Turn in Wanted: Maggot Eye
    .goto Tirisfal Glades,61.26,50.84
    .target Magistrate Sevren
    .turnin 358 >> Turn in Graverobbers
    .turnin 359 >> Turn in Forsaken Duties
    .accept 405 >> Accept The Prodigal Lich
    .accept 366 >> Accept Return the Book

step
    >>Collect 5 Notched Ribs and 3 Blackened Skulls
    .goto Tirisfal Glades,58.2,51.5
    .target Deathguard Dillinger
    .accept 426 >> Accept The Mills Overrun
    .goto Tirisfal Glades,61.7,52.3
    .target Coleman Farthing
    .accept 355 >> Accept Speak with Sevren
    .accept 362 >> Accept The Haunted Mills
    .goto Tirisfal Glades,47.4,43.7,50,0
    .complete 426,1 --Collect Notched Rib (x5)
    .complete 426,2 --Collect Blackened Skull (x3)
    .mob Rattlecage Soldier
    .mob Darkeye Bonecaster

step
    >>Turn in The Mills Overrun, Speak with Sevren, The Haunted Mills, The Prodigal Lich and Return the Book
    .goto Tirisfal Glades,58.2,51.5
    .target Deathguard Dillinger
    .turnin 426 >> Turn in The Mills Overrun
    .goto Tirisfal Glades,61.7,52.3
    .target Coleman Farthing
    .turnin 355 >> Turn in Speak with Sevren
    .turnin 362 >> Turn in The Haunted Mills
    .goto Tirisfal Glades,61.26,50.84
    .target Magistrate Sevren
    .turnin 405 >> Turn in The Prodigal Lich
    .goto Tirisfal Glades,84.1,17.4
    .target Bethor Iceshard
    .turnin 366 >> Turn in Return the Book

step
    >>Accept Delivery to Silverpine Forest
    .goto Tirisfal Glades,59.5,52.4
    .target Apothecary Johaan
    .accept 445 >> Accept Delivery to Silverpine Forest

step
    >>Grind to level 10
    .goto Tirisfal Glades,45.0,55.0,60,0
    .mob Scarlet Warrior
    .mob Rotting Dead
    .mob Ravaged Corpse
    .xp 10
]],
  "Undead-1-10"
)
