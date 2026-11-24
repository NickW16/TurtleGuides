-- Orc/Troll 1-6 Durotar, written for Turtle WoW 1.12.1.
-- luacheck: ignore 621
local TG = _G.TurtleGuides
TG:RegisterGuideText(
  [[
#classic
<< Horde
#name 1-6 Durotar
#version 2
#group Turtle Guides (H)
#subgroup Durotar
#defaultfor Orc/Troll
#next 6-16 The Barrens

step << !Orc !Troll
    #sticky
    #completewith next
    .goto Durotar,43.29,68.53
    +This route is for Orcs and Trolls. Pick your race's own starter guide instead.

step
    #label Valley
    .goto Durotar,43.29,68.53
    >>Kaltunk stands just outside the Den entrance.
    .target Kaltunk
    .accept 4641 >> Accept Your Place In The World

step
    .goto Durotar,42.28,68.48,12,0
    .goto Durotar,42.06,68.32
    .target Gornek
    .turnin 4641 >> Turn in Your Place In The World

step
    .goto Durotar,42.06,68.32
    .target Gornek
    .accept 788 >> Accept Cutting Teeth

step
    .goto Durotar,42.73,67.23
    .target Galgar
    .accept 4402 >> Accept Galgar's Cactus Apple Surprise

step
    .goto Durotar,42.59,67.34
    .target Duokna
    .vendor >> Sell grey items. Casters should top up on water here.

step << Mage/Warlock/Priest/Shaman
    .goto Durotar,42.59,67.34
    .target Duokna
    .collect 159,10 --Refreshing Spring Water (x10)

step << Hunter
    .goto Durotar,42.59,67.34
    .target Duokna
    .collect 2512,200 --Rough Arrow (x200)

step
    .goto Durotar,42.06,68.32
    .target Gornek
    .accept 789 >> Accept Sting of the Scorpid

step << Warrior
    .goto Durotar,42.89,69.44
    .target Frang
    .trainer >> Train Battle Shout and Rend if you can afford them.

step << Shaman
    .goto Durotar,42.39,69.00
    .target Shikrik
    .trainer >> Train Rockbiter Weapon and Earth Shock.

step << Mage
    .goto Durotar,42.51,69.04
    .target Mai'ah
    .trainer >> Train Arcane Intellect and Frostbolt.

step << Priest
    .goto Durotar,42.36,68.81
    .target Ken'jai
    .trainer >> Train Power Word: Fortitude and Shadow Word: Pain.

step << Rogue
    .goto Durotar,41.27,68.00,12,0
    .target Rwag
    .trainer >> Train Backstab.

step << Hunter
    .goto Durotar,42.84,69.32
    .target Jen'shan
    .trainer >> Train Serpent Sting.

step << Orc Warlock
    .goto Durotar,40.65,68.52
    .target Nartok
    .trainer >> Train Immolate.

step << Orc Warrior
    .goto Durotar,42.06,68.32
    .target Gornek
    .accept 2383 >> Accept Simple Parchment

step << Troll Warrior
    .goto Durotar,42.06,68.32
    .target Gornek
    .accept 3065 >> Accept Simple Tablet

step << Orc Hunter
    .goto Durotar,42.06,68.32
    .target Gornek
    .accept 3087 >> Accept Etched Parchment

step << Troll Hunter
    .goto Durotar,42.06,68.32
    .target Gornek
    .accept 3082 >> Accept Etched Tablet

step << Orc Rogue
    .goto Durotar,42.06,68.32
    .target Gornek
    .accept 3088 >> Accept Encrypted Parchment

step << Troll Rogue
    .goto Durotar,42.06,68.32
    .target Gornek
    .accept 3083 >> Accept Encrypted Tablet

step << Orc Shaman
    .goto Durotar,42.06,68.32
    .target Gornek
    .accept 3089 >> Accept Rune-Inscribed Parchment

step << Troll Shaman
    .goto Durotar,42.06,68.32
    .target Gornek
    .accept 3084 >> Accept Rune-Inscribed Tablet

step << Troll Priest
    .goto Durotar,42.06,68.32
    .target Gornek
    .accept 3085 >> Accept Hallowed Tablet

step << Troll Mage
    .goto Durotar,42.06,68.32
    .target Gornek
    .accept 3086 >> Accept Glyphic Tablet

step << Orc Warlock
    .goto Durotar,42.06,68.32
    .target Gornek
    .accept 3090 >> Accept Tainted Parchment

step << Orc Warlock
    .goto Durotar,41.52,68.36,12,0
    .goto Durotar,41.24,68.16,12,0
    .goto Durotar,42.59,69.00
    .target Ruzan
    .accept 1485 >> Accept Vile Familiars

step
    .goto Durotar,44.63,68.65
    .target Foreman Thazz'ril
    .accept 5441 >> Accept Lazy Peons

step
    .goto Durotar,42.13,68.41,15,0
    .goto Durotar,41.52,68.36,12,0
    .goto Durotar,40.59,62.59
    .target Hana'zua
    .accept 790 >> Accept Sarkoth

step
    #completewith Sarkoth
    .goto Durotar,43.57,67.28,35,0
    .goto Durotar,42.20,65.40,45,0
    >>Mottled Boars are the first mobs on the road out of camp. Ten finish Cutting Teeth.
    .complete 788,1 --Mottled Boar slain (x10)
    .mob Mottled Boar

step
    .goto Durotar,41.30,65.03,40,0
    >>Stay in the boar area until level 2 before moving farther south.
    .xp 2

step
    #completewith Sarkoth
    .goto Durotar,44.67,64.92,30,0
    .goto Durotar,43.45,62.96,40,0
    >>Cactus Apples are picked from the ground under the cacti, not dropped by mobs.
    .complete 4402,1 --Cactus Apple (x10)

step
    #completewith Sarkoth
    .goto Durotar,43.26,58.28,40,0
    .goto Durotar,42.81,58.41,40,0
    >>Scorpid Workers carry the tails for Gornek's second quest.
    .complete 789,1 --Scorpid Worker Tail (x10)
    .mob Scorpid Worker

step
    #completewith Sarkoth
    .goto Durotar,44.98,69.13,20,0
    .goto Durotar,45.64,65.70,45,0
    .use 16114 >> Use the Foreman's Blackjack on sleeping peons.
    .complete 5441,1 --Peons Awoken (x5)
    .target Lazy Peon

step
    #label Sarkoth
    .goto Durotar,40.60,66.80
    >>Sarkoth is a level 5 scorpion west of the valley. Loot his claw.
    .complete 790,1 --Sarkoth's Mangled Claw (x1)
    .target Sarkoth

step
    .goto Durotar,40.59,62.59
    .target Hana'zua
    .turnin 790 >> Turn in Sarkoth

step
    .goto Durotar,40.59,62.59
    .target Hana'zua
    .accept 804 >> Accept Sarkoth

step
    .goto Durotar,42.29,68.39,12,0
    .goto Durotar,42.06,68.32
    .target Gornek
    .turnin 788 >> Turn in Cutting Teeth

step
    .goto Durotar,42.06,68.32
    .target Gornek
    .turnin 804 >> Turn in Sarkoth

step
    .goto Durotar,42.73,67.23
    .target Galgar
    .turnin 4402 >> Turn in Galgar's Cactus Apple Surprise

step
    .goto Durotar,42.06,68.32
    .target Gornek
    .turnin 789 >> Turn in Sting of the Scorpid

step
    .goto Durotar,44.63,68.65
    .target Foreman Thazz'ril
    .turnin 5441 >> Turn in Lazy Peons

step
    .goto Durotar,44.63,68.65
    .target Foreman Thazz'ril
    .accept 6394 >> Accept Thazz'ril's Pick

step
    .goto Durotar,43.87,58.42,40,0
    >>Work the Vile Familiar spawn around the Burning Blade Coven until level 3.
    .xp 3

step << !Warlock
    .goto Durotar,42.85,69.15
    .target Zureetha Fargaze
    .accept 792 >> Accept Vile Familiars

step << !Warlock
    .goto Durotar,43.87,58.42,0
    .goto Durotar,44.53,58.62,40,0
    .goto Durotar,45.18,58.42,40,0
    .goto Durotar,45.83,58.59,40,0
    .goto Durotar,45.79,57.43,40,0
    .goto Durotar,46.46,57.57,40,0
    >>Twelve Vile Familiars satisfy Zureetha's version of the quest.
    .complete 792,1 --Vile Familiar slain (x12)
    .mob Vile Familiar

step << Orc Warlock
    .goto Durotar,43.87,58.42,0
    .goto Durotar,44.53,58.62,40,0
    .goto Durotar,45.18,58.42,40,0
    .goto Durotar,45.83,58.59,40,0
    >>Ruzan needs six heads instead of a simple kill count.
    .complete 1485,1 --Vile Familiar Head (x6)
    .mob Vile Familiar

step << Orc Warlock
    .goto Durotar,41.24,68.16,12,0
    .goto Durotar,42.59,69.00
    .target Ruzan
    .turnin 1485 >> Turn in Vile Familiars

step << Orc Warlock
    .goto Durotar,42.59,69.00
    .target Ruzan
    .accept 1499 >> Accept Vile Familiars

step << Orc Warlock
    .goto Durotar,42.85,69.15
    .target Zureetha Fargaze
    .turnin 1499 >> Turn in Vile Familiars

step << !Warlock
    .goto Durotar,42.85,69.15
    .target Zureetha Fargaze
    .turnin 792 >> Turn in Vile Familiars

step
    .goto Durotar,42.85,69.15
    .target Zureetha Fargaze
    .accept 794 >> Accept Burning Blade Medallion

step
    .goto Durotar,45.35,56.27,30
    >>Enter the Burning Blade cave east of the valley.
    .isOnQuest 6394

step
    .goto Durotar,45.37,55.39,15,0
    .goto Durotar,44.43,54.51,15,0
    .goto Durotar,43.72,53.79
    >>The pick rests against the back wall of the cave.
    .complete 6394,1 --Thazz'ril's Pick (x1)

step
    .goto Durotar,42.70,52.99
    >>Yarrog Baneshadow carries the medallion. He hits hard; use water and bandages.
    .complete 794,1 --Burning Blade Medallion (x1)
    .target Yarrog Baneshadow

step
    .goto Durotar,42.70,52.99,25,0
    .goto Durotar,42.97,51.14,25,0
    .goto Durotar,43.56,52.05,25,0
    >>Clear the remaining cultists here until level 4.
    .xp 4

step
    .goto Durotar,42.85,69.15
    .target Zureetha Fargaze
    .turnin 794 >> Turn in Burning Blade Medallion

step
    .goto Durotar,42.85,69.15
    .target Zureetha Fargaze
    .accept 805 >> Accept Report to Sen'jin Village

step
    .goto Durotar,44.63,68.65
    .target Foreman Thazz'ril
    .turnin 6394 >> Turn in Thazz'ril's Pick

step
    .goto Durotar,42.59,67.34
    .target Duokna
    .vendor >> Sell junk and refill water before the run to Sen'jin.

step << Orc Warrior
    .goto Durotar,42.89,69.44
    .target Frang
    .turnin 2383 >> Turn in Simple Parchment

step << Troll Warrior
    .goto Durotar,42.89,69.44
    .target Frang
    .turnin 3065 >> Turn in Simple Tablet

step << Warrior
    .goto Durotar,42.89,69.44
    .target Frang
    .trainer >> Train Charge or Parry if you can afford it.

step << Orc Hunter
    .goto Durotar,42.84,69.32
    .target Jen'shan
    .turnin 3087 >> Turn in Etched Parchment

step << Troll Hunter
    .goto Durotar,42.84,69.32
    .target Jen'shan
    .turnin 3082 >> Turn in Etched Tablet

step << Hunter
    .goto Durotar,42.84,69.32
    .target Jen'shan
    .trainer >> Train Hunter's Mark or Arcane Shot.

step << Orc Rogue
    .goto Durotar,41.52,68.36,12,0
    .goto Durotar,41.27,68.00
    .target Rwag
    .turnin 3088 >> Turn in Encrypted Parchment

step << Troll Rogue
    .goto Durotar,41.52,68.36,12,0
    .goto Durotar,41.27,68.00
    .target Rwag
    .turnin 3083 >> Turn in Encrypted Tablet

step << Rogue
    .goto Durotar,41.27,68.00
    .target Rwag
    .trainer >> Train Sinister Strike or Gouge.

step << Orc Shaman
    .goto Durotar,42.39,69.00
    .target Shikrik
    .turnin 3089 >> Turn in Rune-Inscribed Parchment

step << Troll Shaman
    .goto Durotar,42.39,69.00
    .target Shikrik
    .turnin 3084 >> Turn in Rune-Inscribed Tablet

step << Shaman
    .goto Durotar,42.40,69.17
    .target Canaga Earthcaller
    .trainer >> Train Healing Wave if you have the coin.

step << Troll Priest
    .goto Durotar,42.36,68.81
    .target Ken'jai
    .turnin 3085 >> Turn in Hallowed Tablet

step << Priest
    .goto Durotar,42.36,68.81
    .target Ken'jai
    .trainer >> Train Smite or Power Word: Shield.

step << Troll Mage
    .goto Durotar,42.51,69.04
    .target Mai'ah
    .turnin 3086 >> Turn in Glyphic Tablet

step << Mage
    .goto Durotar,42.51,69.04
    .target Mai'ah
    .trainer >> Train Fireball or Fire Blast.

step << Orc Warlock
    .goto Durotar,41.24,68.16,12,0
    .goto Durotar,40.82,68.03,12,0
    .goto Durotar,40.65,68.52
    .target Nartok
    .turnin 3090 >> Turn in Tainted Parchment

step << Orc Warlock
    .goto Durotar,40.65,68.52
    .target Nartok
    .trainer >> Train Shadow Bolt or Life Tap.

step
    #label Leave
    .goto Durotar,47.09,69.21,25,0
    .goto Durotar,49.02,69.13,20,0
    .goto Durotar,49.90,68.43,25
    >>Leave the Valley of Trials along the southern road.
    .isOnQuest 805

step
    #label Senjin
    .goto Durotar,54.20,73.36,0
    .goto Durotar,54.09,76.31,25,0
    .goto Durotar,54.52,74.83,25,0
    .goto Durotar,54.20,73.36,25,0
    >>Lar patrols a short loop near the village entrance.
    .target Lar Prowltusk
    .accept 786 >> Accept Thwarting Kolkar Aggression

step
    .goto Durotar,56.0,73.9
    .target Vel'rin Fang
    .accept 817 >> Accept Practical Prey

step
    .goto Durotar,55.95,73.93
    .target Master Vornal
    .accept 818 >> Accept A Solvent Spirit

step
    .goto Durotar,55.94,74.40
    .target Master Gadrin
    .turnin 805 >> Turn in Report to Sen'jin Village

step
    .goto Durotar,55.94,74.40
    .target Master Gadrin
    .accept 808 >> Accept Minshina's Skull

step
    .goto Durotar,55.94,74.40
    .target Master Gadrin
    .accept 826 >> Accept Zalazane

step
    .goto Durotar,56.16,74.43,8,0
    .goto Durotar,56.31,73.8,8
    >>Enter the large hut to reach the vendor.
    .isOnQuest 805

step << Mage/Warlock/Priest
    .goto Durotar,56.29,73.41
    .target K'waii
    .collect 159,20 --Refreshing Spring Water (x20)

step << Rogue
    .goto Durotar,56.29,73.41
    .target K'waii
    .collect 3131,200 --Weighted Throwing Axe (x200)

step << Shaman
    .goto Durotar,56.47,73.12
    .target Trayexir
    .vendor >> Sell junk. A Walking Stick is a big upgrade if you can afford it.

step << Shaman
    .goto Durotar,56.47,73.12
    .target Trayexir
    .collect 2495,1 --Walking Stick (x1)

step << Rogue
    .goto Durotar,56.47,73.12
    .target Trayexir
    .vendor >> Sell junk. A Stiletto is worth buying if funds allow.

step << Rogue
    .goto Durotar,56.47,73.12
    .target Trayexir
    .collect 2494,1 --Stiletto (x1)

step << Orc Warrior
    .goto Durotar,56.47,73.12
    .target Trayexir
    .vendor >> Sell junk. Save for a Large Axe if your weapon is weak.

step << Orc Warrior
    .goto Durotar,56.47,73.12
    .target Trayexir
    .collect 2491,1 --Large Axe (x1)

step << Troll Warrior
    .goto Durotar,56.47,73.12
    .target Trayexir
    .vendor >> Sell junk. Save for a Tomahawk if your weapon is weak.

step << Troll Warrior
    .goto Durotar,56.47,73.12
    .target Trayexir
    .collect 2490,1 --Tomahawk (x1)

step
    .goto Durotar,58.0,74.5,40,0
    >>Durotar Tigers east of the village drop the furs Vel'rin wants.
    .complete 817,1 --Durotar Tiger Fur (x4)
    .mob Durotar Tiger

step
    .goto Durotar,57.5,75.0,40,0
    >>Minshina's Skull comes from the trolls deeper in the same jungle.
    .complete 808,1 --Minshina's Skull (x1)
    .mob Hexed Troll

step
    .goto Durotar,58.54,75.89,40,0
    >>Makrura along the shore carry the intact eyes.
    .complete 818,1 --Intact Makrura Eye (x4)
    .mob Makrura

step
    .goto Durotar,57.73,77.91,40,0
    >>Surf Crawlers in the water drop the mucus.
    .complete 818,2 --Crawler Mucus (x8)
    .mob Surf Crawler

step
    .goto Durotar,58.0,72.0,40,0
    >>Work through the Hexed Trolls first.
    .complete 826,1 --Hexed Troll slain (x8)
    .mob Hexed Troll

step
    .goto Durotar,58.8,70.5,40,0
    >>Voodoo Trolls are mixed in with the same camp.
    .complete 826,2 --Voodoo Troll slain (x8)
    .mob Voodoo Troll

step
    .goto Durotar,59.5,69.0,30,0
    >>Zalazane is the named troll at the far end of the camp.
    .complete 826,3 --Zalazane's Head (x1)
    .target Zalazane

step
    .goto Durotar,49.81,81.29
    >>Destroy the Valley of Trials attack plan.
    .complete 786,1 --Attack Plan: Valley of Trials destroyed

step
    .goto Durotar,47.66,77.34
    >>Destroy the Sen'jin Village attack plan.
    .complete 786,2 --Attack Plan: Sen'jin Village destroyed

step
    .goto Durotar,46.23,78.94
    >>Destroy the Razor Hill attack plan.
    .complete 786,3 --Attack Plan: Razor Hill destroyed

step
    .goto Durotar,55.94,74.40
    .target Master Gadrin
    .turnin 808 >> Turn in Minshina's Skull

step
    .goto Durotar,55.94,74.40
    .target Master Gadrin
    .turnin 826 >> Turn in Zalazane

step
    .goto Durotar,56.0,73.9
    .target Vel'rin Fang
    .turnin 817 >> Turn in Practical Prey

step
    .goto Durotar,55.95,73.93
    .target Master Vornal
    .turnin 818 >> Turn in A Solvent Spirit

step
    .goto Durotar,54.20,73.36
    .target Lar Prowltusk
    .turnin 786 >> Turn in Thwarting Kolkar Aggression

step
    .goto Durotar,56.5,72.5,40,0
    >>Finish off any remaining kills around Sen'jin. Vendor and repair before leaving.
    .vendor >> Sell junk and repair.
    .xp 6
  ]],
  "OrcTroll-1-10"
)
