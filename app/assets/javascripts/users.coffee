@usersReady = () ->
  $("[data-object~='typeahead-users']").each( () ->
    $this = $(this)
    $this.typeahead(
      remote: root_url + "users/invite?q=%QUERY"
      template: '<p><strong>{{name}}</strong></p><p>{{value}}</p>'
      engine: Hogan
    )
  )
