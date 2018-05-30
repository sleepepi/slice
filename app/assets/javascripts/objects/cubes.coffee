@cubesReady = ->
  $("#cubes").sortable(
    axis: "y"
    forcePlaceholderSize: true
    handle: ".cube-id"
    placeholder: "cube-wrapper-placeholder"
    stop: (event, ui) ->
      tray = new Tray
      tray.updateCubePositions()
      tray.saveCubePositions()
  )
