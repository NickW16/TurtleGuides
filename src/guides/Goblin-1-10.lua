-- guide data adapted from RestedXP Guides by RestedXP (RXPGuides).
-- source: https://github.com/RestedXP/RXPGuides
-- licensed under CC BY-NC-SA 4.0: https://creativecommons.org/licenses/by-nc-sa/4.0/
-- modified for Turtle WoW 1.12.1, with syntax and route adjustments.
-- goblin 1-10 starter route
-- luacheck: ignore 621
local TG = _G.TurtleGuides
TG:RegisterGuideText(
  [[
#classic
<< Horde
#name 1-10 Blackstone Island
#version 1
#group Turtle Guides (H)
#subgroup Blackstone Island
#defaultfor Goblin
#next 10-16 Durotar

step
    >>Talk to Kazznik and Overseer Kizzcrack
    .goto Blackstone Island,36.5,62.9
    .target Kazznik
    .accept 80120 >> Accept Garbage Man
    .goto Blackstone Island,35.6,63.0
    .target Overseer Kizzcrack
    .accept 41154 >> Accept Pit-Iful Work
    .accept 41155 >> Accept The Robotics Expert
    .accept 41156 >> Accept Foreman's Blues
    .accept 41157 >> Accept Delayed Shipments

step
    >>Collect 8 Trash and 10 Coal
    .goto Blackstone Island,35.8,63.0,30,0
    .complete 80120,1 --Collect Trash (x8)
    .complete 41154,1 --Collect Coal (x10)

step
    >>Turn in Pit-Iful Work and Garbage Man
    .goto Blackstone Island,35.6,63.0
    .target Overseer Kizzcrack
    .turnin 41154 >> Turn in Pit-Iful Work
    .goto Blackstone Island,36.5,62.9
    .target Kazznik
    .turnin 80120 >> Turn in Garbage Man
    .goto Blackstone Island,37.5,62.8
    .target Balnack Copperlight
    .turnin 41155 >> Turn in The Robotics Expert
    .accept 41150 >> Accept Defunct Mainframes
    .accept 41151 >> Accept Haywire Havoc
    .goto Blackstone Island,37.5,67.9
    .target Foreman Pipelatch
    .turnin 41156 >> Turn in Foreman's Blues
    .accept 41153 >> Accept Foreman Pipelatch

step
    >>Collect 6 Defunct Mainframes, then kill 8 Haywire Battlechickens
    .goto Blackstone Island,35.0,64.5,35,0
    .complete 41150,1 --Collect Defunct Mainframe (x6)
    .goto Blackstone Island,35.0,66.5,35,0
    .complete 41151,1 --Kill Haywire Battlechicken (x8)
    .mob Haywire Battlechicken

step
    >>Kill 10 Ashfeather Scavengers
    .goto Blackstone Island,37.0,74.0,40,0
    .complete 41153,1 --Kill Ashfeather Scavenger (x10)
    .mob Ashfeather Scavenger
    .goto Blackstone Island,37.5,67.9
    .target Foreman Pipelatch
    .turnin 41153 >> Turn in Foreman Pipelatch

step
    >>Turn in Defunct Mainframes and Haywire Havoc
    .goto Blackstone Island,37.5,62.8
    .target Balnack Copperlight
    .turnin 41150 >> Turn in Defunct Mainframes
    .turnin 41151 >> Turn in Haywire Havoc
    .accept 41152 >> Accept DV-500

step
    >>Kill DV-500, collect the Advanced Processing Unit, then turn in DV-500
    .goto Blackstone Island,38.0,60.0,30,0
    .complete 41152,1 --Collect Advanced Processing Unit (x1)
    .mob DV-500
    .goto Blackstone Island,37.5,62.8
    .target Balnack Copperlight
    .turnin 41152 >> Turn in DV-500

step
    >>Talk to Dazlon Brassdigger and Ranala Greedvolt
    .goto Blackstone Island,34.8,78.3
    .target Dazlon Brassdigger
    .turnin 41157 >> Turn in Delayed Shipments
    .accept 41158 >> Accept Revenge of the Deep
    .accept 41159 >> Accept Dirty Deeds Drowned Deep Below
    .goto Blackstone Island,35.1,78.1
    .target Ranala Greedvolt
    .accept 41160 >> Accept Under The Sea

step
    >>Kill 8 Stoneshell Makrura and 8 Stoneshell Scrabblers, then loot the logbook and stash
    .goto Blackstone Island,31.5,90.0,45,0
    .complete 41158,1 --Kill Stoneshell Makrura (x8)
    .complete 41158,2 --Kill Stoneshell Scrabbler (x8)
    .mob Stoneshell Makrura
    .mob Stoneshell Scrabbler
    .goto Blackstone Island,34.0,86.0,35,0
    .complete 41159,1 --Collect Hangmans Plunder's Logbook (x1)
    .complete 41160,1 --Collect Ranala's Sunken Stash (x1)

step
    >>Turn in Revenge of the Deep, Dirty Deeds Drowned Deep Below and Under The Sea
    .goto Blackstone Island,34.8,78.3
    .target Dazlon Brassdigger
    .turnin 41158 >> Turn in Revenge of the Deep
    .turnin 41159 >> Turn in Dirty Deeds Drowned Deep Below
    .goto Blackstone Island,35.1,78.1
    .target Ranala Greedvolt
    .turnin 41160 >> Turn in Under The Sea

step
    >>Talk to Taxxlo Rustgate, Supplymaster Maxlo and Supervisor Ozzick
    .goto Blackstone Island,48.2,67.6
    .target Taxxlo Rustgate
    .accept 41169 >> Accept Bearer Of Bad News
    .accept 41171 >> Accept Searching Wreckage
    .accept 41172 >> Accept War on Venture Co.
    .goto Blackstone Island,47.5,68.5
    .target Supplymaster Maxlo
    .accept 41164 >> Accept Salvaging Convoys
    .accept 41166 >> Accept Redistribution
    .accept 41165 >> Accept Dry As A Desert
    .goto Blackstone Island,48.9,64.2
    .target Supervisor Ozzick
    .accept 41264 >> Accept Disruption at Black Ash Mine
    .accept 41265 >> Accept Disruption at Rustgate Lumber Yard

step
    >>Fly to Sparkwater Port, turn in Bearer Of Bad News, then return to Taxxlo Rustgate
    .goto Blackstone Island,61.3,84.5
    .target Gazzik
    .goto Durotar,58.7,26.4
    .target Grand Taskmaster Nert Blastentom
    .turnin 41169 >> Turn in Bearer Of Bad News
    .accept 41170 >> Accept Solutions On Their Way
    .goto Blackstone Island,48.2,67.6
    .target Taxxlo Rustgate
    .turnin 41170 >> Turn in Solutions On Their Way

step
    >>Kill 8 Malfunctioning Mine-Bots and collect 8 Mining Supplies
    .goto Blackstone Island,48.9,65.4
    .target Technician Reyvo
    .accept 41174 >> Accept Workplace Hazard
    .goto Blackstone Island,49.6,63.1
    .target Mining Foreman Bizzlo
    .accept 41175 >> Accept Mudpaw Mining Mishap
    .goto Blackstone Island,37.0,69.0,40,0
    .complete 41174,1 --Kill Malfunctioning Mine-Bot (x8)
    .mob Malfunctioning Mine-Bot
    .goto Blackstone Island,57.0,59.5,40,0
    .complete 41175,1 --Collect Mining Supplies (x8)
    .mob Mudpaw Miner

step
    >>Turn in Workplace Hazard and Mudpaw Mining Mishap
    .goto Blackstone Island,48.9,65.4
    .target Technician Reyvo
    .turnin 41174 >> Turn in Workplace Hazard
    .goto Blackstone Island,49.6,63.1
    .target Mining Foreman Bizzlo
    .turnin 41175 >> Turn in Mudpaw Mining Mishap
    .goto Blackstone Island,64.3,83.1
    .target Fanzo Edgeline
    .accept 41161 >> Accept The Supercutter 1500
    .accept 41162 >> Accept Clearing Nuisances
    .goto Blackstone Island,61.3,84.5
    .target Gazzik
    .accept 41163 >> Accept Battletron Calamity
    .goto Blackstone Island,63.0,77.7
    .target Schera Framesnap
    .accept 41176 >> Accept She Sells Sea Shells
    .goto Blackstone Island,62.0,83.5
    .target Bruiser Rakklan
    .accept 41167 >> Accept The Murloc Threat

step
    >>Collect the Supercutter Remote, kill 8 Ashfeather Swoopers, 8 Blackvenom Scorpids and 10 Faulty Battletrons
    .goto Blackstone Island,64.0,80.0,30,0
    .complete 41161,1 --Collect Supercutter 1500 Remote (x1)
    .goto Blackstone Island,56.5,73.0,35,0
    .complete 41162,1 --Kill Ashfeather Swooper (x8)
    .complete 41162,2 --Kill Blackvenom Scorpid (x8)
    .mob Ashfeather Swooper
    .mob Blackvenom Scorpid
    .goto Blackstone Island,46.0,77.5,40,0
    .complete 41163,1 --Kill Faulty Battletron 1000 (x10)
    .mob Faulty Battletron 1000

step
    >>Collect 20 Blackstone Sea Shells and 20 Muckfin Scales
    .goto Blackstone Island,64.0,72.0,40,0
    .complete 41176,1 --Collect Blackstone Sea Shell (x20)
    .goto Blackstone Island,58.0,88.0,50,0
    .complete 41167,1 --Collect Muckfin Scale (x20)
    .mob Muckfin Murloc
    .mob Muckfin Trapper
    .mob Muckfin Tidecaller
    .goto Blackstone Island,64.3,83.1
    .target Fanzo Edgeline
    .turnin 41161 >> Turn in The Supercutter 1500
    .turnin 41162 >> Turn in Clearing Nuisances
    .goto Blackstone Island,61.3,84.5
    .target Gazzik
    .turnin 41163 >> Turn in Battletron Calamity
    .goto Blackstone Island,63.0,77.7
    .target Schera Framesnap
    .turnin 41176 >> Turn in She Sells Sea Shells
    .goto Blackstone Island,62.0,83.5
    .target Bruiser Rakklan
    .turnin 41167 >> Turn in The Murloc Threat

step
    >>Talk to Shazzlan
    .goto Blackstone Island,48.5,69.2
    .target Shazzlan
    .accept 41168 >> Accept Maritime Gumbo

step
    >>Collect 13 Rustgate Tools and the Crate of Rebalanced Frameworks, then kill Venture Co. Lumber Workers and Cartographers
    .goto Blackstone Island,55.0,64.0,50,0
    .complete 41164,1 --Collect Rustgate Tool (x13)
    .goto Blackstone Island,61.5,83.0,25,0
    .complete 41166,1 --Collect Crate of Rebalanced Frameworks (x1)
    .goto Blackstone Island,61.0,64.0,40,0
    .complete 41265,1 --Kill Venture Co. Lumber Worker (x8)
    .complete 41265,2 --Kill Venture Co. Cartographer (x8)
    .mob Venture Co. Lumber Worker
    .mob Venture Co. Cartographer

step
    >>Collect 8 Crawler Meat and 6 Makrura Legs, then turn in the Rustgate quests
    .goto Blackstone Island,50.0,82.0,40,0
    .complete 41168,1 --Collect Crawler Meat (x8)
    .complete 41168,2 --Collect Makrura Leg (x6)
    .mob Makrura
    .goto Blackstone Island,48.5,69.2
    .target Shazzlan
    .turnin 41168 >> Turn in Maritime Gumbo
    .goto Blackstone Island,47.5,68.5
    .target Supplymaster Maxlo
    .turnin 41164 >> Turn in Salvaging Convoys
    .turnin 41166 >> Turn in Redistribution
    .goto Blackstone Island,48.9,64.2
    .target Supervisor Ozzick
    .turnin 41265 >> Turn in Disruption at Rustgate Lumber Yard

step
    >>Collect the Venture Co. Logbook and 14 Venture Co. Medallions
    .goto Blackstone Island,50.0,86.0,40,0
    .complete 41171,1 --Collect Venture Co. Logbook (x1)
    .goto Blackstone Island,60.0,60.0,45,0
    .complete 41172,1 --Collect Venture Co. Medallion (x14)
    .mob Venture Co. Traitor
    .goto Blackstone Island,48.2,67.6
    .target Taxxlo Rustgate
    .turnin 41171 >> Turn in Searching Wreckage
    .turnin 41172 >> Turn in War on Venture Co.
    .accept 41173 >> Accept Destroying Venture Co. Leadership

step
    >>Kill Gelwex Goldfingers and Dex, then turn in Destroying Venture Co. Leadership
    .goto Blackstone Island,53.2,29.3
    .complete 41173,1 --Collect Gelwex' Head (x1)
    .mob Gelwex Goldfingers
    .goto Blackstone Island,55.0,30.0,35,0
    .complete 41173,2 --Collect Dex' Head (x1)
    .mob Dex
    .goto Blackstone Island,48.2,67.6
    .target Taxxlo Rustgate
    .turnin 41173 >> Turn in Destroying Venture Co. Leadership

step
    >>Talk to Pumpworker Fizzlo, Pumpmaster Galvax and Bruiser Yevo
    .goto Blackstone Island,49.5,24.8
    .target Pumpworker Fizzlo
    .accept 41183 >> Accept Ashen Pelts
    .goto Blackstone Island,58.5,25.0
    .target Pumpmaster Galvax
    .turnin 41165 >> Turn in Dry As A Desert
    .accept 41184 >> Accept Right From Under My Green Nose
    .goto Blackstone Island,57.7,25.4
    .target Bruiser Yevo
    .accept 41185 >> Accept War On Mudpaw
    .accept 41186 >> Accept Grabb Mudhide

step
    >>Collect 6 Ashpaw Pelts, 15 Mudpaw Armbands, the Paw of Grabb Mudhide and Rustgate's Water Shipment
    .goto Blackstone Island,50.0,45.0,40,0
    .complete 41183,1 --Collect Ashpaw Pelt (x6)
    .mob Ashpaw Hyena
    .mob Ashpaw Hunter
    .goto Blackstone Island,57.0,55.0,40,0
    .complete 41185,1 --Collect Mudpaw Armband (x15)
    .mob Mudpaw Miner
    .goto Blackstone Island,58.6,37.7
    .complete 41186,1 --Collect Paw of Grabb Mudhide (x1)
    .mob Grabb Mudhide
    .goto Blackstone Island,56.0,30.0,35,0
    .complete 41184,1 --Collect Rustgate's Water Shipment (x1)

step
    >>Turn in Ashen Pelts, War On Mudpaw, Grabb Mudhide and Right From Under My Green Nose
    .goto Blackstone Island,49.5,24.8
    .target Pumpworker Fizzlo
    .turnin 41183 >> Turn in Ashen Pelts
    .goto Blackstone Island,57.7,25.4
    .target Bruiser Yevo
    .turnin 41185 >> Turn in War On Mudpaw
    .turnin 41186 >> Turn in Grabb Mudhide
    .goto Blackstone Island,47.5,68.5
    .target Supplymaster Maxlo
    .turnin 41184 >> Turn in Right From Under My Green Nose

step
    >>Kill Supervisor Laggle, then turn in Disruption at Black Ash Mine and The Big Man
    .goto Blackstone Island,62.0,58.0,30,0
    .complete 41264,1 --Kill Supervisor Laggle (x1)
    .mob Supervisor Laggle
    .goto Blackstone Island,48.9,64.2
    .target Supervisor Ozzick
    .turnin 41264 >> Turn in Disruption at Black Ash Mine
    .accept 41266 >> Accept The Big Man
    .goto Blackstone Island,48.2,67.6
    .target Taxxlo Rustgate
    .turnin 41266 >> Turn in The Big Man

step
    *Once the Union work is finished, take the flying machine from Gazzik's Workshop to Sparkwater Port. Durotar has the next stretch of quests waiting.
    .goto Blackstone Island,45.0,55.0,60,0
    .mob Mudpaw Miner
    .mob Venture Co. Traitor
    .xp 10
]],
  "Goblin-1-10"
)
