cBeatingEffect = CreateClass()

function cBeatingEffect:Init (x,y,human)
	self.x = x 
	self.y = y 
	self.human = human 
	
	gDecals:Add(x,y,1000*20,kGfx_Blood,math.random(0,4)*40,0,40,40, math.random(0,360))
	
	if gMyTicks > gNextBangT then 
		gNextBangT = gMyTicks + 500
		MakeBang_meinLeben(x,y-30)
	end
	
	local img = kGfx_Cloud
	self.ang = 0
	self.nextBeatTime = frandom(100,400)
	self.anim = newAnimation(img,128,128,0.25,16)		-- ( image, fw, fh, delay, frames ) 
	
	self.timeout = gMyTicks + frandom(1000,2000)
end

function cBeatingEffect:Draw (dt)
	self.anim:draw(self.x, self.y, 0, 1,1, 64, 64) 
end 

function cBeatingEffect:Step (dt)
	self.anim:update(dt)
end
