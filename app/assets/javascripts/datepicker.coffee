@resetDatePickers = () ->
  $('.datepicker-dropdown').remove() # Clean up DOM
  $(".datepicker").datepicker('remove')
  $(".datepicker").datepicker( autoclose: true )
  $(".datepicker").change( () ->
    try
      $(this).val($.datepicker.formatDate('mm/dd/yy', $.datepicker.parseDate('mm/dd/yy', $(this).val())))
    catch e
      # Nothing
  )
