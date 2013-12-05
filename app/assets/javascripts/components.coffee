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
    console.log @lives

Crafty.c 'Player',
  init: (scoreboard) ->
    Crafty.sprite 200, 240, 'assets/horse.png',
      PlayerSprite: [0, 0]

    @requires('Grid, Collision, SpriteAnimation, PlayerSprite')
      .collision(new Crafty.polygon([40,180], [40,280], [200,280], [200,180]))
      .onHit('Stone', @stoneHit).bindKeyboard().movement().attr(x: 100, y: 320)
      .reel('PlayerRunning', 1000, 0, 0, 30).animate('PlayerRunning', -1)

  player: (scoreboard) ->
    @scoreboard = scoreboard

  stoneHit: ->
    @scoreboard.updateLives -1

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
      @scoreboard.updateScore 1

Crafty.c 'Stone',
  init: ->
    Crafty.sprite 140, 50, 'assets/stone.png',
      StoneSprite: [0, 0]

    @requires('Grid, Solid, Collision, StoneSprite')
