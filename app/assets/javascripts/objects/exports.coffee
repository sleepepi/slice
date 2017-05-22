$(document)
  .on('change', '[data-object~="export-filters"]', ->
    return if $(this).val() == ""
    $this = $(this)
    values = $("#export_filters").val().split(" ")
    filter_type_found = false
    values_new = $.map(values, (value) ->
      tokens = value.split(":")
      if tokens[0] == $this.data('filter-type')
        filter_type_found = true
        objects = tokens[1].split(",")
        objects.push("#{$this.val()}")
        tokens[1] = $.unique(objects).sort().join(",")
      tokens.join(":")
    )
    values_new.push("#{$(this).data('filter-type')}:#{$(this).val()}") unless filter_type_found
    $(this).val("").trigger("chosen:updated")
    $("#export_filters").val(values_new.join(" "))
  )
  .on('change', '[data-object~="export-filters-subjects"]', ->
    return if $(this).val() == ""
    $this = $(this)
    values = $("#export_filters").val().split(" ")
    filter_type_found = false
    values_new = $.map(values, (value) ->
      if value == $this.val()
        filter_type_found = true
      value
    )
    values_new.push("#{$(this).val()}") unless filter_type_found
    $(this).val("").trigger("chosen:updated")
    $("#export_filters").val(values_new.join(" "))
  )
