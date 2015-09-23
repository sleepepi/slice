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
  timeInMs = Date.now()
  $("#{filter_element} .chzn-select").chosen({ allow_single_deselect: true })

  $("#{filter_element} [data-object~='variable-typeahead']").each( () ->
    $this = $(this)
    $this.typeahead(
      remote: root_url + 'projects/' + $("#sheet_project_id").val() + '/variables/' + $this.data('variable-id') + '/typeahead' + '?query=%QUERY' + "&sheet_authentication_token=#{($('#sheet_authentication_token').val() || '')}"
    )
  )
  updateAllVariables()
  updateCalculatedVariables()
  $( ".grid_sortable" ).sortable(
    axis: "y"
    handle: ".grid-handle"
  )
  signaturesReady()
  console.log "Sheet initialized in #{Date.now() - timeInMs} ms"

@evaluateBranchingLogic = () ->
  $('[data-object~="evaluate-branching-logic"]').each( (index, element) ->
    visible = elementVisible(element)
    if visible
      $(element).show()
    else
      $(element).hide()
  )

@sheetsReady = () ->
  initializeSheet()
  evaluateBranchingLogic()
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
  .on('typeahead:selected', "#sheet_subject_id", (event, datum) ->
    $(this).val(datum['value'])
    $('#sheet_subject_acrostic').val(datum['acrostic'])
    $('#site_id').val(datum['site_id'])
  )
  .on('change', '#locked', () ->
    $('#sheets_search').submit()
  )
