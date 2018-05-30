# Handles setting up XMLHttpRequests.

@csrfToken = ->
  document.querySelector("meta[name=csrf-token]").content

@serializeForXMLHttpRequest = (obj, prefix) ->
  str = []
  p = undefined
  for p of obj
    `p = p`
    if obj.hasOwnProperty(p)
      k = if prefix then prefix + '[' + p + ']' else p
      v = obj[p]
      str.push if v != null and typeof v == 'object' then serializeForXMLHttpRequest(v, k) else encodeURIComponent(k) + '=' + encodeURIComponent(v)
  str.join '&'
