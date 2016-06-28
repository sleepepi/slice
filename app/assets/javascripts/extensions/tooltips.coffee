@tooltipsReady = ->
  $('.tooltip').remove()
  return unless document.documentElement.ontouchstart == undefined
  $("[rel~=tooltip]").tooltip(trigger: 'hover')
