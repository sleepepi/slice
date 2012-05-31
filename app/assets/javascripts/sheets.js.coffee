# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/
jQuery ->
  $("#sheet_design_id").on('change', () ->
    $.post(root_url + 'designs/selection', $("#sheet_design_id").serialize(), null, "script")
    false
  )

  $("#sheet_project_id, #sheet_subject_id").on('change', () ->
    $.post(root_url + 'sites/selection', 'project_id=' + $("#sheet_project_id").val() + '&' + $("#sheet_subject_id").serialize(), null, "script")
    false
  )

  $("#email_popup").on('click', () ->
    $('#send_email_modal').modal({ dynamic: true })
    false
  )
