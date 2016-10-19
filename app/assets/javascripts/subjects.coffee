@subjectsReady = ->
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
