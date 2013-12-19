//= require jquery
//= require jquery_ujs
//= require turbolinks

//= require crafty

//= require assets
//= require components
//= require game

$ ->
  isMobile = navigator.userAgent.match(/(iPhone|iPod|iPad|BlackBerry|Android|Windows Phone|Opera Mobi)/i)?
  hasTouch = "ontouchstart" of window or navigator.msMaxTouchPoints

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

  $('#controls').show() if hasTouch
  $(document).on 'click', '#controls button', (e) ->
    e.preventDefault()
