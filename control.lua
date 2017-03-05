-- luacheck: globals refresh_rate global game defines script
local controllersPerTick = 5
local alphasPerTick = 10

local function removeSpriteObj(obj)
  if obj.valid then
    if obj.passenger then
      obj.passenger.destroy()
    end
    obj.clear_items_inside()
    obj.destroy()
  end
end

local function removeSpriteObjs(nixie)
  for _,obj in pairs(global.spriteobjs[nixie.unit_number]) do
    if obj.valid then
      if obj.passenger then
        obj.passenger.destroy()
      end
      obj.clear_items_inside()
      obj.destroy()
    end
  end
end

local smallstep=1/12
local bigstep=1/80
--build LuT to convert states into orientation values.
local function projected_orientation(turn)
  local x = math.sin(turn * math.pi * 2)
  local y = -math.cos(turn * math.pi * 2)

  y = y * math.cos(math.pi / 4)

  return math.atan2(x, -y) / (math.pi * 2)
end

local stateOrientMap = {
  { -- state map for big nixies
  ["0"]=projected_orientation(0*bigstep),
  ["1"]=projected_orientation(1*bigstep),
  ["2"]=projected_orientation(2*bigstep),
  ["3"]=projected_orientation(3*bigstep),
  ["4"]=projected_orientation(4*bigstep),
  ["5"]=projected_orientation(5*bigstep),
  ["6"]=projected_orientation(6*bigstep),
  ["7"]=projected_orientation(7*bigstep),
  ["8"]=projected_orientation(8*bigstep),
  ["9"]=projected_orientation(9*bigstep),
  ["A"]=projected_orientation(10*bigstep),
  ["B"]=projected_orientation(11*bigstep),
  ["C"]=projected_orientation(12*bigstep),
  ["D"]=projected_orientation(13*bigstep),
  ["E"]=projected_orientation(14*bigstep),
  ["F"]=projected_orientation(15*bigstep),
  ["G"]=projected_orientation(16*bigstep),
  ["H"]=projected_orientation(17*bigstep),
  ["I"]=projected_orientation(18*bigstep),
  ["J"]=projected_orientation(19*bigstep),
  ["K"]=projected_orientation(20*bigstep),
  ["L"]=projected_orientation(21*bigstep),
  ["M"]=projected_orientation(22*bigstep),
  ["N"]=projected_orientation(23*bigstep),
  ["O"]=projected_orientation(24*bigstep),
  ["P"]=projected_orientation(25*bigstep),
  ["Q"]=projected_orientation(26*bigstep),
  ["R"]=projected_orientation(27*bigstep),
  ["S"]=projected_orientation(28*bigstep),
  ["T"]=projected_orientation(29*bigstep),
  ["U"]=     projected_orientation(30*bigstep),
  ["V"]=     projected_orientation(31*bigstep),
  ["W"]=     projected_orientation(32*bigstep),
  ["X"]=     projected_orientation(33*bigstep),
  ["Y"]=     projected_orientation(34*bigstep),
  ["Z"]=     projected_orientation(35*bigstep),
  ["err"]=   projected_orientation(36*bigstep),
  ["dot"]=   projected_orientation(37*bigstep),
  ["negative"]= projected_orientation(38*bigstep), -- for negative numbers

  --extended symbols
  ["off"]=   projected_orientation(39*bigstep),
  ["?"]=projected_orientation(40*bigstep),
  ["!"]=projected_orientation(41*bigstep),
  ["@"]=projected_orientation(42*bigstep),
  ["["]=projected_orientation(43*bigstep),
  ["]"]=projected_orientation(44*bigstep),
  ["{"]=projected_orientation(45*bigstep),
  ["}"]=projected_orientation(46*bigstep),
  ["("]=projected_orientation(47*bigstep),
  [")"]=projected_orientation(48*bigstep),
  ["/"]=projected_orientation(49*bigstep),
  ["*"]=projected_orientation(50*bigstep),
  ["-"]=projected_orientation(51*bigstep), -- for subtraction operation
  ["+"]=projected_orientation(52*bigstep),

  },
  { -- state map for small nixies
  ["off"]=smallstep*0,
  ["0"]=smallstep*1,
  ["1"]=smallstep*2,
  ["2"]=smallstep*3,
  ["3"]=smallstep*4,
  ["4"]=smallstep*5,
  ["5"]=smallstep*6,
  ["6"]=smallstep*7,
  ["7"]=smallstep*8,
  ["8"]=smallstep*9,
  ["9"]=smallstep*10,
  ["negative"]=smallstep*11,
  },
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
  ["signal-negative"] = "negative",
  ["train-stop"] = "dot", -- for compatibility with earlier versions

  --extended symbols
  ["signal-stop"] = "dot",
  ["signal-qmark"]="?",
  ["signal-exmark"]="!",
  ["signal-at"]="@",
  ["signal-sqopen"]="[",
  ["signal-sqclose"]="]",
  ["signal-curopen"]="{",
  ["signal-curclose"]="}",
  ["signal-paropen"]="(",
  ["signal-parclose"]=")",
  ["signal-slash"]="/",
  ["signal-asterisk"]="*",
  ["signal-minus"]="-",
  ["signal-plus"]="+",
}

local signalColorMap = {
  ["off"]           = {r=1.0,  g=1.0,  b=1.0, a=1}, -- off state, no glow
  ["default"]       = {r=1.0,  g=0.6,  b=0.2, a=1}, -- pretty close to original-orange
  ["signal-red"]    = {r=1.0,  g=0.2,  b=0.2, a=1},
  ["signal-green"]  = {r=0.2,  g=1.0,  b=0.2, a=1},
  ["signal-blue"]   = {r=0.6,  g=0.6,  b=1.0, a=1}, -- pure blue is too dark, so brighten it up just a little bit
  ["signal-yellow"] = {r=1.0,  g=1.0,  b=0.2, a=1},
  ["signal-pink"]   = {r=1.0,  g=0.4,  b=1.0, a=1},
  ["signal-cyan"]   = {r=0.0,  g=1.0,  b=1.0, a=1},
}

local function RegisterStrings()
  if remote.interfaces['signalstrings'] and remote.interfaces['signalstrings']['register_signal'] then
    local syms = {
      ["signal-stop"] = ".",
      ["signal-qmark"]="?",
      ["signal-exmark"]="!",
      ["signal-at"]="@",
      ["signal-sqopen"]="[",
      ["signal-sqclose"]="]",
      ["signal-curopen"]="{",
      ["signal-curclose"]="}",
      ["signal-paropen"]="(",
      ["signal-parclose"]=")",
      ["signal-slash"]="/",
      ["signal-asterisk"]="*",
      ["signal-minus"]="-",
      ["signal-plus"]="+",
    }
    for name,char in pairs(syms) do
      remote.call('signalstrings','register_signal',name,char)
    end
  end
end


--sets the state(s) and update the sprite for a nixie
local function setStates(nixie,newstates,color)
  for key,new_state in pairs(newstates) do
    local obj = global.spriteobjs[nixie.unit_number][key]
    if obj and obj.valid then
      if nixie.energy > 70 then
        obj.orientation=stateOrientMap[#newstates][new_state]
        if not color then color=signalColorMap["default"] end
        if new_state == "off" then color=signalColorMap["off"] end
        -- create and color a passenger
        if not obj.passenger then
          obj.passenger = obj.surface.create_entity{name="nixie-colorman", position=obj.position,force=obj.force}
          obj.passenger.active=false
        end
        obj.passenger.color=color
      else
        obj.orientation=stateOrientMap[#newstates]["off"]
      end
    else
      game.players[1].print("invalid nixie?")
    end
  end
end

-- from binbinhfr/SmartDisplay, modified to check both wires and add them
local function get_signal_value(entity)
	local behavior = entity.get_control_behavior()
	if behavior == nil then	return nil end

	local condition = behavior.circuit_condition
	if condition == nil then return nil end

  -- shortcut, return stored value if unchanged
  if condition.fulfilled and condition.condition.comparator=="=" then
    return condition.condition.constant,false
  end

	local signal = condition.condition.first_signal

	if signal == nil or signal.name == nil then return(nil)	end

	local redval,greenval=0,0

	local network = entity.get_circuit_network(defines.wire_type.red)
	if network then
	  redval = network.get_signal(signal)
	end

	network = entity.get_circuit_network(defines.wire_type.green)
	if network then
	  greenval = network.get_signal(signal)
	end


	local val = redval + greenval

  condition.condition.comparator="="
  condition.condition.constant=val
  condition.condition.second_signal=nil
  behavior.circuit_condition = condition
	return val,true
end

local validEntityName = {
  ['nixie-tube']       = 1,
  ['nixie-tube-alpha'] = 1,
  ['nixie-tube-small'] = 2
}

local function displayBlank(entity)
  local nextdigit = global.nextdigit[entity.unit_number]

  setStates(entity,(#global.spriteobjs[entity.unit_number]==1) and {"off"} or {"off","off"})
  if nextdigit and nextdigit.valid then
    displayBlank(nextdigit)
  end
end

local function displayNegative(entity,color)
  local nextdigit = global.nextdigit[entity.unit_number]

  setStates(entity,(#global.spriteobjs[entity.unit_number]==1) and {"negative"} or {"off","negative"},color)
  if nextdigit and nextdigit.valid then
    displayBlank(nextdigit)
  end
end

local function displayValue(entity,v,color)
  local negative=v<0
  if negative then v=-v end
  local nextdigit = global.nextdigit[entity.unit_number]

  if #global.spriteobjs[entity.unit_number] == 1 then
    local m=v%10
    v=(v-m)/10
    local state = tostring(m)
    setStates(entity,{state},color)
    if nextdigit and nextdigit.valid then
      if v == 0 and negative then
        displayNegative(nextdigit,color)
      elseif negative then
        displayValue(nextdigit,-v,color)
      elseif v == 0 then
        displayBlank(nextdigit)
      else
        displayValue(nextdigit,v,color)
      end
    end
  else
    local m=v%100 -- two digits for this pair of nixies
    v=(v-m)/100 -- remove two digits from what's left
    local n=m%10 -- ones digit for this pair
    m=(m-n)/10 -- tens digit for this pair
    local state1
    local state2 = tostring(n)
    if m>0 or v>0 then
      state1 = tostring(m)
    elseif negative then
      state1 = "negative"
      negative = nil
    else
      state1 = "off"
    end
    setStates(entity,{state1,state2},color)

    if nextdigit and nextdigit.valid then
      if v == 0 and negative then
        displayNegative(nextdigit,color)
      elseif negative then
        displayValue(nextdigit,-v,color)
      elseif v == 0 then
        displayBlank(nextdigit)
      else
        displayValue(nextdigit,v,color)
      end
    end
  end
end

local function getAlphaSignals(entity,wire_type,charsig,colorsig)
  local net = entity.get_circuit_network(wire_type)

  local ch,co = charsig,colorsig

  if net then
    for _,s in pairs(net.signals) do
      if signalCharMap[s.signal.name] then
        if ch then
          ch = "err"
        else
          ch = signalCharMap[s.signal.name]
        end
      end
      if signalColorMap[s.signal.name] then
        co = signalColorMap[s.signal.name]
      end
    end
  end

  return ch,co
end

local function getColorSignals(entity,wire_type,colorsig)
  local net = entity.get_circuit_network(wire_type)

  local co = colorsig

  if net then
    for _,s in pairs(net.signals) do
      local c = signalColorMap[s.signal.name]
      if c then co = c end
    end
  end

  return co
end

local function onTickController(entity)
  if not entity.valid then
    onRemoveEntity(entity)
    return
  end

  local _,color = nil,nil
  if entity.get_or_create_control_behavior().use_colors then
    color=getColorSignals(entity,defines.wire_type.red,color)
    color=getColorSignals(entity,defines.wire_type.green,color)
  end

  local v,changed=get_signal_value(entity)
  if v then
    if changed or color then
      displayValue(entity,v,color)
    end
  else
    displayBlank(entity)
  end
end

local function onTickAlpha(entity)
  if not entity then return end

  if not entity.valid then
    onRemoveEntity(entity)
    return
  end

  local charsig,color = nil,nil

  charsig,color=getAlphaSignals(entity,defines.wire_type.red,  charsig,color)
  charsig,color=getAlphaSignals(entity,defines.wire_type.green,charsig,color)
  charsig = charsig or "off"

  if not entity.get_or_create_control_behavior().use_colors then color=nil end

  setStates(entity,{charsig},color)
end


local function onTick(event)

  for _=1,controllersPerTick do
    local nixie
    global.next_controller,nixie = next(global.controllers,global.next_controller)
    if nixie then onTickController(nixie) end
  end

  for _=1,alphasPerTick do
    local nixie
    global.next_alpha,nixie = next(global.alphas,global.next_alpha)
    if nixie then onTickAlpha(nixie) end
  end
end

local function onPlaceEntity(event)

  local entity=event.created_entity
  if not entity.valid then return end

  local num = validEntityName[entity.name]
  if num then
    local pos=entity.position
    local surf=entity.surface

    local sprites = {}
    for n=1, num do
      --place the /real/ thing(s) at same spot
      local name, position
      if num == 1 then -- large tube, one sprite
        name = "nixie-tube-sprite"
        position = {x=pos.x+1/32, y=pos.y+1/32}
      else
        name = "nixie-tube-small-sprite"
        position = {x=pos.x-4/32+((n-1)*10/32), y=pos.y+4/32}
      end
      local sprite=surf.create_entity(
        {
              name=name,
              position=position,
            force=entity.force
        })
      sprite.orientation=0
      sprite.insert({name="coal",count=1})
      sprites[n]=sprite
    end
    global.spriteobjs[entity.unit_number] = sprites

    if entity.name == "nixie-tube-alpha" then
      global.alphas[entity.unit_number] = entity
    else
      --enslave guy to left, if there is one
      local neighbors=surf.find_entities_filtered{
        position={x=entity.position.x-1,y=entity.position.y},
        name=entity.name}
      for _,n in pairs(neighbors) do
        if n.valid then

          if global.next_controller == n.unit_number then
            -- if it's currently the *next* controller, claim that too...
            global.next_controller = entity.unit_number
          end

          global.controllers[n.unit_number] = nil
          global.nextdigit[entity.unit_number] = n
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
          global.nextdigit[n.unit_number]=entity
        end
      end
      if not foundright then
        global.controllers[entity.unit_number] = entity
        setStates(entity,(#global.spriteobjs[entity.unit_number]==1) and {"0"} or {"off","0"})
      end
    end
  end
end

local function onRemoveEntity(entity)
  local _
  if entity.valid then
    if validEntityName[entity.name] then
      removeSpriteObjs(entity)

      --if I was a controller, deregister
      if global.next_controller == entity.unit_number then
        -- if i was the *next* controller, pass it forward...
        global.next_controller,_ = next(global.controllers,global.next_controller)
      end
      global.controllers[entity.unit_number]=nil

      --if i was an alpha, deregister
      if global.next_alpha == entity.unit_number then
        -- if i was the *next* alpha, pass it forward...
        global.next_alpha,_ = next(global.alphas,global.next_alpha)
      end
      global.alphas[entity.unit_number]=nil

      --if I had a next-digit, register it as a controller
      local nextdigit = global.nextdigit[entity.unit_number]
      if nextdigit and nextdigit.valid then
        global.controllers[nextdigit.unit_number] = nextdigit
        displayBlank(nextdigit)
      end

    end
  end
end

script.on_init(function()
  global.alphas = {}
  global.controllers = {}
  global.spriteobjs = {}
  global.nextdigit = {}

  RegisterStrings()
end)

script.on_load(function()
  RegisterStrings()
end)

script.on_configuration_changed(function(data)
  if data.mod_changes and data.mod_changes["nixie-tubes"] then
    --If my data has changed, rebuild all my tables. There are so many old formats, there's no other sensible way to upgrade.

    -- remove ancient config if it's still here
    if global.nixie_tubes then global.nixie_tubes = nil end

    -- clear the tables
    global.alphas = {}
    global.controllers = {}
    global.spriteobjs = {}
    global.nextdigit = {}

    -- and re-index the world
    for _,surf in pairs(game.surfaces) do
      -- Destroy old sprite objects
      for _,sprite in pairs(surf.find_entities_filtered{name="nixie-tube-sprite"}) do
        removeSpriteObj(sprite)
      end
      for _,sprite in pairs(surf.find_entities_filtered{name="nixie-tube-small-sprite"}) do
        removeSpriteObj(sprite)
      end

      -- And re-index all nixies. non-nixie lamps will be ignored by onPlaceEntity
      for _,lamp in pairs(surf.find_entities_filtered{type="lamp"}) do
        onPlaceEntity({created_entity=lamp})
      end
    end
  end
end)

script.on_event(defines.events.on_built_entity, onPlaceEntity)
script.on_event(defines.events.on_robot_built_entity, onPlaceEntity)

script.on_event(defines.events.on_preplayer_mined_item, function(event) onRemoveEntity(event.entity) end)
script.on_event(defines.events.on_robot_pre_mined, function(event) onRemoveEntity(event.entity) end)
script.on_event(defines.events.on_entity_died, function(event) onRemoveEntity(event.entity) end)

script.on_event(defines.events.on_tick, onTick)

script.on_event(defines.events.on_player_driving_changed_state,
    function(event)
      local player=game.players[event.player_index]
      if player.vehicle and
        (player.vehicle.name=="nixie-tube-sprite" or
          player.vehicle.name=="nixie-tube-small-sprite") then
        player.vehicle.passenger=nil
      end
    end
  )
