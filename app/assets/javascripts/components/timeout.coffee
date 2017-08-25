@timeoutReady = ->
  if $('[data-object~="current-user"]').length > 0
    interval = setInterval( ->
      $.get("#{root_url}timeout/check", "interval=#{interval}", null, "script")
    , 1000 * 60 * 3) # Once every 3 minutes ((1000 ms * 60) * 3)
  Notification.requestPermission() if typeof Notification isnt 'undefined' and Notification.permission isnt "granted"

@timeoutDesktopNotification = ->
  if typeof Notification isnt 'undefined' and Notification.permission is "granted"
    notification = new Notification(
      'Slice',
      icon: $("[data-object~='notification-png']").data('url')
      body: "Your session is ending soon."
      tag: 'timeout-notification'
    )
    notification.onclick = ->
      window.focus()
      this.close()
  false

@sessionTimedOut = ->
  location.reload true
