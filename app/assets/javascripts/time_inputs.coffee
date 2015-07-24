@pad = (str, max) ->
  if !str then str = ""
  if str.length < max then pad("0" + str, max) else str

@setCurrentTime = (element) ->
  currentTime = new Date()
  time =
    hour: pad(String(currentTime.getHours()), 2)
    min: pad(String(currentTime.getMinutes()), 2)
    sec: pad(String(currentTime.getSeconds()), 2)

  target_name = element.data("target-name")
  date = new Date()
  $("##{target_name}_hour").val(time["hour"])
  $("##{target_name}_minutes").val(time["min"])
  $("##{target_name}_seconds").val(time["sec"])
  $("##{target_name}_hour").change()

@checkFullTime = (element) ->
  changes = {}

  target_name = element.data("target-name")
  changes["hour"] = $("##{target_name}_hour").val()
  changes["minutes"] = $("##{target_name}_minutes").val()
  changes["seconds"] = $("##{target_name}_seconds").val()

  url = root_url + 'check-time'

  $.getJSON(url, changes, (data) ->
    $("##{target_name}_hour").parent().removeClass('has-warning')
    $("##{target_name}_minutes").parent().removeClass('has-warning')
    $("##{target_name}_seconds").parent().removeClass('has-warning')
    $("##{target_name}_hour").parent().removeClass('has-error')
    $("##{target_name}_minutes").parent().removeClass('has-error')
    $("##{target_name}_seconds").parent().removeClass('has-error')
    $("##{target_name}_error").hide()
    $("##{target_name}_warning").hide()
    $("##{target_name}_success").hide()
    $("##{target_name}_alert_box").removeClass('bs-callout-success')
    $("##{target_name}_alert_box").removeClass('bs-callout-warning')
    $("##{target_name}_alert_box").removeClass('bs-callout-danger')
    if data
      $("##{target_name}_alert_box").show()
      $("##{target_name}_message").html(data['message'])
      $("##{target_name}_time_string").html(data['time_string'])
      $("##{target_name}_#{data['status']}").show()
      $("##{target_name}_alert_box").addClass('bs-callout-success')
    if data['status'] == 'warning'
      $("##{target_name}_seconds").parent().addClass('has-warning')
      $("##{target_name}_alert_box").addClass('bs-callout-warning')
    if data['status'] == 'error'
      $("##{target_name}_alert_box").addClass('bs-callout-danger')
      $("##{target_name}_seconds").parent().addClass('has-error')
      $("##{target_name}_hour").parent().addClass('has-error')
      $("##{target_name}_minutes").parent().addClass('has-error')
    if data['status'] == 'empty'
      $("##{target_name}_alert_box").hide()
  ).fail( (d, textStatus, error) ->
    # Nothing
  )
  false

@checkFullDate = (element) ->
  changes = {}

  target_name = element.data("target-name")
  changes["day"] = $("##{target_name}_day").val()
  changes["month"] = $("##{target_name}_month").val()
  changes["year"] = $("##{target_name}_year").val()

  url = root_url + 'check-date'

  $.getJSON(url, changes, (data) ->
    $("##{target_name}_month").parent().removeClass('has-warning')
    $("##{target_name}_day").parent().removeClass('has-warning')
    $("##{target_name}_year").parent().removeClass('has-warning')
    $("##{target_name}_month").parent().removeClass('has-error')
    $("##{target_name}_day").parent().removeClass('has-error')
    $("##{target_name}_year").parent().removeClass('has-error')
    $("##{target_name}_error").hide()
    $("##{target_name}_warning").hide()
    $("##{target_name}_success").hide()
    $("##{target_name}_alert_box").removeClass('bs-callout-success')
    $("##{target_name}_alert_box").removeClass('bs-callout-warning')
    $("##{target_name}_alert_box").removeClass('bs-callout-danger')
    if data
      $("##{target_name}_alert_box").show()
      $("##{target_name}_message").html(data['message'])
      $("##{target_name}_date_string").html(data['date_string'])
      $("##{target_name}_#{data['status']}").show()
      $("##{target_name}_alert_box").addClass('bs-callout-success')
    if data['status'] == 'warning'
      $("##{target_name}_year").parent().addClass('has-warning')
      $("##{target_name}_alert_box").addClass('bs-callout-warning')
    if data['status'] == 'error'
      $("##{target_name}_alert_box").addClass('bs-callout-danger')
      $("##{target_name}_year").parent().addClass('has-error')
      $("##{target_name}_month").parent().addClass('has-error')
      $("##{target_name}_day").parent().addClass('has-error')
    if data['status'] == 'empty'
      $("##{target_name}_alert_box").hide()
  ).fail( (d, textStatus, error) ->
    # Nothing
  )
  false

@clearDateFields = (element) ->
  target_name = element.data("target-name")
  $("##{target_name}_day").val("")
  $("##{target_name}_month").val("")
  $("##{target_name}_year").val("")
  $("##{target_name}_day").change()

@setCurrentDate = (element) ->
  target_name = element.data("target-name")
  date = new Date()
  $("##{target_name}_day").val(date.getDate())
  $("##{target_name}_month").val(date.getMonth()+1)
  $("##{target_name}_year").val(date.getFullYear())
  $("##{target_name}_day").change()

@clearTimeFields = (element) ->
  target_name = element.data("target-name")
  $("##{target_name}_hour").val("")
  $("##{target_name}_minutes").val("")
  $("##{target_name}_seconds").val("")
  $("##{target_name}_hour").change()

$(document)
  .on('click', '[data-object~="set-time-input-to-current-time"]', () ->
    setCurrentTime($(this))
    false
  )
  .on('change', ".time-input input", () ->
    checkFullTime($(this))
  )
  .on('blur', ".time-input input", () ->
    checkFullTime($(this))
  )
  .on("click", '[data-object~="clear-time-input"]', (event) ->
    clearTimeFields($(this))
    event.preventDefault()
  )
  .on("click", '[data-object~="clear-date-input"]', () ->
    clearDateFields($(this))
    false
  )
  .on('change', '[data-object~="date-field"]', () ->
    checkFullDate($(this))
  )
  .on('blur', '[data-object~="date-field"]', () ->
    checkFullDate($(this))
  )
  .on('click', '[data-object~="set-date-input-to-current-date"]', () ->
    setCurrentDate($(this))
    false
  )

