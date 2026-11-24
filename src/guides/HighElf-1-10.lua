-- high elf 1-10 starter route
-- luacheck: ignore 621
local TG = _G.TurtleGuides
TG:RegisterGuideText(
  [[
#classic
<< Alliance
#name 1-10 High Elf (A)
#version 1
#group Turtle Survival (A)
#subgroup Thalassian Highlands
#defaultfor HighElf

step
    .goto Thalassian Highlands,48.28,84.30 >> Talk to |cRXP_FRIENDLY_Aerthand Skyshield|r
    .target Aerthand Skyshield
    .accept 41187 >> Accept Refugees no More

step
    .goto Thalassian Highlands,48.56,83.64 >> Turn in to |cRXP_FRIENDLY_Commander Anarileth|r
    .target Commander Anarileth
    .turnin 41187 >> Turn in Refugees no More
    .accept 41188 >> Accept Provisions for Refugees

step
    >>Kill |cRXP_ENEMY_Young Thalassian Boars|r for |cRXP_LOOT_Young Thalassian Boar Flanks|r
    .goto Thalassian Highlands,50.00,79.10,35,0 >> Boars just south of Brinthilien
    .goto Thalassian Highlands,52.10,84.00,35,0 >> Follow the boar path north
    .collect 41118,10 --Collect Young Thalassian Boar Flank (x10)
    .mob Young Thalassian Boar

step
    .goto Thalassian Highlands,48.56,83.64 >> Return to |cRXP_FRIENDLY_Commander Anarileth|r
    .target Commander Anarileth
    .turnin 41188 >> Turn in Provisions for Refugees
    .accept 41189 >> Accept Safety for Refugees
    .accept 41226 >> Accept Magically Sealed Letter << Mage
    .accept 41227 >> Accept Elegant Letter << Paladin
    .accept 41228 >> Accept Blessed Elegant Letter << Priest
    .accept 41229 >> Accept Shady Letter << Rogue
    .accept 41230 >> Accept Plain Letter << Warrior
    .accept 41231 >> Accept Feathered Letter << Hunter

step << Mage
    .goto Thalassian Highlands,49.76,85.31 >> Talk to |cRXP_FRIENDLY_Magister Ala'shor Sunblood|r
    .target Magister Ala'shor Sunblood
    .turnin 41226 >> Turn in Magically Sealed Letter
    >>Train your class spells

step << Paladin
    .goto Thalassian Highlands,49.03,86.11 >> Talk to |cRXP_FRIENDLY_Lor'thas the Holy|r
    .target Lor'thas the Holy
    .turnin 41227 >> Turn in Elegant Letter
    >>Train your class spells

step << Priest
    .goto Thalassian Highlands,49.09,86.21 >> Talk to |cRXP_FRIENDLY_Priestess Maelah Sunsworn|r
    .target Priestess Maelah Sunsworn
    .turnin 41228 >> Turn in Blessed Elegant Letter
    >>Train your class spells

step << Rogue
    .goto Thalassian Highlands,46.25,86.69 >> Talk to |cRXP_FRIENDLY_Leela the Shadow|r
    .target Leela the Shadow
    .turnin 41229 >> Turn in Shady Letter
    >>Train your class spells

step << Warrior
    .goto Thalassian Highlands,46.28,86.62 >> Talk to |cRXP_FRIENDLY_Valanos Dawnfire|r
    .target Valanos Dawnfire
    .turnin 41230 >> Turn in Plain Letter
    >>Train your class spells

step << Hunter
    .goto Thalassian Highlands,46.53,84.37 >> Talk to |cRXP_FRIENDLY_Ranger Rubinah Sunsworn|r
    .target Ranger Rubinah Sunsworn
    .turnin 41231 >> Turn in Feathered Letter
    >>Train your class spells

step
    .goto Thalassian Highlands,47.34,84.18 >> Talk to |cRXP_FRIENDLY_Dalicia Sweetsilver|r
    .target Dalicia Sweetsilver
    .accept 41190 >> Accept Thalassian Goulash

step
    >>Kill |cRXP_ENEMY_Young Crimson Lynxes|r and |cRXP_ENEMY_Forest Hawkstriders|r for |cRXP_LOOT_Lynx Steaks|r and |cRXP_LOOT_Forest Hawkstrider Legs|r
    .goto Thalassian Highlands,46.60,76.50,35,0 >> Young Crimson Lynxes south of camp
    .goto Thalassian Highlands,47.40,70.90,35,0 >> Forest Hawkstriders farther south
    .complete 41189,1 --Kill Young Crimson Lynx (x12)
    .collect 41119,6 --Collect Forest Hawkstrider Leg (x6)
    .collect 41120,8 --Collect Lynx Steak (x8)
    .mob Young Crimson Lynx
    .mob Forest Hawkstrider

step
    .goto Thalassian Highlands,47.21,79.08 >> Talk to |cRXP_FRIENDLY_Avenant|r
    .target Avenant
    .accept 41191 >> Accept A Crown of Flowers

step
    >>Collect 10 |cRXP_LOOT_Thalassian Daisies|r
    .goto Thalassian Highlands,48.60,82.30,25,0 >> Thalassian Daisy clusters around the camp
    .collect 41121,10 --Collect Thalassian Daisies (x10)

step
    .goto Thalassian Highlands,46.61,86.96 >> Talk to |cRXP_FRIENDLY_Ranathir|r
    .target Ranathir
    .accept 41196 >> Accept Maddening Hunger

step
    >>Loot a |cRXP_LOOT_Charged Arcane Crystal|r
    .goto Thalassian Highlands,42.50,79.70,25,0 >> Arcane Crystal Packages west of Brinthilien
    .collect 41123,1 --Collect Charged Arcane Crystal (x1)

step
    .goto Thalassian Highlands,47.80,84.08 >> Talk to |cRXP_FRIENDLY_Phylas Hawkwing|r
    .target Phylas Hawkwing
    .accept 41192 >> Accept Arcane Golem Revolt

step
    >>Kill the arcane golems
    .goto Thalassian Highlands,41.40,78.40,25,0 >> Malfunctioning Arcane Golems
    .goto Thalassian Highlands,40.70,82.70,25,0 >> Defective Arcane Golems and Arcane Pounders
    .complete 41192,1 --Kill Malfunctioning Arcane Golem (x8)
    .complete 41192,2 --Kill Defective Arcane Golem (x6)
    .complete 41192,3 --Kill Arcane Pounder (x4)
    .mob Malfunctioning Arcane Golem
    .mob Defective Arcane Golem
    .mob Arcane Pounder

step
    .goto Thalassian Highlands,47.34,84.18 >> Turn in to |cRXP_FRIENDLY_Dalicia Sweetsilver|r
    .target Dalicia Sweetsilver
    .turnin 41190 >> Turn in Thalassian Goulash

step
    .goto Thalassian Highlands,47.21,79.08 >> Turn in to |cRXP_FRIENDLY_Avenant|r
    .target Avenant
    .turnin 41191 >> Turn in A Crown of Flowers

step
    .goto Thalassian Highlands,46.61,86.96 >> Turn in to |cRXP_FRIENDLY_Ranathir|r
    .target Ranathir
    .turnin 41196 >> Turn in Maddening Hunger

step
    .goto Thalassian Highlands,47.80,84.08 >> Turn in to |cRXP_FRIENDLY_Phylas Hawkwing|r
    .target Phylas Hawkwing
    .turnin 41192 >> Turn in Arcane Golem Revolt

step
    .goto Thalassian Highlands,48.56,83.64 >> Turn in to |cRXP_FRIENDLY_Commander Anarileth|r
    .target Commander Anarileth
    .turnin 41189 >> Turn in Safety for Refugees
    .accept 41193 >> Accept A Troubling Presence

step
    >>Kill |cRXP_ENEMY_Blood Elf Spies|r and |cRXP_ENEMY_Veloren Brightstar|r, then loot the |cRXP_LOOT_Feltouched Letter|r
    .goto Thalassian Highlands,53.30,74.40,25,0 >> Blood Elf Spy camp east of Brinthilien
    .goto Thalassian Highlands,52.79,74.69 >> Veloren Brightstar
    .complete 41193,1 --Kill Blood Elf Spy (x8)
    .complete 41193,2 --Kill Veloren Brightstar (x1)
    .collect 41122,1 --Collect Feltouched Letter (x1)
    .accept 41194 >> Accept A Letter from the Royalty
    .mob Blood Elf Spy
    .mob Veloren Brightstar

step
    .goto Thalassian Highlands,48.56,83.64 >> Return to |cRXP_FRIENDLY_Commander Anarileth|r
    .target Commander Anarileth
    .turnin 41193 >> Turn in A Troubling Presence
    .turnin 41194 >> Turn in A Letter from the Royalty
    .accept 41195 >> Accept Message for the Windrunner

step
    .goto Thalassian Highlands,48.84,80.36 >> Talk to |cRXP_FRIENDLY_Solenia Solarcrest|r
    .target Solenia Solarcrest
    .accept 41197 >> Accept Delivery to Alah'Thalas

step
    .goto Alah'Thalas,59.69,61.47 >> Talk to |cRXP_FRIENDLY_Vereesa Windrunner|r
    .target Vereesa Windrunner
    .turnin 41195 >> Turn in Message for the Windrunner
    .accept 41236 >> Accept The Silver Covenant

step
    .goto Alah'Thalas,36.41,76.84 >> Turn in to |cRXP_FRIENDLY_Tiriel Brightwater|r
    .target Tiriel Brightwater
    .turnin 41197 >> Turn in Delivery to Alah'Thalas

step
    .goto Thalassian Highlands,44.16,57.74 >> Turn in to |cRXP_FRIENDLY_Commander Braedin|r
    .target Commander Braedin
    .turnin 41236 >> Turn in The Silver Covenant
    .accept 41219 >> Accept Wyrms of the Highlands

step
    >>Kill |cRXP_ENEMY_Brilliant Mana Wyrms|r for |cRXP_LOOT_Mana Wyrm Eyes|r
    .goto Thalassian Highlands,44.94,58.88,25,0 >> Mana Wyrms around the Silver Covenant Camp
    .collect 41165,10 --Collect Mana Wyrm Eye (x10)
    .mob Brilliant Mana Wyrm

step
    .goto Thalassian Highlands,44.16,57.74 >> Turn in to |cRXP_FRIENDLY_Commander Braedin|r
    .target Commander Braedin
    .turnin 41219 >> Turn in Wyrms of the Highlands

step
    .goto Thalassian Highlands,26.76,25.44 >> Talk to |cRXP_FRIENDLY_Warden Sira Moonwarden|r
    .target Warden Sira Moonwarden
    .accept 41245 >> Accept All Along the Farstride

step
    >>Kill |cRXP_ENEMY_Farstride Netters|r and |cRXP_ENEMY_Farstride Coastrunners|r
    .goto Thalassian Highlands,36.46,41.30,30,0 >> Farstride coast
    .complete 41245,1 --Kill Farstride Netter (x8)
    .complete 41245,2 --Kill Farstride Coastrunner (x8)
    .mob Farstride Netter
    .mob Farstride Coastrunner

step
    .goto Thalassian Highlands,26.76,25.44 >> Turn in to |cRXP_FRIENDLY_Warden Sira Moonwarden|r
    .target Warden Sira Moonwarden
    .turnin 41245 >> Turn in All Along the Farstride
    .accept 41248 >> Accept Naga All Along

step
    >>Kill |cRXP_ENEMY_Reefscale Nagas|r for |cRXP_LOOT_Reefscale Naga Scales|r
    .goto Thalassian Highlands,20.06,48.15,30,0 >> Reefscale Nagas on the southern coast
    .collect 41198,9 --Collect Reefscale Naga Scale (x9)
    .mob Reefscale Sunderer
    .mob Reefscale Sorceress
    .mob Reefscale Warrior

step
    .goto Thalassian Highlands,26.76,25.44 >> Turn in to |cRXP_FRIENDLY_Warden Sira Moonwarden|r
    .target Warden Sira Moonwarden
    .turnin 41248 >> Turn in Naga All Along
    .accept 41249 >> Accept Leaders of the Reefscale

step
    >>Kill the |cRXP_ENEMY_Reefscale leaders|r and |cRXP_ENEMY_Reefscale Sunderers|r
    .goto Thalassian Highlands,16.83,42.11,25,0 >> Lady Renirja
    .goto Thalassian Highlands,13.67,50.77,25,0 >> Lord Vash'arj
    .complete 41249,1 --Kill Reefscale Sunderer (x7)
    .complete 41249,2 --Kill Lord Vash'arj (x1)
    .complete 41249,3 --Kill Lady Renirja (x1)
    .mob Reefscale Sunderer
    .mob Lord Vash'arj
    .mob Lady Renirja

step
    .goto Thalassian Highlands,26.76,25.44 >> Turn in to |cRXP_FRIENDLY_Warden Sira Moonwarden|r
    .target Warden Sira Moonwarden
    .turnin 41249 >> Turn in Leaders of the Reefscale

step
    .goto Thalassian Highlands,48.10,82.00,40,0 >> Grind to level 10
    .xp 10
]],
  "H-Turtle-Alliance-1-10_HighElf"
)
