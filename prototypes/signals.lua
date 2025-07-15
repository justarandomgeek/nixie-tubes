data:extend(
  {{
    type = "item-subgroup",
    name = "virtual-signal-symbol",
    group = "signals",
    order = "e"
  }}
)


local symcount=1
local function create_symsignal(name,sort)
  data:extend(
  {
    {
      type = "virtual-signal",
      name = "signal-" .. name,
      icon = "__nixie-tubes__/graphics/signal/signal_" .. name .. ".png",
      icon_size = 32,
      subgroup = "virtual-signal-symbol",
      order = "e[symbols]-" .. sort .. "[" .. name .. "]"
    }
  })
  symcount = symcount + 1
end

--extended symbols
create_symsignal("curopen",'a-ca')
create_symsignal("curclose",'a-cb')
create_symsignal("at",'c')

create_symsignal("float",'x')
create_symsignal("hex",'x')
create_symsignal("precision",'x')
