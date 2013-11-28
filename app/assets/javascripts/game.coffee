class @Game
  @options =
    width: 76
    height: 42
    element: '#main'

    tile:
      width: 16
      height: 16

  @width  = @options.width * @options.tile.width
  @height = @options.height * @options.tile.height

  constructor: ->
    Crafty.init Game.width, Game.height, Game.options.element
    Crafty.background('#F3DB43')
    Crafty.e('Player').at(4, 32)
