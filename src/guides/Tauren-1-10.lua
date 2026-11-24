-- tauren 1-10 starter route
-- luacheck: ignore 621
local TG = _G.TurtleGuides
TG:RegisterGuideText(
  [[
#classic
<< Horde
#name 1-10 Mulgore
#version 1
#group Turtle Guides (H)
#subgroup Mulgore
#defaultfor Tauren
#next 10-16 The Barrens

step
    >>Talk to Grull Hawkwind and Chief Hawkwind
    .goto Mulgore,44.9,77.1
    .target Grull Hawkwind
    .accept 747 >> Accept The Hunt Begins
    .goto Mulgore,44.2,76.1
    .target Chief Hawkwind
    .accept 752 >> Accept A Humble Task

step
    >>Turn in A Humble Task to Greatmother Hawkwind and collect the Water Pitcher
    .goto Mulgore,50.0,81.2
    .target Greatmother Hawkwind
    .turnin 752 >> Turn in A Humble Task
    .accept 753 >> Accept A Humble Task
    .goto Mulgore,50.2,81.4
    .complete 753,1 --Collect Water Pitcher (x1)

step
    >>Talk to Brave Windfeather and Grull Hawkwind
    .goto Mulgore,44.7,76.7
    .target Brave Windfeather
    .accept 3376 >> Accept Break Sharptusk!
    .goto Mulgore,44.9,77.1
    .target Grull Hawkwind
    .turnin 747 >> Turn in The Hunt Begins
    .accept 750 >> Accept The Hunt Continues
    .accept 780 >> Accept The Battleboars
    .accept 763 >> Accept Rites of the Earthmother

step
    >>Kill 7 Plainstriders, 10 Mountain Cougars, 8 Battleboars and Sharptusk
    .goto Mulgore,48.0,77.0,45,0
    .complete 747,1 --Collect Plainstrider Meat (x7)
    .complete 747,2 --Collect Plainstrider Feather (x7)
    .complete 750,1 --Collect Mountain Cougar Pelt (x10)
    .complete 780,1 --Kill Battleboar (x8)
    .complete 3376,1 --Kill Sharptusk (x1)
    .mob Plainstrider
    .mob Mountain Cougar
    .mob Battleboar
    .target Sharptusk

step
    >>Turn in the hunting quests to Grull, Brave Windfeather, Greatmother Hawkwind and Chief Hawkwind
    .goto Mulgore,44.9,77.1
    .target Grull Hawkwind
    .turnin 750 >> Turn in The Hunt Continues
    .turnin 780 >> Turn in The Battleboars
    .goto Mulgore,44.7,76.7
    .target Brave Windfeather
    .turnin 3376 >> Turn in Break Sharptusk!
    .goto Mulgore,50.0,81.2
    .target Greatmother Hawkwind
    .turnin 753 >> Turn in A Humble Task
    .goto Mulgore,44.2,76.1
    .target Chief Hawkwind
    .turnin 763 >> Turn in Rites of the Earthmother

step
    >>Talk to Baine Bloodhoof, Ruul Eagletalon, Mull Thunderhorn, Harken Windtotem, Maur Raincaller and Antur Fallow
    .goto Mulgore,47.5,60.2
    .target Baine Bloodhoof
    .accept 745 >> Accept Sharing the Land
    .accept 767 >> Accept Rite of Vision
    .accept 746 >> Accept Dwarven Digging
    .goto Mulgore,47.4,62.0
    .target Ruul Eagletalon
    .accept 743 >> Accept Dangers of the Windfury
    .goto Mulgore,48.5,60.4
    .target Mull Thunderhorn
    .accept 748 >> Accept Poison Water
    .goto Mulgore,48.7,59.3
    .target Harken Windtotem
    .accept 761 >> Accept Swoop Hunting
    .goto Mulgore,47.0,57.1
    .target Maur Raincaller
    .accept 766 >> Accept Mazzranache
    .goto Mulgore,38.5,81.5
    .target Antur Fallow
    .accept 1656 >> Accept A Task Unfinished

step
    >>Kill Venture Co. Workers, Windfury Harpies, Swoops and Mazzranache
    .goto Mulgore,51.0,58.0,50,0
    .complete 745,1 --Kill Venture Co. Worker (x10)
    .complete 767,1 --Kill Venture Co. Mechanic (x1)
    .complete 746,1 --Collect Dwarven Digging Equipment (x1)
    .complete 743,1 --Kill Windfury Harpy (x10)
    .complete 748,1 --Collect Creek Water Sample (x3)
    .complete 761,1 --Kill Swoop (x12)
    .complete 766,1 --Kill Mazzranache (x1)
    .mob Venture Co. Worker
    .mob Windfury Harpy
    .mob Swoop
    .target Mazzranache

step
    >>Turn in the Bloodhoof quests
    .goto Mulgore,47.5,60.2
    .target Baine Bloodhoof
    .turnin 745 >> Turn in Sharing the Land
    .turnin 767 >> Turn in Rite of Vision
    .turnin 746 >> Turn in Dwarven Digging
    .goto Mulgore,47.4,62.0
    .target Ruul Eagletalon
    .turnin 743 >> Turn in Dangers of the Windfury
    .goto Mulgore,48.5,60.4
    .target Mull Thunderhorn
    .turnin 748 >> Turn in Poison Water
    .goto Mulgore,48.7,59.3
    .target Harken Windtotem
    .turnin 761 >> Turn in Swoop Hunting
    .goto Mulgore,47.0,57.1
    .target Maur Raincaller
    .turnin 766 >> Turn in Mazzranache

step
    >>Talk to Zarlman Two-Moons, Mull Thunderhorn and Baine Bloodhoof
    .goto Mulgore,47.8,57.5
    .target Zarlman Two-Moons
    .accept 771 >> Accept Rite of Vision
    .turnin 771 >> Turn in Rite of Vision
    .accept 772 >> Accept Rite of Vision
    .goto Mulgore,48.5,60.4
    .target Mull Thunderhorn
    .accept 754 >> Accept Winterhoof Cleansing
    .accept 756 >> Accept Thunderhorn Totem
    .accept 758 >> Accept Thunderhorn Cleansing
    .goto Mulgore,47.5,60.2
    .target Baine Bloodhoof
    .accept 759 >> Accept Wildmane Totem

step
    >>Cleanse the water holes, place the totems and complete the vision quest
    .goto Mulgore,49.0,53.0,50,0
    .complete 754,1 --Cleanse the Winterhoof Water Hole
    .complete 756,1 --Place Thunderhorn Totem
    .complete 758,1 --Cleanse the Thunderhorn Water Hole
    .complete 759,1 --Place Wildmane Totem
    .complete 772,1 --Complete the vision quest
    .mob Winterhoof Water Elemental
    .mob Thunderhorn Water Elemental

step
    >>Turn in the totem quests and talk to Skorn Whitecloud
    .goto Mulgore,48.5,60.4
    .target Mull Thunderhorn
    .turnin 754 >> Turn in Winterhoof Cleansing
    .turnin 756 >> Turn in Thunderhorn Totem
    .turnin 758 >> Turn in Thunderhorn Cleansing
    .accept 760 >> Accept Wildmane Cleansing
    .goto Mulgore,47.5,60.2
    .target Baine Bloodhoof
    .turnin 759 >> Turn in Wildmane Totem
    .goto Mulgore,47.8,57.5
    .target Zarlman Two-Moons
    .turnin 772 >> Turn in Rite of Vision
    .goto Mulgore,46.8,60.2
    .target Skorn Whitecloud
    .accept 861 >> Accept The Hunter's Way

step
    >>Talk to Seer Wiserunner, Lorekeeper Raintotem and the Ancestral Spirit
    .goto Mulgore,32.7,36.1
    .target Seer Wiserunner
    .accept 773 >> Accept Rite of Wisdom
    .goto Mulgore,59.9,25.6
    .target Lorekeeper Raintotem
    .accept 833 >> Accept A Sacred Burial
    .goto Mulgore,61.5,21.0
    .target Ancestral Spirit
    .accept 775 >> Accept Journey into Thunder Bluff
    .collect 4854,1 --Collect Demon Scarred Cloak (x1)
    .accept 770 >> Accept The Demon Scarred Cloak

step
    >>Collect the Dirt-Stained Map, defeat the gnoll attackers and talk to Innkeeper Kauth
    .goto Mulgore,63.2,82.7,40,0
    .collect 4851,1 --Collect Dirt-Stained Map (x1)
    .accept 781 >> Accept Attack on Camp Narache
    .complete 781,1 --Defeat the gnoll attackers
    .goto Mulgore,46.6,61.1
    .target Innkeeper Kauth
    .turnin 1656 >> Turn in A Task Unfinished
    .turnin 781 >> Turn in Attack on Camp Narache

step
    >>Collect the Mysterious Leaf and talk to Gennia Runetotem, Melyndella and Vira Younghoof
    .goto Mulgore,52.0,66.0,40,0
    .complete 40583,1 --Collect Mysterious Leaf (x1)
    .accept 40583 >> Accept A Curious Leaf
    .goto Mulgore,48.5,59.6
    .target Gennia Runetotem
    .turnin 40583 >> Turn in A Curious Leaf
    .accept 40584 >> Accept A Dryad in Mulgore
    .accept 40365 >> Accept A Trial of Sincerity
    .goto Mulgore,59.1,54.3
    .target Melyndella
    .turnin 40584 >> Turn in A Dryad in Mulgore
    .accept 40585 >> Accept A Quest For an Antidote
    .goto Mulgore,46.8,60.8
    .target Vira Younghoof
    .turnin 40585 >> Turn in A Quest For an Antidote
    .accept 40587 >> Accept A Dryad's Gratitude
    .goto Mulgore,59.1,54.3
    .target Melyndella
    .turnin 40587 >> Turn in A Dryad's Gratitude

step
    >>Collect 8 Prairie Stalker Pelts and turn in to Kherra and Gennia Runetotem
    .goto Mulgore,56.0,52.0,45,0
    .complete 40365,1 --Collect Prairie Stalker Pelt (x8)
    .mob Prairie Stalker
    .goto Mulgore,58.4,58.8
    .target Kherra
    .turnin 40365 >> Turn in A Trial of Sincerity
    .accept 40366 >> Accept An Earnest Offering
    .goto Mulgore,48.5,59.6
    .target Gennia Runetotem
    .turnin 40366 >> Turn in An Earnest Offering

step
    >>Turn in the remaining quests at Bloodhoof, Seer Wiserunner, Lorekeeper Raintotem and the Ancestral Spirit
    .goto Mulgore,48.5,60.4
    .target Mull Thunderhorn
    .turnin 760 >> Turn in Wildmane Cleansing
    .goto Mulgore,32.7,36.1
    .target Seer Wiserunner
    .turnin 773 >> Turn in Rite of Wisdom
    .goto Mulgore,59.9,25.6
    .target Lorekeeper Raintotem
    .turnin 833 >> Turn in A Sacred Burial
    .goto Mulgore,61.5,21.0
    .target Ancestral Spirit
    .turnin 775 >> Turn in Journey into Thunder Bluff
    .goto Mulgore,46.8,60.2
    .target Skorn Whitecloud
    .turnin 861 >> Turn in The Hunter's Way

step
    >>Grind to level 10
    .goto Mulgore,55.0,48.0,50,0
    .complete 770,1 --Kill Demon Scarred Harpies (x1)
    .mob Plainstrider
    .mob Harvest Watcher
    .xp 10
]],
  "Tauren-1-10"
)
