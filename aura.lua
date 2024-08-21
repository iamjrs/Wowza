local Aura = Wowza.Aura

function Aura:new(aura_table)
    local new = {}
    setmetatable(new, self)
    self.__index = self
    new:unpack(aura_table)
    return new
end

function Aura:unpack(aura_table)

    local name, icon, count,
    dispelType, duration, expirationTime, 
    source, isStealable, nameplateShowPersonal,
    spellId, canApplyAura, isBossDebuff, 
    castByPlayer, nameplateShowAll, timeMod, aura_type = unpack(aura_table)

    self.name = name
    self.icon = icon
    self.count = count
    self.dispel_type = dispelType
    self.duration = duration
    self.expiration_time = expirationTime
    self.source = source
    self.is_stealable = isStealable
    self.nameplate_show_personal = nameplateShowPersonal
    self.spell_id = spellId
    self.can_apply_aura = canApplyAura
    self.is_boss_debuff = isBossDebuff
    self.cast_by_player = castByPlayer
    self.nameplate_show_all = nameplateShowAll
    self.time_mod = timeMod
    self.type = aura_type

    -- Calculate remaining time
    self.remaining_time     = 0
    if self.expiration_time then
        self.remaining_time = self.expiration_time - GetTime()
    end

    return self
end
