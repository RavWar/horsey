Crafty.c 'Grid',
  init: ->
    @requires('2D, DOM').attr
      w: Game.tile.width,
      h: Game.tile.height

  at: (x, y) ->
    if x == undefined && y == undefined
      { x: @x / Game.tile.width, y: @y / (Game.tile.height + 1) }
    else
      @attr
        x: x * Game.tile.width
        y: y * Game.tile.height

###Crafty.c 'Lanes',
  init: ->
    @requires('Lane')
    @ids = []

    for i in [1..Game.options.lanes]
      @ids.push Crafty.e('Lane').at(9.6, i)

Crafty.c 'Lane',
  init: ->
    @requires('Grid, Color').color('rgb(20, 50, 40)').attr(h: 100)###

Crafty.c 'Stone',
  init: ->
    @requires('Grid, Color, Solid, Collision, WiredHitBox').color('rgb(20, 185, 40)')

Crafty.c 'Player',
  init: ->
    @score = 0

    Crafty.sprite 200, 240, 'assets/horse.png',
      PlayerSprite: [0, 0]

    @requires('Grid, Collision, SpriteAnimation, PlayerSprite, WiredHitBox')
      .collision(new Crafty.polygon([40,180], [40,280], [200,280], [200,180]))
      .onHit('Stone', @stoneHit).bindKeyboard().movement().attr(x: 100, y: 320)
      .reel('PlayerRunning', 1000, 0, 0, 30).animate('PlayerRunning', -1)

  stoneHit: ->
    console.log 1

  bindKeyboard: ->
    @.bind 'KeyDown', (e) =>
      if e.keyCode == 38 and @.y > @calcHeight(Game.options.header) - 280
        @.y -= Game.tile.height
      else if e.keyCode == 40 and @.y < @calcHeight(Game.options.lanes) - 180
        @.y += Game.tile.height

  calcHeight: (lanes) ->
    (lanes + 1) * Game.tile.height

  movement: ->
    @.bind 'EnterFrame', =>
      @.x += 8
      Crafty.viewport.x -= 8
      @score += 1
      $('#score').text @score
