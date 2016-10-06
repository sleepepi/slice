@typeaheadReady = ->
  $('[data-object~="typeahead"]').each( ->
    $this = $(this)
    $this.typeahead(
      local: $this.data('local')
    )
  )
