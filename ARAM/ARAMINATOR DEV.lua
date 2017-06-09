--if Game.mapID ~= HOWLING_ABYSS then return end

local lolVersion = "7.10"
local scrVersion = "0.5.56 Pre-Beta" 

ARAMinator = true -- <--- check this variable to check if ARAMinator is running

local menuIcon = "http://i.imgur.com/9FyhHk4.jpg"
local PMenu = MenuElement({type = MENU, id = "PMenu", name = "ARAM-inator! | Beta", leftIcon = menuIcon})
PMenu:MenuElement({id = "Enabled", name = "Enabled", value = true})

PMenu:MenuElement({type = MENU, id = "ARAM", name = "ARAM Settings"})

PMenu:MenuElement({type = MENU, id = "Drawing", name = "Drawing Settings"})
PMenu.Drawing:MenuElement({id = "Enabled", name = "Enable Drawing", value = true})
PMenu.Drawing:MenuElement({id = "Start", name = "Draw Start Timer/Intro", value = true})
PMenu.Drawing:MenuElement({id = "Target", name = "Draw Current Target", value = true})
PMenu.Drawing:MenuElement({id = "Defense", name = "Draw Current Defense Area", value = true})
PMenu.Drawing:MenuElement({id = "Teammates", name = "Draw Current Helped Teammates", value = true})
PMenu.Drawing:MenuElement({id = "RUN", name = "Draw RUN IT DOWN MID!", value = true})
PMenu.Drawing:MenuElement({id = "Items", name = "Draw Items to Buy", value = true})
PMenu.Drawing:MenuElement({id = "Turret", name = "Draw Turret defense area", value = true})

PMenu:MenuElement({type = MENU, id = "Performance", name = "Performance Settings"})
PMenu.Performance:MenuElement({id = "Target", name = "Recalculate Target after X Ticks", value = 1, min = 1, max = 100, step = 1})

PMenu:MenuElement({type = MENU, id = "Humanizer", name = "Humanizer Settings"})
PMenu.Humanizer:MenuElement({id = "Start", name = "Start Timer Randomizer", value = 10, min = 0, max = 10, step = 1})

PMenu:MenuElement({type = MENU, id = "Debug", name = "Debug"})
PMenu.Debug:MenuElement({id = "Dump",name = "Debug Range", key = string.byte("H")})
PMenu.Debug:MenuElement({id = "LK",name = "Debug LK", key = string.byte("N")})
PMenu.Debug:MenuElement({id = "RK",name = "Debug RK", key = string.byte("M")})


--vectors
local vecRedStart = {Vector(11587,-132,11717), Vector(11659,-132,11657), Vector(11505,-132,11405), Vector(11569,-132,11577), Vector(11781,-132,11781)}
local vecRedLeftBaseTurret = {
{Vector(11587,-132,11717), Vector(11659,-132,11657), Vector(11505,-132,11405), Vector(11569,-132,11577), Vector(11781,-132,11781), Vector(10505,-178,10917), Vector(10294,-181,11171)},
{Vector(11587,-132,11717), Vector(11659,-132,11657), Vector(11505,-132,11405), Vector(11569,-132,11577), Vector(11781,-132,11781), Vector(10505,-178,10917), Vector(10294,-181,11171), Vector(10691,-178,11144), Vector(10547,-178,10461)}
}
local vecRedRightBaseTurret = {

}


--
local vecBlueStart = {Vector(857,-132,1387), Vector(793,-132,1215), Vector(963,-129,1037), Vector(1116,-132,1330), Vector(1367,-132,1171)}
local vecBlueLeftBaseTurret = {
{Vector(857,-132,1387), Vector(793,-132,1215), Vector(963,-129,1037), Vector(1116,-132,1330), Vector(1367,-132,1171), Vector(1667,-178,2607), Vector(1801,-178,2459)},
{Vector(857,-132,1387), Vector(793,-132,1215), Vector(963,-129,1037), Vector(1116,-132,1330), Vector(1367,-132,1171), Vector(1667,-178,2607), Vector(1801,-178,2459), Vector(1439,-178,2618)}
}
local vecBlueRightBaseTurret = {
{Vector(857,-132,1387), Vector(793,-132,1215), Vector(963,-129,1037), Vector(1116,-132,1330), Vector(1367,-132,1171), Vector(1667,-178,2607), Vector(1801,-178,2459)},
{Vector(857,-132,1387), Vector(793,-132,1215), Vector(963,-129,1037), Vector(1116,-132,1330), Vector(1367,-132,1171), Vector(1667,-178,2607), Vector(1801,-178,2459)}
}
local vecBlueInnerTurret = {
{Vector(857,-132,1387), Vector(793,-132,1215), Vector(963,-129,1037), Vector(1116,-132,1330), Vector(1367,-132,1171), Vector(1667,-178,2607), Vector(1801,-178,2459)},
{Vector(857,-132,1387), Vector(793,-132,1215), Vector(963,-129,1037), Vector(1116,-132,1330), Vector(1367,-132,1171), Vector(1667,-178,2607), Vector(1801,-178,2459), Vector(1439,-178,2618)},
{Vector(857,-132,1387), Vector(793,-132,1215), Vector(963,-129,1037), Vector(1116,-132,1330), Vector(1367,-132,1171), Vector(1667,-178,2607), Vector(1801,-178,2459), Vector(1439,-178,2618), Vector(1609,-178,2987)}
}
local vecBlueOuterTurret = {
{Vector(857,-132,1387), Vector(793,-132,1215), Vector(963,-129,1037), Vector(1116,-132,1330), Vector(1367,-132,1171), Vector(1667,-178,2607), Vector(1801,-178,2459)},
{Vector(857,-132,1387), Vector(793,-132,1215), Vector(963,-129,1037), Vector(1116,-132,1330), Vector(1367,-132,1171), Vector(1667,-178,2607), Vector(1801,-178,2459)},
{Vector(857,-132,1387), Vector(793,-132,1215), Vector(963,-129,1037), Vector(1116,-132,1330), Vector(1367,-132,1171), Vector(1667,-178,2607), Vector(1801,-178,2459), Vector(1439,-178,2618)}
}

--vars
local rangeQ = nil
local rangeW = nil
local rangeE = nil
local rangeR = nil

--state vars
local state = 0
local moveState = -1
local fightArea = -1

--enums/constants (lua BS trickery)
--building constants
local const_MIDLANE = 0
local const_TURRET_OUTER = 1
local const_TURRET_INNER = 2
local const_INHIB = 3
local const_TURRET_NEXUS_1 = 4
local const_TURRET_NEXUS_2 = 5
local const_NEXUS = 6

--move types
local const_GOTO_TEAM = 7
local const_GOTO_TURRET = 8
local const_GOTO_INHIB = 9
local const_GOTO_NEXUS = 10

--fight types
local const_ATTACK = 11
local const_POKE = 12
local const_RUN = 13

--Build Types
local AD = 14
local AP = 15
local HYBRID = 16
local TANK = 17
local TANK_AD = 18
local TANK_AP = 19
local TANK_HP = 20

--spell types
local DAMAGE = 21
local HEAL = 22
local CC = 23
local VISION = 24
local TOGGLE = 25
local PASSIVE = 26
local GAPCLOSE = 27
local ESCAPE = 28
local PLACED = 29
local UNUSED = 30
local SPAM = 31
local SELFHEAL = 32

--turrets
local turretsBlue =  nil
local turretsRed = nil

--State Specific Vars
--0 (prep)
local timerValue = nil
local timerStart = nil
local timerEnd = nil
local ranged = false
local teamFriends = {}
local teamEnemys = {}
local resolution = nil
--1 (move)
local positionNext = nil
local positions = {}
--2 (attack)
local targetNext = nil
local targets = {}
local tarCount = 0
--3 (defense)
local currentTurret = nil
local defenseArea = nil
--4 (help team)
local helpedTeammates = {}
local helpPriorityOne = nil
--5 (buy/dead)
local build = {}
local nextItem = nil
--6 (run it down mid)
local midRunGold = 4500
--7 (other)

--8 buying item
local buyText = "LONG"
local nextLetter = 'L'
local letterCount = 0
local lettersTotal = 4
local letterEveryTicks = 5
local currentLetterTick = 0

-- class shit
local currentHeroData = nil

HeroData = {}
HeroData.__index = HeroData


function HeroData.create(name, buildStyle, customBuild) 
	local hdta = {}
	setmetatable(hdta,HeroData) 
	hdta.name = name      
	hdta.buildStyle = buildStyle
	hdta.customBuild = customBuild
	return hdta
end

function HeroData.get_BuildStyle(self)
 	return self.buildStyle
end

function HeroData.ToString(self)
	local returnStr = self.name .. "|" .. self.buildStyle .. "|" .. self.customBuild
  	return returnStr
end

--

ShopItem = {}
ShopItem.__index = ShopItem

function ShopItem.create(name, build) 
	local spim = {}
	setmetatable(spim,ShopItem) 
	spim.name = name      
	spim.build = build
	return spim
end
--items
--{"Name", price, itemID, BUILD, "item1", "item2",....}
shopItemsDone = {
--T3
{"Abyssal Scepter", 2750, AP, "Amplifying Tome", "Fiendish Codex", "Negatron Cloak"},
{"Death's Dance", 3500, AD, "Vampiric Scepter", "Pickaxe", "Caulfield's Warhammer"},
{"Duskblade of Draktharr", 3250, AD, "Serrated Dirk", "B. F. Sword"},
{"Luden's Echo", 3200, AP, "Needlessly Large Rod", "Aether Wisp"},
{"Rod of Ages", 2700, AP, "Catalyst of Aeons", "Blasting Wand"},
{"Warmog's Armor", 2850, TANK_HP, "Giant's Belt", "Kindlegem", "Crystalline Bracer"},
{"Spirit Visage", 2800, TANK, "Spectre's Cowl", "Kindlegem"},
{"Infinity Edge", 3600, AD, "B. F. Sword", "Pickaxe", "Cloak of Agility"},
{"Athene's Unholy Grail", 2100, AP, "Fiendish Codex", "Chalice of Harmony"},
{"Banshee's Veil", 2450, TANK, "Spectre's Cowl", "Negatron Cloak"},
{"Dead Man's Plate", 2900, TANK, "Chain Vest", "Giant's Belt"},
{"Lich Bane", 3200, AP, "Sheen", "Aether Wisp", "Blasting Wand"},
{"Locket of the Iron Solari", 2200, TANK, "Aegis of the Legion", "Null-Magic Mantle"},
{"Maw of Malmortius", 3250, AD, "Hexdrinker", "Caulfield's Warhammer"},
{"Morellonomicon", 2900, AP, "Fiendish Codex", "Amplifying Tome", "Lost Chapter"},
{"Wit's End", 2500, AD, "Recurve Bow", "Negatron Cloak", "Dagger"},
{"Void Staff", 2650, AP, "Blasting Wand", "Amplifying Tome"},
{"Thornmail", 2350, TANK, "Cloth Armor", "Chain Vest"},
{"Sunfire Cape", 2900, TANK, "Chain Vest", "Bami's Cinder"},
{"Sterak's Gage", 2600, TANK_AD, "Jaurim's Fist", "Long Sword"},
{"Statikk Shiv", 2600, AD, "Zeal", "Kircheis Shard"},
{"Rapid Firecannon", 2600, AD, "Zeal", "Kircheis Shard"},
{"Runaan's Hurricane", 2600, AD, "Recurve Bow", "Zeal"},
{"Randuin's Omen", 2900, TANK, "Warden's Mail", "Giant's Belt"},
{"Rabadon's Deathcap", 3800, AP, "Needlessly Large Rod", "Blasting Wand", "Amplifying Tome"},
{"Phantom Dancer", 2550, AD, "Zeal", "Dagger","Dagger"},
{"Nashor's Tooth", 3000, AP, "Stinger", "Fiendish Codex"},
{"Mortal Reminder", 2700, AD, "Last Whisper", "Executioner's Calling"},
{"Lord Dominik's Regards", 2700, AD, "Last Whisper", "Giant Slayer"},
{"Hextech Gunblade", 3400, HYBRID, "Bilgewater Cutlass", "Hextech Revolver"},
{"Guinsoo's Rageblade", 3600, HYBRID, "Recurve Bow", "Blasting Wand", "Pickaxe"},
{"Trinity Force", 3733, HYBRID, "Sheen", "Phage", "Stinger"},
{"The Black Cleaver", 3100, AD, "Phage", "Caulfield's Warhammer"},
{"Rylai's Crystal Scepter", 2600, AP, "Blasting Wand", "Amplifying Tome", "Ruby Crystal"},
{"Berserker's Greaves", 1100, AD, "Boots of Speed", "Dagger"},
{"Boots of Swiftness", 900, HYBRID, "Boots of Speed"},
{"Frozen Mallet", 3100, TANK, "Jaurim's Fist", "Giant's Belt"},
{"Ionian Boots of Lucidity", 900, AP, "Boots of Speed"},
{"Mercury's Treads", 1100, TANK, "Boots of Speed", "Null-Magic Mantle"},
{"Ninja Tabi", 1100, TANK, "Boots of Speed", "Cloth Armor"},
{"The Bloodthirster", 3700, AD, "B. F. Sword", "Vampiric Scepter", "Long Sword"}
}

shopItemsBuild = {
--T2
{"Kindlegem", 800, TANK, "Ruby Crystal"},
{"Hexdrinker", 1300, AD, "Long Sword", "Null-Magic Mantle"},
{"Giant's Belt", 1000, TANK, "Ruby Crystal"},
{"Giant Slayer", 1000, AD, "Long Sword"},
{"Last Whisper", 1300, AD, "Pickaxe"},
{"Fiendish Codex", 900, AP, "Amplifying Tome"},
{"Executioner's Calling", 800, AD, "Long Sword"},
{"Catalyst of Aeons", 1100, AP, "Ruby Crystal", "Sapphire Crystal"},
{"Caulfield's Warhammer", 1100, AD, "Long Sword", "Long Sword"},
{"Aegis of the Legion", 1100, TANK, "Null-Magic Mantle", "Cloth Armor"},
{"Aether Wisp", 850, AP, "Amplifying Tome"},
{"Bami's Cinder", 1100, TANK, "Ruby Crystal"},
{"Zeal", 1300, AD, "Brawler's Gloves", "Dagger"},
{"Crystalline Bracer", 650, TANK, "Ruby Crystal", "Rejuvenation Bead"},
{"Hextech Revolver", 1050, AP, "Amplifying Tome", "Amplifying Tome"},
{"Jaurim's Fist", 1200, TANK_AD, "Long Sword", "Ruby Crystal"},
{"Kircheis Shard", 750, AD, "Dagger"},
{"Lost Chapter", 900, AP, "Amplifying Tome", "Rejuvenation Bead"},
{"Warden's Mail", 1000, TANK, "Cloth Armor", "Cloth Armor"},
{"Vampiric Scepter", 900, 1053, AD, "Long Sword"},
{"Stinger", 1100, AP, "Dagger", "Dagger"},
{"Sheen", 1050, AP, "Sapphire Crystal"},
{"Serrated Dirk", 1100, AD, "Long Sword", "Long Sword"},
{"Phage", 1250, AD, "Long Sword", "Ruby Crystal"},
{"Negatron Cloak", 720, TANK, "Null-Magic Mantle"},
{"Bilgewater Cutlass", 1500, HYBRID, "Vampiric Scepter", "Long Sword"},
{"Chain Vest", 800, TANK, "Cloth Armor"},
{"Chalice of Harmony", 800, AP, "Faerie Charm", "Faerie Charm", "Null-Magic Mantle"},
{"Glacial Shroud", 1000, TANK, "Sapphire Crystal", "Cloth Armor"},
{"Recurve Bow", 1000, AD, "Dagger", "Dagger"},
{"Spectre's Cowl", 1200, TANK, "Ruby Crystal", "Null-Magic Mantle"},
--T1
{"Amplifying Tome", 435, AP},
{"B. F. Sword", 1300, AD},
{"Blasting Wand", 850, AP},
{"Boots of Speed", 300, HYBRID},
{"Brawler's Gloves", 400, AD},
{"Cloak of Agility", 800, AD},
{"Cloth Armor", 300, TANK},
{"Dagger", 300, AD},
{"Faerie Charm", 125, AP},
{"Long Sword", 350, AD},
{"Null-Magic Mantle", 450, TANK},
{"Pickaxe", 875, AD},
{"Rejuvenation Bead", 150, TANK},
{"Ruby Crystal", 400, TANK},
{"Sapphire Crystal", 350, AP}
}

function OnLoad()
	--set state
	state = 0
	resolution = Game.Resolution()
	--get melee or ranged
	ranged = IsHeroRanged()
	GetRanges()
	--setup timer
	StartTimer()
	currentHeroData = GetHeroInfo(myHero)
	--Add Allys and Enemies to Tables
	for i=1,Game.HeroCount(),1 do
		if not Game.Hero(i).isMe then
			if Game.Hero(i).isAlly then
				table.insert(teamFriends,Game.Hero(i))
			else
				table.insert(teamEnemys,Game.Hero(i))
			end
		else
			--print("ME! " .. i)
		end
	end

	--print(HOWLING_ABYSS .. " " .. SUMMONERS_RIFT .. " " .. TWISTED_TREELINE)

end

function OnTick()
	if PMenu.Debug.Dump:Value() then
		print(rangeQ .. " " .. rangeW .. " " .. rangeE .. " " .. rangeR)
	end

	if PMenu.Debug.LK:Value() then
		print(cursorPos.x .. " " .. cursorPos.y)
		for i=6,11,1 do
			print(i-5 .. " " .. myHero:GetItemData(i).itemID)
		end
	end


	if PMenu.Debug.RK:Value() then
		SearchItem(string.upper(shopItems[8][1]))
	end


	if state == 0 then
		timerValue = os.difftime(os.time(),timerStart)
		if timerValue >= timerEnd then
			state = 1
			moveState = const_TURRET_OUTER
		end
		--print(timerValue)
	elseif state == 1 then
		if moveState == const_TURRET_OUTER then

		end
	elseif state == 2 then

	elseif state == 3 then

	elseif state == 4 then

	elseif state == 5 then

	elseif state == 6 then

	elseif state == 7 then

	elseif state == 8 then
		if currentLetterTick >= letterEveryTicks then
			Control.KeyDown(nextLetter)
			Control.KeyUp(nextLetter)
			if letterCount > lettersTotal then
				BuySearchedItem()
			else
				nextLetter = string.char(string.byte(buyText,letterCount))
				letterCount = letterCount + 1
			end
			currentLetterTick = 0
		else
			currentLetterTick = currentLetterTick + 1
		end

	end
end

function OnDraw()
	local currentVec;
	local drawPointCount;

	drawPointCount = Tablelength(vecBlueStart)
	print(drawPointCount)
	for i = 1,drawPointCount,1 do
		Draw.Circle(vecBlueStart[i], 10, 4, Draw.Color(255,255,0,0))
	end

	for i=1,Game.TurretCount() ,1 do
		currentVec = Game.Turret(i).pos:To2D()
		if currentVec.onScreen then
			Draw.Text(i, 60, currentVec, Draw.Color(255,0,255,0))
		end
	end

	for i=1,5,1 do
		currentVec = teamEnemys[i].pos
		if currentVec:DistanceTo() <= 700 then
			Draw.Circle(currentVec, 50, 2, Draw.Color(150,255,255,0))
		else
			Draw.Circle(currentVec, 50, 1, Draw.Color(150,0,255,0))
		end
	end

	if state == 0 then
		if PMenu.Drawing.Start:Value() then
			Draw.Text("Welcome to:", 40, resolution.x/2 -100 ,150, Draw.Color(255,255,255,255))
			Draw.Text("ARAMinator!!", 60, resolution.x/2 - 25 ,175, Draw.Color(255,255,255,255))
			Draw.Text("Bot Starting in: " .. timerEnd - timerValue, 40, resolution.x/2 - 100,250, Draw.Color(255,255,255,255))
		end
	elseif state == 1 then

	elseif state == 2 then

	elseif state == 3 then

	elseif state == 4 then

	elseif state == 5 then

	elseif state == 6 then

	elseif state == 7 then

	end
end

function IsHeroRanged()
	if myHero.range >= 310 then
		print("ARAM | Ranged Champion Detected")
		return true
	else
		print("ARAM | Melee Champion Detected")
		return false
	end
end

function CalculateTarget()

end

function StartTimer()
	timerStart = os.time()
	timerEnd = 10 + math.random(0,PMenu.Humanizer.Start:Value())
	timerValue = os.difftime(os.time(),timerStart)
end

function GetHeroInfo(objToCheck)
	local heroName = nil
	if objToCheck == nil then
		heroName = myHero.charName
	else
		heroName = objToCheck.charName
	end

	local hd = nil

	if heroName == "Aatrox" then
		hd = HeroData.create(heroName, TANK_HP, false, {GAPCLOSE,TOGGLE,DAMAGE,DAMAGE})--
	elseif heroName == "Ahri" then
		hd = HeroData.create(heroName, AP, false, {DAMAGE,CC,DAMAGE,ESCAPE})--
	elseif heroName == "Akali" then
		hd = HeroData.create(heroName, AP, false, {DAMAGE,ESCAPE,DAMAGE,GAPCLOSE})--
	elseif heroName == "Alistar" then
		hd = HeroData.create(heroName, TANK_AP, false, {DAMAGE,ESCAPE,DAMAGE,DAMAGE})--
	elseif heroName == "Amumu" then
		hd = HeroData.create(heroName, TANK_AP, false, {GAPCLOSE,DAMAGE,DAMAGE,CC})--
	elseif heroName == "Anivia" then
		hd = HeroData.create(heroName, AP, false, {DAMAGE,ESCAPE,DAMAGE,DAMAGE})--
	elseif heroName == "Annie" then
		hd = HeroData.create(heroName, AP, false, {DAMAGE,DAMAGE,ESCAPE,DAMAGE})--
	elseif heroName == "Ashe" then
		hd = HeroData.create(heroName, AD, false, {DAMAGE,DAMAGE,VISION,CC})--
	elseif heroName == "Aurelion Sol" then
		hd = HeroData.create(heroName, TANK_AP, false, {CC,DAMAGE,DAMAGE,DAMAGE})--
	elseif heroName == "Azir" then
		hd = HeroData.create(heroName, AP, false, {DAMAGE,DAMAGE,DAMAGE,DAMAGE})--
	elseif heroName == "Bard" then
		hd = HeroData.create(heroName, AP, false, {DAMAGE,UNUSED,UNUSED,CC})--
	elseif heroName == "Blitzcrank" then
		hd = HeroData.create(heroName, TANK_AP, false, {GAPCLOSE,ESCAPE,CC,DAMAGE})--
	elseif heroName == "Brand" then
		hd = HeroData.create(heroName, AP, false, {DAMAGE,DAMAGE,DAMAGE,DAMAGE})--
	elseif heroName == "Braum" then
		hd = HeroData.create(heroName, TANK_AP, false, {DAMAGE,ESCAPE,SELFSHIELD,CC})--
	elseif heroName == "Caitlyn" then
		hd = HeroData.create(heroName, AD, false, {DAMAGE,CC,ESCAPE,DAMAGE})--
	elseif heroName == "Camille" then
		hd = HeroData.create(heroName, AD, false, {DAMAGE,CC,ESCAPE,DAMAGE})--
	elseif heroName == "Cassiopeia" then
		hd = HeroData.create(heroName, AP, false, {DAMAGE,DAMAGE,DAMAGE,CC})--
	elseif heroName == "Cho'Gath" then
		hd = HeroData.create(heroName, TANK_AP, false, {CC,DAMAGE,TOGGLE,DAMAGE})--
	elseif heroName == "Corki" then
		hd = HeroData.create(heroName, AD, false, {DAMAGE,ESCAPE,DAMAGE,DAMAGE})--
	elseif heroName == "Darius" then
		hd = HeroData.create(heroName, TANK_AD, false, {DAMAGE,DAMAGE,GAPCLOSE,DAMAGE})--
	elseif heroName == "Diana" then
		hd = HeroData.create(heroName, AP, false, {DAMAGE,DAMAGE,CC,GAPCLOSE})--
	elseif heroName == "Dr. Mundo" then
		hd = HeroData.create(heroName, TANK_HP, false, {DAMAGE,TOGGLE,DAMAGE,SELFHEAL})--
	elseif heroName == "Draven" then
		hd = HeroData.create(heroName, AD, false, {DAMAGE,DAMAGE,CC,DAMAGE})--
	elseif heroName == "Ekko" then
		hd = HeroData.create(heroName, AP, false, {DAMAGE,CC,DAMAGE,ESCAPE})--
	elseif heroName == "Elise" then
		hd = HeroData.create(heroName, AP, false, {DAMAGE,DAMAGE,DAMAGE,DAMAGE}, true)--!!
	elseif heroName == "Evelynn" then
		hd = HeroData.create(heroName, AP, false, {DAMAGE,ESCAPE,DAMAGE,DAMAGE})--
	elseif heroName == "Ezreal" then
		hd = HeroData.create(heroName, HYBRID, false, {DAMAGE,DAMAGE,ESCAPE,DAMAGE})--
	elseif heroName == "Fiddlesticks" then
		hd = HeroData.create(heroName, AP, false, {CC,SELFHEAL,DAMAGE,DAMAGE})--
	elseif heroName == "Fiora" then
		hd = HeroData.create(heroName, TANK_AD, false, {DAMAGE,DAMAGE,DAMAGE,DAMAGE})
	elseif heroName == "Fizz" then
		hd = HeroData.create(heroName, AP, false, {DAMAGE,DAMAGE,DAMAGE,DAMAGE})
	elseif heroName == "Galio" then
		hd = HeroData.create(heroName, TANK_AP, false, {DAMAGE,DAMAGE,DAMAGE,DAMAGE})
	elseif heroName == "Gangplank" then
		hd = HeroData.create(heroName, AD, false, {DAMAGE,DAMAGE,DAMAGE,DAMAGE}, true)--!!
	elseif heroName == "Garen" then
		hd = HeroData.create(heroName, TANK_AD, false, {DAMAGE,DAMAGE,DAMAGE,DAMAGE})
	elseif heroName == "Gnar" then
		hd = HeroData.create(heroName, TANK_AP, false, {DAMAGE,UNUSED,ESCAPE,DAMAGE})
	elseif heroName == "Gragas" then
		hd = HeroData.create(heroName, AP, false, {DAMAGE,DAMAGE,DAMAGE,DAMAGE})
	elseif heroName == "Graves" then
		hd = HeroData.create(heroName, AD, false, {DAMAGE,DAMAGE,DAMAGE,DAMAGE})
	elseif heroName == "Hecarim" then
		hd = HeroData.create(heroName, TANK_AD, false, {DAMAGE,DAMAGE,DAMAGE,DAMAGE})
	elseif heroName == "Heimerdinger" then
		hd = HeroData.create(heroName, AP, false, {PLACED,DAMAGE,CC,DAMAGE}, true)
	elseif heroName == "Illaoi" then
		hd = HeroData.create(heroName, AP, false, {DAMAGE,DAMAGE,DAMAGE,DAMAGE})
	elseif heroName == "Irelia" then
		hd = HeroData.create(heroName, TANK_AD, false, {DAMAGE,DAMAGE,DAMAGE,DAMAGE})
	elseif heroName == "Ivern" then
		hd = HeroData.create(heroName, AP, false, {DAMAGE,DAMAGE,DAMAGE,DAMAGE})
	elseif heroName == "Janna" then
		hd = HeroData.create(heroName, AD, false, {DAMAGE,CC,DAMAGE,DAMAGE})
	elseif heroName == "Jarvan IV" then
		hd = HeroData.create(heroName, TANK_AD, false, {DAMAGE,DAMAGE,DAMAGE,DAMAGE})
	elseif heroName == "Jax" then
		hd = HeroData.create(heroName, TANK, false, {DAMAGE,DAMAGE,DAMAGE,DAMAGE})
	elseif heroName == "Jayce" then
		hd = HeroData.create(heroName, AD, false, {DAMAGE,DAMAGE,DAMAGE,DAMAGE})
	elseif heroName == "Jhin" then
		hd = HeroData.create(heroName, AD, false, {DAMAGE,DAMAGE,DAMAGE,DAMAGE})
	elseif heroName == "Jinx" then
		hd = HeroData.create(heroName, AD, false, {DAMAGE,DAMAGE,DAMAGE,DAMAGE})
	elseif heroName == "Kalista" then
		hd = HeroData.create(heroName, AD, false, {DAMAGE,DAMAGE,DAMAGE,DAMAGE})
	elseif heroName == "Karma" then
		hd = HeroData.create(heroName, AP, false, {DAMAGE,CC,SHIELD,DAMAGE})--
	elseif heroName == "Karthus" then
		hd = HeroData.create(heroName, AP, false, {DAMAGE,CC,DAMAGE,DAMAGE})
	elseif heroName == "Kassadin" then
		hd = HeroData.create(heroName, AP, false, {DAMAGE,DAMAGE,DAMAGE,DAMAGE})
	elseif heroName == "Katarina" then
		hd = HeroData.create(heroName, AP, false, {DAMAGE,DAMAGE,DAMAGE,DAMAGE})
	elseif heroName == "Kayle" then
		hd = HeroData.create(heroName, AD, false, {DAMAGE,DAMAGE,DAMAGE,DAMAGE})
	elseif heroName == "Kennen" then
		hd = HeroData.create(heroName, AP, false, {DAMAGE,DAMAGE,ESCAPE,DAMAGE})--
	elseif heroName == "Kha'Zix" then
		hd = HeroData.create(heroName, AP, false, {DAMAGE,DAMAGE,DAMAGE,DAMAGE})
	elseif heroName == "Kindred" then
		hd = HeroData.create(heroName, AD, false, {DAMAGE,DAMAGE,DAMAGE,DAMAGE})
	elseif heroName == "Kled" then
		hd = HeroData.create(heroName, AD, false, {DAMAGE,DAMAGE,DAMAGE,DAMAGE}, true)
	elseif heroName == "Kog'Maw" then
		hd = HeroData.create(heroName, HYBRID, false, {DAMAGE,DAMAGE,CC,DAMAGE})--
	elseif heroName == "LeBlanc" then
		hd = HeroData.create(heroName, AP, false, {DAMAGE,DAMAGE,DAMAGE,DAMAGE})
	elseif heroName == "Lee Sin" then
		hd = HeroData.create(heroName, TANK_AD, false, {DAMAGE,DAMAGE,DAMAGE,DAMAGE})
	elseif heroName == "Leona" then
		hd = HeroData.create(heroName, TANK_AP, false, {DAMAGE,DAMAGE,DAMAGE,DAMAGE})
	elseif heroName == "Lissandra" then
		hd = HeroData.create(heroName, AP, false, {DAMAGE,DAMAGE,DAMAGE,DAMAGE})
	elseif heroName == "Lucian" then
		hd = HeroData.create(heroName, AD, false, {DAMAGE,DAMAGE,DAMAGE,DAMAGE})
	elseif heroName == "Lulu" then
		hd = HeroData.create(heroName, AD, false, {DAMAGE,DAMAGE,DAMAGE,DAMAGE})
	elseif heroName == "Lux" then
		hd = HeroData.create(heroName, AP, false, {DAMAGE,DAMAGE,DAMAGE,DAMAGE})
	elseif heroName == "Malphite" then
		hd = HeroData.create(heroName, TANK_AP, false, {DAMAGE,DAMAGE,DAMAGE,DAMAGE})
	elseif heroName == "Malzahar" then
		hd = HeroData.create(heroName, AP, false, {DAMAGE,DAMAGE,DAMAGE,DAMAGE})
	elseif heroName == "Maokai" then
		hd = HeroData.create(heroName, TANK_AP, false, {DAMAGE,DAMAGE,DAMAGE,DAMAGE})
	elseif heroName == "Master Yi" then
		hd = HeroData.create(heroName, AD, false, {DAMAGE,DAMAGE,DAMAGE,DAMAGE})
	elseif heroName == "Miss Fortune" then
		hd = HeroData.create(heroName, AD, false, {DAMAGE,DAMAGE,DAMAGE,DAMAGE})
	elseif heroName == "Mordekaiser" then
		hd = HeroData.create(heroName, TANK_AP, false, {DAMAGE,DAMAGE,DAMAGE,DAMAGE})
	elseif heroName == "Morgana" then
		hd = HeroData.create(heroName, AP, false, {DAMAGE,DAMAGE,DAMAGE,DAMAGE})
	elseif heroName == "Nami" then
		hd = HeroData.create(heroName, AP, false, {DAMAGE,DAMAGE,DAMAGE,DAMAGE})
	elseif heroName == "Nasus" then
		hd = HeroData.create(heroName, TANK_AP, false, {DAMAGE,DAMAGE,DAMAGE,DAMAGE})
	elseif heroName == "Nautilus" then
		hd = HeroData.create(heroName, TANK_AP, false, {DAMAGE,DAMAGE,DAMAGE,DAMAGE})
	elseif heroName == "Nidalee" then
		hd = HeroData.create(heroName, AP, false, {DAMAGE,DAMAGE,DAMAGE,DAMAGE})
	elseif heroName == "Nocturne" then
		hd = HeroData.create(heroName, TANK_AD, false, {DAMAGE,DAMAGE,DAMAGE,DAMAGE})
	elseif heroName == "Nunu" then
		hd = HeroData.create(heroName, AP, false, {DAMAGE,DAMAGE,DAMAGE,DAMAGE})
	elseif heroName == "Olaf" then
		hd = HeroData.create(heroName, TANK_AD, false, {DAMAGE,DAMAGE,DAMAGE,DAMAGE})
	elseif heroName == "Orianna" then
		hd = HeroData.create(heroName, AP, false, {DAMAGE,DAMAGE,DAMAGE,DAMAGE})
	elseif heroName == "Pantheon" then
		hd = HeroData.create(heroName, TANK_AD, false, {DAMAGE,DAMAGE,DAMAGE,DAMAGE})
	elseif heroName == "Poppy" then
		hd = HeroData.create(heroName, TANK_AD, false, {DAMAGE,DAMAGE,DAMAGE,DAMAGE})
	elseif heroName == "Quinn" then
		hd = HeroData.create(heroName, AD, false, {DAMAGE,DAMAGE,DAMAGE,DAMAGE})
	elseif heroName == "Rammus" then
		hd = HeroData.create(heroName, TANK_AP, false, {DAMAGE,SELFSHIELD,CC,DAMAGE})--
	elseif heroName == "Rek'Sai" then
		hd = HeroData.create(heroName, TANK_AP, false, {DAMAGE,DAMAGE,DAMAGE,DAMAGE})
	elseif heroName == "Renekton" then
		hd = HeroData.create(heroName, TANK_AD, false, {DAMAGE,DAMAGE,DAMAGE,DAMAGE})
	elseif heroName == "Rengar" then
		hd = HeroData.create(heroName, TANK_AD, false, {DAMAGE,DAMAGE,DAMAGE,DAMAGE})
	elseif heroName == "Riven" then
		hd = HeroData.create(heroName, TANK_AD, false, {GAPCLOSE,CC,SELFSHIELD,DAMAGE})--
	elseif heroName == "Rumble" then
		hd = HeroData.create(heroName, AP, false, {DAMAGE,DAMAGE,DAMAGE,DAMAGE})
	elseif heroName == "Ryze" then
		hd = HeroData.create(heroName, AP, false, {DAMAGE,DAMAGE,DAMAGE,DAMAGE})
	elseif heroName == "Sejuani" then
		hd = HeroData.create(heroName, TANK_AP, false, {DAMAGE,DAMAGE,DAMAGE,DAMAGE})
	elseif heroName == "Shaco" then
		hd = HeroData.create(heroName, AP, false, {DAMAGE,DAMAGE,DAMAGE,DAMAGE})
	elseif heroName == "Shen" then
		hd = HeroData.create(heroName, TANK, false, {DAMAGE,DAMAGE,DAMAGE,DAMAGE})
	elseif heroName == "Shyvana" then
		hd = HeroData.create(heroName, TANK_AD, false, {DAMAGE,DAMAGE,DAMAGE,DAMAGE})
	elseif heroName == "Singed" then
		hd = HeroData.create(heroName, AP, false, {DAMAGE,DAMAGE,DAMAGE,DAMAGE})
	elseif heroName == "Sion" then
		hd = HeroData.create(heroName, TANK_AP, false, {DAMAGE,DAMAGE,DAMAGE,DAMAGE})
	elseif heroName == "Siver" then
		hd = HeroData.create(heroName, AD, false, {DAMAGE,DAMAGE,DAMAGE,DAMAGE})
	elseif heroName == "Skarner" then
		hd = HeroData.create(heroName, TANK, false, {DAMAGE,DAMAGE,DAMAGE,DAMAGE})
	elseif heroName == "Sona" then
		hd = HeroData.create(heroName, AP, false, {DAMAGE,DAMAGE,DAMAGE,DAMAGE})
	elseif heroName == "Soraka" then
		hd = HeroData.create(heroName, AP, false, {DAMAGE,DAMAGE,DAMAGE,DAMAGE})
	elseif heroName == "Swain" then
		hd = HeroData.create(heroName, AP, false, {DAMAGE,DAMAGE,DAMAGE,DAMAGE})
	elseif heroName == "Syndra" then
		hd = HeroData.create(heroName, AP, false, {DAMAGE,DAMAGE,DAMAGE,DAMAGE})
	elseif heroName == "Tahm Kench" then
		hd = HeroData.create(heroName, TANK_AP, false, {DAMAGE,DAMAGE,DAMAGE,DAMAGE})
	elseif heroName == "Taliyah" then
		hd = HeroData.create(heroName, AP, false, {DAMAGE,DAMAGE,DAMAGE,DAMAGE})
	elseif heroName == "Talon" then
		hd = HeroData.create(heroName, AD, false, {DAMAGE,DAMAGE,DAMAGE,DAMAGE})
	elseif heroName == "Taric" then
		hd = HeroData.create(heroName, TANK_AP, false, {DAMAGE,DAMAGE,DAMAGE,DAMAGE})
	elseif heroName == "Teemo" then
		hd = HeroData.create(heroName, AP, false, {DAMAGE,DAMAGE,DAMAGE,DAMAGE})
	elseif heroName == "Thresh" then
		hd = HeroData.create(heroName, AD, false, {DAMAGE,DAMAGE,DAMAGE,DAMAGE})
	elseif heroName == "Tristana" then
		hd = HeroData.create(heroName, AD, false, {DAMAGE,DAMAGE,DAMAGE,DAMAGE})
	elseif heroName == "Tryndamere" then
		hd = HeroData.create(heroName, TANK_AD, false, {DAMAGE,DAMAGE,DAMAGE,DAMAGE})
	elseif heroName == "Twisted Fate" then
		hd = HeroData.create(heroName, AP, false, {DAMAGE,DAMAGE,DAMAGE,DAMAGE})
	elseif heroName == "Twitch" then
		hd = HeroData.create(heroName, AD, false, {DAMAGE,DAMAGE,DAMAGE,DAMAGE})
	elseif heroName == "Udyr" then
		hd = HeroData.create(heroName, TANK_AP, false, {DAMAGE,DAMAGE,DAMAGE,DAMAGE})
	elseif heroName == "Urgot" then
		hd = HeroData.create(heroName, AD, false, {DAMAGE,DAMAGE,DAMAGE,DAMAGE})
	elseif heroName == "Varus" then
		hd = HeroData.create(heroName, AD, false, {DAMAGE,DAMAGE,DAMAGE,DAMAGE})
	elseif heroName == "Vayne" then
		hd = HeroData.create(heroName, AD, false, {DAMAGE,DAMAGE,DAMAGE,DAMAGE})
	elseif heroName == "Veigar" then
		hd = HeroData.create(heroName, AP, false, {DAMAGE,DAMAGE,DAMAGE,DAMAGE})
	elseif heroName == "Vel'Koz" then
		hd = HeroData.create(heroName, AP, false, {DAMAGE,DAMAGE,CC,DAMAGE})--
	elseif heroName == "Vi" then
		hd = HeroData.create(heroName, TANK_AD, false, {DAMAGE,DAMAGE,DAMAGE,DAMAGE})
	elseif heroName == "Viktor" then
		hd = HeroData.create(heroName, AP, false, {DAMAGE,DAMAGE,DAMAGE,DAMAGE})
	elseif heroName == "Vladimir" then
		hd = HeroData.create(heroName, AP, false, {DAMAGE,DAMAGE,DAMAGE,DAMAGE})
	elseif heroName == "Volibear" then
		hd = HeroData.create(heroName, TANK_AD, false, {DAMAGE,DAMAGE,DAMAGE,DAMAGE})
	elseif heroName == "Warwick" then
		hd = HeroData.create(heroName, TANK_AP, false, {DAMAGE,DAMAGE,DAMAGE,DAMAGE})
	elseif heroName == "Wukong" then
		hd = HeroData.create(heroName, TANK_AD, false, {DAMAGE,DAMAGE,DAMAGE,DAMAGE})
	elseif heroName == "Xerath" then
		hd = HeroData.create(heroName, AP, false, {DAMAGE,DAMAGE,DAMAGE,DAMAGE})
	elseif heroName == "Xin Zhao" then
		hd = HeroData.create(heroName, TANK_AD, false, {DAMAGE,DAMAGE,DAMAGE,DAMAGE})
	elseif heroName == "Yasuo" then
		hd = HeroData.create(heroName, AD, false, {DAMAGE,SHIELD,ESCAPE,DAMAGE})
	elseif heroName == "Yorick" then
		hd = HeroData.create(heroName, TANK_AP, false, {DAMAGE,CC,CC,DAMAGE})--
	elseif heroName == "Zac" then
		hd = HeroData.create(heroName, TANK_HP, false, {DAMAGE,DAMAGE,DAMAGE,DAMAGE})
	elseif heroName == "Zed" then
		hd = HeroData.create(heroName, AD, false, {DAMAGE,DAMAGE,DAMAGE,DAMAGE})
	elseif heroName == "Ziggs" then
		hd = HeroData.create(heroName, AP, false, {DAMAGE,DAMAGE,DAMAGE,DAMAGE})
	elseif heroName == "Zilean" then
		hd = HeroData.create(heroName, AP, false, {DAMAGE,DAMAGE,DAMAGE,DAMAGE})
	elseif heroName == "Zyra" then
		hd = HeroData.create(heroName, AP, false, {DAMAGE,DAMAGE,DAMAGE,DAMAGE})
	elseif heroName == "Xayah" then
		hd = HeroData.create(heroName, AD, false, {DAMAGE,DAMAGE,DAMAGE,DAMAGE})
	elseif heroName == "Rakan" then
		hd = HeroData.create(heroName, AP, false, {DAMAGE,DAMAGE,DAMAGE,DAMAGE})
	end

	if hd == nil then
		print("ARAM | NO Supported Champ Found.")
		print("^ THIS IS A BUG! REPORT THIS! ^")
	end

	return hd;

end

function GetRanges()
	rangeQ = myHero:GetSpellData(_Q).range
	rangeW = myHero:GetSpellData(_W).range
	rangeE = myHero:GetSpellData(_E).range
	rangeR = myHero:GetSpellData(_R).range
end

function SetInitialTurrets()

end

function CustomBuilds()

end

function SearchItem(searchText)
	Control.LeftClick(603,183)
	buyText = searchText
	nextLetter = string.char(string.byte(buyText,1))
    letterCount = 2
    lettersTotal = string.len(buyText)
    letterEveryTicks = 2
    currentLetterTick = 0
    state = 8
end

function BuySearchedItem()
	Control.RightClick(540,235)
	state = 5
end

function HasItem(itemID, itemName)
	local ret = false
	for i=6,11,1 do
		if myHero:GetItemData(i).itemID == itemID then
			ret = true
		end
	end
	return ret
end

function GetBuild()
	local EFS = GetEnemyTeamFightStyle()
	local retBuild = {}

	if buildStyle == AD then

	elseif buildStyle == AP then

	elseif buildStyle == HYBRID then

	elseif buildStyle == TANK then

	elseif buildStyle == TANK_HP then

	elseif buildStyle == TANK_AD then

	elseif buildStyle == TANK_AP then

	else
		print("ARAM | ERROR GETTING BUILD!")
	end

	return retBuild;
end

function GetEnemyTeamFightStyle()
	local EFSEnemyBuilds = {}
	local lastHer = nil
	for i=1,5,1 do
		lastHer = GetHeroInfo(teamEnemys[i])
		table.insert(EFSEnemyBuilds,lastHer[2])
		print(lastHer[2])
	end
	return EFSEnemyBuilds
end

function PrintHeroData(heroDataToPrint)

end

function Tablelength(T)
  local count = 0
  for _ in pairs(T) do count = count + 1 end
  return count
end