@traysReady = ->
  Tray.attachEventHandlers()

$(document)
  .on("keyup", "#tray_name", ->
    new_value = this.value.trim().replace(/[^a-zA-Z0-9]/g, "-").toLowerCase()
    new_value = new_value.replace(/-{2,}/g, "-").replace(/-$/, "")
    target = document.querySelector("#tray-slug-preview")
    if !!new_value
      target.innerHTML = new_value if target
    else
      target.innerHTML = "untitled" if target
  )
