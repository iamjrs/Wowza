function GetGroup()

   local baseKeys   = {'6','7','8','9','0','-','=','[',']',';',"'",','}
   local modKeys    = {'A', 'CS', 'AS'}
   local partyKeys  = {'C8', 'C9', 'C0', 'C-'}
   local raidKeys   = {}
   local group      = {}

   group['player']            = {}
   group['player']['keybind'] = 'C7'

   for p=1,4 do
       local unit = 'party' .. p
       if UnitExists(unit) then
           group[unit]            = {}
           group[unit]['keybind'] = partyKeys[p]
       else
         break
      end
   end

   for n,modKey in pairs(modKeys) do
       for n2,baseKey in pairs(baseKeys) do
           local key = modKey .. baseKey
           table.insert(raidKeys, key)
       end
   end

   for r=1,36 do
      local unit = 'raid' .. r
      if UnitExists(unit) then
         group[unit]            = {}
         group[unit]['keybind'] = raidKeys[r]
      else
         break
      end
   end

   for unit,info in pairs(group) do
       local health             = UnitHealth(unit)
       local healthMax          = UnitHealthMax(unit)
       local healthPct          = health / healthMax * 100
       group[unit]['health']    = health
       group[unit]['healthMax'] = healthMax
       group[unit]['healthPct'] = healthPct
   end

   return group

end

function GetKeybind(ability_name)
   
   local spellTexture
   
   if type(ability_name) == 'string' then
      spellTexture = C_Spell.GetSpellTexture(ability_name)
      
   elseif type(ability_name) == 'number' then
      spellTexture = ability_name
   end
   
   local keybinds = {}
   local keybind = ""
   
   if not spellTexture then
      -- .delay
      -- .depth
      -- .time
      -- .wait
      
      local itemName, itemLink, itemQuality, itemLevel, itemMinLevel, itemType, itemSubType, itemStackCount, itemEquipLoc, itemTexture, sellPrice, classID, subclassID, bindType, expansionID, setID, isCraftingReagent = C_Item.GetItemInfo(ability_name)
      spellTexture = itemTexture
   end
   
   if spellTexture then
      --print(spellTexture)
      
      local actionBindingMap = {
         {1,'ACTIONBUTTON'},
         {61,'MULTIACTIONBAR1BUTTON'},
         {49,'MULTIACTIONBAR2BUTTON'},
         {25,'MULTIACTIONBAR3BUTTON'},
         {37,'MULTIACTIONBAR4BUTTON'},
      }
      
      for bar=1,#actionBindingMap do
         
         local actionIndex  = actionBindingMap[bar][1]
         local bindingLabel = actionBindingMap[bar][2]
         
         for slot=1,12 do
            
            local actionId                = actionIndex-1 + slot
            local type, globalId, subType = GetActionInfo(actionId)
            
            if globalId then
               local texture              = C_Spell.GetSpellTexture(globalId)
            end
            
            local actionTexture           = GetActionTexture(actionId)
            
            local bindingId               = bindingLabel .. slot
            local command, key1, key2     = GetBindingKey(bindingId)
            
            if spellTexture == texture or spellTexture == actionTexture then
               
               --   local keybind = ""
               keybind = ""
               
               if command then
                  
                  if string.find(command, 'CTRL') then keybind = keybind .. "C" end
                  if string.find(command, 'SHIFT') then keybind = keybind .. "S" end
                  if string.find(command, 'ALT') then keybind = keybind .. "A" end
                  keybind = keybind .. string.sub(command,-1,-1)
                  
               end
               
               return keybind
               
            end
            
         end
         
      end
      
   end
   
   return keybind
   
end

function parse_auras(auraName)
   
   local ignore = {'Variables', 'Toggles', 'Pixel', 'Pixel 2', 'Update Wowza', 'Functions'}

   local data = WeakAuras.GetData(auraName)
   
   for a,b in pairs(ignore) do
      if b == data.id then
         return
      end
   end
   
   local auras = {}
   
   if data.controlledChildren then
      
      for index,name in pairs(data.controlledChildren) do
         
         local auras2 = parse_auras(name)
         
         if auras2 then
            for a,b in pairs(auras2) do
               table.insert(auras, b)
            end
         end
         
      end
      
   else
      table.insert(auras, data.id)
   end
   
   return auras
   
end

function KeybindToColor(keybind)

      local MOD_CONTROL = 1
      local MOD_SHIFT   = 2
      local MOD_ALT     = 4
      
      local r,g,b = 0,0,0
      local key, mod
      
      local keybind = keybind:lower()
      
      if #keybind == 1 then
      key = keybind
      
      else
      key = keybind:sub(-1)
      mod = keybind:sub(1,#keybind-1)
      
      if string.find(mod, 'c') then r = r + MOD_CONTROL end
      if string.find(mod, 's') then r = r + MOD_SHIFT end
      if string.find(mod, 'a') then r = r + MOD_ALT end
      
      end
      
      b = string.byte(key)
      
      return r,g,b

end


function ColorToRegion(r,g,b)
   
   local region = WeakAuras.GetRegion('Pixel')
   
   if region then
     
     if r then r = r/255 end
     if b then b = b/255 end
     
     local current = {region.color_r, region.color_b}
     local new     = {r,b}
     
     if current ~= new then
       region:Color(r,0,b,1)
       return true
     end
     
   end
   
end


function KeybindToRegion(keybind)
  
   if keybind and KeybindToColor then
     
     local map = {}
     map['tab'] = {0,0,9}
     map['wait'] = {0,0,0}
     
     for k,v in pairs(map) do
       local r,g,b = v[1], v[2], v[3]
       if keybind == k then
         if ColorToRegion then
           ColorToRegion(r,g,b)
           return true
         end
       end
     end
     
     local r,g,b = KeybindToColor(keybind)
     
     if b and ColorToRegion then
       ColorToRegion(r,g,b)
       return true
      end
   
   end

end

function UpdateWowza()

   Wowza.group = Wowza.Group:new()

   local focus_name, _ = UnitName('focus')

   if focus_name ~= Wowza.focus.name then
      Wowza.focus.name = focus_name
      Wowza.focus.last_change = GetTime()
   end

   Wowza.focus.time_since_change = GetTime() - Wowza.focus.last_change

   local auras = parse_auras('Wowza')

   for a,b in pairs(WeakAurasSaved.displays) do
      if WeakAuras.IsAuraLoaded(a) then
         if string.find(a, 'Wowza:') then
            local aurasNew = parse_auras(a)
            for c,d in pairs(aurasNew) do
               table.insert(auras, d)
            end
            
         end
      end
   end


   for i=#auras,1, -1 do
      
      index,auraName = i, auras[i]

      local data = WeakAuras.GetData(auraName)

      local isActive = WeakAuras.IsAuraActive(auraName)

      if data.triggers.disjunctive == 'custom' then
         local triggerFunc = WeakAuras.LoadFunction('return ' .. data.triggers.customTriggerLogic)
         local triggers = WeakAuras.GetActiveTriggers(auraName)
         isActive = triggerFunc(triggers)
      end

      if isActive == true then

         if data.customText and string.find(data.customText, 'aura_env') then

            local func = WeakAuras.LoadFunction('return ' .. data.triggers[1].trigger.custom)
            local keybind = func()
            if keybind then
               if auraName ~= Wowza.last_cast then
                  -- print(auraName)
                  Wowza.last_cast = auraName
               end
               return KeybindToRegion(keybind)
            end

         else if data.customText then

            local func = WeakAuras.LoadFunction('return ' .. data.customText)
            local keybind = func()

            if keybind then
               if auraName ~= Wowza.last_cast then
                  print(auraName)
                  Wowza.last_cast = auraName
               end
               return KeybindToRegion(keybind)
            end
         end
      end

      end
   end

end

Wowza       = {}
Wowza.Group = {}
Wowza.Unit  = {}
Wowza.Aura  = {}

Wowza.last_cast = nil

Wowza.focus = {
   name = nil,
   last_change = 0,
   time_since_change = 0
}

local frame = CreateFrame('Frame')
frame:SetScript("OnUpdate", UpdateWowza)