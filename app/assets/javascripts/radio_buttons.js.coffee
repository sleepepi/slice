@toggleRadioButton = (rb) ->
  # Need this function since there's no way of preventing default radio button click behavior
  console.log rb
  if rb.data("previous") == "checked"
    rb.prop("checked", false)
    rb.data("previous", "unchecked")
  else
    rb.data("previous", "checked")
  rb.change()

jQuery ->
  $(document).on("keydown", ".radio input:radio", (e) ->
    selected_value = String.fromCharCode(e.which)
    selected_radio = $(this).closest(".control-group").find(":radio[value='" + selected_value + "']").first()

    if e.which == 192
      $(this).closest(".control-group").find("*[data-object='clear-radio']").click()
    else if selected_radio
      selected_radio.prop("checked", true)
      toggleRadioButton(selected_radio)
    false
  )

  $(document).on("click", ".radio input:radio", () ->
    $(this).focus()
    toggleRadioButton($(this))
  )


