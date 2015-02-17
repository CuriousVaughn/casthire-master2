# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
$(document).ready ->
  if $('#hero-section').length > 0
    resizeBg = ->
      windowHeight = $(window).height()
      navHeight = $('#navigation').height()
      heroPadding = $('#hero-section').css('padding').replace('px 0px', '')

      $('.hero-section').height(windowHeight - navHeight - heroPadding)

    resizeBg()

    $(window).resize ->
      resizeBg()
