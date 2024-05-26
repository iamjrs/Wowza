local Group = Wowza.Group
local Unit  = Wowza.Unit

function Group:new()
    local new = {}
    setmetatable(new, self)
    self.__index = self
    new:update()
    return new
end

function Group:update()

    -- Populate group members
    self.members = {}
    table.insert( self.members, Unit:new('player') )
    
    local numSubgroupMembers = GetNumSubgroupMembers()

    for i=1, numSubgroupMembers do
        local unit_id = 'party' .. i
        table.insert( self.members, Unit:new(unit_id) )
    end

    return self
end
