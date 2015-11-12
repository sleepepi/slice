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
      remote: "#{root_url}external/typeahead?query=%QUERY&design=#{$this.data('design')}&variable_id=#{$this.data('variable-id')}&handoff=#{$this.data('handoff')}"
    )
  )
  updateAllDesignOptionsVisibility()
  updateCalculatedVariables()
  $( ".grid_sortable" ).sortable(
    axis: "y"
    handle: ".grid-handle"
  )
  signaturesReady()
  # console.log "Sheet initialized in #{Date.now() - timeInMs} ms"

@sheetsReady = () ->
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
  .on('change', '#locked', () ->
    $('#sheets_search').submit()
  )
