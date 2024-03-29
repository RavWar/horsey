//= require crafty
//= require assets
//= require components

window.isMobile = navigator.userAgent.match(/(iPhone|iPod|iPad|BlackBerry|Android|Windows Phone|Opera Mobi)/i)?

class @Game
  @options =
    el: 'main'
    lives: 3
    lanes: 4
    header: 2

  @tile =
    width: 100
    height: 100

  @speed  = 8
  @width  = 960
  @height = (Game.options.lanes + Game.options.header) * Game.tile.height
  @lifeRandom  = 0.00008
  @stoneRandom = 0.032
  @pauseHalted = false

  @togglePause: ->
    return if @pauseHalted and !Crafty._paused

    Crafty.pause()
    $('#pause').toggleClass('active')
    playing = not playing

    if Crafty._paused
      @pauseHalted = true
    else
      setTimeout (=>
        @pauseHalted = false
      ), 5000

  @appendLife: ->
    $('#lives').append "<div class='life'>"

  constructor: ->
    Crafty.init(Game.width, Game.height, Game.options.el)
    @initScenes()
    Crafty.scene 'start'

  initScenes: ->
    Crafty.scene 'start', =>
      $('#start').show()
    , =>
      $('#start').hide()

    Crafty.scene 'game', =>
      @initBackground()
      @scoreboard = Crafty.e('Scoreboard')
      @player = Crafty.e('Player').player(@scoreboard)
      @lifeRandom  = Game.lifeRandom
      @stoneRandom = Game.stoneRandom
      @lastX = Crafty.viewport.x

      setInterval (=>
        return unless Crafty.viewport.x < @lastX
        @lastX = Crafty.viewport.x
        @generateElements()
      ), 100
    , =>
      $('#game').hide()

      # Save score and freeze the value
      a = @scoreboard.score
      window.score = ((a) ->
        -> a
      )(a)

      # Reset game state
      Game.speed = 8
      Crafty.viewport.x = 0
      for num in [$('#lives .life').length..2]
        Game.appendLife()

    Crafty.scene 'end', =>
      $('#gameover').show()
      $('#gameover .top').hide()
      $('#gameover .prelim-score').show()
      $('#gameover .result span').text score()
      Crafty.audio.play 'gameover', 1, 0.2 unless isMobile

      $.ajax
        type: 'post'
        url: '/place'
        data:
          score: score()
        async: false
        success: (place) ->
          $('#gameover .place span').text place
    , =>
      $('#gameover').hide()

  initBackground: ->
    $('#game').show()
    #Crafty.e('Object').addComponent('NewYearsSprite').attr x: 1200, y: 46, z: 4

    field = Crafty.e('PlayField')
    Crafty.e('PlayField')
      .attr
        x: field.w

    line = Crafty.e('Line')
    Crafty.e('Line')
      .attr
        x: line.w

    unless isMobile
      ###clouds = Crafty.e('Clouds')
      Crafty.e('Clouds')
       .attr
         x: clouds.w###

      mountains = Crafty.e('Mountains')
      Crafty.e('Mountains')
       .attr
         x: mountains.w

  generateElements: ->
    rand = Math.random()
    @generateStones rand
    @generateLives rand
    @generateObjects rand

  generateStones: (rand) ->
    step = if isMobile then 0.06 else 0.016
    return @stoneRandom += step if rand > @stoneRandom + Game.speed / 900
    @stoneRandom = Game.stoneRandom
    pos = @randPosition()

    return if @horizontalStoneLimit(pos.x, pos.y)
    return if @verticalStoneLimit(pos.x)

    random = Math.floor(Math.random()*4) + 1
    sprite = "Stone#{random}Sprite"
    e = Crafty.e('Stone').addComponent(sprite).at(pos.x / Game.tile.width, pos.lane)
    e.collision(new Crafty.polygon([0,20], [e.w,20], [e.w,e.h+10], [0,e.h+10]))

  generateLives: (rand) ->
    return @lifeRandom += 0.00005 if rand > @lifeRandom
    @lifeRandom = Game.lifeRandom
    pos = @randPosition()
    pos.x -= 200

    return if @lifeLimit(pos.x, pos.y)

    Crafty.e('Life').attr x: pos.x, y: pos.y - 20

  generateObjects: (rand) ->
    random = Math.floor(Math.random()*15) + 7

    chance = if random in [13, 14, 15, 16]
      0.12
    else if random in [7, 8, 9, 10, 11, 12]
      0.24
    else if random in [17, 18]
      0.075
    else if random is 19
      0.0015
    else if random is 20
      0.002
    else if random is 21
      0.0007
    else
      0.07

    return if rand > chance

    pos = @randPosition 1
    return if @objectLimit(pos.x, pos.y)

    sprite = "Object#{random}Sprite"
    object = Crafty.e('Object').addComponent(sprite)
    object.attr x: pos.x, y: pos.y + 100 - object.h

  randPosition: (lane = null) ->
    lane = lane || Math.floor(Math.random() * 4) + 2
    posx = 12 * Game.tile.width - Crafty.viewport.x
    posy = lane * Game.tile.height

    { lane: lane, x: posx, y: posy }

  verticalStoneLimit: (x) ->
    y = Game.options.header * Game.tile.height
    h = Game.options.lanes * Game.tile.width
    add = Game.speed * 4

    Crafty.map.search(_x: x-550-add, _y: y, _w: 690+add, _h: h).filter((v) ->
      v.has 'Stone'
    ).length > 1

  horizontalStoneLimit: (x, y) ->
    add = Game.speed * 4

    Crafty.map.search(_x: x-400-add, _y: y, _w: 540+add, _h: 50).filter((v) ->
      v.has 'Stone'
    ).length

  lifeLimit: (x, y) ->
    Crafty.map.search(_x: x-250, _y: y, _w: 390, _h: 50).filter((v) ->
      v.has 'Stone' or v.has 'Life'
    ).length

  objectLimit: (x, y) ->
    Crafty.map.search(_x: x-5, _y: y, _w: 5, _h: 120).filter((v) ->
      v.has 'Object'
    ).length

$ ->
  hasTouch = "ontouchstart" of window or navigator.msMaxTouchPoints
  request  = null

  if hasTouch then $('html').addClass 'mobile' else $('html').addClass 'desktop'

  window.game = new Game

  $(document).on 'click', '#pause', (e) ->
    e.preventDefault()
    Game.togglePause()

  #hit = $('#hit').get(0)
  #hit.volume = 0.3

  $(document).on 'click touchstart', '#controls button', (e) ->
    e.preventDefault()
    #hit.play()
    #hit.pause()

  #w = $(window).width()
  #h = $(window).height()
  #$('#container').css 'zoom', 0.5 if hasTouch && (w < 962 || h < 602)

  $('body').on 'click touchstart', '#gameover .play', (e) ->
    e.preventDefault()
    Crafty.scene 'game'

  $('body').on 'click touchstart', '#start .play', ->
    Crafty.audio.play 'bell', 0.5

    #Crafty.load GameAssets.list(), =>
    $('#start').hide()
    $('#keys').show()

    setTimeout ->
      $('#keys').hide()
      $('#game').show()
      Crafty.scene 'game'
    , 2000

  $('body').on 'click touchstart', '#start .top', ->
    $('.start-screen').hide()
    $('.top-screen').show()

  $('body').on 'click touchstart', '#start .back', ->
    $('.top-screen').hide()
    $('.start-screen').show()

  $('body').on 'click touchstart', '.score .save', (e) ->
    e.preventDefault()
    return unless name = $('.score input').val()

    request.abort() if request
    request = $.post '/save', { value: score(), name: name }, (data) ->
      $('#gameover .top .table').html $(data)

      request = null
      $('#gameover .prelim-score').hide()
      $('#gameover .top').show()
