cHuman = CreateClass(cFlockUnit)

function cHuman:Init (x,y)
	cFlockUnit.Init(self,x,y)
	self.dead = false
	self.hp = 10
	self.ang = 0
	self.nextBeatTime = frandom(100,400)
	local img = kGfx_Humans
	self.anim = newAnimation(img,20,20,0.5,4)		-- ( image, fw, fh, delay, frames ) 
end

function cHuman:GetDistToObj (o)
	local dx = self.x - o.x 
	local dy = self.y - o.y 
	return sqrt(dx*dx+dy*dy)
end

function cHuman:HitMe(hitter)
	self.hp = self.hp - math.random(1,3)

	-- reHit
	if (gMyTicks > self.nextBeatTime) then
		self.nextBeatTime = gMyTicks + frandom(300,600)
		if (hitter and self:GetDistToObj(hitter) < kHumanBeatRange) then
--			print("reHit")
			hitter:HitMe()
		end
	end

	if self.hp <= 0 and not self.dead then
		gDeadHumans = gDeadHumans + 1
--		print("gDeadHumans", gDeadHumans)
		self.dead = true
		self:Dead()
	else
		love.audio.play(get_random_from_array(kSound_Hit))
	end
end

function cHuman:Dead ()
--	print("human died")
	gBodys:Add(self.x, self.y, 1000*40, kGfx_DeadBody, 0, 0, 96, 96, math.random(0,360))
	love.audio.play( kSound_Uargs[math.random(1,#kSound_Uargs)] ) 
	remove_from_table_by_value(gHumans, self)
end

function cHuman:Draw (dt)
	self.anim:draw(self.x, self.y, self.ang * rad2deg + 90, kScale_Human, kScale_Human, 10, 10) 
end 

function cHuman:Step (dt)
--	print("human")
	self.ang = SlowTurn(self.ang,math.atan2(self.vy, self.vx),dt * kTurnRate_FlockUnit) 
	self.anim:update(dt)
	self:Flock_ResetForce()

	for k,o in pairs(gCops) do self:Flock_AddForce_RelIfInRange(o, 0,kRad_FlockHumanFlee, kSpeed_HumanFlee,0) end
	for k,o in pairs(gHumans) do self:Flock_AddForce_RelIfInRange(o, 0,kRad_FlockBounce, kSpeed_HumanWalk,kSpeed_HumanWalk) end

	if (gIsKillerMode) then
		if (gCrowdPoint) then self:Flock_AddForce_RelIfInRange(gCrowdPoint, 0,2000, kSpeed_HumanWalk,kSpeed_HumanWalk) end
	else
		if (gCrowdPoint) then self:Flock_AddForce_RelIfInRange(gCrowdPoint, 0,2000, -kSpeed_HumanWalk,-kSpeed_HumanWalk) end
	end

	self:Flock_ApplyVelocity(dt,kSpeed_HumanFlee)
end


