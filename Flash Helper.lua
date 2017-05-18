--variables
local lolVersion = "7.8"
local scrVersion = "0.5.28 Beta"

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

local bushesInRange = {}

--Main Menu
local PMenuFH = MenuElement({type = MENU, id = "PMenuFH", name = "Flash Helper | Beta", leftIcon = menuIcon})
PMenuFH:MenuElement({id = "Enabled", name = "Enabled", value = true})

--PMenuFH:MenuElement({type = MENU, id = "Flashing", name = "Flash Settings"})
--PMenuFH.Flashing:MenuElement({id = "Brush",name = "Flash to Brush when possible", value = false})
--PMenuFH.Flashing:MenuElement({id = "Juke",name = "Juke when possible", value = false})
--PMenuFH.Flashing:MenuElement({id = "AutoFlash",name = "Auto Flash (beta)", value = false})

--Main Menu-- Key Setting
PMenuFH:MenuElement({type = MENU, id = "Key", name = "Key Settings"})
PMenuFH.Key:MenuElement({id = "Flash",name = "Flash HotKey", key = string.byte("F")})
--PMenuFH.Key:MenuElement({id = "Dump",name = "Debug Position", key = string.byte("H")})

--Main Menu-- Drawing 
PMenuFH:MenuElement({type = MENU, id = "Drawing", name = "Drawing"})
PMenuFH.Drawing:MenuElement({type = MENU, id = "Basic", name = "Basic"})
PMenuFH.Drawing.Basic:MenuElement({id = "Flash", name = "Draw Flash Range", value = true})
PMenuFH.Drawing.Basic:MenuElement({id = "Tran", name = "Alpha", value = 0.5, min = 0, max = 1, step = 0.01})
PMenuFH.Drawing.Basic:MenuElement({id = "During", name = "Only Draw when Flash off CD", value = true})
PMenuFH.Drawing:MenuElement({type = MENU, id = "Bushes", name = "Bushes"})
PMenuFH.Drawing.Bushes:MenuElement({id = "Bushes", name = "Draw Bushes", value = true})
PMenuFH.Drawing.Bushes:MenuElement({id = "Alpha", name = "Alpha", value = 0.75, min = 0, max = 1, step = 0.01})
PMenuFH.Drawing.Bushes:MenuElement({id = "During", name = "Only Draw when Flash off CD", value = true})

local hasFlash = true;
local flashSlot = 0;
local flashSpell = SUMMONER_1;
local flashHK = HK_SUMMONER_1;
local justFlashed = false;
local flashTimer = 0;
local autoAttacking = false
--OW variables
local EOrbWalk = false
local ICOrbWalk= false
local GOSOrbWalk = false
local extLibOrbWalk = false
local otherOW = false

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
	if not PMenuFH.Enabled:Value() then return end
	if not hasFlash then return end
	if frameOne then
		GetOrbWalker()
		frameOne = false
	end
	if myHero.dead then return end
	if justFlashed then
		flashTimer = flashTimer + 1;
		if flashTimer >= 20 then
			flashTimer = 0
			justFlashed = false
		end
	else
	--if PMenuFH.Key.Dump:Value() then
		--print(math.floor(myHero.pos.x + 0.5) .. ", " .. math.floor(myHero.pos.y + 0.5) .. ", ".. math.floor(myHero.pos.z + 0.5))
	--end
	--
		if PMenuFH.Key.Flash:Value() then
			if CanFlash() then
				FlashGO();
			else
				print("Will retry next Tick.")
			end
		end
	end
end


function OnDraw()
	local lineWidth = 1
	if not hasFlash then return end
	if myHero.dead then return end
	if PMenuFH.Drawing.Basic.Flash:Value() then
		if PMenuFH.Drawing.Basic.During:Value() and myHero:GetSpellData(flashSpell).currentCd ~= 0 then
			
		else
			Draw.Circle(myHero.pos,405,1,Draw.Color(PMenuFH.Drawing.Basic.Tran:Value() * 255, 255, 255, 0))
		end
	end
	--Draw.Circle(myHero.pos,415,1,Draw.Color(PMenuFH.Drawing.Tran:Value() * 255, 255, 255, 0))
	if PMenuFH.Drawing.Bushes.Bushes:Value() then
		if PMenuFH.Drawing.Bushes.During:Value() and myHero:GetSpellData(flashSpell).currentCd ~= 0 then

		else
			if Game.mapID == 11 then
				for i=1,39,1 do 
					if bushPositionsSR[i]:To2D().onScreen then
						if bushPositionsSR[i]:DistanceTo() <= 440 and myHero:GetSpellData(flashSpell).currentCd == 0 then
							lineWidth = 3
						else
							lineWidth = 1
						end
						Draw.Circle(bushPositionsSR[i],75,lineWidth,Draw.Color(PMenuFH.Drawing.Bushes.Alpha:Value() * 255, 255, 255, 0))
					end
				end
			end
			if Game.mapID == 10 then
				for i=1,11,1 do 
					if bushPositionsTT[i]:To2D().onScreen then
						if bushPositionsTT[i]:DistanceTo() <= 440 and myHero:GetSpellData(flashSpell).currentCd == 0 then
							lineWidth = 3
						else
							lineWidth = 1
						end
						Draw.Circle(bushPositionsTT[i],75,lineWidth,Draw.Color(PMenuFH.Drawing.Bushes.Alpha:Value() * 255, 255, 255, 0))
					end
				end
			end
			if Game.mapID == 12 then
				for i=1,6,1 do
					if bushPositionsHA[i]:To2D().onScreen then
						if bushPositionsHA[i]:DistanceTo() <= 440 and myHero:GetSpellData(flashSpell).currentCd == 0 then
							lineWidth = 3
						else
							lineWidth = 1
						end
						Draw.Circle(bushPositionsHA[i],75,lineWidth,Draw.Color(PMenuFH.Drawing.Bushes.Alpha:Value() * 255, 255, 255, 0))
					end
				end
			end
		end
	end
end

function CanFlash()
	if GOSOrbWalk then
		if CanFlashBasic() then
			return true;
		end

	elseif ICOrbWalk then
		if CanFlashBasic() and not autoAttacking then
			return true;
		end

	elseif EOrbWalk then
		if CanFlashBasic() then
			return true;
		end
	else
		if CanFlashBasic() then
			return true;
		end
	end

	return false;

end

function GetOrbWalker()
	if EOW then 
		print("Flash Helper | eXternal Orbwalker Detected.")
		EOrbWalk = true
	elseif _G.SDK then
		print("Flash Helper | IC's Orbwalker Detected.")
		ICOrbWalk = true
		_G.SDK.Orbwalker:OnPreAttack(ICAAStart())
		_G.SDK.Orbwalker:OnAttack(ICAAEnd())
	elseif _G.Orbwalker then
		print("Flash Helper | Noddy's Orbwalker Detected.")
		GOSOrbWalk = true
	else
		print("Flash Helper | ExtLib / No Orbwalker");
		otherOW = true;
	end
end

function CanFlashBasic()
	if myHero:GetSpellData(flashSpell).currentCd ~= 0 then
		print("Flash Helper | Flash Failed | COOLDOWN")
		return false
	end

	if myHero.attackData.state == STATE_WINDUP then
		print("Flash Helper | Flash Failed | OrbWalker WINDUP")
		return false;
	end

	return true;
end

function FlashGO()
	Control.RightClick(cursorPos)
	print("Flash Helper | Flashing!")
	justFlashed = true;
	flashTimer = 0;
	Control.CastSpell(flashHK)
end

function ICAAStart()
	autoAttacking = true
	print("IC AA")
end

function ICAAEnd()
	autoAttacking = false
	print("IC Done")
end