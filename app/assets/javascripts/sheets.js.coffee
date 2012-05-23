# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/
jQuery ->
  $("#sheet_design_id").change( () ->
    $.post(root_url + 'designs/selection', $("#sheet_design_id").serialize(), null, "script")
    false
  )
