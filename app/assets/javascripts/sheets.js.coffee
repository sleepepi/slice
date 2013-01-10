# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

@initializeSheet = (filter_element = '') ->
  $("#{filter_element} .chzn-select").chosen({ allow_single_deselect: true })
  $("#{filter_element} .timepicker").timepicker({ 'timeFormat': 'H:i:s' })
  $("#{filter_element} .datepicker").datepicker(
    showOtherMonths: true
    selectOtherMonths: true
    changeMonth: true
    changeYear: true
    onClose: (text, inst) -> $(this).focus()
  )
  $("#{filter_element} .datepicker").change( () ->
    try
      $(this).val($.datepicker.formatDate('mm/dd/yy', $.datepicker.parseDate('mm/dd/yy', $(this).val())))
    catch error
      # Nothing
  )
  $("#{filter_element} [data-object~='variable-typeahead']").each( () ->
    $this = $(this)
    $this.typeahead(
      source: (query, process) ->
        variable_id = $this.data('variable-id')
        return $.get(root_url + 'projects/' + $("#sheet_project_id").val() + '/variables/' + variable_id + '/typeahead', { query: query, sheet_authentication_token: ($('#sheet_authentication_token').val() || "") }, (data) -> return process(data))
    )
  )
  updateAllVariables()
  updateCalculatedVariables()
  $('[data-spy~="affix"]').affix( offset: { top: 423 } )
  checkAllRanges()
  $("span[rel~=tooltip], label[rel~=tooltip]").tooltip( trigger: 'hover' )
  $("span[rel~=popover], label[rel~=popover]").popover( trigger: 'hover' )

jQuery ->
  $("#sheet_design_id").on('change', () ->
    $.post(root_url + 'projects/' + $("#sheet_project_id").val() + '/designs/selection', $(this).serialize(), null, "script")
    false
  )

  $("#sheet_subject_id, #sheet_study_date").on('change', () ->
    $.post(root_url + 'projects/' + $("#sheet_project_id").val() + '/sheets/project_selection', $("sheet_design_id").serialize() + $("#hidden_sheet_id").serialize() + '&' + $("#sheet_subject_id").serialize() + '&' + $("#sheet_design_id").serialize() + '&' + $("#sheet_study_date").serialize(), null, "script")
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

  $("#email_history_popup").on('click', () ->
    $('#email_history_modal').modal({ dynamic: true })
    false
  )

  $(document)
    .on('click', '[data-object~="export"]', () ->
      window.location = $($(this).data('target')).attr('action') + '.' + $(this).data('format') + '?' + $($(this).data('target')).serialize()
      false
    )
    .on('click', "[data-link]", (e) ->
      if nonStandardClick(e)
        window.open($(this).data("link"))
        return false
      else
        window.location = $(this).data("link")
    )

  initializeSheet()
