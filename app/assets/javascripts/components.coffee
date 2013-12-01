Crafty.c 'Grid',
  init: ->
    @attr
      w: Game.options.tile.width,
      h: Game.options.tile.height

  at: (x, y) ->
    if x == undefined && y == undefined
      { x: @x/Game.options.tile.width, y: @y/Game.options.tile.height }
    else
      @attr
        x: x * Game.options.tile.width
        y: y * Game.options.tile.height

Crafty.c 'Stone',
  init: ->
    @requires('2D, Grid, Canvas, Color, Solid').color('rgb(20, 185, 40)')

Crafty.c 'Player',
  init: ->
    @requires('2D, Grid, Canvas, Multiway, Color, Collision')
      .color('rgb(20, 75, 40)').onHit('Stone', @stoneHit).bindKeyboard().setMovement()

  stoneHit: ->
    newColor = '#'+(0x1000000+(Math.random())*0xffffff).toString(16).substr(1,6)
    @.color newColor

  bindKeyboard: ->
    @.bind 'KeyDown', (e) =>
      if e.keyCode == 38 and @.y > 264
        @.y -= 128
      else if e.keyCode == 40 and @.y < 512
        @.y += 128

  setMovement: ->
    @.bind 'EnterFrame', =>
      @.x += 8
      Crafty.viewport.x -= 8
