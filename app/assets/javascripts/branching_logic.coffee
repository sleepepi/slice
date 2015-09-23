@elementVisible = (element) ->
  visible = true

  try
    branching_logic = eval($(element).data('branching-logic'))
  catch
    branching_logic = ''

  if branching_logic != '' and branching_logic != undefined
    try
      visible = eval(branching_logic)
    catch error
      console.log "Error in branching logic syntax. #{error}"

  return visible
