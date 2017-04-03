--variables
local lolVersion = "7.6"
local scrVersion = "0.2.12 Alpha"

menuIcon = "http://i.imgur.com/uO0pDv8.png"

local bushPositionsSR = {Vector(2334,53,13524), Vector(1660,53,13012), Vector(1174,53,12320), 
Vector(2994,-70,11006), Vector(2318,53,9726), Vector(816,53,8168), Vector(5012,0,8440), 
Vector(3386,53,7766), Vector(4820,51,7118), Vector(6546,49,4690), Vector(8606,52,4670), 
Vector(5634,51,3506), Vector(6884,51,3122), Vector(8096,52,3496), Vector(10400,50,3060),
Vector(9228,59,2130), Vector(7780,49,814), Vector(12490,54,1510), Vector(13342,51,2484), 
Vector(11902,-67,3932), Vector(9414,-71,5676), Vector(8128,-71,6302), Vector(8654,-71,6630),
Vector(6302,-68,8134), Vector(6744,-71,8528), Vector(5234,-71,9104), Vector(7176,53,14118),
Vector(5654,53,12762), Vector(4460,57,11794), Vector(6784,54,11454), Vector(7988,56,11784),
Vector(9200,53,11428), Vector(8282,50,10250), Vector(6252,54,10246), Vector(9974,52,7888),
Vector(9840,21,6476), Vector(11484,52,7132), Vector(12502,52,5196), Vector(14112,52,7002)}

local bushPositionsTT = {Vector(4978,-106,8835), Vector(7162,-111,7937), Vector(8216,-111,7915),
Vector(10426,-106,8797), Vector(9066,-99,6927), Vector(8660,-102,6897), Vector(6722,-102,6903),
Vector(6322,-98,6951), Vector(5164,-110,5653), Vector(7706,-98,5579), Vector(10238,-110,5653)}

local bushPositionsHA = {Vector(4153,-178,5177), Vector(5447,-178,6327), Vector(5907,-178,6459),
Vector(6365,-178,6959), Vector(6547,-178,7393), Vector(7731,-178,8623)}

--Main Menu
local PMenu = MenuElement({type = MENU, id = "PMenu", name = "Flash Helper | Pre-Beta", leftIcon = menuIcon})
PMenu:MenuElement({id = "Enabled", name = "Enabled", value = true})

--Main Menu-- Key Setting
PMenu:MenuElement({type = MENU, id = "Key", name = "Key Settings"})
PMenu.Key:MenuElement({id = "Flash",name = "Flash HotKey", key = string.byte("F")})
--PMenu.Key:MenuElement({id = "Dump",name = "Debug Position", key = string.byte("H")})

--Main Menu-- Drawing 
PMenu:MenuElement({type = MENU, id = "Drawing", name = "Drawing"})
PMenu.Drawing:MenuElement({type = MENU, id = "Basic", name = "Basic"})
PMenu.Drawing.Basic:MenuElement({id = "Flash", name = "Draw Flash Range", value = true})
PMenu.Drawing.Basic:MenuElement({id = "Tran", name = "Alpha", value = 0.5, min = 0, max = 1, step = 0.01})
PMenu.Drawing.Basic:MenuElement({id = "During", name = "Only Draw when Flash off CD", value = true})
PMenu.Drawing:MenuElement({type = MENU, id = "Bushes", name = "Bushes"})
PMenu.Drawing.Bushes:MenuElement({id = "Bushes", name = "Draw Bushes", value = true})
PMenu.Drawing.Bushes:MenuElement({id = "Alpha", name = "Alpha", value = 0.75, min = 0, max = 1, step = 0.01})
PMenu.Drawing.Bushes:MenuElement({id = "During", name = "Only Draw when Flash off CD", value = false})

local hasFlash = true;
local flashSlot = 0;
local flashSpell = SUMMONER_1;
local flashHK = HK_SUMMONER_1;
local justFlashed = false;
local flashTimer = 0;
--OW variables
local EOrbWalk = false
local ICOrbWalk= false
local GOSOrbWalk = false
local autoAttacking = false

local frameOne = true

function OnLoad()
	print("Flash Helper V: ".. scrVersion .." | Loaded | By: TheBob")
	frameOne = true;
	--print(Game.mapID)
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
	if frameOne then
		GetOrbWalker()
		if ICOrbWalk then
			_G.SDK.Orbwalker:OnPreAttack(ICPreAttack())
			_G.SDK.Orbwalker:OnAttack(ICPostAttack())
		end
		frameOne = false
	end
	if myHero.dead then return end
	--if justFlashed then
	--	flashTimer = flashTimer + 1;
	--	if flashTimer >= 15 then
	--		flashTimer = 0
	--		justFlashed = false
	--	end
	--end
	--if PMenu.Key.Dump:Value() then
		--print(math.floor(myHero.pos.x + 0.5) .. ", " .. math.floor(myHero.pos.y + 0.5) .. ", ".. math.floor(myHero.pos.z + 0.5))
	--end
	--
	if CanFlash() and PMenu.Key.Flash:Value() and not justFlashed then
		FlashGO();
	end
end

function OnDraw()
	local lineWidth = 1
	if not hasFlash then return end
	if myHero.dead then return end
	if PMenu.Drawing.Basic.Flash:Value() then
		if PMenu.Drawing.Basic.During:Value() and not CanFlash() then
			
		else
			Draw.Circle(myHero.pos,405,1,Draw.Color(PMenu.Drawing.Basic.Tran:Value() * 255, 255, 255, 0))
		end
	end
	--Draw.Circle(myHero.pos,415,1,Draw.Color(PMenu.Drawing.Tran:Value() * 255, 255, 255, 0))
	if PMenu.Drawing.Bushes.Bushes:Value() then
		if PMenu.Drawing.Bushes.During:Value() and not CanFlash() then

		else
			if Game.mapID == 11 then
				for i=1,39,1 do 
					if bushPositionsSR[i]:To2D().onScreen then
						if bushPositionsSR[i]:DistanceTo() <= 425 and CanFlash() then
							lineWidth = 3
						else
							lineWidth = 1
						end
						Draw.Circle(bushPositionsSR[i],75,lineWidth,Draw.Color(PMenu.Drawing.Bushes.Alpha:Value() * 255, 255, 255, 0))
					end
				end
			end
			if Game.mapID == 10 then
				for i=1,11,1 do 
					if bushPositionsTT[i]:To2D().onScreen then
						if bushPositionsTT[i]:DistanceTo() <= 425 and CanFlash() then
							lineWidth = 3
						else
							lineWidth = 1
						end
						Draw.Circle(bushPositionsTT[i],75,lineWidth,Draw.Color(PMenu.Drawing.Bushes.Alpha:Value() * 255, 255, 255, 0))
					end
				end
			end
			if Game.mapID == 12 then
				for i=1,6,1 do
					if bushPositionsHA[i]:To2D().onScreen then
						if bushPositionsHA[i]:DistanceTo() <= 425 and CanFlash() then
							lineWidth = 3
						else
							lineWidth = 1
						end
						Draw.Circle(bushPositionsHA[i],75,lineWidth,Draw.Color(PMenu.Drawing.Bushes.Alpha:Value() * 255, 255, 255, 0))
					end
				end
			end
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
	if ICOrbWalk then
		if _G.SDK.Orbwalker:CanMove(myHero) and not autoAttacking then
			print("Flash Helper | Flashing!")
			--Control.Move()
			Control.CastSpell(flashHK)
			justFlashed = true;
			flashTimer = 0;
		else
			print("Flash Helper | Waiting for Auto-Attack/CC | Will retry next tick.")
		end
		
	elseif EOrbWalk then
		--print("Flash Helper | Orbwalker Check Passed! eXt")
		print("Flash Helper | Flashing!")
		--Control.Move()
		Control.CastSpell(flashHK)
		justFlashed = true;
		flashTimer = 0;
	--elseif GOSOrbWalk then
		--print("Flash Helper | Orbwalker Check Passed! GoS")
		
	else
		print("Flash Helper | Flashing!")
		--Control.Move()
		Control.CastSpell(flashHK)
		justFlashed = true;
		flashTimer = 0;
	end
end

function CrowdControlled()

end

function GetOrbWalker()
	if EOW then 
		print("Flash Helper | eXternal Orbwalker Detected.")
		EOrbWalk = true
		DisableDefaultOW()
	elseif _G.SDK then
		print("Flash Helper | IC's Orbwalker integration loaded.")
		ICOrbWalk = true
		DisableDefaultOW()
	elseif _G.Orbwalker then
		print("Flash Helper | GOS Default Orbwalker Detected.")
		GOSOrbWalk = true
	else
		print("Flash Helper | No Orbwalker?");
	end
end


function DisableDefaultOW()
    if _G.Orbwalker then
    	_G.Orbwalker.Enabled:Value(false)
    	_G.Orbwalker.Drawings.Enabled:Value(false)
    	--print("Flash Helper | Default Orbwalker Disabled");
	end
end

function ICPreAttack()
	autoAttacking = true;
end

function ICPostAttack()
	autoAttacking = false;
end