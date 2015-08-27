# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

@activateSheetDraggables = () ->
  $('[data-object~="sheet-draggable"]').draggable(
    revert: 'invalid'
    helper: () ->
      "<div class='sheet-drag-helper'>Sheet #{$(this).data('sheet-name')}</div>"
    cursorAt: { left: 10 }
    appendTo: "body"
  )

@activateEventDroppables = () ->
  $('[data-object~="event-droppable"]').droppable(
    hoverClass: "event-droppable-hover"
    tolerance: "pointer"
    drop: ( event, ui ) ->
      project_id = $(this).data('project-id')
      subject_event_id = $(this).data('subject-event-id')
      sheet_id = ui['draggable'].data('sheet-id')
      $.post(root_url + "projects/#{project_id}/sheets/#{sheet_id}/move_to_event", "_method=patch&subject_event_id=#{subject_event_id}", null, "script")
    accept: ( draggable ) ->
      $(this).data('subject-event-id') != draggable.data('subject-event-id')
  )


@initializeSheet = (filter_element = '') ->
  $("#{filter_element} .chzn-select").chosen({ allow_single_deselect: true })
  $("#{filter_element} .datepicker").datepicker('remove')
  $("#{filter_element} .datepicker").datepicker( autoclose: true )

  $("#{filter_element} .datepicker").change( () ->
    try
      $(this).val($.datepicker.formatDate('mm/dd/yy', $.datepicker.parseDate('mm/dd/yy', $(this).val())))

    catch error
      # Nothing
  )


  $("#{filter_element} [data-object~='variable-typeahead']").each( () ->
    $this = $(this)
    $this.typeahead(
      remote: root_url + 'projects/' + $("#sheet_project_id").val() + '/variables/' + $this.data('variable-id') + '/typeahead' + '?query=%QUERY' + "&sheet_authentication_token=#{($('#sheet_authentication_token').val() || '')}"
    )
  )
  updateAllVariables()
  updateCalculatedVariables()
  $("span[rel~=tooltip], label[rel~=tooltip]").tooltip( trigger: 'hover' )
  $("span[rel~=popover], label[rel~=popover]").popover( trigger: 'hover' )
  $( ".grid_sortable" ).sortable(
    axis: "y"
    handle: ".grid-handle"
  )
  $('[rel=tooltip]').tooltip()
  signaturesReady()

@evaluateBranchingLogic = () ->
  $('[data-object~="evaluate-branching-logic"]').each( (index, element) ->
    if $(element).data('branching-logic') == ""
      branching_logic_result = true
    else
      try
        branching_logic_result = eval($(element).data('branching-logic'))
      catch error
        branching_logic_result = true

    if branching_logic_result
      # $(element).css('background', "#ccc")
    else
      $(element).hide()
      # $(element).css('background', "#0f0")
  )

@sheetsReady = () ->
  $('#sheet_subject_id').each( () ->
    $this = $(this)
    $this.typeahead(
      local: $("#sheet_subject_id").data('local')
      template: '<p><span class="label label-{{status_class}}">{{status}}</span> <strong>{{subject_code}}</strong> {{acrostic}}</p>'
      engine: Hogan
    )
  )
  initializeSheet()
  activateSheetDraggables()
  activateEventDroppables()

$(document)
  .on('click', '[data-object~="export"]', () ->
    url = $($(this).data('target')).attr('action') + '.' + $(this).data('format') + '?' + $($(this).data('target')).serialize()
    if $(this).data('page') == 'blank'
      window.open(url)
    else
      window.location = url
    false
  )
  .on('click', "[data-link]", (e) ->
    if $(e.target).is('a')
      # Do nothing, propagate standard behavior
    else if nonStandardClick(e)
      window.open($(this).data("link"))
      return false
    else
      Turbolinks.visit($(this).data("link"))
  )
  .on('click', '[data-object~="export-data"]', () ->
    $('[data-dismiss~=alert]').click()
    form = $(this).data('target')
    $.get($(form).attr("action"), $(form).serialize() + '&export=1', null, "script")
    $(this).attr('disabled', 'disabled')
    false
  )
  .on('change', '#sheet_design_id', () ->
    $.post(root_url + 'projects/' + $("#sheet_project_id").val() + '/designs/selection', $(this).serialize() + '&' + $("#sheet_subject_id").serialize(), null, "script")
    false
  )
  .on('typeahead:selected', "#sheet_subject_id", (event, datum) ->
    $(this).val(datum['value'])
    $('#sheet_subject_acrostic').val(datum['acrostic'])
    $('#site_id').val(datum['site_id'])
  )
  .on('change', '#locked', () ->
    $('#sheets_search').submit()
  )
