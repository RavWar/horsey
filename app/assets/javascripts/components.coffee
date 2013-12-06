Crafty.audio.add
  bell: ['sounds/bell.mp3', 'sounds/bell.ogg'],
  wheels: ['sounds/wheels.mp3', 'sounds/wheels.ogg'],
  creak: ['sounds/creak.mp3', 'sounds/creak.ogg'],
  hit: ['sounds/hit.mp3', 'sounds/hit.ogg']

Crafty.sprite 200, 240, 'assets/horse.png',
  PlayerSprite: [0, 0]

Crafty.sprite 140, 50, 'assets/stone1.png',
  StoneSprite: [0, 0]

Crafty.sprite 960, 400, 'assets/dirt.png',
  DirtSprite: [0, 0]

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

Crafty.c 'PlayField',
  init: ->
    @requires('Grid, DirtSprite').attr y: Game.options.header * Game.tile.height
    @bind 'EnterFrame', ->
      if @x <= -Crafty.viewport.x - Crafty.viewport.width
        @x = -Crafty.viewport.x + Crafty.viewport.width

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
    Crafty.audio.play 'hit', 1

Crafty.c 'Player',
  init: (scoreboard) ->
    @requires('Grid, Collision, SpriteAnimation, PlayerSprite')
      .collision(new Crafty.polygon([40,180], [40,280], [200,280], [200,180]))
      .reel('PlayerRunning', 1000, 0, 0, 30).animate('PlayerRunning', -1)
      .onHit('Stone', @stoneHit).bindKeyboard().movement()
      .attr(x: 100, y: 310, z: 5)

    setInterval (=>
      Game.speed += 1
    ), 2000

    Crafty.audio.play 'bell', 1

  player: (scoreboard) ->
    @scoreboard = scoreboard

  stoneHit: ->
    Crafty.pause()
    @scoreboard.updateLives -1

    setTimeout (=>
      @x += 300
      Crafty.viewport.x -= 300
      Crafty.pause()
    ), 1000

  bindKeyboard: ->
    @bind 'KeyDown', (e) =>
      if e.keyCode == 38 and @y > @calcHeight(Game.options.header) - 220
        @moveLane 'down'
      else if e.keyCode == 40 and @y < @calcHeight(Game.options.lanes) - 240
        @moveLane 'up'
      else if e.keyCode == 80
        Crafty.pause()

  moveLane: (direction) ->
    timesRun = 0
    interval = setInterval (=>
      @y += if direction == 'up' then 2 else -2
      timesRun += 2
      clearInterval interval if timesRun >= Game.tile.height
    ), 1

  calcHeight: (lanes) ->
    (lanes + 1) * Game.tile.height

  movement: ->
    @bind 'EnterFrame', => @moveScene()

  moveScene: ->
    @x += Game.speed
    Crafty.viewport.x -= Game.speed
    @scoreboard.updateScore Game.speed

Crafty.c 'Stone',
  init: ->
    @requires('Grid, Solid, Collision, StoneSprite')
