require("AnAL")
require("TEsound")
require("util")
require("riseicon")
require("beating")
require("flockunit")
require("copsquad")
require("cop")
require("human")
require("decal")

kSpeed_GlobalFactor = 0.5
kSpeed_HumanWalk 	= 15 * kSpeed_GlobalFactor *10
kSpeed_HumanFlee 	= 20 * kSpeed_GlobalFactor *15
kSpeed_CopWalk		= 15 * kSpeed_GlobalFactor *15
kSpeed_CopAttack		= 30 * kSpeed_GlobalFactor *25
kSpeed_CopAttackTurbo	= 50 * kSpeed_GlobalFactor *45
kSpeed_Player		= 35 * kSpeed_GlobalFactor *30
kRad_FlockBounce = 30
kRad_FlockHumanFlee = 160
kPlayerBeatKOTime = 2100

kIntroTime = 6000

kGameTimeout = 2 * 60*1000 + kIntroTime-2000
kKillerModeTime = 10*1000

gNextBangT = 0

kScale_FlockUnits	= 3.0
kTurnRate_FlockUnit	= 0.01 * pi
kScale_Player	= kScale_FlockUnits
kScale_Human	= kScale_FlockUnits
kScale_Cop		= kScale_FlockUnits
kScale_Point	= 1

kPlayerCamMaxAngleDiff	= 40*deg2rad
kPlayerCamRange			= 300

kHumanBeatRange		= 40	

kCopBeatRange		= 40	
kCopSquadBeatProb	= 0.3

kScreenW = 800
kScreenH = 600

local border = 38
kAreaMinX,kAreaMaxX = border ,kScreenW -border
kAreaMinY,kAreaMaxY = border ,kScreenH -border

gHumanCount = 6
gHumanCounter = 0 --gHumanCount
gHumanCounterMax = 22
gDeadHumans = 0

gCopsCounter = 0
gCopsCount = 6
gCopsCounterMax = 0
gDeadCops = 0

gCops = {}
gHumans = {}
gCopSquads = {}
--gPlayers = {}
gBeatingEffect = {}
gRiseIcons = {}
gBang = {}
gIntro = true
gGameOver = false

-- if love0.8.0 else love0.7.0
if love.graphics.setDefaultImageFilter then
	love.graphics.setDefaultImageFilter("nearest", "nearest")
else
	-- before all other: redefining the love.graphics.newImage for setFilter
	local __newImage = love.graphics.newImage -- old function
	function love.graphics.newImage( ... ) -- new function that sets nearest filter
	   local img = __newImage( ... ) -- call old function with all arguments to this function
	   img:setFilter( 'nearest', 'nearest' )	-- 'linear', 'linear' or 'nearest', 'nearest'
	   return img
	end
end

function love.load()
	print("loading...")
	math.randomseed(os.time())
	math.random(); math.random(); math.random()

	gTime = love.timer.getTime( ) -- in seconds
	gMyTicks = gTime * 1000 -- in milliseconds
	gEndT = gMyTicks + kGameTimeout

	-- Load a font
	local font4_img = love.graphics.newImage("gfx/font4.png")
    font4 = love.graphics.newImageFont(font4_img,
    " abcdefghijklmnopqrstuvwxyz" ..
    "ABCDEFGHIJKLMNOPQRSTUVWXYZ0" ..
    "123456789.,!?-+/():;%&`'*#=[]\"")
    -- Load a font
	local cgafont_img = love.graphics.newImage("gfx/cgafont.png")
    gFontCga = love.graphics.newImageFont(cgafont_img,
	" !\"#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\]^_``abcdefghijklmnopqrstuvwxyz{|}~")
	
	if love.web then
		love.graphics.setFont(font4)
	else
		love.graphics.setFont(gFontCga)
	end
	
	kSound_stadium1 = love.audio.newSource( "sound/1_Beep.ogg" ) 
	
	kSound_meinLeben = love.audio.newSource( "sound/meinleben.ogg" ) 

	kSound_Hit = {
		love.audio.newSource( "sound/hit.ogg" ),
		love.audio.newSource( "sound/hit2.ogg" ),
		love.audio.newSource( "sound/hit3.ogg" ),
	}
	
	kSound_Wawawa = {
		love.audio.newSource( "sound/wawawa01.ogg" ),
		love.audio.newSource( "sound/wawawa02.ogg" ),
	}

	kSound_Uargs = {
		love.audio.newSource( "sound/uarg1.ogg" ),
		love.audio.newSource( "sound/uarg2.ogg" ),
		love.audio.newSource( "sound/uarg3.ogg" ),
	}
	kSound_Pain = {
		love.audio.newSource( "sound/pain1.ogg" ),
		love.audio.newSource( "sound/pain2.ogg" ),
		love.audio.newSource( "sound/pain3.ogg" ),
		love.audio.newSource( "sound/pain1.ogg" ),
		love.audio.newSource( "sound/pain2.ogg" ),
		love.audio.newSource( "sound/pain3.ogg" ),
		love.audio.newSource( "sound/pain1.ogg" ),
		love.audio.newSource( "sound/pain2.ogg" ),
		love.audio.newSource( "sound/pain3.ogg" ),
		love.audio.newSource( "sound/nuaeh.ogg" ),
	}
	
	kGfx_Bg		= love.graphics.newImage("gfx/bg2.png")

	kGfx_Arena	= love.graphics.newImage("gfx/arena.png")
	kGfx_Cop	= love.graphics.newImage("gfx/cops.png")		
	kGfx_Humans = love.graphics.newImage("gfx/humans.png")

	kGfx_Blood	= love.graphics.newImage("gfx/blood.png")
	kGfx_DeadBody	= love.graphics.newImage("gfx/deadbody.png")
	
	kGfx_intro1= love.graphics.newImage("gfx/intro1.png")
	kGfx_intro2= love.graphics.newImage("gfx/intro2.png")
	kGfx_intro3= love.graphics.newImage("gfx/intro3.png")
	kGfx_Intros = {
		kGfx_intro1,
		kGfx_intro2,
		kGfx_intro3,
	}

	kGfx_Bang_Flashmob_meinLeben = {
		love.graphics.newImage("gfx/meinLeben.png"),
		love.graphics.newImage("gfx/meinLeben2.png"),
		love.graphics.newImage("gfx/meinLeben3.png")
	}

	kGfx_Cloud = love.graphics.newImage("gfx/cloud2.png")
	kGfx_Endscreen = love.graphics.newImage("gfx/theend.png")
	
--	for i=1,3 do 
--		MakeCopSquad(30+math.random(0,110),400+math.random(0,110),3,40)
--	end

--	for i=1, gHumanCounter do 
--		MakeHuman(300+math.random(0,110),200+math.random(0,110))
--	end
	
	gDecals = CreateClassInstance(cDecal)
	gBodys = CreateClassInstance(cDecal)
	
	gStartTicks = love.timer.getTime()
end

-- Keypressed: Called whenever a key was pressed. 
function love.keypressed(key)
	if key == 'lalt' or key == ' ' then
		if gHumanCounter < gHumanCount then
			MakeHuman(400+math.random(0,10),20+math.random(0,10))
			gHumanCounter=gHumanCounter+1
		end
	end

	if key == 'rshift' or key == 'return' then
		if gCopsCounter < gCopsCount then
			MakeCopSquad(400+math.random(0,10),580+math.random(0,10),1,1)
			gCopsCounter=gCopsCounter+1
		end
	end

	if key=='f' then
		love.graphics.toggleFullscreen()
	end

	if key=='escape' then
		love.event.push("quit")
	end
end 

function love.mousepressed( x, y, button )
	if (gMyTicks < kIntroTime) then return end
	if button == 'r' then
		if gCopsCounter < gCopsCount then
			MakeCopSquad(x,y,1,1)
			gCopsCounter=gCopsCounter+1
		end
	elseif button == 'l' then
		if gHumanCounter < gHumanCount then
			MakeHuman(x,y)
			gHumanCounter=gHumanCounter+1
		end
	end
end

function MakeBeatingEffect	(x,y,human)				local o = CreateClassInstance(cBeatingEffect,x,y,human)			table.insert(gBeatingEffect,o) return o end
function MakeCopSquad		(x,y,num,r)	 			local o = CreateClassInstance(cCopSquad,x,y,num,r)  			table.insert(gCopSquads,	o) return o end
function MakeCop			(x,y) 					local o = CreateClassInstance(cCop,x,y)							table.insert(gCops,			o) return o end
function MakeHuman			(x,y) 					local o = CreateClassInstance(cHuman,x,y)						table.insert(gHumans,		o) return o end
function MakeRiseIcon		(x,y,params)			local o = CreateClassInstance(cRiseIcon,x,y,params)				table.insert(gRiseIcons,	o) return o end

function SpawnBeating (x,y,target)
	MakeBeatingEffect(x,y,target)
end

function MakeBang_meinLeben		(x,y) 
	local randomLeben=random(#kGfx_Bang_Flashmob_meinLeben)
	return MakeRiseIcon(x,y,{img=kGfx_Bang_Flashmob_meinLeben[randomLeben],maxt=500,riseh=0,s=kScale_Point})
end

gNextBeatingTimeoutCheck = 0
gNextRiseIconTimeoutCheck = 0
gNextNewCrowdPointT = 0
gStartIngameMusic = false

zTime=nil
function love.update(dt)
	if not zTime then zTime=love.timer.getTime() end
	gTime = love.timer.getTime() - zTime -- in seconds
	gMyTicks = gTime * 1000 -- in milliseconds

	local timeleft = gEndT - gMyTicks

--gMyTicks        5123.0001449585 gEndT   127003.9999485  timeleft 121880.99980354 kIntroTime      6000
--gMyTicks	   1355775789801      gEndT   1355775913699   timeleft 123898          kIntroTime 6000
--	print("gMyTicks",gMyTicks, "gEndT", gEndT, "timeleft", timeleft, "kIntroTime", kIntroTime)

	if (not gGameStarted) then timeleft = kIntroTime*1000 end

	if (timeleft < 0 or gDeadHumans == gHumanCount or gDeadCops == gCopsCount) then gGameOver = true end
	if (gGameOver) then return GameOver_Update(dt) end

	if (gTime < #kGfx_Intros) then return end -- intro in progress
	if not gGameStarted then 
		gGameStarted = true
		--start music
		TEsound.playLooping("sound/2_crowd.ogg", "backmusic", 200, 1.0)
		gEndT = gMyTicks + kGameTimeout
	end

	-- return until intro is showed
	if (gMyTicks < kIntroTime) then return end

	-- ingame mode

	-- start ingame music
	if (gMyTicks > kIntroTime) and not gStartIngameMusic then
		love.audio.play(kSound_stadium1)
		gStartIngameMusic = true
	end

	for k,o in pairs(gCops) do o:Step(dt) end
	for k,o in pairs(gCopSquads) do o:Step(dt) end
	for k,o in pairs(gHumans) do o:Step(dt) end

	for k,o in pairs(gBeatingEffect) do o:Step(dt) end
	for k,o in pairs(gRiseIcons) do o:Step(dt) end
	for k,o in pairs(gBang) do o:Step(dt) end

	if (gMyTicks > gNextBeatingTimeoutCheck) then
		gNextBeatingTimeoutCheck = gMyTicks + 100
		gBeatingEffect = filter_array(gBeatingEffect,function (o) return gMyTicks < o.timeout end)
	end
	if (gMyTicks > gNextRiseIconTimeoutCheck) then
		gNextRiseIconTimeoutCheck = gMyTicks + 100
		gRiseIcons = filter_array(gRiseIcons,function (o) return not o.bIsDead end)
	end
	if (gMyTicks > gNextRiseIconTimeoutCheck) then
		gNextRiseIconTimeoutCheck = gMyTicks + 100
		gBang = filter_array(gBang,function (o) return not o.bIsDead end)
	end

	-- crowd runs to random point
	if gMyTicks > gNextNewCrowdPointT then
		gNextNewCrowdPointT = gMyTicks + frandom(2000,3000)
		gCrowdPoint = {x=frandom(kAreaMinX,kAreaMaxX),y=frandom(kAreaMinY,kAreaMaxY)}
	end

	gDecals:Step(dt)
	gBodys:Step(dt)
	
	collectgarbage("step")
	 
	TEsound.cleanup()
end

function love.draw()
	-- intro in progress
	if (gMyTicks < kIntroTime) then 
		love.graphics.draw(kGfx_Intros[1])
		
		if (gMyTicks > kIntroTime/2) then 
			love.graphics.draw(kGfx_Intros[2])
		end
		if (gMyTicks > kIntroTime/1.5) then 
			love.graphics.draw(kGfx_Intros[3])
		end
		return 
	end

	if (gGameOver) then return GameOver_Draw() end
	love.graphics.draw(kGfx_Bg)
	gBodys:Draw()
	gDecals:Draw()

	for k,o in pairs(gHumans) do o:Draw() end
	for k,o in pairs(gCops) do o:Draw() end

	for k,o in pairs(gBeatingEffect) do o:Draw() end
	for k,o in pairs(gRiseIcons) do o:Draw() end
	for k,o in pairs(gBang) do o:Draw() end
	
	--draw Arena
	love.graphics.draw(kGfx_Arena)

	if love.web then
		local timeleft = max(0,gEndT - gMyTicks)
		local seconds = math.fmod(floor(timeleft/1000),60) --mod(floor(timeleft/1000),60)
		local minutes = floor(timeleft/1000/60)
		local timetext = "Time: " .. minutes .. ":" .. seconds
		love.graphics.print(timetext, 20, 2 )
	else
		local timeleft = max(0,gEndT - gMyTicks)
		local seconds = mod(floor(timeleft/1000),60)
		local minutes = floor(timeleft/1000/60)
		local timetext = sprintf("Time: %d:%02d",minutes,seconds)
		love.graphics.setColor(254,254,254,255)
		love.graphics.print(timetext, 10, 2 )
		love.graphics.setColor(255,255,255,255)
	end
end

function GameOver_Update(dt)
	if not love.web then
		if love.keyboard.isDown(" ") then
			print("reload game")
			TEsound.stop("backmusic")
			gIntro = true
			gGameStarted=false
			gStartIngameMusic = false
			gNextBangT = 0
			love.filesystem.load("main.lua")() 
		end
	end
end

function GameOver_Draw()
	TEsound.stop("backmusic", true)
	love.graphics.draw(kGfx_Endscreen)

	local text = ""
	local x=210
	if gDeadCops > gDeadHumans then
		text = "Pussies won! You killed " .. gDeadCops .. " Dicks."
	elseif gDeadHumans == gDeadCops then
		text = "The game ended in a draw. You are all Pussies ;-)"
		if love.web then
			x=x-20
		else
			x=x-190
		end
	else
		text = "Dicks won! You killed " .. gDeadHumans .. " pussies."
	end

	if love.web then
		love.graphics.setColor(255,128,128,255)
		love.graphics.printf(text, x, 545, 700, "left" )
		love.graphics.setColor(255,255,255,255)
		love.graphics.printf("press F5 to try again", 250, 565, 700, "left" )
	else
		love.graphics.setColor(1,1,1,255)
		love.graphics.printf(text, x-10, 545, 800, "left" )
		love.graphics.setColor(1,1,1,255)
		love.graphics.printf("press SPACE to try again", 250, 565, 700, "left" )
		love.graphics.setColor(255,255,255,255)
	end
end
