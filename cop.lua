cCop = CreateClass(cFlockUnit)

function cCop:Init (x,y)
	cFlockUnit.Init(self,x,y)
	self.dead = false
	self.hp = 10
	self.ang = 0
	self.nextBeatTime = frandom(100,400)
	local img = kGfx_Cop
	self.anim = newAnimation(img,20,20,0.5,4)		-- ( image, fw, fh, delay, frames ) 
end

function cCop:HitMe ()
	self.hp = self.hp - math.random(1,3)

	if self.hp <= 0 and not self.dead then
		gDeadCops = gDeadCops + 1
--		print("gDeadCops", gDeadCops)
		self.dead = true
		self:Dead()
	end
end

function cCop:Dead ()
--	print("cop died")
	gBodys:Add(self.x, self.y, 1000*40, kGfx_DeadBody, 0, 0, 96, 96, math.random(0,360))
	love.audio.play(kSound_meinLeben)
	remove_from_table_by_value(gCops, self)
	remove_from_table_by_value(gCopSquads, self.squad)
end

function cCop:Draw (dt)
	self.anim:draw(self.x, self.y, self.ang * rad2deg + 90, kScale_Cop, kScale_Cop, 10, 10)
end 

function cCop:Step (dt)
--	print("cop")
	self.ang = SlowTurn(self.ang,math.atan2(self.vy, self.vx),dt * kTurnRate_FlockUnit) 
	self.anim:update(dt) 
	self:Flock_ResetForce()
	
	local myspeed = kSpeed_CopWalk
	if (self.bAttack) then myspeed = kSpeed_CopAttack end
	if (gIsKillerMode) then myspeed = kSpeed_CopAttackTurbo end
	
	local target = self.target
	for k,o in pairs(gCops) do self:Flock_AddForce_RelIfInRange(o, 0,kRad_FlockBounce, myspeed*2,myspeed*2) end
	
	if target then 
		local mywalkspeed = myspeed
		self:Flock_AddForce_RelIfInRange(target, 0,2000, -myspeed,-myspeed)
	end

	if (gMyTicks > self.nextBeatTime) then
		self.nextBeatTime = gMyTicks + frandom(300,600)
		if (self.bAttack and target and self:GetDistToObj(target) < kCopBeatRange) then 
			SpawnBeating(target.x,target.y,target)
			target:HitMe(self)
		end
	end

	self:Flock_ApplyVelocity(dt,myspeed)
end


