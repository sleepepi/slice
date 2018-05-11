@elementVisible = (element) ->
  visible = true

  try
    branching_logic = eval($(element).data('branching-logic'))
  catch
    branching_logic = ''

  if branching_logic
    try
      visible = eval(branching_logic)
    catch error
      console.error "Error in branching logic syntax. #{error} #{$(element).data('branching-logic')}"

  return visible
