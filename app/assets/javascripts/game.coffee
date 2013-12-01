class @Game
  @options =
    width: 15
    height: 9
    element: 'main'

    tile:
      width: 64
      height: 64

  @width  = @options.width * @options.tile.width
  @height = @options.height * @options.tile.height

  constructor: ->
    Crafty.init Game.width, Game.height, Game.options.element
    Crafty.background('#F3DB43')
    @player = Crafty.e('Player').at(1, 8)
    @generateStones()

  generateStones: ->
    @player.bind 'EnterFrame', =>
      return if Math.random() > 0.05

      lane = (Math.floor(Math.random()*3) + 2) * 2
      Crafty.e('Stone').at 18 - Crafty.viewport.x / Game.options.tile.width, lane
