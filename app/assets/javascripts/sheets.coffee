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
    classes:
      'ui-droppable-hover': 'event-droppable-hover'
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
  $("#{filter_element} .chosen-select").chosen({ allow_single_deselect: true })
  updateAllDesignOptionsVisibility()
  updateCalculatedVariables()
  $('[data-object~="grid-sortable"]').sortable(
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

@updateCoverage = ->
  $('[data-object~="sheet-coverage-updater"]').each( (index, element) ->
    setTimeout (->
      $.post($(element).data('url'), null, null, 'script')
      return
    ), 1000 + index * 1000
  )

@sheetFiltersTextcompleteReady = ->
  $('[data-object~="sheet-filters-textcomplete"]').each( ->
    $this = $(this)
    $this.textcomplete(
      [
        {
          name: 'search'
          match: /(\b)([\w\-]+\:[\w\-]*)$/
          search: (term, callback) ->
            $.getJSON("#{root_url}projects/#{$this.data('project-id')}/sheets/search", { search: term, scope: 'full-word-colon' })
              .done((resp) -> callback(resp))
              .fail(-> callback([]))
          replace: (item) ->
            return "$1#{item.value}"
          template: (item) ->
            if item.label?
              "#{item.label}"
            else
              "#{item.value}"
          cache: true
        },
        {
          name: 'search'
          match: /(\b)([\w\-]+\:([\w\-]+\,)+[\w\-]*)$/
          search: (term, callback) ->
            $.getJSON("#{root_url}projects/#{$this.data('project-id')}/sheets/search", { search: term, scope: 'full-word-comma' })
              .done((resp) -> callback(resp))
              .fail(-> callback([]))
          replace: (item) ->
            return "$1#{item.value}"
          template: (item) ->
            if item.label?
              "#{item.label}"
            else
              "#{item.value}"
          cache: true
        },
        {
          name: 'search'
          match: /(^|\s)([\w\-]+)$/
          search: (term, callback) ->
            $.getJSON("#{root_url}projects/#{$this.data('project-id')}/sheets/search", { search: term, scope: '' })
              .done((resp) -> callback(resp))
              .fail(-> callback([]))
          replace: (item) ->
            return "$1#{item.value}"
          template: (item) ->
            if item.label?
              "#{item.label}"
            else
              "#{item.value}"
          cache: true
        },
        {
          name: 'search'
          match: /(^|\s)(\w+\:[^\s]*)$/
          search: (term, callback) ->
            words = ['randomized']
            resp = $.map(words, (word) ->
              if word.indexOf(term) == 0
                word
              else
                null
            )
            callback(resp)
          replace: (value) -> return "$1is:#{value}"
        }
      ], { appendTo: 'body' }
    )
  )

@sheetsReady = ->
  initializeSheet()
  activateSheetDraggables()
  activateEventDroppables()
  fix_ie10_placeholder()
  updateCoverage()
  sheetFiltersTextcompleteReady()

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
  .on('click', '[data-object~="sheet-export-link"]', (e) ->
    url = "#{root_url}projects/#{$(this).data('project-id')}/exports/new?filters=#{$("#search").val()}"
    if nonStandardClick(e)
      window.open(url)
      false
    else
      Turbolinks.visit(url)
  )
