# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/
jQuery ->
  $("#subject_project_id").on('change', () ->
    $.post(root_url + 'projects/' + $("#subject_project_id").val() + '/sites/selection', 'subject_code=' + $("#subject_subject_code").val() + '&select=1', null, "script")
    false
  )
