@facesEnableSortable = (element) ->
  container = if element then $(element).closest(".cube-faces") else $(".cube-faces")
  container.sortable(
    axis: "y"
    forcePlaceholderSize: true
    handle: ".face-id"
    placeholder: "face-wrapper-placeholder"
    stop: (event, ui) ->
      cube = new Cube(ui.item[0])
      cube.updateFacePositions()
      cube.saveFacePositions()
  )

$(document)
  .on("mouseenter", ".face-id:not(.cube-faces.ui-sortable .face-id)", ->
    # If the cube-faces is not yet sortable, make it sortable (just in time sortable).
    facesEnableSortable(this)
  )
