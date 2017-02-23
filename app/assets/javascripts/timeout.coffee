@timeoutReady = ->
  if $('[data-object~="current-user"]').length > 0
    interval = setInterval( ->
      $.get("#{root_url}timeout/check", "interval=#{interval}", null, "script")
    , 1000 * 60 * 3) # Once every 3 minutes ((1000 ms * 60) * 3)

@sessionTimedOut = ->
  location.reload true
