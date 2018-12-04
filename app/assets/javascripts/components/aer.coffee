@activateAerDesignDraggables = ->
  $("[data-object~=aer-designs-draggable]").draggable(
    connectToSortable: "[data-object~=aer-designs-sortable]"
    helper: "clone"
    tolerance: "pointer"
    cursor: "pointer"
    cursorAt: { left: 10 }
    # revert: "invalid"
    revert: (droppable) ->
      if droppable
        design_ids = droppable.sortable("toArray", attribute: "data-design-id")
        return design_ids.includes("#{$(this).data("design-id")}")
      else
        return true
    appendTo: "body"
  )

@activateAerDesignSortables = ->
  $.each($("[data-object~=aer-designs-sortable]"), ->
    $this = $(this)
    $this.sortable(
      cancel: ".aer-design-empty"
      placeholder: "aer-design-placeholder"
      forcePlaceholderSize: true
      tolerance: "pointer"
      cursor: "pointer"
      revert: "invalid"
      over: -> $(this).find(".aer-design-empty").hide()
      out: -> $this.find(".aer-design-empty").show()
      stop: (event, ui) ->
        $this.find(".aer-design-empty").remove()
        params = {}
        params.design_ids = $this.sortable("toArray", attribute: "data-design-id")
        $.post("#{$this.data("url")}", params, null, "script")
        if params.design_ids.length == 0
          $this.append("<div class=\"aer-design-empty\">No designs found.</div>")
      beforeStop: (event, ui) -> ui.item.removeAttr("style")
    )
  )


@aerReady = ->
  activateAerDesignDraggables()
  activateAerDesignSortables()
