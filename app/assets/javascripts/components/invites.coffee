$(document)
  .on("click", "[data-object~=role-level]", ->
    role_level = $(this).find("input").val()
    $("[data-roles]").hide()
    $("[data-roles~=#{role_level}]").show()
    $("[name=\"invite[role]\"]").prop("checked", false)

    $("#invite_subgroup_type").val("")
    $("#invite_subgroup_id").val("")
    $("[name=\"invite[team_id]\"]").prop("checked", false)
    $("[name=\"invite[site_id]\"]").prop("checked", false)

    if role_level == "site" and $("[name=\"invite[site_id]\"]").length == 1
      $("[name=\"invite[site_id]\"]").click()
    else if role_level == "ae_team" and $("[name=\"invite[team_id]\"]").length == 1
      $("[name=\"invite[team_id]\"]").click()

  )
  .on("click", "[data-object~=role-selection]", ->
    if $(this).find("input").prop("checked") == true
      $("#invite_subgroup_type").val($(this).data("subgroup-type"))
      $("#invite_subgroup_id").val($(this).find("input").val())
    else
      $("#invite_subgroup_type").val("")
      $("#invite_subgroup_id").val("")
  )
