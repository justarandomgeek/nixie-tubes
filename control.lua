local sunpack = string.unpack
local spack = string.pack
local sformat = string.format
local dwire_connector_id = defines.wire_connector_id

---@class NixieStorage
---@field alphas {[integer]:LuaEntity?}
---@field next_alpha? integer
---@field controllers {[integer]:LuaEntity?}
---@field next_controller? integer
---@field nextdigit {[integer]:LuaEntity?}
---@field cache {[integer]:NixieCache?}
storage = {}

---@class NixieCache
---@field control? LuaLampControlBehavior
---@field flags? integer
---@field lastvalue? integer
---@field lastcolor Color[]
---@field sprites LuaRenderObject[]


---@param unit_number integer
---@return NixieCache
local function getCache(unit_number)
  local cache = storage.cache[unit_number]
  if not cache then
    cache = {
      lastcolor = {},
      sprites = {},
    }
    storage.cache[unit_number] = cache
  end
  return cache
end

local validEntityName = {
  ['nixie-tube']       = 1,
  ['nixie-tube-alpha'] = 1,
  ['nixie-tube-small'] = 2
}

local signalCharMap = {
  ["signal-0"] = "0",
  ["signal-1"] = "1",
  ["signal-2"] = "2",
  ["signal-3"] = "3",
  ["signal-4"] = "4",
  ["signal-5"] = "5",
  ["signal-6"] = "6",
  ["signal-7"] = "7",
  ["signal-8"] = "8",
  ["signal-9"] = "9",
  ["signal-A"] = "A",
  ["signal-B"] = "B",
  ["signal-C"] = "C",
  ["signal-D"] = "D",
  ["signal-E"] = "E",
  ["signal-F"] = "F",
  ["signal-G"] = "G",
  ["signal-H"] = "H",
  ["signal-I"] = "I",
  ["signal-J"] = "J",
  ["signal-K"] = "K",
  ["signal-L"] = "L",
  ["signal-M"] = "M",
  ["signal-N"] = "N",
  ["signal-O"] = "O",
  ["signal-P"] = "P",
  ["signal-Q"] = "Q",
  ["signal-R"] = "R",
  ["signal-S"] = "S",
  ["signal-T"] = "T",
  ["signal-U"] = "U",
  ["signal-V"] = "V",
  ["signal-W"] = "W",
  ["signal-X"] = "X",
  ["signal-Y"] = "Y",
  ["signal-Z"] = "Z",
  ["signal-letter-dot"] = "dot",
  ["signal-question-mark"]="?",
  ["signal-exclamation-mark"]="!",
  ["signal-left-square-bracket"]="[",
  ["signal-right-square-bracket"]="]",
  ["signal-left-parenthesis"]="(",
  ["signal-right-parenthesis"]=")",
  ["signal-multiplication"]="*",
  ["signal-slash"]="slash",
  ["signal-minus"]="-",
  ["signal-plus"]="+",
  ["signal-percent"]="%",

  --extended symbols
  ["signal-at"]="@",
  ["signal-curopen"]="{",
  ["signal-curclose"]="}",
}

local state_names = {
  ['.'] = "dot",
  ['/'] = "slash",
}

--sets the state(s) and update the sprite for a nixie
local is_simulation = script.level.is_simulation

---@param nixie LuaEntity
---@param cache NixieCache
---@param newstates string[]
---@param newcolor? Color
local function setStates(nixie,cache,newstates,newcolor)
  for key,new_state in pairs(newstates) do
    if not new_state or new_state == "off" then
      new_state = "off"
    elseif string.match(new_state, "[^A-Z0-9.?!(){}*@/+[%]%-%%]") then -- any undisplayable characters
      new_state = "err"
    else -- and a few chars need renames...
      new_state = state_names[new_state] or new_state
    end

    local obj = cache.sprites[key]
    if not (obj and obj.valid) then
      cache.lastcolor[key] = nil

      local num = validEntityName[nixie.name]
      ---@type Vector.0
      local position
      if num == 1 then -- large tube, one sprite
        position = {x=1/32, y=1/32}
      else
        position = {x=-9/64+((key-1)*20/64), y=3/64} -- sprite offset
      end
      obj = rendering.draw_sprite{
        sprite = "nixie-tube-sprite-" .. new_state,
        target = { entity = nixie, offset = position},
        surface = nixie.surface,
        tint = {r=1.0,  g=1.0,  b=1.0, a=1.0},
        x_scale = 1/num,
        y_scale = 1/num,
        render_layer = "object",
        }

      cache.sprites[key] = obj
    end

    if nixie.energy > 70 or is_simulation then
      obj.sprite = "nixie-tube-sprite-" .. new_state

      local color = newcolor
      if not color then color = {r=1.0,  g=0.6,  b=0.2, a=1.0} end
      if new_state == "off" then color={r=1.0,  g=1.0,  b=1.0, a=1.0} end

      if not (cache.lastcolor[key] and (cache.lastcolor[key].r == color.r) and (cache.lastcolor[key].g == color.g) and (cache.lastcolor[key].b == color.b) and (cache.lastcolor[key].a == color.a)) then
        cache.lastcolor[key] = color
        obj.color = color
      end
    else
      if obj.sprite ~= "nixie-tube-sprite-off" then
        obj.sprite = "nixie-tube-sprite-off"
      end
      obj.color = {r=1.0,  g=1.0,  b=1.0, a=1.0}
      cache.lastcolor[key] = nil
    end
  end
end

---@param behavior LuaLampControlBehavior
---@return SignalID?
local function get_selected_signal(behavior)
  if behavior == nil then
    return nil
  end

	local condition = behavior.circuit_condition
	if condition == nil then
    return nil
  end

  behavior.circuit_enable_disable = true
  local signal = condition.first_signal --[[@as SignalID? ]]
  if signal and not condition.fulfilled then
    -- use >= MININT32 to ensure always-on
    condition.comparator="≥"
    condition.constant=-0x80000000
    condition.second_signal=nil
    behavior.circuit_condition = condition
  end

  if signal and signal.name then
    return signal
  end

  return nil
end

---@param entity LuaEntity
---@param vs? string
---@param color? Color
local function displayValString(entity,vs,color)
  local offset = vs and #vs or 0
  while entity do
    ---@type LuaEntity?
    local nextdigit = storage.nextdigit[entity.unit_number]
    local cache = getCache(entity.unit_number)
    local chcount = #cache.sprites

    if not vs then
      setStates(entity,cache,(chcount==1) and {"off"} or {"off","off"})
    elseif offset < chcount then
      setStates(entity,cache,{"off",vs:sub(offset,offset)},color)
    elseif offset >= chcount then
      setStates(entity,cache,
        (chcount==1) and
          {vs:sub(offset,offset)} or
          {vs:sub(offset-1,offset-1),vs:sub(offset,offset)}
        ,color)
    end

    if nextdigit then
      if nextdigit.valid then
        if offset>chcount then
          offset = offset-chcount
        else
          vs = nil
        end
      else
        --when a nixie in the middle is removed, it doesn't have the unit_number to it's right to remove itself
        storage.nextdigit[entity.unit_number] = nil
        nextdigit = nil
      end
    end
    ---@diagnostic disable-next-line:cast-local-type
    entity = nextdigit
  end
end

---@param entity LuaEntity
---@return string?
local function getAlphaSignals(entity)
  local signals = entity.get_signals(dwire_connector_id.circuit_red, dwire_connector_id.circuit_green)
  ---@type string
  local ch

  if signals and #signals > 0 then
    for _,s in pairs(signals) do
      if s.signal.type == "virtual" and signalCharMap[s.signal.name] then
        if ch then
          return "err"
        else
          ch = signalCharMap[s.signal.name]
        end
      end
    end
  end

  return ch
end

---@type SignalID
local sigNumType = {name="signal-number-type",type="virtual"}

---@class (exact) NixieTubesNumberType
---@field split_read? false
---@field read fun(value:int32):number
---@field format fun(value:number, hex:boolean):string

---@class (exact) NixieTubesSplitNumberType
---@field split_read true
---@field read fun(green:int32, red:int32):number
---@field format fun(value:number, hex:boolean):string

---@type {[int32]:(NixieTubesNumberType|NixieTubesSplitNumberType)}
local numberType = {
  ---@type NixieTubesNumberType
  default = { -- everything else: int32
    read = function (value)
      return value
    end,
    format = function (value, hex)
      if hex then
        return sformat("%s%X", value<0 and "-" or "", math.abs(value))
      end
      return sformat("%i", value)
    end,
  },
  [-1] = { -- uint32
    read = function (value)
      return bit32.band(value)
    end,
    format = function (value, hex)
      if hex then
        return sformat("%X", value)
      end
      return sformat("%i", value)
    end,
  },
  [1] = { --float
    read = function (value)
      return (sunpack(">f", spack(">i4", value)))
    end,
    format = function (value, hex)
      if hex then
        return sformat("%A", value)
      end
      return sformat("%G", value)
    end,
  },
  [2] = { -- double
    split_read = true,
    read = function (green, red)
      return (sunpack(">d", spack(">i4i4", green, red)))
    end,
    format = function (value, hex)
      if hex then
        return sformat("%A", value)
      end
      return sformat("%.14G", value)
    end,
  },
}

---@param dec_precision integer
---@param hex_precision integer
---@return fun(value:number, hex:boolean):string
local function fixed_format(dec_precision, hex_precision)
  local decfmt = sformat("%%.%if", dec_precision)
  local hexfmt = sformat("%%s%%X.%%0%iX", hex_precision)
  return function(value, hex)
      if hex then
        local sign = value<0 and "-" or ""
        value = math.abs(value)
        local ipart = math.floor(value)
        local fpart = math.fmod(value, 1) * (16^hex_precision)
        return sformat(hexfmt, sign, ipart, fpart)
      end
      return sformat(decfmt, value)
  end
  
end


-- 10 based fractions in type codes 10,100,1000,...
for i = 1,9,1 do
  local format = fixed_format(i, math.ceil(i/1.2))
  local base = 10^i
  numberType[base] = { -- signed
    read = function (value)
      return value / base
    end,
    format = format
  }
  numberType[-base] = { -- unsigned
    read = function (value)
      return bit32.band(value) / base
    end,
    format = format,
  }
end

-- 2 based fractions in type codes 4,8,16,32,...
for i = 2,31,1 do
  local format = fixed_format(math.ceil(i/3.32), math.ceil(i/4))
  local base = 2^i
  numberType[base] = { -- signed
    read = function (value)
      return value / base
    end,
    format = format,
  }

  numberType[-base] = { -- unsigned
    read = function (value)
      return bit32.band(value) / base
    end,
    format = format,
  }
end


---@type SignalID
local sigHex = {name="signal-hex",type="virtual"}

---@param entity LuaEntity
---@param cache NixieCache
local function onTickController(entity,cache)
  local control = cache.control
  if not (control and control.valid) then
    control = entity.get_or_create_control_behavior() --[[@as LuaLampControlBehavior]]
    cache.control = control
  end

  local typeCode = entity.get_signal(sigNumType, dwire_connector_id.circuit_red, dwire_connector_id.circuit_green)
  local numType = numberType[typeCode] or numberType.default

  local hex = entity.get_signal(sigHex, dwire_connector_id.circuit_green, dwire_connector_id.circuit_red) ~= 0

  local selected = get_selected_signal(control)
  ---@type number
  local v = 0
  if selected then
    if numType.split_read then
      v = numType.read(
        entity.get_signal(selected, dwire_connector_id.circuit_green),
        entity.get_signal(selected, dwire_connector_id.circuit_red)
      )
    else
      v = numType.read(entity.get_signal(selected, dwire_connector_id.circuit_red, dwire_connector_id.circuit_green))
    end
  end

  local use_colors = cache.control.use_colors
  -- flags up beyond 32b values to keep space free for the whole format code range
  local flags = bit32.band(typeCode) + (hex and 0x100000000 or 0) + (use_colors and 0x200000000 or 0)

  --if value or any flags changed, or always update while use_colors...
  if cache.lastvalue ~= v or use_colors or flags ~= cache.flags then
    cache.flags = flags
    cache.lastvalue = v

    displayValString(entity,numType.format(v, hex),control.use_colors and control.color or nil)
  end

end

---@param entity LuaEntity
---@param cache NixieCache
local function onTickAlpha(entity,cache)
  ---@type Color?
  local color
  local control = cache.control
  if not (control and control.valid) then
    control = entity.get_or_create_control_behavior() --[[@as LuaLampControlBehavior]]
    cache.control = control
  end
  if control.use_colors then
    entity.always_on = true
    color = control.color
  end
  local is_on = (not control.circuit_enable_disable) or (control.circuit_condition and control.circuit_condition.fulfilled)
  local charsig = is_on and getAlphaSignals(entity) or "off"

  setStates(entity,cache,{charsig},color)
end

script.on_event(defines.events.on_tick, function()
  for _=1, settings.global["nixie-tube-update-speed-numeric"].value do
    ---@type LuaEntity?
    local nixie
    if storage.next_controller and not storage.controllers[storage.next_controller] then
      storage.next_controller=nil
    end

    
    storage.next_controller,nixie = next(storage.controllers,storage.next_controller)
    
    ::retry::
    if nixie then
      if nixie.valid then
        onTickController(nixie,getCache(storage.next_controller))
      else
        -- advance now before removal...
        local gone = storage.next_controller
        ---@cast gone -?
        storage.next_controller,nixie = next(storage.controllers,storage.next_controller)

        -- promote next digit if any
        local nextdigit = storage.nextdigit[gone]
        if nextdigit then
          if nextdigit.valid then
            storage.controllers[nextdigit.unit_number] = nextdigit
            displayValString(nextdigit)
          end
          storage.nextdigit[gone] = nil
        end

        storage.controllers[gone] = nil
        storage.cache[gone] = nil
        goto retry
      end
    else
      break
    end
  end

  for _=1, settings.global["nixie-tube-update-speed-alpha"].value do
    ---@type LuaEntity?
    local nixie
    if storage.next_alpha and not storage.alphas[storage.next_alpha] then
      storage.next_alpha=nil
    end
    
    storage.next_alpha,nixie = next(storage.alphas,storage.next_alpha)

    ::retry::
    if nixie then
      if nixie.valid then
        onTickAlpha(nixie, getCache(storage.next_alpha))
      else
        -- advance now before removal...
        local gone = storage.next_alpha
        ---@cast gone -?
        storage.next_alpha,nixie = next(storage.alphas,storage.next_alpha)

        storage.alphas[gone] = nil
        storage.cache[gone] = nil
        goto retry
      end
    else
      break
    end
  end
end)

script.on_event(defines.events.on_object_destroyed, function (event)
  if event.type ~= defines.target_type.entity then return end
  
  -- promote next digit if any
  local nextdigit = storage.nextdigit[event.useful_id]
  if nextdigit then
    if nextdigit.valid then
      storage.controllers[nextdigit.unit_number] = nextdigit
      displayValString(nextdigit)
    end
    storage.nextdigit[event.useful_id] = nil
  end


end)

---@param entity LuaEntity
local function onPlaceEntity(entity)
  local num = validEntityName[entity.name]
  if num then
    script.register_on_object_destroyed(entity)
    local surf=entity.surface
    local cache =getCache(entity.unit_number)
    local sprites = cache.sprites
    for n=1, num do
      --place the /real/ thing(s) at same spot
      ---@type Vector
      local position
      if num == 1 then -- large tube, one sprite
        position = {x=1/32, y=1/32}
      else
        position = {x=-9/64+((n-1)*20/64), y=3/64} -- sprite offset
      end
      local sprite= rendering.draw_sprite{
        sprite = "nixie-tube-sprite-off",
        target = { entity = entity, offset = position},
        surface = entity.surface,
        tint = {r=1.0,  g=1.0,  b=1.0, a=1.0},
        x_scale = 1/num,
        y_scale = 1/num,
        render_layer = "object",
        }

      sprites[n]=sprite
    end

    cache.control = entity.get_or_create_control_behavior() --[[@as LuaLampControlBehavior]]

    if entity.name == "nixie-tube-alpha" then
      storage.alphas[entity.unit_number] = entity
    else

      --enslave guy to left, if there is one
      local neighbors=surf.find_entities_filtered{
        position={x=entity.position.x-1,y=entity.position.y},
        name=entity.name}
      for _,n in pairs(neighbors) do
        if n.valid then
          if storage.next_controller == n.unit_number then
            -- if it's currently the *next* controller, clear that
            storage.next_controller = nil
          end
          storage.controllers[n.unit_number] = nil
          storage.nextdigit[entity.unit_number] = n
        end
      end

      --slave self to right, if any
      neighbors=surf.find_entities_filtered{
        position={x=entity.position.x+1,y=entity.position.y},
        name=entity.name}
      local foundright=false
      for _,n in pairs(neighbors) do
        if n.valid then
          foundright=true
          storage.nextdigit[n.unit_number]=entity
        end
      end
      if not foundright then
        storage.controllers[entity.unit_number] = entity
      end
    end
  end
end


script.on_init(function()
  storage.alphas = {}
  storage.controllers = {}
  storage.cache = {}
  storage.nextdigit = {}
end)

local function RebuildNixies()
  -- clear the tables
  storage = {
    alphas = {},
    controllers = {},
    cache = {},
    nextdigit = {},
  }

  -- wipe out any lingering sprites i've just deleted the references to...
  rendering.clear("nixie-tubes")

  local names = {}
  for name in pairs(validEntityName) do
    names[#names+1] = name
  end
  -- and re-index the world
  for _,surf in pairs(game.surfaces) do
    -- re-index all nixies
    for _,lamp in pairs(surf.find_entities_filtered{name=names}) do
      onPlaceEntity(lamp)
    end
  end
end

remote.add_interface("nixie-tubes",{
  RebuildNixies = RebuildNixies
})

commands.add_command("RebuildNixies","Reset all Nixie Tubes to clear display glitches.", RebuildNixies)

script.on_configuration_changed(function(data)
  if data.mod_changes and data.mod_changes["nixie-tubes"] then
    RebuildNixies()
  end
end)

local filters = {
}
local names = {}
for name in pairs(validEntityName) do
  filters[#filters+1] = {filter="name",name=name}
  filters[#filters+1] = {filter="ghost_name",name=name}
  names[#names+1] = name
end


script.on_event(defines.events.on_script_trigger_effect, function (event)
  if event.effect_id == "nixie-created" then
    local entity = event.cause_entity
    if entity then
      onPlaceEntity(entity)
    end
  end
end)
