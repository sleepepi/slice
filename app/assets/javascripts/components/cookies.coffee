@createCookie = (name, value, days) ->
  expires = undefined
  if days
    date = new Date()
    date.setTime date.getTime() + (days * 24 * 60 * 60 * 1000)
    expires = "; expires=#{date.toGMTString()}"
  else
    expires = ''
  document.cookie = "#{encodeURIComponent(name)}=#{encodeURIComponent(value)}#{expires}; path=/"
  return

@readCookie = (name) ->
  nameEQ = "#{encodeURIComponent(name)}="
  ca = document.cookie.split(';')
  i = 0

  while i < ca.length
    c = ca[i]
    c = c.substring(1, c.length)  while c.charAt(0) is ' '
    return decodeURIComponent(c.substring(nameEQ.length, c.length)) if c.indexOf(nameEQ) is 0
    i++
  null

@eraseCookie = (name) ->
  createCookie name, "", -1
  return

$(document)
  .on("click", "[data-object~=set-cookie]", ->
    createCookie($(this).data("cookie-key"), $(this).data("cookie-value"))
  )
  .on("click", "[data-object~=service-announcement]", ->
    createCookie($(this).data("cookie"), "1", $(this).data("days"))
    $("#service-announcement").remove()
    false
  )
  .on("click", "[data-object~=service-announcement-link]", ->
    createCookie($(this).data("cookie"), "1", 180)
    $("#service-announcement").remove()
  )
