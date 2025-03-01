local WeakAuras = Wowza.WeakAuras

function WeakAuras.HekiliDisplay()

    local rec = _G.Hekili.DisplayPool.Primary.Recommendations[1]
  
    if rec and GetKeybind then
      --print(rec.actionName, rec.keybind)
      if rec.keybind and #rec.keybind > 0 then
        return rec.keybind
      end
      
      if rec.texture then
        return GetKeybind(rec.texture)
      end
      
    end

end

function WeakAuras.WaitOnHekiliTrigger()

  -- Table of abilities to check range for
  
  local rangeChecks = {}
  
  -- Paladin
  rangeChecks["Shield of the Righteous"] = "Rebuke"

  -- Warrior
  rangeChecks["Demoralizing Shout"] = "Pummel"
  rangeChecks["Champion's Spear"] = "Pummel"
  rangeChecks["Ravager"] = "Pummel"

  -- Druid
  rangeChecks["Swipe"] = "Ferocious Bite"
  rangeChecks["Brutal Slash"] = "Ferocious Bite"

  -- Shaman
  rangeChecks["Surging Totem"] = "Stormstrike"

  
  local rec = _G.Hekili.DisplayPool.Primary.Recommendations[1]
  
  if rec then
    
    -- If target is out of action range, wait
    
    if rec.actionName then
      local action = _G.Hekili.Class.abilities[rec.actionName]
      if rangeChecks[action.name] ~= nil then
        local spellInRange = C_Spell.IsSpellInRange(rangeChecks[action.name], 'target')
        if spellInRange == false then
          return true
        end
      end
    end
    
    -- If action is currently queued, wait

    -- if rec.actionName then
    --   local action = _G.Hekili.Class.abilities[rec.actionName]
    --   if action.name ~= "Lava Lash" then
    --     -- local gcd = C_Spell.GetSpellCooldown(61304)
    --     local queued = C_Spell.IsCurrentSpell(action.name)
    --     if queued then
    --       return true
    --     end
    --   end
    -- end

    -- If action is OFF GCD, don't wait
    
    if rec.actionName then
      local action = _G.Hekili.Class.abilities[rec.actionName]
      if action.gcd == 'off' then
        return false
      end
    end
    
    -- If action is not ready, wait
    
    if rec.exact_time then
      local _, _, _, lagWorld = GetNetStats()
      local lag_ms = lagWorld / 1000
      local buffer = 0.1 + lag_ms
      if GetTime() < (rec.exact_time - buffer) then
        return true
      end
    end
    
  end

end