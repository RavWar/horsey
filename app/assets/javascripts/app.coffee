//= require jquery
//= require jquery_ujs
//= require turbolinks

//= require crafty

//= require assets
//= require components
//= require game

$ ->
  game = new Game if $('#container').length

  $(document).on 'click', '.play', (e) ->
    e.preventDefault()
    $('#start').hide()
    $('#game').show()

  $(document).on 'click', '#pause', (e) ->
    e.preventDefault()
    Crafty.pause()
    $(this).toggleClass('active')
    playing = not playing
