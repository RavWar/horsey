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
    Crafty.init(Game.width, Game.height, Game.options.el).background('#F3DB43')
    @scoreboard = Crafty.e('Scoreboard')
    @player = Crafty.e('Player').player(@scoreboard)
    @generateStones()

  generateStones: ->
    @player.bind 'EnterFrame', =>
      return if Math.random() > 0.035

      lane  = Math.floor(Math.random()*4) + 2
      posx  = 10 - Crafty.viewport.x / Game.tile.width
      stone = Crafty.e('Stone').at posx, lane
      stone.destroy() if stone.hit('Stone')
