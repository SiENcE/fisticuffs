--function printf(...) io.write(string.format("%d:",Client_GetTicks())..string.format(...)) end
-- protected call string fromatting, errors don't crash the program
function pformat(...) 
	local success,s = pcall(string.format,...)
	if (success) then return s end
	s = "string.format error ("..s..") #"..strjoin(",",{...}).."#"
	print(s)
	print(_TRACEBACK())
	return s
end
function printf(...) io.write(pformat(...)) end
function sprintf(...) return pformat(...) end


sin = math.sin
cos = math.cos
min = math.min
max = math.max
floor = math.floor
ceil = math.ceil
mod = math.mod
sqrt = math.sqrt
random = math.random
pi = math.pi
rad2deg = 180/pi
deg2rad = pi/180



function SlowTurn (oldang,newang,maxturn)  -- param and result in radian
	return oldang + max(-maxturn,min(maxturn,AngWrap(newang - oldang)))
end

function AngWrap (angdiff) 
	while angdiff < -pi do angdiff = angdiff + 2*pi end
	while angdiff >  pi do angdiff = angdiff - 2*pi end
	return angdiff
end
function Interpolate (t,a,b) return t*a + (1-t)*b end

function dist (x,y,x2,y2) return hypot(x-x2,y-y2) end
function hypot (dx,dy) return sqrt(dx*dx + dy*dy) end

function frandom (rmin,rmax) return rmin + random()*(rmax-rmin) end

function get_random_from_array (arr) return arr[random(1,max(1,#arr))] end
function filter_array (arr,fun) 
	local res = {}
	for k,v in pairs(arr) do if (fun(v)) then table.insert(res,v) end end
	return res
end

function remove_from_table_by_value(t, value)
	for k,v in pairs(t) do
		if v == value then
			t[k] = nil
			return
		end
	end
end

-- creates a new class, optionally derived from a parentclass
function CreateClass(parentclass_or_nil) 
	local p = parentclass_or_nil and setmetatable({},parentclass_or_nil._class_metatable) or {}
	-- OLD: parentclass_or_nil and CopyArray(parentclass_or_nil) or {}
	-- by metatable instead of copying, we avoid problems when not all parentclass methods are registered yet at class creation
	p._class_metatable = { __index=p } 
	return p 
end

-- creates a class instance and calls the Init function if it exists with the given parameter ...
function CreateClassInstance(class, ...) 
	local o = setmetatable({},class._class_metatable)
	if o.Init then o:Init(...) end
	return o
end



--[[
Dequeue = {}
Dequeue.__index = Dequeue

function Dequeue:new()
	return setmetatable({__first=0,__last=-1}, self)
end

function Dequeue:addFirst(elem)
	self.__first = self.__last + 1
	self[self.__first] = elem
end

function Dequeue:addLast(elem)
	self.__last = self.__last + 1
	self[last.__last] = elem
end

function Dequeue:first()
	return self[self.__first]
end

function Dequeue:last()
	return self[self.__last]
end

function Dequeue:getFirst()
	if self.__first > self.__last then return nil end
	local result = self[self.__last]
	self.__last = self.__last - 1
	return result
end

function Dequeue:getLast()
	if self.__first > self.__last then return nil end
	local result = self[self.__last]
	self.__last = self.__last - 1
	return result
end

function Dequeue:size()
	return (self.__last - self.__first + 1)
end
]]--
