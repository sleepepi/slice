@hideInvite = ->
  $('#invite-success').hide()
  $('#invite-container').show()

@inviteSuccess = ->
  $('#invite-container').hide()
  $('#invite-success').show()
  $('#invite_email').val('')

$(document)
  .on('click', '[data-object~="invite-toggle"]', ->
    hideInvite()
    false
  )
