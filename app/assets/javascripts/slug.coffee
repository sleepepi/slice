$(document)
  .on("keyup", "[data-object~=create-slug]", ->
    new_value = this.value.trim().replace(/[^a-zA-Z0-9]/g, "-").toLowerCase()
    new_value = new_value.replace(/-{2,}/g, "-").replace(/-$/, "")
    target = document.querySelector(this.getAttribute("data-target"))
    target.value = new_value if target
  )
