local numberType = require("number_type")
local plugins = require("plugins")


local script = script
local remote = remote
local commands = commands
local rendering = rendering
local settings = settings
local dwcircuit_green = defines.wire_connector_id.circuit_green
local dwcircuit_red = defines.wire_connector_id.circuit_red

local ssub = string.sub
local bband = bit32.band
local pairs = pairs
local next = next
local pcall = pcall
local log = log
local tostring = tostring

--local _ENV = nil

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
  ["signal-colon"]=":",

  --extended symbols
  ["signal-at"]="@",
  ["signal-curopen"]="{",
  ["signal-curclose"]="}",
}

local state_names = {
  ["off"] = "nixie-tube-sprite-off",
  [" "] = "nixie-tube-sprite-off",
  ["\0"] = "nixie-tube-sprite-off",

  ['.'] = "nixie-tube-sprite-dot",
  ['/'] = "nixie-tube-sprite-slash",
}
do
  local chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789?!(){}*@+[]-%:"
  for i = 1, #chars do
    local c = ssub(chars,i,i)
    state_names[c] = "nixie-tube-sprite-"..c
  end
end

--sets the state(s) and update the sprite for a nixie
local is_simulation = script.level.is_simulation

---@param nixie LuaEntity
---@param cache NixieCache
---@param newstates string[]
---@param newcolor? Color
local function setStates(nixie,cache,newstates,newcolor)
  nixie.always_on = true
  for key,new_state in pairs(newstates) do
    new_state = state_names[new_state] or "nixie-tube-sprite-err"

    local sprite = cache.sprites[key]
    if not (sprite and sprite.valid) then
      cache.lastcolor[key] = nil

      local num = validEntityName[nixie.name]
      ---@type Vector.0
      local position
      if num == 1 then -- large tube, one sprite
        position = {x=1/32, y=1/32}
      else
        position = {x=-9/64+((key-1)*20/64), y=3/64} -- sprite offset
      end
      sprite = rendering.draw_sprite{
        sprite = new_state,
        target = { entity = nixie, offset = position},
        surface = nixie.surface,
        tint = {r=1.0,  g=1.0,  b=1.0, a=1.0},
        x_scale = 1/num,
        y_scale = 1/num,
        render_layer = "object",
        }

      cache.sprites[key] = sprite
    end

    if nixie.energy > 70 or is_simulation then
      sprite.sprite = new_state

      local color = newcolor
      if not color then color = {r=1.0,  g=0.6,  b=0.2, a=1.0} end
      if new_state == "nixie-tube-sprite-off" then color={r=1.0,  g=1.0,  b=1.0, a=1.0} end

      local lastcolor = cache.lastcolor[key]
      if not (lastcolor and (lastcolor.r == color.r) and (lastcolor.g == color.g) and (lastcolor.b == color.b) and (lastcolor.a == color.a)) then
        cache.lastcolor[key] = color
        sprite.color = color
      end
    else
      if sprite.sprite ~= "nixie-tube-sprite-off" then
        sprite.sprite = "nixie-tube-sprite-off"
      end
      sprite.color = {r=1.0,  g=1.0,  b=1.0, a=1.0}
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
    local unit_number = entity.unit_number
    ---@cast unit_number -?
    ---@type LuaEntity?
    local nextdigit = storage.nextdigit[unit_number]
    local cache = getCache(unit_number)
    local chcount = validEntityName[entity.name]

    if not vs then
      setStates(entity,cache,(chcount==1) and {"off"} or {"off","off"})
    elseif offset < chcount then
      setStates(entity,cache,{"off",ssub(vs,offset,offset)},color)
    elseif offset >= chcount then
      setStates(entity,cache,
        (chcount==1) and
          {ssub(vs,offset,offset)} or
          {ssub(vs,offset-1,offset-1),ssub(vs,offset,offset)}
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
        storage.nextdigit[unit_number] = nil
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
  local signals = entity.get_signals(dwcircuit_red, dwcircuit_green)
  ---@type string?
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

  local typeCode = entity.get_signal(sigNumType, dwcircuit_red, dwcircuit_green)
  local numType = numberType.map[typeCode] or numberType.default

  local hex = entity.get_signal(sigHex, dwcircuit_green, dwcircuit_red) ~= 0

  local selected = get_selected_signal(control)
  ---@type number
  local value = 0
  if selected then
    -- force type on the typecode signal to be type enum...
    if selected.quality == sigNumType.quality and selected.type==sigNumType.type and selected.name==sigNumType.name then
      numType = numberType.typecode
    end

    local success,result
    if numType.split_read then
      success,result = pcall(numType.read, entity.get_signal(selected, dwcircuit_green), entity.get_signal(selected, dwcircuit_red))
    else
      local read = numType.read
      if read then
        success,result = pcall(read, entity.get_signal(selected, dwcircuit_red, dwcircuit_green))
      else
        success,result = true, entity.get_signal(selected, dwcircuit_red, dwcircuit_green)
      end
    end
    if success then
      value = result
    else
      log{"", "Error in Nixie Tubes Plugin ", numType.from_plugin or "(?)", "[", typeCode, "].read: ", tostring(result) }
    end
  end

  local use_colors = control.use_colors
  -- flags up beyond 32b values to keep space free for the whole format code range
  local flags = bband(typeCode) + (hex and 0x100000000 or 0) + (use_colors and 0x200000000 or 0)

  --if value or any flags changed, or always update while use_colors...
  if cache.lastvalue ~= value or use_colors or flags ~= cache.flags then
    cache.flags = flags
    cache.lastvalue = value

    local success,result = pcall(numType.format, value, hex)
    if not success then
      log{"", "Error in Nixie Tubes Plugin ", numType.from_plugin or "(?)", ".format: ", tostring(result) }
      result = "PLUGIN\1"
    end
    displayValString(entity, result, use_colors and control.color or entity.color)
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
    color = control.color
  else
    color = entity.color
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

script.on_event(defines.events.on_script_trigger_effect, function (event)
  if event.effect_id == "nixie-created" then
    local entity = event.cause_entity
    if entity then
      onPlaceEntity(entity)
    end
  end
end)

plugins.load()