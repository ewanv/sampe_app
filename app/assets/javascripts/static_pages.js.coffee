# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/


$ ->
  $("#micropost_content").on "propertychange input textInput", ->
    left = 140 - $(this).val().length
    left = 0  if left < 0
    $("#counter").text "Characters left: " + left
