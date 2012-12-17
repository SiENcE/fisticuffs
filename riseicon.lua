cRiseIcon = CreateClass()


function cRiseIcon:Init (x,y,params)
	self.x = x 
	self.y = y 
	self.starty = y 
	self.params = params 
	self.startt = gMyTicks
	
	if (params.anim) then self.anim = params.anim end
	if (params.img) then self.anim = params.img end
end

function cRiseIcon:Draw (dt)
	love.graphics.draw(self.anim, self.x, self.y, 0 , self.params.s or 1,self.params.s or 1, 120, 100) 
end 

-- rise : maxt,riseh
function cRiseIcon:Step (dt)
	local params = self.params
	if (params.riseh) then 
		local f = (gMyTicks - self.startt) / params.maxt
		
		self.y = self.starty + f * params.riseh
		
		if (f > 1) then self.bIsDead = true end
	end
	--~ self.anim:update(dt)
end
