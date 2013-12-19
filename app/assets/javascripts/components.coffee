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
      if @x <= -Crafty.viewport.x - @w
        @x = -Crafty.viewport.x + @w - 12

Crafty.c 'Clouds',
  init: ->
    @requires('Grid, CloudsSprite').attr y: Game.options.header * Game.tile.height - @h
    @bind 'EnterFrame', ->
      if @x <= -Crafty.viewport.x - @w
        @x = -Crafty.viewport.x + @w - 12

Crafty.c 'Mountains',
  init: ->
    @requires('Grid, MountainsSprite').attr y: Game.options.header * Game.tile.height - @h
    @bind 'EnterFrame', ->
      if @x <= -Crafty.viewport.x - @w
        @x = -Crafty.viewport.x + @w - 12

Crafty.c 'Line',
  init: ->
    @requires('Grid, LineSprite').attr y: Game.options.header * Game.tile.height - 4, z: 2
    @bind 'EnterFrame', ->
      if @x <= -Crafty.viewport.x - @w
        @x = -Crafty.viewport.x + @w - 12

Crafty.c 'Stone',
  init: ->
    @requires('Grid, Solid, Collision')

Crafty.c 'Object',
  init: ->
    @requires('Grid, Solid, Collision').attr z: 3

Crafty.c 'Life',
  init: ->
    @requires('Grid, Solid, Collision, SpriteAnimation, LifeSprite')
    .collision(new Crafty.polygon([0,40], [0,90], [65,90], [65,40]))
    .reel('LifeBounce', 1000, 0, 0, 16).animate('LifeBounce', -1)

Crafty.c 'Scoreboard',
  init: ->
    @score = 0
    @lives = Game.options.lives

  updateScore: (score) ->
    @score = score
    $('#score').text @score
    ###$('#score').empty()
    digits = @score.toString().split ''
    for digit in digits
      $('#score').append '<span>'+digit+'</span>'###

  updateLives: (change) ->
    @lives += change

    if change > 0
      $('#lives').append "<div class='life'>"
    else
      $('.life:last').remove()
      #Crafty.audio.play 'hit', 1, 0.4
      #hit.play()

Crafty.c 'Player',
  init: (scoreboard) ->
    @requires('Grid, Collision, SpriteAnimation, PlayerSprite')
      .collision(new Crafty.polygon([100,180], [100,280], [200,280], [200,180]))
      .reel('PlayerRunning', @spriteSpeed(), 0, 0, 30)
      .animate('PlayerRunning', -1)
      .attr(x: 100, y: 290, z: 5)
      .onHit('Stone', @stoneHit)
      .onHit('Life', @lifeHit)
      .bindKeyboard()
      .movement()

    #Crafty.audio.play 'bell', 1

  player: (scoreboard) ->
    @count = 0
    @last_speed = Game.speed
    @scoreboard = scoreboard
    @

  spriteSpeed: -> 70000 / (Game.speed + 50)

  stoneHit: (object) ->
    # Remove stone collision
    object[0].obj.collision(new Crafty.polygon([]))

    @unbind 'EnterFrame', @moveGame
    $('body').unbind 'keydown'
    $('#controls .up, #controls .down').unbind 'touchstart'
    @scoreboard.updateLives -1

    # Stop lane movement
    clearInterval @changeLane
    @running = false
    @y = object[0].obj.y - 210

    @removeComponent('PlayerSprite').addComponent('PlayerDropSprite')
      .reel('PlayerDropping', 1050, 0, 0, 23).animate('PlayerDropping', -1)

    @last_speed = Game.speed + 1

    setTimeout (=>
      return Crafty.stop(true) if @scoreboard.lives <= 0

      x = object[0].obj.x + 50 - @x
      @advance x
      @movement()
      @bindKeyboard()

      @removeComponent('PlayerDropSprite').addComponent('PlayerSprite')
        .reel('PlayerRunning', @spriteSpeed(), 0, 0, 30).animate('PlayerRunning', -1)
    ), 1000

  lifeHit: (object) ->
    @scoreboard.updateLives 1
    object[0].obj.destroy()

  bindKeyboard: ->
    $('body').bind 'keydown', (e) =>
      if e.keyCode == 38 and @y > @calcHeight(Game.options.header) - 220
        @moveLane 'down'
      else if e.keyCode == 40 and @y < @calcHeight(Game.options.lanes) - 240
        @moveLane 'up'
      else if e.keyCode == 32
        Crafty.pause()
        $('#pause').toggleClass('active')
    $('#controls .up').bind 'touchstart', (e) =>
      if @y > @calcHeight(Game.options.header) - 220
        @moveLane 'down'
    $('#controls .down').bind 'touchstart', (e) =>
      if @y < @calcHeight(Game.options.lanes) - 240
        @moveLane 'up'
    @

  moveLane: (direction) ->
    return if @running

    @running = true
    timesRun = 0

    @changeLane = setInterval (=>
      tiles = Game.tile.height / 25
      @y += if direction == 'up' then tiles else -tiles
      timesRun += tiles

      if timesRun >= Game.tile.height
        clearInterval @changeLane
        @running = false
    ), 1

  calcHeight: (lanes) ->
    (lanes + 1) * Game.tile.height

  advance: (x) ->
    Crafty('Player').x += x

    for id in Crafty('Clouds')
      Crafty(id).x += x * 0.98

    for id in Crafty('Mountains')
      Crafty(id).x += x * 0.9

    Crafty.viewport.x -= x

  movement: ->
    @bind 'EnterFrame', @moveGame

  moveGame: ->
    # Move everything
    @advance Game.speed

    # Increase game speed
    @count += 1
    if @count >= 125
      Game.speed += 1
      @count = 0

    # Speed up player sprite
    if @last_speed < Game.speed - 2
      @last_speed = Game.speed
      position = @reelPosition()

      # Needed for proper change of reel and animation
      @reel('PlayerDropping', 10000, 0, 0, 23).animate('PlayerDropping', -1)

      @reel('PlayerRunning', @spriteSpeed(), 0, 0, 30).animate('PlayerRunning', -1)
        .reelPosition(position)

    # Update scoreboard
    @scoreboard.updateScore parseInt -Crafty.viewport.x / 200
