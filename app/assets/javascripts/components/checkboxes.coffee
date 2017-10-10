@toggleMutuallyExclusive = (element) ->
  group_name = $(element).attr('name')
  if $("input[name='#{group_name}'][data-mutually-exclusive=true]").length > 0
    if $(element).data("mutually-exclusive") && $(element).prop('checked') == true
      $("input[name='#{group_name}']").prop('checked', false)
      $(element).prop('checked', true)
    else
      $("input[name='#{group_name}'][data-mutually-exclusive=true]").prop('checked', false)

@updateSelectedClass = (element) ->
  toggleMutuallyExclusive(element)
  $("input[name='#{$(element).attr('name')}']:not(:checked)")
    .closest('.checkbox-radio-outline').removeClass('selected')
  $("input[name='#{$(element).attr('name')}']:checked")
    .closest('.checkbox-radio-outline').addClass('selected')

@clearSelections = (element) ->
  group_name = $(element).attr('name')
  $("input[name='#{group_name}']").prop('checked', false)
  $(element).change()
  updateSelectedClass(element)
  updateAllDesignOptionsVisibility()
  updateCalculatedVariables()

@toggleGroupInput = (input, group_name, event) ->
  if input.parent('label').hasClass('selected') and (input.attr('type') == 'checkbox' or event.type == 'click')
    input.prop('checked', false)
  else
    input.prop('checked', true)
  updateSelectedClass(input)
  input.focus()
  input.change()

# input field has to be radio button or checkbox
#  96 = backtick (`)
# 126 = tilda    (~)
@selectWithKeystroke = (event) ->
  if event.which == 96 or event.which == 126
    clearSelections(event.target)
  else
    selected_value = String.fromCharCode(event.which)
    group_name = $(event.target).attr('name')
    input = $("*[name='#{group_name}'][value='#{selected_value}']")
    toggleGroupInput(input, group_name, event) if input.length > 0

$(document)
  .on('keypress', '.checkbox-radio-outline input', selectWithKeystroke)
  .on('click', '.checkbox-radio-outline input:radio', (event) ->
    toggleGroupInput($(this), $(this).attr('name'), event)
  )
  .on('click', '.checkbox-radio-outline input:checkbox', ->
    $(this).focus()
  )
  .on('focus', '.checkbox-radio-outline input', ->
    $(this).closest('.checkbox-radio-outline').addClass('focus')
  )
  .on('focusout', '.checkbox-radio-outline input', ->
    $(this).closest('.checkbox-radio-outline').removeClass('focus')
  )
  .on('change', '.checkbox-radio-outline input:checkbox', ->
    updateSelectedClass($(this))
  )
