@usersReady = ->
  $("[data-object~=typeahead-users]").typeahead("destroy")
  $("[data-object~=typeahead-users]").each( ->
    $this = $(this)
    bloodhound = new Bloodhound(
      datumTokenizer: Bloodhound.tokenizers.obj.whitespace("email")
      queryTokenizer: Bloodhound.tokenizers.whitespace
      remote:
        url: "#{$this.data("path")}?search=%QUERY"
        wildcard: "%QUERY"
    )
    $this.typeahead({ hint: true },
      display: "email"
      source: bloodhound
      templates:
        suggestion: (item) -> return "<div><strong>#{item.full_name}</strong></div><div>#{item.email}</div>"
    )
  )
