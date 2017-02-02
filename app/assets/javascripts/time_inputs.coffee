@pad = (str, max) ->
  if !str then str = ""
  if str.length < max then pad("0" + str, max) else str

@clearDateFields = (element) ->
  target_name = element.data("target-name")
  clearClassStyles(target_name)
  $("##{target_name}_day").val("")
  $("##{target_name}_month").val("")
  $("##{target_name}_year").val("")
  $("##{target_name}_day").change()
  $("##{target_name}_day").blur()

@clearTimeFields = (element, format) ->
  target_name = element.data("target-name")
  clearClassStyles(target_name)
  $("##{target_name}_hours").val("")
  $("##{target_name}_minutes").val("")
  $("##{target_name}_seconds").val("")
  time_period = if format == '12hour-pm' then 'pm' else 'am'
  $("##{target_name}_period").val(time_period)
  $("##{target_name}_hours").change()
  $("##{target_name}_hours").blur()

@clearTimeDurationFields = (element) ->
  target_name = element.data("target-name")
  clearClassStyles(target_name)
  $("##{target_name}_hours").val("")
  $("##{target_name}_minutes").val("")
  $("##{target_name}_seconds").val("")
  $("##{target_name}_hours").change()
  $("##{target_name}_minutes").blur()

@setCurrentDate = (element) ->
  target_name = element.data("target-name")
  date = new Date()
  $("##{target_name}_day").val(date.getDate())
  $("##{target_name}_month").val(date.getMonth()+1)
  $("##{target_name}_year").val(date.getFullYear())
  $("##{target_name}_day").change()
  $("##{target_name}_day").blur()

@setCurrentTime = (element) ->
  currentTime = new Date()
  time =
    hours: pad(String(currentTime.getHours()), 2)
    minutes: pad(String(currentTime.getMinutes()), 2)
    seconds: pad(String(currentTime.getSeconds()), 2)

  target_name = element.data("target-name")
  date = new Date()
  $("##{target_name}_hours").val(time["hours"])
  $("##{target_name}_minutes").val(time["minutes"])
  $("##{target_name}_seconds").val(time["seconds"])
  $("##{target_name}_hours").change()
  $("##{target_name}_hours").blur()

@setCurrentTime12Hour = (element) ->
  currentTime = new Date()
  time =
    hours: pad(String(currentTime.getHours() % 12), 2)
    minutes: pad(String(currentTime.getMinutes()), 2)
    seconds: pad(String(currentTime.getSeconds()), 2)
    period: if currentTime.getHours() < 12 then 'am' else 'pm'

  target_name = element.data("target-name")
  date = new Date()
  $("##{target_name}_hours").val(time["hours"])
  $("##{target_name}_minutes").val(time["minutes"])
  $("##{target_name}_seconds").val(time["seconds"])
  $("##{target_name}_period").val(time["period"])
  $("##{target_name}_hours").change()
  $("##{target_name}_hours").blur()

$(document)
  .on('click', '[data-object~="set-time-input-to-current-time"]', ->
    setCurrentTime($(this))
    false
  )
  .on('click', '[data-object~="set-time-input-to-current-time-12hour"]', ->
    setCurrentTime12Hour($(this))
    false
  )
  .on("click", '[data-object~="clear-time-input"]', (event) ->
    clearTimeFields($(this), $(this).data('format'))
    event.preventDefault()
  )
  .on("click", '[data-object~="clear-time-duration-input"]', (event) ->
    clearTimeDurationFields($(this))
    event.preventDefault()
  )
  .on("click", '[data-object~="clear-date-input"]', ->
    clearDateFields($(this))
    false
  )
  .on('click', '[data-object~="set-date-input-to-current-date"]', ->
    setCurrentDate($(this))
    false
  )
