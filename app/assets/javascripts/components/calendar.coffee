$(document)
  .on('mouseenter', '[data-object~="calendar-window-hover"]', ->
    return false unless document.documentElement.ontouchstart == undefined
    $("[data-object~='calendar-window'][data-task-id=#{$(this).data('task-id')}]").addClass('calendar-window-hover')
  )
  .on('mouseleave', '[data-object~="calendar-window-hover"]', ->
    $("[data-object~='calendar-window'][data-task-id=#{$(this).data('task-id')}]").removeClass('calendar-window-hover')
  )
