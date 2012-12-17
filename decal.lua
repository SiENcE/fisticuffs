cDecal = CreateClass()

function cDecal:Init ()
	self.list = {}
end

function cDecal:Add (x,y,timeout,img,px,py,w,h,ang)
	table.insert(self.list, {timeout=gMyTicks+timeout, x=x, y=y, img=img, px=px or 0, py=py or 0, w=w or img:GetWidth(), h=h or img:GetHeight(), ang=ang or 0})
end

function cDecal:Draw (dt)
	local t = gMyTicks
	for k,v in pairs(self.list) do
--		love.graphics.draw(v.img, v.x, v.y, v.px, v.py, v.w, v.h, v.ang) 
		love.graphics.draw(v.img, v.x, v.y, v.ang, 1,1, 0, 0)
		
--		if v.timeout < t then
--			self.list[k] = nil
--		end
	end
end 

function cDecal:Step (dt)
end
