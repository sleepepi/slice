$(document)
  .on("click", "[data-object~=cube-details-clicker]", ->
    cube = new Cube(this)
    $("#cube-details-edit-box").removeClass("d-none")
    $("#cube-details-edit-box").data("cube", cube.id)
    $("#cube-details-id").html(cube.id)
    $("#cube_cube_type").val(cube.cubeType)
    console.log "cube.cubeType: " + cube.cubeType
    # console.log $("#cube-details-edit-box").data("cube")
    # $(cube.input).toggleClass("active")
    false
  )
  .on("change", "#cube_cube_type", ->
    $element = $("#cube-details-edit-box")
    return unless !!$element.data("cube")
    # console.log "cube_type change"
    params = {}
    params.cube = {}
    params.cube.cube_type = $(this).val()
    url = "#{$element.data("url")}/#{$element.data("cube")}"
    # console.log "$element.data(\"url\"): #{$element.data("url")}"
    # console.log "$element.data(\"cube\"): #{$element.data("cube")}"
    params._method = "patch"
    # console.log params
    $.post(
      url
      params
      null
      "json"
    ).done((data) ->
      if data?
        element = document.querySelector("[data-object~=\"cube-wrapper\"][data-cube=\"#{data.id}\"]")
        cube = new Cube(element)
        cube.cubeType = data.cube_type
        cube.redrawCubeType()
        if cube.hasFaces() && cube.faces.length == 0
          cube.appendNewFaceToCubeWrapper()
    ).fail((data) ->
      console.log "fail: #{data}"
    )
  )
  .on("click", "[data-object~=cube-details-clicker-close]", ->
    $("#cube-details-edit-box").addClass("d-none")
    $("#cube-details-edit-box").data("cube", null)
    $("#cube_cube_type").val("")
    false
  )
