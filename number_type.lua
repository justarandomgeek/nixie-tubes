local sunpack = string.unpack
local spack = string.pack
local sformat = string.format
local bband = bit32.band
local mabs = math.abs
local mceil = math.ceil
local mfloor = math.floor
local mfmod = math.fmod
local _ENV = nil

---@alias NixieTubesFormatFunction fun(value:number, hex:boolean):string

---@class (exact) NixieTubesNumberType
---@field name string
---@field from_plugin? string
---@field split_read? false
---@field read? fun(value:int32):number
---@field format NixieTubesFormatFunction

---@class (exact) NixieTubesSplitNumberType
---@field name string
---@field from_plugin? string
---@field split_read true
---@field read fun(green:int32, red:int32):number
---@field format NixieTubesFormatFunction

---@type {[int32]:(NixieTubesNumberType|NixieTubesSplitNumberType)}
local map = {}

---@param value integer
---@param hex boolean
---@param prefix? string
---@return string
local function int_format(value, hex, prefix)
  if not prefix then prefix = "" end
  if hex then
    if value<0 then
      return sformat("%s-%X", prefix, mabs(value))
    else
      return sformat("%s%X", prefix, mabs(value))
    end
  end
  return sformat("%s%i", prefix, value)
end

---@type NixieTubesNumberType
local default = { -- everything else: int32
  name = "INT32",
  format = int_format,
}
map[0] = default

map[-1] = { -- uint32
  name = "UINT32",
  read = bband,
  format = int_format,
}
map[1] = { --float
  name = "FLOAT",
  read = function (value)
    return (sunpack(">f", spack(">i4", value)))
  end,
  format = function (value, hex)
    if hex then
      return sformat("%A", value)
    end
    return sformat("%G", value)
  end,
}
map[2] = { -- double
  name = "DOUBLE",
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
}

---@param dec_precision integer number of decimal digits after the point
---@param hex_precision integer number of hex digits after the point
---@return NixieTubesFormatFunction
local function make_fixed_format(dec_precision, hex_precision)
  dec_precision = mceil(dec_precision)
  hex_precision = mceil(hex_precision)
  local decfmt = sformat("%%.%if", dec_precision)
  local hexfmt = sformat("%%s%%X.%%0%iX", hex_precision)
  return function(value, hex)
      if hex then
        local sign = value<0 and "-" or ""
        value = mabs(value)
        local ipart = mfloor(value)
        local fpart = mfmod(value, 1) * (16^hex_precision)
        return sformat(hexfmt, sign, ipart, fpart)
      end
      return sformat(decfmt, value)
  end
  
end

---@param base integer
---@param format NixieTubesFormatFunction
local function fixed_base(base, format)
  map[base] = { -- signed
    name = sformat("FIXED /%i", base),
    read = function (value)
      return value / base
    end,
    format = format
  }
  map[-base] = { -- unsigned
    name = sformat("UFIXED /%i", base),
    read = function (value)
      return bband(value) / base
    end,
    format = format,
  }
end

-- 10 based fractions in type codes 10,100,1000,...
for i = 1,9,1 do
  fixed_base(10^i, make_fixed_format(i, i/1.2))
end

-- 2 based fractions in type codes 4,8,16,32,...
for i = 2,31,1 do
  fixed_base(2^i, make_fixed_format(i/3.32, i/4))
end

map[sunpack(">i4", "ASCI")] = {
  name = "4CH ASCII",
  format = function (value, hex)
    return spack(">i4", value)
  end
}


---@generic T
---@param names {[integer]:T} map of value->name or value->object
---@param unknown string name to use if none in map match
---@param getname fun(t:T):string name getter if map is not strings directly
---@return NixieTubesFormatFunction
---@overload fun(names:{[integer]:string},unknown:string):NixieTubesFormatFunction
local function make_enum_format(names, unknown, getname)
  return function (value, hex)
    local found = names[value]
    if found then
      if getname then
        return getname(found)
      end
      return found
    end
    return int_format(value, hex, unknown)
  end
end

---@type NixieTubesNumberType
local typecode = {
  name = "TYPECODE",
  format = make_enum_format(map, "TYPE \1 ", function (t) return t.name end),
}
map[sunpack(">i4", "TYPE")] = typecode

local function time_format(value, hex)
    local sign = value < 0 and "-" or ""
    value = mabs(value)
    local ticks = value % 60
    local seconds = mfloor(value / 60) % 60
    local minutes = mfloor(value / (60*60)) % 60
    local hours = mfloor(value / (60*60*60)) % 24
    local days = mfloor(value / (60*60*60*24))

    if days > 0 then
      return sformat("%s%iD %02i:%02i:%02i.%02i", sign, days, hours, minutes, seconds, ticks)
    elseif hours > 0 then
      return sformat("%s%i:%02i:%02i.%02i", sign, hours, minutes, seconds, ticks)
    elseif minutes > 0 then
      return sformat("%s%i:%02i.%02i", sign, minutes, seconds, ticks)
    else
      return sformat("%s%i.%02i", sign, seconds, ticks)
    end
  end
map[60] = {
  name = "TIME",
  format=time_format,
}
map[-60] = {
  name = "UTIME",
  read = bband,
  format=time_format,
}


return {
  map = map,
  default = default,
  typecode = typecode,
  int_format = int_format,
  make_fixed_format = make_fixed_format,
  make_enum_format = make_enum_format,
}