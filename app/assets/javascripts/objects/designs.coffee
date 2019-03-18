@retrieveVariable = (position) ->
  variable_id = $("#design_option_tokens_#{position}_variable_id").val()
  if variable_id
    $("#variable_#{position}_edit_link").html("Edit")
    $.get("#{root_url}projects/#{$("#design_project_id").val()}/variables/#{variable_id}", "position=#{position}", null, "script")
  else
    $("#variable_#{position}_edit_link").html("Create")
  false

@intersection = (a, b) ->
  [a, b] = [b, a] if a.length > b.length
  value for value in a when value in b

@overlap = (a, b, c = 1) ->
  a = (a || []).map(String)
  b = (b || []).map(String)
  intersection(a, b).length >= c

@designsReady = ->
  $("#form_grid_variables[data-object~=sortable]").sortable( placeholder: "well alert alert-block" )
  initializeDesignReordering()
  $("#form_grid_variables div").last().click()
  if $("[data-object~=ajax-timer]").length > 0
    interval = setInterval( ->
      $("[data-object~=ajax-timer]").each( ->
        $.post($(this).data("path"), "interval=#{interval}", null, "script")
      )
    , 5000)

$(document)
  .on("change", "[data-object~=condition]", ->
    updateAllDesignOptionsVisibility()
    updateCalculatedVariables()
  )
