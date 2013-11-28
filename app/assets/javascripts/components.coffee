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
      .multiway(32, { UP_ARROW: -90, DOWN_ARROW: 90 })
      .color('rgb(20, 75, 40)').stopOnSolids()

  stopOnSolids: ->
    @onHit 'Solid', @stopMovement

  stopMovement: ->
    @_speed = 0

    if @_movement
      @x -= @_movement.x
      @y -= @_movement.y
