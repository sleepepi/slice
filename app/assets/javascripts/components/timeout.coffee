@pingServerForTimeout = (interval) ->
  $.get("#{root_url}timeout/check", "interval=#{interval}", null, "script")

@timeoutReady = ->
  if $("[data-object~=current-user]").length > 0
    interval = setInterval( ->
      pingServerForTimeout(interval)
    , 1000 * 60 * 1) # Once every minute ((1000 ms * 60) * 1)
    removeInterval = ->
      clearInterval(interval)
      $(document).off("turbolinks:load", removeInterval)
    $(document).on("turbolinks:load", removeInterval)

  Notification.requestPermission() if typeof Notification isnt "undefined" and Notification.permission isnt "granted"

@timeoutDesktopNotification = ->
  if typeof Notification isnt "undefined" and Notification.permission is "granted"
    notification = new Notification(
      "Slice",
      icon: $("[data-object~=notification-png]").data("url")
      body: "Your session is ending soon."
      tag: "timeout-notification"
    )
    notification.onclick = ->
      window.focus()
      this.close()
  false

@sessionTimedOut = ->
  location.reload true
