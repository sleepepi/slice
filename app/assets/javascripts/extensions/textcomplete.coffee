# Prefer use of textcomplete over typeahead.

@textcompleteReady = ->
  $("[data-object~=textcomplete]").each( ->
    $this = $(this)
    $this.textcomplete(
      [
        {
          match: /(^)(.+)$/
          search: (term, callback) ->
            $.getJSON("#{$this.data("textcomplete-url")}", { search: term })
              .done((resp) -> callback(resp))
              .fail(-> callback([]))
          replace: (value) ->
            return "#{value}"
          cache: true
        }
      ]
    )
  )
