@activateSheetDraggables = ->
  $('[data-object~="sheet-draggable"]').draggable(
    revert: 'invalid'
    helper: ->
      "<div class='sheet-drag-helper'>Sheet #{$(this).data('sheet-name')}</div>"
    cursorAt: { left: 10 }
    appendTo: "body"
  )

@activateEventDroppables = ->
  $('[data-object~="event-droppable"]').droppable(
    hoverClass: "event-droppable-hover"
    tolerance: "pointer"
    drop: ( event, ui ) ->
      project_id = $(this).data('project-id')
      subject_event_id = $(this).data('subject-event-id')
      sheet_id = ui['draggable'].data('sheet-id')
      $.post("#{root_url}projects/#{project_id}/sheets/#{sheet_id}/move_to_event", "_method=patch&subject_event_id=#{subject_event_id}", null, "script")
    accept: ( draggable ) ->
      $(this).data('subject-event-id') != draggable.data('subject-event-id')
  )

@initializeSheet = (filter_element = '') ->
  $("#{filter_element} .chzn-select").chosen({ allow_single_deselect: true })
  updateAllDesignOptionsVisibility()
  updateCalculatedVariables()
  $('.grid_sortable').sortable(
    axis: 'y'
    handle: '.grid-handle'
  )
  signaturesReady()

# TODO: Might be able to remove this in the future with Turbolinks 5
# https://github.com/turbolinks/turbolinks-classic/issues/455
@fix_ie10_placeholder = ->
  $('textarea').each ->
    if $(@).val() == $(@).attr('placeholder')
      $(@).val ''

@nonStandardClick = (event) ->
  event.which > 1 or event.metaKey or event.ctrlKey or event.shiftKey or event.altKey

@sheetsReady = ->
  initializeSheet()
  activateSheetDraggables()
  activateEventDroppables()
  fix_ie10_placeholder()

$(document)
  .on('click', '[data-object~="export"]', ->
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
