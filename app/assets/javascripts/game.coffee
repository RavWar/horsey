class @Game
  @options =
    el: 'main'
    lanes: 4
    header: 2

  @tile =
    width: 100
    height: 100

  @width  = 960
  @height = (Game.options.lanes + Game.options.header) * Game.tile.height

  constructor: ->
    Crafty.init(Game.width, Game.height, Game.options.el).background('#F3DB43')
    @player = Crafty.e('Player')
    #@lanes  = Crafty.e('Lanes')
    @generateStones()

  generateStones: ->
    @player.bind 'EnterFrame', =>
      return if Math.random() > 0.05

      lane = (Math.floor(Math.random()*3) + 2) * 2
      Crafty.e('Stone').at 18 - Crafty.viewport.x / Game.tile.width, lane
