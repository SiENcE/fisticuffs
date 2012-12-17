cCopSquad = CreateClass()

function cCopSquad:Init (x,y,num,r)
	self.nextthink = 0
	self.members = {}
	for i=1,num do
		local cop = MakeCop(x+frandom(-r,r),y+frandom(-r,r))
		table.insert(self.members,cop)
		cop.squad = self
	end
end

function cCopSquad:Step (dt)
	if (gMyTicks >= self.nextthink) then self:ThinkStep() end
	
end

function cCopSquad:SetTarget (o,bAttack)
	for k,member in pairs(self.members) do 
		member.target = o
		member.bAttack = bAttack
	end
end

function cCopSquad:WalkToRandomPoint () self:SetTarget({x=frandom(kAreaMinX,kAreaMaxX),y=frandom(kAreaMinY,kAreaMaxY)}) end

function cCopSquad:ThinkStep ()
	local waitt = frandom(2000,5000)
	if (gIsKillerMode) then waitt = waitt * 0.5 end
	self.nextthink = gMyTicks + waitt
	
	local r_cam = 200
	local r_human = 300
	local firstmember = self.members[1]
	
	if (random() > kCopSquadBeatProb and (not gIsKillerMode)) then self:WalkToRandomPoint() return end
	
	-- attack some random 
	local o
	for i=1,5 do 
		local a = get_random_from_array(filter_array(gHumans,function (o) return firstmember:GetDistToObj(o) < r_human end))
		if (a and ((not o) or firstmember:GetDistToObj(a) < firstmember:GetDistToObj(o))) then o = a end
	end
	if (o) then self:SetTarget(o,true) return end
	
	self:WalkToRandomPoint()
end
