$(document)
  .on("click", "[data-object~=role-level]", ->
    $("#invite_subgroup_type").val("")
    $("#invite_subgroup_id").val("")
    $("[data-roles]").hide()
    $("[data-roles~=#{$(this).find("input").val()}]").show()
    $("[name=\"invite[role]\"]").prop("checked", false)
  )
  .on("click", "[data-object~=role-selection]", ->
    $("#invite_subgroup_type").val($(this).data("subgroup-type"))
    $("#invite_subgroup_id").val($(this).find("input").val())
  )
