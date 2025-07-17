data:extend{
  {
    type = "tips-and-tricks-item",
    name = "nixie-tubes",
    tag = "[entity=nixie-tube]",
    category = "nixie-tubes",
    is_title = true,
    order = "zz-00",
    dependencies = {"circuit-network"},
    simulation = {
      mods = {"nixie-tubes"},
      init = [[
        local bp="0eNq1lVtugzAQRfcy36aKzZu/dBtVhIA47UhgkDFRoogFdCHdWFdSG9QEKYRH1fwgbMbncsejmQukecMriUJBdAHMSlFD9HaBGt9Fkps9da44RICKF0BAJIVZCTwht1STcmgJoNjzE0S03RHgQqFC3lO6xTkWTZFyqQPGzhOoylofKYVR0xjLeXEJnPULa1tyB2HLIO4kxF4GYZMQZxnEnoS4yyCbG4SAviUlyzxO+UdyxFKaoAxl1qCK9bf99eQBZa3iu7s8olSN3rlK9xHWFnp4rRJTDxajju8EtucEZruoEpkoowbfn1/Q9rGCZ0atNnhqHpLvh3ePekXtdteOmfeWmaeTGfRHIFZdJHk+VVs6oWOwYA3MnoGFa2BsBkY3a2h0jkbX0DZD2vPq7/VZ9cce1B+9NZNfWUsLpSg6obtEsPk8HDBXXD5oojPGG+OaMttxPT8Ih311hVf6yKv9R6/0f71u77z+zajb+dQTp5tM0WCQETjqv+qcsECXUMh8FgaB5+v28QOiY0wL"
        game.tick_paused = false
        game.simulation.camera_alt_info = true
        local result = {game.surfaces[1].create_entities_from_blueprint_string
        {
          string = bp,
          position = {0, 0},
        }}
        remote.call("nixie-tubes", "RebuildNixies")
      ]],
      update = [[

      ]],
    }
  },
  {
    type = "tips-and-tricks-item",
    name = "nixie-tubes-alpha",
    tag = "[entity=nixie-tube-alpha]",
    category = "nixie-tubes",
    indent = 1,
    order = "zz-10",
    dependencies = {"nixie-tubes"},
    simulation = {
      mods = {"nixie-tubes"},
      init = [[
        local bp="0eNrdl12L1DAUhv9LrlNpkqYfA94peCEI3ngxLEs6Rjdsm9Y0HWcY+t89yaCrrhKOFAtDobyT5rw5T0hOJhfSdrMenbGe7C7EHAY7kd3+Qibz2aoutFnVa7Ij1pyMzvzc6kx144MiCyXGftQnsmPLHSXaeuONvkbHH+d7O/etdtCB/tWFknGYIHCwYSwwy0RRvJCUnEFKVi0LfWbHcXY8YSdwdiJhV+Ds8oSdxNmxhF2JshNNwq7C2dUJuxpnVybsGpxdlbBjOc4vtY4Zbl8ImfLDbQyRWsnsaWeEuuCV9dlh6FtjlR9cautCtlAiINC7obtv9YM6GoiCrpM+hKjpVw1l43s9oeST6bx2v7f68xiSORrnZyhOP7K7FqvsDbR8gQ/AEKZgcH3sBCmPysWUd+RlbJhDuYOyBc8fwQs0ON8S/O1q4BINLrYEf70aeIkGz7cEf7caeIUGZ7ex1Gss+M+n1/8H/7AaeIMGL7cEf78WOM/R4NVN7HHO0OCbnuOvVgPnaHB5E8WNo/+5iU3PcX06dKpXwS/rlXv8t3mAW+hX4+IVdM8oPIKyO7rnQRZRiiBllEWQZZQyyCrKKsg6yjrIJkp4U6geQcIdADS76jAIrLGowyg8DAhZGK97SPHpak3JEeYkzrcseVM0jawK1uR5vSzfAHFjEwY="
        game.tick_paused = false
        game.simulation.camera_alt_info = true
        local result = {game.surfaces[1].create_entities_from_blueprint_string
        {
          string = bp,
          position = {0, 0},
        }}
        remote.call("nixie-tubes", "RebuildNixies")
      ]],
      update = [[

      ]],
    }
  },
  {
    type = "tips-and-tricks-item",
    name = "nixie-tubes-color",
    tag = "[virtual-signal=signal-red]",
    category = "nixie-tubes",
    indent = 1,
    order = "zz-20",
    dependencies = {"nixie-tubes"},
    simulation = {
      mods = {"nixie-tubes"},
      init = [[
        local bp="0eNrdmM+O2jAQxt/F52SFnf/cql4rVeq1QiiAF6wNTuQ4dCOUB+hb9NIX65PUBpV6FyYbZ70SygXhEH/j+cXzjcMRrYqGVoJxieZHxNYlr9H8+xHVbMvzQl+TbUXRHDFJ98hDPN/rEWfPjPqyWVHUeYjxDX1Gc9x5FhP9vKh2uTGddAsPUS6ZZPS8iNOgXfJmv6JC6d8K76GqrNWUkuuYSsaPHyIPteoLzjq9olcqZJhK2K8SDFOJ+lXCYSqkXyUaphL0q8TDVLCh4iG1X6Qoi+WK7vIDK4W+a83EumFyqX7bXKY+MlHL5dXmODAhG3XlEvt8h/8JncVrmeud6RMcJmEaxGGqL++rXORSR0N/fv7WtzY1VfGKUqiNI0VDz7M5Xev4tQ6I9YegG3NjMTVKukV3C0dyWdK/Zfgq8IrxU+ArLv+xpA8RAOaRFZIKoL7eINFoDJgEYRQb9bYYnmds5KjHKZB3apc3+ai8dQpG5uOShh5udsuP6n1eFL3Vp5zllhqe2cgFb8rhcatLADkybnWQXGAjh18kOwW/wBGwp3A4DkwyFTAxBCYaa6XxfVopDl55KYZ8BsdjU0/uNPXwdepQH8HJ2Ebi+Kmv25y/v5PAZT+6YTp+xFtBqYtEwTLO4EN83/H5I90t563cMb59aXKzK2v79T5rIyHAhMxsmESTYgIVBME2TMikmEC1Q4gNk2BSTKDeSAIbJnhSTKCmSUK7ZmLYbOC2m3wFOonnpCMRq46UQbQsD5aGATum9dkBLeiF14oVmUGsLE+ihjHf4c6qGH9yAAtDsCzProZjO4b1xQGslhZF+cMBLgLhsjwCG2buGNc3B7jA9wU7WMEJ1sI7//89N/5n99BBJXbCQVL1Op6RhGRpGiek6/4CMOX16Q=="
        game.tick_paused = false
        game.simulation.camera_alt_info = true
        local result = {game.surfaces[1].create_entities_from_blueprint_string
        {
          string = bp,
          position = {0, 0},
        }}
        remote.call("nixie-tubes", "RebuildNixies")
      ]],
      update = [[

      ]],
    }
  },
  {
    type = "tips-and-tricks-item",
    name = "nixie-tubes-formatting",
    tag = "[virtual-signal=signal-hex]",
    category = "nixie-tubes",
    indent = 1,
    order = "zz-30",
    dependencies = {"nixie-tubes"},
    simulation = {
      mods = {"nixie-tubes"},
      init = [[
        local bp="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"
        game.tick_paused = false
        game.simulation.camera_alt_info = true
        game.simulation.camera_zoom = 1.25
        game.surfaces[1].create_global_electric_network()
        game.surfaces[1].create_entity{name="electric-energy-interface", position={x=0,y=100}}
        local result = {game.surfaces[1].create_entities_from_blueprint_string
        {
          string = bp,
          position = {0, 0},
        }}
        remote.call("nixie-tubes", "RebuildNixies")
      ]],
      update = [[

      ]],
    }
  },
}--[[@as data.TipsAndTricksItem[] ]]
