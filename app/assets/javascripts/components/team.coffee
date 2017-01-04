@hideInvite = ->
  $('#invite-success').hide()
  $('#invite-container').show()

@inviteSuccess = ->
  $('#invite-container').hide()
  $('#invite-success').show()

$(document)
  .on('click', '[data-object~="invite-toggle"]', ->
    hideInvite()
    false
  )
