@subjectsReady = () ->
  $("#subject-search").each( () ->
    $this = $(this)
    $this.typeahead(
      remote: root_url + "projects/#{$this.data('project-slug')}/subjects/search?q=%QUERY"
      template: '<p><span class="label label-{{status_class}}">{{status}}</span> <strong>{{subject_code}}</strong></p>'
      engine: Hogan
    )
  )
