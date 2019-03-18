# Methods to allow variables and sections to be reordered on a design.

@initializeDesignReordering = ->
  $("[data-object~=reorder-list]").sortable(
    placeholder: "li-section li-placeholder"
    handle: ".option-handle"
  )

$(document)
  .on("click", "[data-object~=reorder]", ->
    $("[data-object~=reorder]").removeClass("btn-dark").addClass("btn-light")
    $(@).toggleClass("btn-dark btn-light")
    reorder = $(@).data("reorder")
    $("[data-object~=reorder-save]").data("reorder", reorder)
    $("[data-object~=reorder-container]").hide()
    $("[data-object~=reorder-container][data-reorder=#{reorder}]").show()
    false
  )
  .on("click", "[data-object~=reorder-save]", ->
    if $(this).attr("disabled") != "disabled"
      disableWithSpinner(this, "Saving...")
      reorder = $(@).data("reorder")
      rows = $("[data-object~=reorder-list][data-reorder=#{reorder}]").sortable("toArray", attribute: "data-position").toString()
      $reorder_form = $("[data-object~=reorder-form][data-reorder=#{reorder}]")
      $.post($reorder_form.attr("action"), "&rows=#{rows}", null, "script")
    false
  )
