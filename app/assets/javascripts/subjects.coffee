@subjectsAutocompleteReady = ->
  $('[data-object~="subjects-autocomplete"]').each( ->
    $this = $(this)
    $this.textcomplete(
      [
        {
          name: 'submit-on-click'
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
          name: 'submit-on-click'
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
          name: 'submit-on-click'
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
          name: 'submit-on-click'
          match: /(^|\s)no\:([\w\-]*)$/
          search: (term, callback) ->
            words = ['comments', 'files']
            resp = $.map(words, (word) ->
              if word.indexOf(term) == 0
                word
              else
                null
            )
            callback(resp)
          replace: (value) -> return "$1no:#{value}"
        },
        {
          name: 'submit-on-click'
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
          name: 'search'
          match: /(^|\s)designs\:([\w\-]*)$/
          search: (term, callback) ->
            # callback(cache[term], true)
            $.getJSON("#{root_url}projects/#{$this.data('project-id')}/subjects/designs_search", { q: term })
              .done((resp) -> callback(resp) )
              .fail(-> callback([]))
          replace: (item) ->
            return "$1designs:#{item.value}"
          template: (item) ->
            if item.name?
              "#{item.name}"
            else
              "#{item.value}"
          cache: true
        },
        {
          name: 'search'
          match: /(^|\s)events\:([\w\-]*)$/
          search: (term, callback) ->
            # callback(cache[term], true)
            $.getJSON("#{root_url}projects/#{$this.data('project-id')}/subjects/events_search", { q: term })
              .done((resp) -> callback(resp) )
              .fail(-> callback([]))
          replace: (item) ->
            return "$1events:#{item.value}"
          template: (item) ->
            if item.name?
              "#{item.name}"
            else
              "#{item.value}"
          cache: true
        },
        {
          name: 'search'
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
    ).on('textComplete:select': (e, value, strategy) ->
      if strategy.name == 'search' and value not in ['adverse-events', 'has', 'is', 'not', 'no', 'designs', 'events']
        $(this).closest('form').submit()
      else if strategy.name == 'submit-on-click'
        $(this).closest('form').submit()
    )
  )

@subjectsReady = ->
  subjectsAutocompleteReady()
