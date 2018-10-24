@datepickerReady = ->
  $(".datepicker-dropdown").remove() # Clean up DOM
  $(".datepicker").datepicker("remove")
  $(".datepicker").datepicker(autoclose: true)
