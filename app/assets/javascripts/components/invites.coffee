$(document)
  .on("click", "[data-object~=role-level]", ->
    role_level = $(this).find("input").val()
    $("[data-roles]").hide()
    $("[data-roles~=#{role_level}]").show()
    $("[name=\"invite[role]\"]").prop("checked", false)

    $("#invite_subgroup_type").val("")
    $("#invite_subgroup_id").val("")
    $("[data-object~=role-selection-dropdown]").val("")
    $("[name=\"invite[team_id]\"]").prop("checked", false)
    $("[name=\"invite[site_id]\"]").prop("checked", false)

    if role_level == "site" and $("[name=\"invite[site_id]\"]").length == 1
      input = $("[name=\"invite[site_id]\"]")
      parent = $(input).closest("[data-object~=role-selection]")
      $(input).prop("checked", true)
      $("#invite_subgroup_type").val($(parent).data("subgroup-type"))
      $("#invite_subgroup_id").val($(parent).find("input").val())
    else if role_level == "ae_team" and $("[name=\"invite[team_id]\"]").length == 1
      input = $("[name=\"invite[team_id]\"]")
      parent = $(input).closest("[data-object~=role-selection]")
      $(input).prop("checked", true)
      $("#invite_subgroup_type").val($(parent).data("subgroup-type"))
      $("#invite_subgroup_id").val($(parent).find("input").val())
  )
  .on("click", "[data-object~=role-selection]", ->
    if $(this).find("input").prop("checked") == true
      $("#invite_subgroup_type").val($(this).data("subgroup-type"))
      $("#invite_subgroup_id").val($(this).find("input").val())
    else
      $("#invite_subgroup_type").val("")
      $("#invite_subgroup_id").val("")
  )
  .on("change", "[data-object~=role-selection-dropdown]", ->
    if !!$(this).val()
      $("#invite_subgroup_type").val($(this).data("subgroup-type"))
      $("#invite_subgroup_id").val($(this).val())
    else
      $("#invite_subgroup_type").val("")
      $("#invite_subgroup_id").val("")
  )
