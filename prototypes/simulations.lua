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
        local bp="0eNrNl99rgzAQgP+Xe9ZhUn8/b7CHwWAvexilaJutYRpFY2kp/u+LCmthu8HFCX0Ro/E+PzkvlzPkRSfqRioN6RnktlItpG9naOWHyorhmj7VAlKQWpTggMrKYaTkUQpXd7lws6LeZ9A7INVOHCFl/doBobTUUkyxxsFpo7oyF42ZgEdxoK5a82ClBrIJ5sZ3gQMnc8INwbydEtvhdjvcZ8OhEbtriDQjturXfd87P8icQg5tyD5CXlHIkQ05QMg+hezbkEOEHFDIgQ05Qsghhby6kH8JFVFCcRuJGJGIKWTPhpwg5IRCZhZk7iFk5hHQVmSGkSlVyeZrc46RKVXJJsM4Vg7ZpSoNdV9nSrvbqsylynTV/FWMzQeY+Lqpik0u9tlBmifMtHdZaNEga8hBNrozV76x0wz3EcZo3bAIseuFhJDMmKNPdAwXcnya74hmUEB0jBZyfJjviOZqSHT0F3J8nu+INQksIjoGt5urWDvCYqIjX8jxdb4j1n6whOjoLeT4Mt8R6064R3Rkt/s/Yn0QZzTHpRTv/2F5xDouzmmO3u2WHIb1AJzY5yxVcsSxzJrPfxCdGgGzzR435enVHt6Bg3mtUYXHzI8SHvEkjsPIbG6+AJHKVTk="
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
        local bp="0eNrtWmuO2jAQvot/myp+O0j90XOsEOKRtpEg0CRsd7XiAD1IL9aTdJzsQrZ1lGQc7ZKqQgIzON887PlmbPFE1rtTcszTrCTzJ5JuDllB5ndPpEi/ZKudk2WrfULmJEsf0mRWntYJOVOSZtvkgczZeUFJkpVpmSb1c9WXx2V22q+THCZQz/OUHA8FPHLIHD7AzISKPihKHmEoY30+07+AeF8g1gSiBBwq88NuuU6+ru7TQ+4mbtJ8c0rLZZKt1rtkS+Zlfkp8SkVPpTLusF72BbIjWq/6KjUd1uu+QHpE601fparDetsXSHYAxX2BODIM9CKGR7YX0M9pXpTLa0KWj0dnxH2alyeQXKyqZ8w+kVpnUa5cUs84k0ZaoaV14v1xla9KZwT59eMnOfscZVFfT8WIC86uXPFi/QzsXadZZa9HvWikHeyCFgOKZOOeKl6PgapeOIxChHdlkv8p7YwzJd/gB/DBBeqQ76tJr0L8sRKc3DqwyFgloogBZ8LLGwGOoAnpRcIwlx9JIpLfj4ThIxm8qzQi/f32Yxgp3H6LyEW//Rj+klPkLx6FMIl4cyb5CtOGcUkrhXCGoBAeukk5R5AE9yIJBEmE2y8Rqe23XyHoxo+kEenKJ5muBkFx4WtuQ0iCvTlJ1HbPqlljkUXfiqAamzXyHpT6doyKdyH1PjGKJlLoQQ9zvPTbLxAnXj8S5tAYHgmF6BzDtWoE7fujZhClyI+EOTiGRyJGlKJgrRJz4vNGTTJE2YqmWLYkDyggNp5Cl0kv8Pw96pP0cemsALhdR0ZbGHoR5TBE8xoxNMvUMO0Srf1mckQP81iNG28zNEMbpPRswDbN6xysLhJv+35JChnBnm3PJztoNRq9jpUt+RQPQ4xeI4ZecEfDdlfc6Y9iwxBtNyJHc1gbIp4V1QgxxzPoGCuu0NrH8B3PZqplLQ0asW13WHSNaUOM0YhqmlVLD74/bLTFz0436oa71p/odaIeyIeiczfpgXzI0fxxM7tJDN5NvcrkrfQdkgmj4E237yI5OALsPSOAPsrw9hCokBCof2ETaHTzKVqoxKCbzzZEi27/RHh7oWN0OzuCdhOhW6uWaBqGblTH8IejW6s2fwS6ERrDH4kuxW3+KHQpFtMsxUaHsLD4f2XXWeeMCWl2xOTq3IKS79DpO613MWWUwduC1kNWDZ2Ecv0y5pRHlMPYiais58AY5LaSg4hTyeuxgjlwGmH1GOSmlsMH1fUc5fChvWD1mLv5Tg4/g1xWcjeVQrpXcnGVG4dvatvcB4XlYwvwKS2TPXh+/W8oJfcQ22rdlOaxjGNlJIujyJ7PvwGHk+t9"
        game.tick_paused = false
        game.simulation.camera_alt_info = true
        game.simulation.camera_zoom = 1.5
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
