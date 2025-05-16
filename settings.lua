data:extend{
  {
    type = "bool-setting",
    name = "nixie-tube-slashed-zero",
    setting_type = "startup",
    default_value = true,
    order = "nixie-slashed-zero",
  },
  {
    type = "int-setting",
    name = "nixie-tube-update-speed-alpha",
    setting_type = "runtime-global",
    minimum_value = 1,
    default_value = 10,
    order = "nixie-speed-alpha",
  },
  {
    type = "int-setting",
    name = "nixie-tube-update-speed-numeric",
    setting_type = "runtime-global",
    minimum_value = 1,
    default_value = 5,
    order = "nixie-speed-numeric",
  },
  {
    type = "string-setting",
    name = "nixie-tube-flickering",
    setting_type = "runtime-global",
    default_value = "on-outage",
    allowed_values = { "always", "on-outage", "never" },
    order = "nixie-tube-flickering",
  },
}
