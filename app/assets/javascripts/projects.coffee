@projectSortables = ->
  $("[data-object~=projects-sortable]").sortable(
    handle: ".handle-visible"
    axis: "y"
    stop: ->
      params = {}
      params.page = $(this).data("page")
      params.project_ids = $(this).sortable("toArray", attribute: "data-project-id")
      $.post("#{root_url}projects/save_project_order", params, null, "script")
      true
  )

@projectsReady = ->
  projectSortables()
