pad = (str, max) ->
  if !str then str = ""
  if str.length < max then pad("0" + str, max) else str

setCurrentTime = (event) ->
  name = $(event.target).data("target-input")
  currentTime = new Date()
  time =
    hour: pad(String(currentTime.getHours()), 2)
    min: pad(String(currentTime.getMinutes()), 2)
    sec: pad(String(currentTime.getSeconds()), 2)

  $("input:hidden[name='"+name+"']").val(time["hour"]+":"+time["min"]+":"+time["sec"])
  $("input:text[name='hour_"+name+"']").val(time["hour"])
  $("input:text[name='min_"+name+"']").val(time["min"])
  $("input:text[name='sec_"+name+"']").val(time["sec"])

  false

setFullTimeField = (target) ->
  name = target.data("target-input")
  time =
    hour: pad($("input:text[name='hour_"+name+"']").val(), 2)
    min:  pad($("input:text[name='min_"+name+"']").val(), 2)
    sec:  pad($("input:text[name='sec_"+name+"']").val(), 2)

  for key, val of time
    if !val or val.length == 0 then time[key] = "00"
  if $("input:text[name='hour_"+name+"']").val() == '' and $("input:text[name='min_"+name+"']").val() == '' and $("input:text[name='sec_"+name+"']").val() == ''
    $("input:hidden[name='"+name+"']").val('')
  else
    $("input:hidden[name='"+name+"']").val(time["hour"]+":"+time["min"]+":"+time["sec"])
  false

reformatTimeInput = (target, int_val) ->
  name = target.data("target-input")
  if int_val then s = String(int_val) else s = ""
  target.val(pad(s, 2)) unless $("input:hidden[name='"+name+"']").val() == ''
  setFullTimeField(target)

@setFullDateField = (element) ->
  name = element.data("target-input")
  target_input = $(name)
  day_target = $(name.replace("#", "#day_"))
  month_target = $(name.replace("#", "#month_"))
  year_target = $(name.replace("#", "#year_"))

  day_int = parseInt(day_target.val())
  month_int = parseInt(month_target.val())
  year_int = parseInt(year_target.val())

  temp_date = Date.parse("#{year_int}-#{month_int}-#{day_int} 00:00:00");
  date = new Date(temp_date)

  day = date.getDate()
  month = date.getMonth()+1
  year = date.getFullYear()

  if !isNaN(day) and !isNaN(month) and !isNaN(year)
    target_input.val(String(date.getMonth()+1)+"/"+String(date.getDate())+"/"+String(date.getFullYear()))
  else
    target_input.val('')
  target_input.change()
  false

@clearDateFields = (element) ->
  name = element.data("target-input")
  target_input = $(name)
  day_target = $(name.replace("#", "#day_"))
  month_target = $(name.replace("#", "#month_"))
  year_target = $(name.replace("#", "#year_"))

  target_input.val("")
  day_target.val("")
  month_target.val("")
  year_target.val("")
  target_input.change()

@setCurrentDate = (element) ->
  name = element.data("target-input")
  target_input = $(name)
  day_target = $(name.replace("#", "#day_"))
  month_target = $(name.replace("#", "#month_"))
  year_target = $(name.replace("#", "#year_"))

  date = new Date()

  target_input.val(String(date.getMonth()+1)+"/"+String(date.getDate())+"/"+String(date.getFullYear()))
  day_target.val(date.getDate())
  month_target.val(date.getMonth()+1)
  year_target.val(date.getFullYear())
  target_input.change()

clearTimeFields = (name) ->
  $("input:hidden[name='"+name+"']").val("")
  $("input:text[name='hour_"+name+"']").val("")
  $("input:text[name='min_"+name+"']").val("")
  $("input:text[name='sec_"+name+"']").val("")


$(document)
  .on("keypress", ".time-input", (event) ->
    if event.which == 96
      clearTimeFields($(this).find("input:hidden").attr("name"))
      event.preventDefault()
  )
  .on('click', '[data-object~="set-time-input-to-current-time"]', setCurrentTime)
  .on('change', ".time-input input", () ->
    reformatTimeInput($(this), parseInt($(this).val()))
  )
  .on('blur', ".time-input input", () ->
    reformatTimeInput($(this), parseInt($(this).val()))
  )
  .on("click", '[data-object~="clear-time-input"]', (event) ->
    clearTimeFields($(this).data("target-input"))
    event.preventDefault()
  )
  .on("click", '[data-object~="clear-date-input"]', () ->
    clearDateFields($(this))
    false
  )
  .on('change', '[data-object~="date-field"]', () ->
    setFullDateField($(this))
  )
  .on('blur', '[data-object~="date-field"]', () ->
    setFullDateField($(this))
  )
  .on('click', '[data-object~="set-date-input-to-current-date"]', () ->
    setCurrentDate($(this))
    false
  )

