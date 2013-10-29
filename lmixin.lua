local setmetatable = setmetatable
local ipairs = ipairs
local pairs = pairs
local getfenv = getfenv
local type = type

local mixmeta = {}
mixmeta.__index = mixmeta

mixmeta.__newindex = function(m, k, v)
	m._members[k] = v
end

mixmeta.__call = function(m, ...)
	local o = setmetatable({_prototype = m}, m._members)
	local ctor = o[m.__type]
	
	if ctor ~= nil then
		ctor(o, ...)
	end
	
	return o
end

function mixmeta:include(...)
	for _, m in ipairs{...} do
		if not self:includes(m) then
			self._mixins[m.__type] = m
	
			for k, v in pairs(m._members) do
				if k ~= "__index" and k ~= "__call" and k ~= "__newindex" then
					self._members[k] = v
				end
			end
		end
	end
end

function mixmeta:includes(m)
	return self._mixins[m.__type] ~= nil
end

function mixin(name)
	local m = {}
	m._mixins = {}
	m.__type = name
	m._members = {}
	m._members.__index = m._members
	
	local fenv = getfenv(2)
	fenv[name] = setmetatable(m, mixmeta)
	
	local inc
	inc = function(name)
		m:include(fenv[name])
		return inc
	end
	
	return inc
end
