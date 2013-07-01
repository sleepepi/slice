pad = (str, max) ->
  if str.length < max then pad("0" + str, max) else str

reformatAndSwitchFocus = (target, int_val, next_input) ->
  target.val(pad(String(int_val), 2))
  next_input.focus().select() if next_input

manageTimeInput = (event, target, next_input, min_val, max_val) ->
  # Accounts for main keyboard key codes and num pad key codes
  if (event.keyCode >= 48 and event.keyCode <= 57) or ((event.keyCode-48) >= 48 and (event.keyCode-48) <= 57)
    val = target.val()
    int_val = parseInt(val)

    if val.length == 1 and int_val >= Math.floor(max_val / 10.0) and int_val <= 9
      reformatAndSwitchFocus(target, int_val, next_input)
    else if val.length == 2
      if int_val >= min_val and int_val <= max_val
        reformatAndSwitchFocus(target, int_val, next_input)
      else
        target.select()
  else
    target.select()


jQuery ->
  $(document).on("keyup", ".time-input .hour-box input", (event) ->
    manageTimeInput(event, $(this), $(".time-input .min-box input"), 0, 23)
  )
  $(document).on("keyup", ".time-input .min-box input", () ->
    manageTimeInput(event, $(this), $(".time-input .sec-box input"), 0, 59)
  )
  $(document).on("keyup", ".time-input .sec-box input", () ->
    manageTimeInput(event, $(this), null, 0, 59)
  )