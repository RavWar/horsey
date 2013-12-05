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

Crafty.c 'Scoreboard',
  init: ->
    @score = 0
    @lives = Game.options.lives

  updateScore: (change) ->
    @score += change
    $('#score').text @score

  updateLives: (change) ->
    @lives += change
    $('.life:last').remove()
    Crafty.stop(true) if @lives <= 0

Crafty.c 'Player',
  init: (scoreboard) ->
    @speed = 8

    Crafty.sprite 200, 240, 'assets/horse.png',
      PlayerSprite: [0, 0]

    @requires('Grid, Collision, SpriteAnimation, PlayerSprite')
      .collision(new Crafty.polygon([40,180], [40,280], [200,280], [200,180]))
      .reel('PlayerRunning', 1000, 0, 0, 30).animate('PlayerRunning', -1)
      .onHit('Stone', @stoneHit).bindKeyboard().movement()
      .attr(x: 100, y: 310, z: 5)

    setInterval (=>
      @speed += 1
    ), 5000

  player: (scoreboard) ->
    @scoreboard = scoreboard

  stoneHit: ->
    Crafty.pause()
    @scoreboard.updateLives -1

    setTimeout (=>
      @.x += 300
      Crafty.viewport.x -= 300
      Crafty.pause()
    ), 1000

  bindKeyboard: ->
    @.bind 'KeyDown', (e) =>
      if e.keyCode == 38 and @.y > @calcHeight(Game.options.header) - 290
        @.y -= Game.tile.height
      else if e.keyCode == 40 and @.y < @calcHeight(Game.options.lanes) - 190
        @.y += Game.tile.height

  calcHeight: (lanes) ->
    (lanes + 1) * Game.tile.height

  movement: ->
    @.bind 'EnterFrame', => @moveScene()

  moveScene: ->
    @.x += @speed
    Crafty.viewport.x -= @speed
    @scoreboard.updateScore @speed

Crafty.c 'Stone',
  init: ->
    Crafty.sprite 140, 50, 'assets/stone1.png',
      StoneSprite: [0, 0]

    @requires('Grid, Solid, Collision, StoneSprite')
