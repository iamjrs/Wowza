local unit_keybinds = {}
unit_keybinds['player'] = "c7"
unit_keybinds['party1'] = "c8"
unit_keybinds['party2'] = "c9"
unit_keybinds['party3'] = "c0"
unit_keybinds['party4'] = "c-"

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
    self.keybind    = unit_keybinds[self.id]

    -- Health checks
    self.health     = UnitHealth(self.id)
    self.health_max = UnitHealthMax(self.id)
    self.health_pct = self.health / self.health_max * 100

    -- Range check
    self.in_range   = self.id == 'player' or UnitInRange(self.id)
    self.role       = UnitGroupRolesAssigned(self.id)

    self:get_auras()
    return self
end


function Unit:get_auras()

    -- Populate unit auras
    self.auras = {}

    local i = 1
    while true do
        local aura = Aura:new({UnitAura(self.id, i)})
        if aura.name then
            table.insert( self.auras, aura )
            i = i + 1
        else
            break
        end
    end
    return self
end


function Unit:has_aura(aura_name)
    
    -- Check for aura
    for _, aura in pairs(self.auras) do
        if aura.name == aura_name then
            return aura
        end
    end
    return false
end


