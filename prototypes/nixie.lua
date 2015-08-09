data:extend(
{
  {
    type = "recipe",
    name = "nixie-tube",
    enabled = "true",
    ingredients =
    {
      {"iron-plate",3},
      {"copper-cable", 5},
      {"iron-stick", 12},
    },
    result = "nixie-tube"
  },
  {
    type = "item",
    name = "nixie-tube",
    icon = "__gophers-test__/graphics/nixie-icon.png",
    flags = {"goes-to-quickbar"},
    subgroup = "energy",
    order = "c-a",
    place_result = "nixie-tube-sprite",
    stack_size = 50
  },

  {
    type = "lamp",
    name = "nixie-tube",
    icon = "__gophers-test__/graphics/nixie-digit-0.png",
    flags = {"placeable-neutral","player-creation", "not-on-map"},
    minable = {hardness = 0.2, mining_time = 0.5, result = "nixie-tube"},
    max_health = 55,
    order = "z[zebra]",
    corpse = "small-remnants",
    collision_box = {{-0.4, -0.4}, {0.4, .4}},
    selection_box = {{-0.5, -0.5}, {0.5, 0.5}},
    energy_source =
    {
      type = "electric",
      usage_priority = "secondary-input"
    },
    energy_usage_per_tick = "8KW",
    light = {intensity = 0.0, size = 0, color = {r=1, g=.6, b=.3, a=0}},
    picture_off =
    {
      filename = "__gophers-test__/graphics/nixie-nope.png",
      priority = "high",
      width = 32,
      height = 64,
      shift = {0, -.5}
    },
    picture_on =
    {
      filename = "__gophers-test__/graphics/nixie-nope.png",
      priority = "high",
      width = 32,
      height = 64,
      shift = {0, -0.5}
    },
    circuit_wire_connection_point =
    {
      shadow =
      {
        red = {0.859375, -0.896875},
        green = {0.859375, -0.896875},
      },
      wire =
      {
        red = {0.45, 0.25},
        green = {0.45, 0.25},
      }
    },

    circuit_wire_max_distance = 7.5
  },

  {
    type = "car",
    name = "nixie-tube-sprite",
    icon = "__gophers-test__/graphics/nixie-digit-off.png",
    flags = {"pushable", "placeable-neutral", "player-creation"},
    minable = {mining_time = 1, result = "nixie-tube"},
    max_health = 200,
    corpse = "small-remnants",
    energy_per_hit_point = 1,
    crash_trigger = crash_trigger(),
    resistances =
    {
      {
        type = "fire",
        percent = 50
      },
      {
        type = "impact",
        percent = 30,
        decrease = 30
      }
    },
    collision_box = {{-0.1, -.1}, {.1,.1}},
    collision_mask = { "item-layer", "object-layer", "player-layer", "water-tile"},
    selection_box = {{0,0}, {0,0}},
    effectivity = 0.5,
    braking_power = "200kW",
    burner =
    {
      effectivity = 0.6,
      fuel_inventory_size = 1,
      smoke =
      {
        {
          name = "smoke",
          deviation = {0.25, 0.25},
          frequency = 50,
          position = {0, 1.5},
          starting_frame = 3,
          starting_frame_deviation = 5,
          starting_frame_speed = 0,
          starting_frame_speed_deviation = 5
        }
      }
    },
    consumption = "150kW",
    friction = 2e-3,
    light =
    {
      {
        type = "oriented",
        minimum_darkness = 0.3,
        picture =
        {
          filename = "__core__/graphics/light-cone.png",
          priority = "medium",
          scale = 2,
          width = 200,
          height = 200
        },
        shift = {-0.6, -14},
        size = 2,
        intensity = 0.6
      },
      {
        type = "oriented",
        minimum_darkness = 0.3,
        picture =
        {
          filename = "__core__/graphics/light-cone.png",
          priority = "medium",
          scale = 2,
          width = 200,
          height = 200
        },
        shift = {0.6, -14},
        size = 2,
        intensity = 0.6
      }
    },
    animation =
    {
      layers =
      {
        {
          width = 32,
          height = 64,
          frame_count = 1,
          direction_count = 12,
          shift = {0, -0.5},
          animation_speed = 0.1,
          max_advance = 0.2,
          stripes =
          {
            {
             filename = "__gophers-test__/graphics/nixie-digit-strip.png",
             width_in_frames = 1,
             height_in_frames = 12,
            },
          }
        },
      }
    },
    stop_trigger_speed = 0.2,
    stop_trigger =
    {
      {
        type = "play-sound",
        sound =
        {
          {
            filename = "__base__/sound/car-breaks.ogg",
            volume = 0.6
          },
        }
      },
    },
    sound_minimum_speed = 0.2;
    vehicle_impact_sound =  { filename = "__base__/sound/car-metal-impact.ogg", volume = 0.65 },
    working_sound =
    {
      sound =
      {
        filename = "__base__/sound/car-engine.ogg",
        volume = 0.6
      },
      activate_sound =
      {
        filename = "__base__/sound/car-engine-start.ogg",
        volume = 0.6
      },
      deactivate_sound =
      {
        filename = "__base__/sound/car-engine-stop.ogg",
        volume = 0.6
      },
      match_speed_to_activity = true,
    },
    open_sound = { filename = "__base__/sound/car-door-open.ogg", volume=0.7 },
    close_sound = { filename = "__base__/sound/car-door-close.ogg", volume = 0.7 },
    rotation_speed = 0.015,
    weight = 700,
    guns = { "vehicle-machine-gun" },
    inventory_size = 80
  },


})