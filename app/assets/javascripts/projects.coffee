@projectsReady = () ->
  $('[data-object~="projects-sortable"]').sortable(
    handle: ".handle"
    axis: "y"
    stop: () ->
      favored_order = if $('[data-object~="projects-sortable"][data-category~="favored"]').length > 0
        $('[data-object~="projects-sortable"][data-category~="favored"]').sortable('toArray', attribute: 'data-project-id')
      else
        []
      unfavored_order = if $('[data-object~="projects-sortable"][data-category~="unfavored"]').length > 0
        $('[data-object~="projects-sortable"][data-category~="unfavored"]').sortable('toArray', attribute: 'data-project-id')
      else
        []
      sortable_order = favored_order.concat(unfavored_order)
      params = {}
      params.page = $(this).data('page')
      params.project_ids = sortable_order
      $.post(root_url + 'projects/save_project_order', params, null, "script")
      true
  )

$(document)
  .on('click', '[data-loading-text]', () ->
    $(this).button('loading')
  )
