//= require crafty
//= require assets
//= require components

#window.isMobile = navigator.userAgent.match(/(iPhone|iPod|iPad|BlackBerry|Android|Windows Phone|Opera Mobi)/i)?

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

  constructor: ->
    Crafty.init(Game.width, Game.height, Game.options.el)
    @initBackground()
    @scoreboard = Crafty.e('Scoreboard')
    @player = Crafty.e('Player').player(@scoreboard)
    @generateElements()

  initBackground: ->
    field = Crafty.e('PlayField')
    Crafty.e('PlayField')
      .attr
        x: field.w

    #unless isMobile
    clouds = Crafty.e('Clouds')
    Crafty.e('Clouds')
     .attr
       x: clouds.w

    mountains = Crafty.e('Mountains')
    Crafty.e('Mountains')
     .attr
       x: mountains.w

  generateElements: ->
    @player.bind 'EnterFrame', =>
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
    pos.x = pos.x - 200

    return if @lifeLimit(pos.x, pos.y)

    Crafty.e('Life').attr x: pos.x, y: pos.y - 20

  generateObjects: ->
    return if Math.random() > 0.05
    pos = @randPosition 1

    return if @objectLimit(pos.x, pos.y)

    random = Math.floor(Math.random()*14) + 7
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
    Crafty.map.search(_x: x-600, _y: y, _w: 740, _h: h).filter((v) ->
      v.has 'Stone'
    ).length > 1

  horizontalStoneLimit: (x, y) ->
    Crafty.map.search(_x: x-400, _y: y, _w: 540, _h: 50).filter((v) ->
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
  isMobile = navigator.userAgent.match(/(iPhone|iPod|iPad|BlackBerry|Android|Windows Phone|Opera Mobi)/i)?
  hasTouch = "ontouchstart" of window or navigator.msMaxTouchPoints

  game = new Game

  $(document).on 'click', '.play', (e) ->
    e.preventDefault()
    $('#start').hide()
    $('#game').show()

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
