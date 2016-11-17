@updateSelectedClass = (group_name) ->
  $("input[name='#{group_name}']:not(:checked)")
    .closest('.checkbox-radio-outline').removeClass('selected')
  $("input[name='#{group_name}']:checked")
    .closest('.checkbox-radio-outline').addClass('selected')

$(document)
  .on('change', '.checkbox-radio-outline input:checkbox, .checkbox-radio-outline input:radio', ->
    console.log 'checkbox-radio-outline'
    updateSelectedClass($(this).attr('name'))
  )
