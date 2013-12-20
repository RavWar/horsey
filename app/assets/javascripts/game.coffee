//= require crafty
//= require assets
//= require components

isMobile = navigator.userAgent.match(/(iPhone|iPod|iPad|BlackBerry|Android|Windows Phone|Opera Mobi)/i)?

class @Game extends GameAssets
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
    Crafty.e('Object').addComponent('NewYearsSprite').attr x: 1200, y: 46, z: 4

    field = Crafty.e('PlayField')
    Crafty.e('PlayField')
      .attr
        x: field.w

    line = Crafty.e('Line')
    Crafty.e('Line')
      .attr
        x: line.w

    unless isMobile
      clouds = Crafty.e('Clouds')
      Crafty.e('Clouds')
       .attr
         x: clouds.w

      mountains = Crafty.e('Mountains')
      Crafty.e('Mountains')
       .attr
         x: mountains.w

  generateElements: ->
    @generateStones()
    @generateLives()
    @generateObjects()

  generateStones: ->
    return if Math.random() > 0.055 + Game.speed / 1000
    pos = @randPosition()

    return if @horizontalStoneLimit(pos.x, pos.y)
    return if @verticalStoneLimit(pos.x)

    random = Math.floor(Math.random()*4) + 1
    sprite = "Stone#{random}Sprite"
    Crafty.e('Stone').addComponent(sprite).at pos.x / Game.tile.width, pos.lane

  generateLives: ->
    return if Math.random() > 0.0022
    pos = @randPosition()
    pos.x -= 200

    return if @lifeLimit(pos.x, pos.y)

    Crafty.e('Life').attr x: pos.x, y: pos.y - 20

  generateObjects: ->
    random = Math.floor(Math.random()*15) + 7

    chance = if random in [13, 14, 15, 16]
      0.08
    else if random in [7, 8, 9, 10, 11, 12]
      0.16
    else if random in [17, 18]
      0.04
    else if random is 19
      0.0005
    else if random is 20
      0.001
    else if random is 21
      0.0005
    else
      0.05

    return if Math.random() > chance

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
    add = Game.speed * 3

    Crafty.map.search(_x: x-400-add, _y: y, _w: 540+add, _h: h).filter((v) ->
      v.has 'Stone'
    ).length > 1

  horizontalStoneLimit: (x, y) ->
    add = Game.speed * 3

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

  window.game = new Game

  $(document).on 'click', '#pause', (e) ->
    e.preventDefault()
    Crafty.pause()
    $(this).toggleClass('active')
    playing = not playing

  #hit = $('#hit').get(0)
  #hit.volume = 0.3

  $('#controls').show() if hasTouch
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
    $('#start').hide()
    $('#keys').show()

    setTimeout ->
      $('#keys').hide()
      $('#game').show()
      Crafty.scene 'game'
    , 1500

  $('body').on 'click touchstart', '.score .save', (e) ->
    e.preventDefault()
    return unless name = $('.score input').val()

    request.abort() if request
    request = $.post '/save', { value: score(), name: name }, (data) ->
      $('.top').html $(data)

      request = null
      $('#gameover .prelim-score').hide()
      $('#gameover .top').show()
