local unit_keybinds = {
    player = 'c7',
    party1 = 'c8',
    party2 = 'c9',
    party3 = 'c0',
    party4 = 'c-'
}

local Unit = Wowza.Unit
local Aura = Wowza.Aura

function Unit:new(unit_id)
    local new = {}
    setmetatable(new, self)
    self.__index = self
    new.id = unit_id
    new:update()
    return new
end

function Unit:update()
    
    -- Keybind
    self.keybind            = unit_keybinds[self.id]

    -- Health checks
    self.health             = UnitHealth(self.id)
    self.health_max         = UnitHealthMax(self.id)
    self.health_absorb      = UnitGetTotalHealAbsorbs(self.id)
    self.health_incoming    = UnitGetIncomingHeals(self.id) or 0

    -- self.health_pct         = self.health / self.health_max * 100
    self.health_pct         = (self.health + self.health_incoming) / self.health_max * 100

    -- Range check
    self.in_range           = self.id == 'player' or UnitInRange(self.id)
    self.role               = UnitGroupRolesAssigned(self.id)

    -- Valid or not
    self.is_valid = self.health > 0 and self.in_range and not UnitIsUnit(self.id, 'focus')

    -- Update aura info
    self:get_auras()

    return self

end


function Unit:get_auras()

    -- Populate unit auras
    self.auras = {}

    local aura_checks = 16

    for n,func in pairs({UnitBuff, UnitDebuff}) do
        
        local aura_types = {'HELPFUL', 'HARMFUL'}

        for i=1,aura_checks do
            local aura = {func(self.id, i)}
            local aura_type = aura_types[n]
            table.insert(aura, 16, aura_type)
            aura = Aura:new(aura)

            if aura.name then
                table.insert(self.auras, aura)
            else
                break
            end
        end
    end

    return self

end


function Unit:has_aura(aura_name, aura_remaining_time)
    
    local aura_remaining_time = aura_remaining_time or 0

    -- Check for aura
    for _, aura in pairs(self.auras) do
        if aura.name == aura_name then
            if aura.remaining_time >= aura_remaining_time then
                return aura
            end
        end
    end

    return false

end


function Unit:has_aura_type(dispel_types)

    --local dispel_type = dispel_type or {'Curse', 'Disease', 'Magic', 'Poison'}

    if type(dispel_types) == 'string' then
        dispel_types = {dispel_types}
    end

    -- Check for aura
    for _, aura in pairs(self.auras) do
        for _,dispel_type in pairs(dispel_types) do
            if aura.dispel_type == dispel_type and aura.type == 'HARMFUL' then
                return aura
            end
        end
    end

    return false

end
