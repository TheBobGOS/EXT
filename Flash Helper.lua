--variables
local lolVersion = "7.6"
local scrVersion = "0.1.7 Beta"

menuIcon = "http://i.imgur.com/uO0pDv8.png"

--Main Menu
local PMenu = MenuElement({type = MENU, id = "PMenu", name = "Flash Helper - Beta", leftIcon = menuIcon})
PMenu:MenuElement({id = "Enabled", name = "Enabled", value = true})

--Main Menu-- Key Setting
PMenu:MenuElement({type = MENU, id = "Key", name = "Key Settings"})
PMenu.Key:MenuElement({id = "Flash",name = "Flash HotKey", key = string.byte("F")})

--Main Menu-- Drawing 
PMenu:MenuElement({type = MENU, id = "Drawing", name = "Drawing"})
PMenu.Drawing:MenuElement({id = "Flash", name = "Draw Flash Range", value = true})
PMenu.Drawing:MenuElement({id = "Tran", name = "Draw Alpha", value = 0.5, min = 0, max = 1, step = 0.01})
PMenu.Drawing:MenuElement({id = "During", name = "Only Draw When Off CD", value = true})

local hasFlash = true;
local flashSlot = 0;
local flashSpell = SUMMONER_1;
local flashHK = HK_SUMMONER_1;
local justFlashed = false;
local flashTimer = 0;

function OnLoad()
	print("Flash Helper V: ".. scrVersion .." | Loaded | By: TheBob")
	if myHero:GetSpellData(SUMMONER_1).name == "SummonerFlash" then
		print("Flash Helper | Flash Found in summoner slot 1")
		flashHK = HK_SUMMONER_1;
		flashSpell = SUMMONER_1;
	elseif myHero:GetSpellData(SUMMONER_2).name == "SummonerFlash" then
		print("Flash Helper | Flash Found in summoner slot 2")
		flashHK = HK_SUMMONER_2;
		flashSpell = SUMMONER_2;
	else
		hasFlash = false;
		print("Flash Helper | Flash not found. Script will be disabled")
	end
end

function OnTick()
	if not PMenu.Enabled:Value() then return end
	if not hasFlash then return end
	if myHero.dead then return end
	if justFlashed then
		flashTimer = flashTimer + 1;
		if flashTimer >= 15 then
			flashTimer = 0
			justFlashed = false
		end
	end
	--
	if CanFlash() and PMenu.Key.Flash:Value() and not justFlashed then
		FlashGO();
	end
end

function OnDraw()
	if not hasFlash then return end
	if myHero.dead then return end
	if PMenu.Drawing.Flash:Value() then
		if PMenu.Drawing.During:Value() and not CanFlash() then
			
		else
			Draw.Circle(myHero.pos,415,1,Draw.Color(PMenu.Drawing.Tran:Value() * 255, 255, 255, 0))
		end
	end
end

function CanFlash()
	if myHero:GetSpellData(flashSpell).currentCd == 0 then
		return true;
	else
		return false;
	end
end

function FlashGO()
	print("Flash Helper | Flashing!")
	--Control.Move()
	Control.CastSpell(flashHK,cursorPos)
	justFlashed = true;
	flashTimer = 0;
end

function CrowdControlled()

end