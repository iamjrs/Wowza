local Aura = Wowza.Aura

function Aura:new(aura_table)
    local new = {}
    setmetatable(new, self)
    self.__index = self
    new:unpack(aura_table)
    return new
end

function Aura:unpack(aura_table)

    -- Unpack UnitAura response
    self.name               = aura_table[1]
    self.icon               = aura_table[2]
    self.count              = aura_table[3]
    self.dispel_type        = aura_table[4]
    self.duration           = aura_table[5]
    self.expiration_time    = aura_table[6]
    self.remaining_time     = 0

    if self.expiration_time then
        self.remaining_time = self.expiration_time - GetTime()
    end

    self.source             = aura_table[7]
    self.can_apply_aura     = aura_table[8]
    self.is_boss_debuff     = aura_table[9]
    self.cast_by_player     = aura_table[10]
    self.nameplate_show_all = aura_table[11]
    self.time_mod           = aura_table[12]
    return self
end
