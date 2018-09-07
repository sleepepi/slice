@tooltipsReady = ->
  $(".tooltip").remove()
  return unless document.documentElement.ontouchstart == undefined
  $("[rel~=tooltip]").tooltip(trigger: "hover") # TODO: Remove this in favor of [data-toggle=tooltip]
  $("[data-toggle=tooltip]").tooltip()
