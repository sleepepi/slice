@typeaheadReady = ->
  $('[data-object~="typeahead"]').typeahead('destroy')
  $('[data-object~="typeahead"]').each( ->
    $this = $(this)
    bloodhound = new Bloodhound(
      datumTokenizer: Bloodhound.tokenizers.whitespace
      queryTokenizer: Bloodhound.tokenizers.whitespace
      local: $this.data('local')
    )
    $this.typeahead({ hint: true }, { source: bloodhound })
  )
