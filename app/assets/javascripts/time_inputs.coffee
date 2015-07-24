@pad = (str, max) ->
  if !str then str = ""
  if str.length < max then pad("0" + str, max) else str

@setCurrentTime = (event) ->
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

@setFullTimeField = (target) ->
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

@reformatTimeInput = (target, int_val) ->
  name = target.data("target-input")
  if int_val then s = String(int_val) else s = ""
  target.val(pad(s, 2)) unless $("input:hidden[name='"+name+"']").val() == ''
  setFullTimeField(target)

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

@clearTimeFields = (name) ->
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
    checkFullDate($(this))
  )
  .on('blur', '[data-object~="date-field"]', () ->
    checkFullDate($(this))
  )
  .on('click', '[data-object~="set-date-input-to-current-date"]', () ->
    setCurrentDate($(this))
    false
  )

