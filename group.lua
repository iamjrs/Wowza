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
    local player    = Unit:new('player')
    self.player     = player
    self.members    = {}

    table.insert(self.members, player)

    local numSubgroupMembers = GetNumSubgroupMembers()

    for i=1, numSubgroupMembers do
        local unit_id = 'party' .. i
        local unit = Unit:new(unit_id)
        table.insert( self.members, unit )
    end

    table.sort( self.members, function(a,b) return a.health_pct < b.health_pct end )

    return self
end

function Group:lowest_without_aura(aura_name, health_pct_thresh, aura_remaining_time)

    local matches = {}

    health_pct_thresh   = health_pct_thresh or 100
    aura_remaining_time = aura_remaining_time or 0

    for _,member in pairs(self.members) do

        if member.health > 0 and member.health_pct <= health_pct_thresh then

            if member.in_range then

                if not member:has_aura(aura_name, aura_remaining_time) then

                    table.insert(matches, member)

                end
            end
        end
    end

    return matches

end

function Group:members_below_health_pct(health_pct)
    local matches = {}
    for _, member in pairs(self.members) do
        if member.health_pct < health_pct then
            table.insert(matches, member)
        end
    end
    return matches
end