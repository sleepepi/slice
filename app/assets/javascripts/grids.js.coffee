@gridDown = (element, e) ->
  parts = $(element).attr('id').split('_')
  parts[2] = parseInt(parts[2]) - 1
  if $("##{parts.join('_')}").length > 0
    setFocusToField("##{parts.join('_')}")
  else
    gridBack(element, e)

@gridUp = (element, e) ->
  parts = $(element).attr('id').split('_')
  parts[2] = parseInt(parts[2]) + 1
  if $("##{parts.join('_')}").length > 0
    setFocusToField("##{parts.join('_')}")
  else
    gridForward(element, e)

@gridForward = (element, e) ->
  navigatables = $("[data-object~='cursor-navigatable']")
  if navigatables[navigatables.index(element) + 1]
    next_id = $(navigatables[navigatables.index(element) + 1]).attr('id')
    setFocusToField("##{next_id}")
    e.preventDefault()
    e.stopPropagation()
    false

@gridBack = (element, e) ->
  navigatables = $("[data-object~='cursor-navigatable']")
  if navigatables[navigatables.index(element) - 1]
    prev_id = $(navigatables[navigatables.index(element) - 1]).attr('id')
    setFocusToField("##{prev_id}")
    e.preventDefault()
    e.stopPropagation()
    false

$(document)
  .on('keydown', "[data-object~='cursor-navigatable']", (e) ->
    if e.which == 37 and $(this).getCursorPosition() == 0
      gridBack($(this), e)
    if e.which == 39 and $(this).getCursorPosition() == $(this).val().length
      gridForward($(this), e)
    if e.which == 38
      gridDown($(this), e)
    if e.which == 40
      gridUp($(this), e)
  )
  .on('focus', ".table-grid input", () ->
    $(this).closest('.table-grid tr').addClass('info');
  )
  .on('blur', ".table-grid input", () ->
    $(this).closest('.table-grid tr').removeClass('info');
  )
