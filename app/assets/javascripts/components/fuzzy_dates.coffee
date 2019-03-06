@fuzzyDateNext = (element) ->
  nextElement = $(element).next("[data-object~=fuzzy-date]")[0]
  setFocusStart(nextElement) if !!nextElement

@fuzzyDatePrevious = (element) ->
  prevElement = $(element).prev("[data-object~=fuzzy-date]")[0]
  setFocusEnd(prevElement) if !!prevElement

$(document)
  .on("keyup", "[data-object~=fuzzy-date]", (e) ->
    if e.which >= 48 && e.which <= 57
      $(this).val(String.fromCharCode(e.keyCode))
      # e.stopPropagation()
      # e.preventDefault()
      fuzzyDateNext(this)
    else if e.which == 37
      fuzzyDatePrevious(this)
    else if e.which == 39
      fuzzyDateNext(this)
    else if e.which == 8
      # Backspace
      $(this).val("")
      fuzzyDatePrevious(this)
    else if e.which == 46
      # Delete
      $(this).val("")
    else if e.which == 9 || e.which == 13 || e.which == 16 || e.which == 27 || e.which == 38 || e.which == 40
      # Enter, Escape, Tabs and Arrow keys
    else
      $(this).val("")
  )
