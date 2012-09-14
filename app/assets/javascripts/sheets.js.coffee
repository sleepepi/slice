# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/
jQuery ->
  $("#sheet_design_id").on('change', () ->
    $.post(root_url + 'designs/selection', $(this).serialize(), null, "script")
    false
  )

  $("#sheet_project_id, #sheet_subject_id").on('change', () ->
    $.post(root_url + 'sheets/project_selection', 'project_id=' + $("#sheet_project_id").val() + '&' + $("#sheet_subject_id").serialize() + '&' + $("#sheet_design_id").serialize(), null, "script")
    false
  )

  $("#email_popup").on('click', () ->
    $('#send_email_modal').modal({ dynamic: true })
    false
  )

  $("#info_popup").on('click', () ->
    $('#info_modal').modal({ dynamic: true })
    false
  )

  $(document).on('click', '[data-object~="export"]', () ->
    window.location = $($(this).data('target')).attr('action') + '.' + $(this).data('format') + '?' + $($(this).data('target')).serialize()
    false
  )
