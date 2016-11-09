@adverseEventsSubjectSearchReady = ->
  $("#subject-search").typeahead('destroy')
  $("#subject-search").each( ->
    $this = $(this)
    bloodhound = new Bloodhound(
      datumTokenizer: Bloodhound.tokenizers.obj.whitespace('value')
      queryTokenizer: Bloodhound.tokenizers.whitespace
      remote:
        url: "#{root_url}projects/#{$this.data('project-slug')}/subjects/search?q=%QUERY"
        wildcard: '%QUERY'
    )
    $this.typeahead({ hint: true },
      display: 'value'
      source: bloodhound
      templates:
        suggestion: (item) -> return "<div><strong>#{item.subject_code}</strong></div>"
    )
  )

@subjectsAutocompleteReady = ->
  $('[data-object~="subjects-autocomplete"]').each( ->
    $this = $(this)
    $this.textcomplete(
      [
        {
          match: /(^|\s)has\:([\w\-]*)$/
          search: (term, callback) ->
            words = ['adverse-events', 'comments', 'files']
            resp = $.map(words, (word) ->
              if word.indexOf(term) == 0
                word
              else
                null
            )
            callback(resp)
          replace: (value) -> return "$1has:#{value}"
        },
        {
          match: /(^|\s)is\:([\w\-]*)$/
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
        },
        {
          match: /(^|\s)not\:([\w\-]*)$/
          search: (term, callback) ->
            words = ['randomized']
            resp = $.map(words, (word) ->
              if word.indexOf(term) == 0
                word
              else
                null
            )
            callback(resp)
          replace: (value) -> return "$1not:#{value}"
        },
        {
          match: /(^|\s)adverse-events\:([\w\-]*)$/
          search: (term, callback) ->
            words = ['open', 'closed']
            resp = $.map(words, (word) ->
              if word.indexOf(term) == 0
                word
              else
                null
            )
            callback(resp)
          replace: (value) -> return "$1adverse-events:#{value}"
        },
        {
          match: /(^|\s)([\w\-]+)$/
          search: (term, callback) ->
            # callback(cache[term], true)
            $.getJSON("#{root_url}projects/#{$this.data('project-id')}/subjects/autocomplete", { q: term })
              .done((resp) -> callback(resp))
              .fail(-> callback([]))
          replace: (value) ->
            return "$1#{value}"
          cache: true
        }
      ], { appendTo: 'body' }
    )
  )

@subjectsReady = ->
  adverseEventsSubjectSearchReady()
  subjectsAutocompleteReady()
