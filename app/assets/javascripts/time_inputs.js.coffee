# Crude fix for nearly-simultaneous keyboard presses causing unwanted focus changes

@last_focus_change = Date.now()

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
  $("input:hidden[name='"+name+"']").val(time["hour"]+":"+time["min"]+":"+time["sec"])

  false

reformatTimeInput = (target, int_val) ->
  if int_val then s = String(int_val) else s = ""
  target.val(pad(s, 2))
  setFullTimeField(target)

focusOnNext = (target) ->
  current_time = Date.now()
  if (current_time - last_focus_change) > 150
    @last_focus_change = current_time
    if target.closest(".time-box").nextAll(".time-box").length > 0
      next_input = target.closest(".time-box").nextAll(".time-box").first().find("input").first()
    else if target.closest(".control-group").next(".control-group").length > 0
      next_input = target.closest(".control-group").next(".control-group").find("input:visible").first()

    if next_input
      next_input.select()
    else
      target.closest("form").find("input:submit").first().focus()

manageTimeInput = (event, target, min_val, max_val) ->
  val = target.val()
  if (event.keyCode >= 48 and event.keyCode <= 57) or ((event.keyCode-48) >= 48 and (event.keyCode-48) <= 57)
    int_val = parseInt(val)

    if val.length == 1 and int_val >= Math.ceil(max_val / 10.0) and int_val <= 9
      #focusOnNext(target, next_input)
      focusOnNext(target)
    else if val.length == 2
      if int_val >= min_val and int_val <= max_val
        #focusOnNext(target, next_input)
        focusOnNext(target)
      else
        target.select()
  else
    target.select()

clearTimeFields = (name) ->
  $("input:hidden[name='"+name+"']").val("")
  $("input:text[name='hour_"+name+"']").val("")
  $("input:text[name='min_"+name+"']").val("")
  $("input:text[name='sec_"+name+"']").val("")


jQuery ->
  $(document)
    .on("keypress", ".time-input", (event) ->
      if event.which == 96
        clearTimeFields($(this).find("input:hidden").attr("name"))
        event.preventDefault()
    )
    .on("keyup", ".time-input .hour-box input", (event) ->
      manageTimeInput(event, $(this), 0, 23)
    )
    .on("keyup", ".time-input .min-box input", (event) ->
      manageTimeInput(event, $(this), 0, 59)
    )
    .on("keyup", ".time-input .sec-box input", (event) ->
      manageTimeInput(event, $(this), 0, 59)
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
