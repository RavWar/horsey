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

  constructor: ->
    Crafty.init(Game.width, Game.height, Game.options.el)
    @initBackground()
    @scoreboard = Crafty.e('Scoreboard')
    @player = Crafty.e('Player').player(@scoreboard)
    @generateElements()

  initBackground: ->
    Crafty.e('PlayField')
    Crafty.e('PlayField')
      .attr
        x: Crafty.viewport.width

  generateElements: ->
    @player.bind 'EnterFrame', =>
      @generateStones()
      @generateLives()

  generateStones: ->
    return if Math.random() > 0.045 + Game.speed / 1000
    pos = @randPosition()

    return if @horizontalStoneLimit(pos.x, pos.y)
    return if @verticalStoneLimit(pos.x)

    Crafty.e('Stone').at pos.x / Game.tile.width, pos.lane

  generateLives: ->
    return if Math.random() > 0.002
    pos = @randPosition()
    pos.x = pos.x - 200

    return if @lifeLimit(pos.x, pos.y)

    Crafty.e('Life').at pos.x / Game.tile.width, pos.lane

  randPosition: ->
    lane = Math.floor(Math.random()*4) + 2
    posx = 12 * Game.tile.width - Crafty.viewport.x
    posy = lane * Game.tile.height

    { lane: lane, x: posx, y: posy }

  verticalStoneLimit: (x) ->
    y = Game.options.header * Game.tile.height
    h = Game.options.lanes * Game.tile.width
    Crafty.map.search(_x: x-600, _y: y, _w: 740, _h: h).filter((v) ->
      v.has 'Stone'
    ).length > 2

  horizontalStoneLimit: (x, y) ->
    Crafty.map.search(_x: x-400, _y: y, _w: 540, _h: 50).filter((v) ->
      v.has 'Stone'
    ).length

  lifeLimit: (x, y) ->
    console.log x, y
    Crafty.map.search(_x: x-200, _y: y, _w: 340, _h: 50).filter((v) ->
      v.has 'Stone' or v.has 'Life'
    ).length
