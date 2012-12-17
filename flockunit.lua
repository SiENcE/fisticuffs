cFlockUnit = CreateClass()

function cFlockUnit:Init (x,y)
	self.x = x
	self.y = y
	self.vx = 0
	self.vy = 0
end

function cFlockUnit:GetDistToObj (o)
	local dx = self.x - o.x 
	local dy = self.y - o.y 
	return sqrt(dx*dx+dy*dy)
end

function cFlockUnit:Flock_AddForce_RelIfInRange (o,mind,maxd,minf,maxf)
	if (o == self) then return end
	local dx = self.x - o.x 
	local dy = self.y - o.y 
	local d = sqrt(dx*dx+dy*dy)
	dx = max(-1,min(1,dx / d))
	dy = max(-1,min(1,dy / d))
	if (d <= 0 or d < mind or d > maxd) then return end
	local df = (d - mind) / (maxd - mind)
	local f = minf + df * (maxf-minf)
	self:Flock_AddForce(f*dx,f*dy)
end

function cFlockUnit:Flock_AddForce (vx,vy)
	self.flockv_c  = self.flockv_c  + 1 
	self.flockv_vx = self.flockv_vx + vx
	self.flockv_vy = self.flockv_vy + vy
end

function cFlockUnit:Flock_ResetForce ()
	self.flockv_c = 0
	self.flockv_vx = 0
	self.flockv_vy = 0
end

function cFlockUnit:Flock_ApplyVelocity (dt,myspeed)
	if (self.flockv_c > 0) then 
		local scale = myspeed / hypot( self.flockv_vx , self.flockv_vy )
		local acc = 0.9
		local iacc = (1-acc)
		self.vx = acc*self.vx + iacc * scale * self.flockv_vx
		self.vy = acc*self.vy + iacc * scale * self.flockv_vy
		
		self.x = self.x + dt * self.vx
		self.y = self.y + dt * self.vy
		
		self.x = max(kAreaMinX,min(kAreaMaxX,self.x))
		self.y = max(kAreaMinY,min(kAreaMaxY,self.y))
	end
end
