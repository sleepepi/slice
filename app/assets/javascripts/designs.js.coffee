# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

jQuery ->
  $('#add_more_variables').click( () ->
    $.post(root_url + 'designs/add_variable', $("form").serialize() + "&_method=post", null, "script")
    false
  )
