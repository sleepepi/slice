@updateSelectedClass = (group_name) ->
  $("input[name='#{group_name}']:not(:checked)")
    .closest('.checkbox-radio-outline').removeClass('selected')
  $("input[name='#{group_name}']:checked")
    .closest('.checkbox-radio-outline').addClass('selected')

$(document)
  .on('change', '.checkbox-radio-outline input', ->
    updateSelectedClass($(this).attr('name'))
  )
