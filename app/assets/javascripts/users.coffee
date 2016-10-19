@usersReady = ->
  $("[data-object~='typeahead-users']").typeahead('destroy')
  $("[data-object~='typeahead-users']").each( ->
    $this = $(this)
    bloodhound = new Bloodhound(
      datumTokenizer: Bloodhound.tokenizers.obj.whitespace('value')
      queryTokenizer: Bloodhound.tokenizers.whitespace
      remote:
        url: "#{root_url}users/invite?q=%QUERY"
        wildcard: '%QUERY'
    )
    $this.typeahead({ hint: true },
      display: 'value'
      source: bloodhound
      templates:
        suggestion: (item) -> return "<div><strong>#{item.name}</strong></div><div>#{item.value}</div>"
    )
  )
