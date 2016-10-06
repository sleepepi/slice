@randomizationSchemesReady = ->
  $('#tasks[data-object~="sortable"]').sortable(handle: '.item-handle')

$(document)
  .on('change', '#randomization_scheme_algorithm', ->
    if $(this).val() == 'minimization'
      $("[data-object~='show-for-minimization']").show()
    else
      $("[data-object~='show-for-minimization']").hide()
  )
