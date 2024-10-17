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
        local bp="0eNrtmu1u2jAUhu/Fv80U28d2grQfu46qQgHSNRIEFkLXquICdiG7sV3JjpMR2s0OOdZUNdNUVNyD/ZBj+339oT6z5eZY7Ouyatj8mZWrXXVg85tndig/V/nGxap8W7A5q8rHspg1x2XBTpyV1bp4ZHNxuuWsqJqyKYuuXfvH06I6bpdFjRW4pz1n+90Bm+wqx3cY+UFz9sTms/R04n9A5DiIGoSocRAYhMA4iB6E6HEQOwgx4yBmEGLHQbJBSDoOkg5CslEQmQxCRDKOIi4UznDGN/Vus1gW9/lDuatdpVVZr45lsyiqfLkp1mze1MeC92Fssu6Bd2V9aBYXuTRPe/cAD2XdHDHSP1FXY/aJdd95aHInuZkUYCFVBlIX3u7zOm/cQ7Af376zkzfLi6bOnBm2XJZV2/LPdPspjTMqkPChWLkWh9dllPNZ5xzz3DRF/Xv0aracfcEP8PndoOzqbVvpVaIf28DR9YZIbKpVkgj0FfzxZi+JOjZeiiIK2U8Bogj9FKof+CmGKEM/heoIfkpK1KGZpA6pnuXtK5nEqlm/uZrvsRpNz0EZS0EUIHgpkihAP0URBeinAFGAfoomCtBPMUQBwhQFKC1RgP6+SmMFqN5cgHebXd78NQmO869+pknvrnrclkskw5SRbiCGKZJ42PBTFPG04acAcZvip2iiS/op1LOCn2KJLumnUE8LfkpGdEkvBajHBTlFlwRBdEl/X8lYlxRT2KbwHi/f1oTB5zazA+I2Awp1feqDAQVmr8A0BZZegRkKLHsBm6LiLFEr4lW+67LuxNBerbzv0zooSBTY8PROKeN+XphVYBJlFJgahumEAoMrMEGB6SswGWMJMgBTMZYQgkHMk4XS1DFPFoKZGLMKpWljzEpO06x0GtNzoWHIYnouADPUm5Hk1Ui8sFF3ZzjRexJDcZa+B0I9SnGWflVS05zYRhGnj7wq5Pey7oJQVuMvE542QExeXR3sCSWvI0d+Ehc6Mpy3idlsQcArbMxmKwRLYzZbIVgWs9kKwGwSs6UJwUTMliYEkzELcwimYhbmEAxi1qQQTMesSTDNNcmaSFuGf8CWrY20Zfh/g9S7/i1nX3Fj6/K5EQkXXODrlv8qp10Z37g057LkMuESyy7EIWnjWMZ42sYxJDnIruzqmK4OuDpguzi+cdPVwfMR1lFtHd3GOz5+jHHdxl1Vjtpu43CJY0hwnAlt2ZzLmFXZFFtM+fLfSJw94Li100EbmUGWaYVyyzJ5Ov0EYy8NcA=="
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
