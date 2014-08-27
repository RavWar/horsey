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

Crafty.c 'Clouds',
  init: ->
    @requires('Grid, CloudsSprite').attr y: Game.options.header * Game.tile.height - @h

Crafty.c 'Mountains',
  init: ->
    @requires('Grid, MountainsSprite').attr y: Game.options.header * Game.tile.height - @h

Crafty.c 'Line',
  init: ->
    @requires('Grid, LineSprite').attr y: Game.options.header * Game.tile.height - 4, z: 2

Crafty.c 'Town',
  init: ->
    @requires('Grid, Town1Sprite').attr y: Game.options.header * Game.tile.height - @h, z: 3

Crafty.c 'Stone',
  init: ->
    @requires('Grid, Solid, Collision')

Crafty.c 'Object',
  init: ->
    @requires('Grid, Solid, Collision').attr z: 3

Crafty.c 'Life',
  init: ->
    @requires('Grid, Solid, Collision, SpriteAnimation, LifeSprite')
    .collision(new Crafty.polygon([0,40], [0,90], [100,90], [100,40]))
    .reel('LifeBounce', 1000, 0, 0, 16).animate('LifeBounce', -1).attr z: 4

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
      Game.appendLife()
    else
      $('.life:last').remove()
      Crafty.audio.play 'hit', 1, 0.5 unless isMobile
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

  player: (scoreboard) ->
    @count = 0
    @last_town  = 0
    @last_viewport = 0
    @last_speed = Game.speed
    @scoreboard = scoreboard
    @

  spriteSpeed: -> 70000 / (Game.speed + 50)

  stoneHit: (object) ->
    # Remove stone collision
    object[0].obj.collision(new Crafty.polygon([]))

    @unbind 'EnterFrame', @gameFrame
    $('body').unbind 'keypress'
    $('#controls .up, #controls .down').unbind 'touchstart'
    @scoreboard.updateLives -1

    # Stop lane movement
    clearInterval @changeLane
    @running = false
    @y = object[0].obj.y - 210

    @removeComponent('PlayerSprite').addComponent('PlayerDropSprite')
      .reel('PlayerDropping', 1050, 0, 0, 23).animate('PlayerDropping', 1)

    @last_speed = Game.speed + 1

    setTimeout (=>
      return Crafty.scene('end') if @scoreboard.lives <= 0

      x = object[0].obj.x + 50 - @x
      @last_viewport = Crafty.viewport.x - x

      @advance x
      @movement()
      @bindKeyboard()

      @removeComponent('PlayerDropSprite').addComponent('PlayerSprite')
        .reel('PlayerRunning', @spriteSpeed(), 0, 0, 30).animate('PlayerRunning', -1)
    ), 2000

  lifeHit: (object) ->
    @scoreboard.updateLives 1
    Crafty.audio.play 'pickup', 1, 0.025 unless isMobile
    object[0].obj.destroy()

  bindKeyboard: ->
    $('body').bind 'keypress', (e) =>
      # Arrows or W and S
      if e.keyCode == 38 or e.keyCode == 87
        @moveLane 'down'
      else if e.keyCode == 40 or e.keyCode == 83
        @moveLane 'up'
      else if e.keyCode == 32
        Game.togglePause()

    $('#controls .up').bind 'touchstart', (e) =>
      @moveLane 'down'
    $('#controls .down').bind 'touchstart', (e) =>
      @moveLane 'up'
    @

  moveLane: (direction) ->
    return if @running or Crafty._paused

    if direction == 'up'
      return unless @y < @calcHeight(Game.options.lanes) - 240
    else
      return unless @y > @calcHeight(Game.options.header) - 220

    @running = true
    timesRun = 0

    @changeLane = setInterval (=>
      limit = if isMobile then 15 else 25
      multiplier = if Game.speed > limit then 2 else 1
      num = if isMobile then 8/multiplier else 20/multiplier
      tiles = Game.tile.height / num
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

    #for id in Crafty('Clouds')
    #  Crafty(id).x += x * 0.98

    for id in Crafty('Mountains')
      Crafty(id).x += x * 0.9

    # Slow down last visible town
    #id = Crafty('Town')[Crafty('Town').length-1]
    #town = Crafty(id) if id
    #if town and town.x > -Crafty.viewport.x - 1000
    #  town.x += x * 0.75

    Crafty.viewport.x -= x

  movement: ->
    @bind 'EnterFrame', @gameFrame

  gameFrame: ->
    # game.generateElements()

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

    # Play pedal sounds
    unless isMobile
      Crafty.audio.play 'pedal1', 1, 0.2 if @reelPosition() == 1
      Crafty.audio.play 'pedal2', 1, 0.2 if @reelPosition() == 15

    # Move some background entities if needed
    #for entity in ['PlayField', 'Clouds', 'Mountains', 'Line']
    for entity in ['PlayField', 'Mountains', 'Line']
      for id in Crafty(entity)
        element = Crafty id

        if element.x <= -Crafty.viewport.x - element.w
          # Line positions up
          other_id = if Crafty(entity)[0] == id then 1 else 0
          other_el = Crafty Crafty(entity)[other_id]
          element.x = other_el.x + other_el.w

    # Prevent viewport abuse
    if Crafty.viewport.x < @last_viewport - Game.speed
      Crafty.viewport.x = @last_viewport

    @last_viewport = Crafty.viewport.x

    # Update scoreboard
    @scoreboard.updateScore parseInt -Crafty.viewport.x / 200

    # Generate town
    #if parseInt(@scoreboard.score / 97) > @last_town
    #  @last_town += 1
    #  Crafty.e('Town').attr x: -Crafty.viewport.x + 1000
