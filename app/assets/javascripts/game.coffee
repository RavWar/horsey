class @Game
  @options =
    el: 'main'
    lives: 3
    lanes: 4
    header: 2

  @tile =
    width: 100
    height: 100

  @width  = 960
  @height = (Game.options.lanes + Game.options.header) * Game.tile.height

  constructor: ->
    Crafty.init(Game.width, Game.height, Game.options.el)
    @field = Crafty.e('Grid, Image').image('assets/dirt.png', 'repeat')
      .at(1, Game.options.header).attr({ w: 960, h: 400 })
    @scoreboard = Crafty.e('Scoreboard')
    @player = Crafty.e('Player').player(@scoreboard)
    @generateStones()

  generateStones: ->
    @player.bind 'EnterFrame', =>
      @field.attr({ w: Crafty.viewport.width - Crafty.viewport.x })
      return if Math.random() > 0.04

      lane = Math.floor(Math.random()*4) + 2
      posx = 10 * Game.tile.width - Crafty.viewport.x
      posy = lane * Game.tile.height

      return if @horizontalStoneLimit(posx, posy)
      return if @verticalStoneLimit(posx)

      Crafty.e('Stone').at posx / Game.tile.width, lane

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
