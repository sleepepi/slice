@fuzzyDateNext = (element) ->
  nextElement = $(element).next("[data-object~=fuzzy-date]")[0]
  setFocusStart(nextElement) if !!nextElement

@fuzzyDatePrevious = (element) ->
  prevElement = $(element).prev("[data-object~=fuzzy-date]")[0]
  setFocusEnd(prevElement) if !!prevElement

$(document)
  .on("keyup", "[data-object~=fuzzy-date]", (e) ->
    if (e.which >= 48 && e.which <= 57) || (e.which >= 96 && e.which <= 105)
      # Normalize numpad keys to work as well.
      keyValue = if e.which >= 96 then e.which - 48 else e.which
      $(this).val(String.fromCharCode(keyValue))
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
  .on("click", "[data-object~=fuzzy-date-today]", ->
    date = new Date()
    dy = date.getDate()
    mo = date.getMonth() + 1
    yr = date.getFullYear()
    key = $(this).data("key")
    $("#medication_#{key}_mo_1").val(parseInt(mo / 10))
    $("#medication_#{key}_mo_2").val(mo % 10)
    $("#medication_#{key}_dy_1").val(parseInt(dy / 10))
    $("#medication_#{key}_dy_2").val(dy % 10)
    $("#medication_#{key}_yr_1").val(parseInt(yr / 1000))
    $("#medication_#{key}_yr_2").val((parseInt(yr / 100)) % 10)
    $("#medication_#{key}_yr_3").val((parseInt(yr / 10)) % 10)
    $("#medication_#{key}_yr_4").val(yr % 10)
    false
  )
  .on("click", "[data-object~=fuzzy-date-clear]", ->
    key = $(this).data("key")
    $("#medication_#{key}_mo_1").val("")
    $("#medication_#{key}_mo_2").val("")
    $("#medication_#{key}_dy_1").val("")
    $("#medication_#{key}_dy_2").val("")
    $("#medication_#{key}_yr_1").val("")
    $("#medication_#{key}_yr_2").val("")
    $("#medication_#{key}_yr_3").val("")
    $("#medication_#{key}_yr_4").val("")
    false
  )
