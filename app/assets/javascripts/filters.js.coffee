
@activateFilterSortable = () ->
  $('.filter-sort-container').sortable(
    placeholder: 'filter-bubble-faded'
    connectWith: '.filter-sort-container, #trash'
    activeClass: 'droppable-hover'
    # start: $('[rel~=tooltip]').tooltip('hide')
    # update: ( event, ui ) -> # Should be this one
    stop: ( event, ui ) ->
      axis = $(ui.item).parent('.filter-sort-container').data('axis')
      $(ui.item).children('input[data-name~="axis"]').val(axis)
      submitReportWithFilters()
    # stop: function() { columns = $('#sortable1').sortable('toArray').toString();
    #   rows = $('#sortable2').sortable('toArray').toString();
    #   $.post($('#reorder_report_form').attr('action'), '&columns='+columns+'&rows='+rows, null, 'script');
    #   showWaiting('#report_table', ' Loading Report', true);
    # }
  ).disableSelection()

  $('.filter-sort-container').droppable( activeClass: 'droppable-hover', tolerance: 'pointer' )


jQuery ->
  $(document)
    .on('click', '[data-object~="open-new-filter-modal"]', () ->
      $.post($("#new_filter_form").attr('action'), $("#filters_form").serialize(), null, 'script')
      false
    )
    .on('change', '[data-object~="variable-selection"]', () ->
      $($(this).data('target')).submit()
    )
    .on('click', '[data-object~="add-filter"]', () ->
      variable_id = $("#variable_id").val()
      if $("#missing").is(":checked")
        missing = '1'
      else
        missing = '0'
      if $("[name='by']:checked").val()?
        by_var = $("[name='by']:checked").val()
      else
        by_var = ''
      $.post($('#filters_form').attr('action'), $('#filters_form').serialize()+"&f[][id]="+variable_id+"&f[][missing]=" + missing + "&f[][by]=" + by_var, null, 'script')
      hideContourModal()
      false
    )
    .on('click', '[data-object~="edit-filter"]', () ->
      variable_id = $(this).data('variable-id')
      project_id = $(this).data('project-id')
      missing = $('#variable_'+variable_id).children('input[data-name~="missing"]').val()
      axis = $('#variable_'+variable_id).children('input[data-name~="axis"]').val()
      by_var = $('#variable_'+variable_id).children('input[data-name~="by"]').val()
      $.post(root_url + "projects/" + project_id + "/edit_filter?variable_id=" + variable_id + "&missing=" + missing + "&axis=" + axis + "&by=" + by_var, null, 'script')
      false
    )
    .on('click', '[data-object~="update-filter"]', () ->
      variable_id = $(this).data('variable-id')
      if $("#missing").is(":checked")
        missing = '1'
      else
        missing = '0'
      $("#variable_"+variable_id).children('input[data-name~="missing"]').val(missing)
      $("#variable_"+variable_id).children('input[data-name~="by"]').val($("[name='by']:checked").val())
      $.post($('#filters_form').attr('action'), $('#filters_form').serialize(), null, 'script')
      hideContourModal()
      false
    )
    .on('click', '[data-object~="remove-filter"]', () ->
      $($(this).data('target')).remove()
      submitReportWithFilters()
      hideContourModal()
      false
    )
    .on('click', '[data-object~="filters-link"]', () ->
      project_id = $(this).data('project-id')
      design_id = $(this).data('design-id')
      window.location = root_url + "projects/#{project_id}/designs/#{design_id}/blank?" + $('#filters_form').serialize()
      false
    )

  activateFilterSortable()
