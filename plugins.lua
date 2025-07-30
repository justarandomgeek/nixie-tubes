require("util")
local numberType = require("number_type")

local remote = remote
local prototypes = prototypes

local string = string
local sunpack = string.unpack
local sformat = string.format
local pairs = pairs
local ipairs = ipairs
local next = next
local pcall = pcall
local xpcall = xpcall
local assert = assert
local error = error
local log = log
local load = load
local type = type
local tostring = tostring
local select = select
local tonumber = tonumber
local table = table
local bit32 = bit32
local math = math
local table_size = table_size
local defines_copy = table.deepcopy(defines)

-- force capturing everything needed for plugins
local _ENV = nil

---@class (exact) NixieTubesPluginData
---@field numberType? {[int32|string]:{code:string}}

local function sandbox_env()
  ---@class NixieTubesPluginEnv
  local env = {
    -- limited set of builtins:
    assert = assert,
    error = error,
    pcall = pcall,
    xpcall = xpcall,
    ipairs = ipairs,
    next = next,
    pairs = pairs,
    select = select,
    tonumber = tonumber,
    tostring = tostring,
    type = type,
    table = table,
    string = string,
    bit32 = bit32,
    math = math,
    table_size = table_size,

    -- plus a few utils for formatters:
    int_format = numberType.int_format,
    make_fixed_format = numberType.make_fixed_format,
    make_enum_format = numberType.make_enum_format,

    -- or hop over to your own vm for a full env, if you really must...
    -- it's like 10x slower than a direct call, but quicker for dev...
    -- but you can't add/remove remotes in the sandbox, only call!
    remote = {
      call = remote.call,
      --interfaces = remote.interfaces, --todo: this needs more magic to read on-demand. worth it?
    },
    prototypes = prototypes,
    defines = defines_copy, -- since it's just a table, give them a copy so they can't clobber them for me...
  }
  return env
end

---@param name string
---@param key integer
---@param code string
local function loadPluginNumberType(name, key, code)
  -- just throw now if the load/call are bad
  local plugin = assert(load(code, sformat("=(nixie-tubes plugin %s numtype %i)", name, key), "t", sandbox_env()))
  local numtype = plugin() --[[@as NixieTubesNumberType|NixieTubesSplitNumberType|nil]]
  if not numtype then
    log{"", "Nixie Tubes Plugin ", name, " returned nothing"}
    return
  end
  local splitreadtype = type(numtype.split_read)
  local readtype = type(numtype.read)
  if type(numtype.format)~="function" or
    (readtype~="nil" and readtype~="function") or
    type(numtype.name)~="string" or
    (splitreadtype~="nil" and splitreadtype~="boolean") then
    error(sformat("Nixie Tubes Plugin %s numberType %i is malformed", name, key))
  end
  numtype.from_plugin = name
  numberType.map[key]=numtype
  log{"", "Nixie Tubes Plugin ", name, " registered typecode ", key}
end

local function loadPlugins()
  for name, mod_data in pairs(prototypes.mod_data) do
    if mod_data.data_type == "NixieTubesPluginData" then
      local data = mod_data.data --[[@as NixieTubesPluginData]]
      if data.numberType then
        for key, numtype in pairs(data.numberType) do
          local ktype = type(key)
          if ktype=="string" then
            if #key ~= 4 then
              error(sformat("Invalid numberType string key length %s in Nixie Tubes Plugin %s, must be exactly 4 bytes", ktype, name))
            end
            key = sunpack(">i4", key)
          elseif ktype~="number" then
            error(sformat("Invalid numberType key type %s in Nixie Tubes Plugin %s", ktype, name))
          end
          if numberType.map[key] then
            error(sformat("Nixie Tubes Plugin %s requested numberType %i which is already registered", name, key))
          end
          loadPluginNumberType(name, key, numtype.code)
        end
      end
    end
  end
end

return {
  load = loadPlugins
}