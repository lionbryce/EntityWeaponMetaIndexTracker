local Player = FindMetaTable( "Player" )
local Weapon = FindMetaTable( "Weapon" )
local entity = FindMetaTable( "Entity" )
local ent_GetTable = entity.GetTable

GLOBAL_metaindexed = {}

local indexed = GLOBAL_metaindexed
local indexedextra = {}

function Player:__index( key )

	local trace = debug.traceback()
	
	--
	-- Search the metatable. We can do this without dipping into C, so we do it first.
	--
	local val = Player[key]
	if ( val != nil ) then 
		indexed[trace] = (indexed[trace] or 0) + 1
		indexedextra[trace] = {key,"player meta"}
		return val 
	end

	--
	-- Search the entity metatable
	--
	local val = entity[key]
	if ( val != nil ) then 
		indexed[trace] = (indexed[trace] or 0) + 1
		indexedextra[trace] = {key,"entity meta"}
		return val
	end

	--
	-- Search the entity table
	--
	local tab = entity.GetTable( self )
	if ( tab ) then
		indexed[trace] = (indexed[trace] or 0) + 1
		indexedextra[trace] = {key,"entity table"}
		return tab[ key ]
	end

	return nil

end

function Weapon:__index( key )
	
	local trace = debug.traceback()
	
	--
	-- Search the metatable. We can do this without dipping into C, so we do it first.
	--
	local val = Weapon[key]
	if ( val != nil ) then 
		indexed[trace] = (indexed[trace] or 0) + 1
		indexedextra[trace] = {key,"weapon meta"}
		return val 
	end

	--
	-- Search the entity metatable
	--
	local val = entity[key]
	if ( val != nil ) then 
		indexed[trace] = (indexed[trace] or 0) + 1
		indexedextra[trace] = {key,"entity meta"}
		return val
	end

	--
	-- Search the entity table
	--
	--local tab = ent_GetTable( self )
	--if tab then
		local val = ent_GetTable( self )[ key ]
		if ( val != nil ) then
			indexed[trace] = (indexed[trace] or 0) + 1
			indexedextra[trace] = {key,"entity table"}
			return val
		end
	--end

	--
	-- Legacy: sometimes use self.Owner to get the owner.. so lets carry on supporting that stupidness
	-- This needs to be retired, just like self.Entity was.
	--
	if ( key == "Owner" ) then
		indexed[trace] = (indexed[trace] or 0) + 1
		indexedextra[trace] = {key,"weapon owner"}
		return entity.GetOwner( self )
	end
	
	return nil
	
end

function metaindexfindertop(count) --lua_run metaindexfindertop()
	local out = {}
	for k,v in pairs(indexed) do
		out[#out+1] = {k,v}
	end
	
	table.sort( out, function(a, b) return a[2] > b[2] end )
	
	for i=1,(count or #out) do
		local trace = out[i][1]
		local extra = indexedextra[trace]
		print(out[i][2], extra[1], extra[2], trace)
	end
end

--lua_openscript metaindexfinder.lua