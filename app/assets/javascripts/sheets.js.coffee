# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

@initializeSheet = (filter_element = '') ->
  $("#{filter_element} .chzn-select").chosen({ allow_single_deselect: true })
  $("#{filter_element} .timepicker").timepicker( showMeridian: false, showSeconds: true, defaultTime: false )
  $("#{filter_element} .datepicker").datepicker('remove')
  $("#{filter_element} .datepicker").datepicker( autoclose: true )

  $("#{filter_element} .datepicker").change( () ->
    try
      $(this).val($.datepicker.formatDate('mm/dd/yy', $.datepicker.parseDate('mm/dd/yy', $(this).val())))

    catch error
      # Nothing
  )


  $("#{filter_element} [data-object~='variable-typeahead']").each( () ->
    $this = $(this)
    $this.typeahead(
      remote: root_url + 'projects/' + $("#sheet_project_id").val() + '/variables/' + $this.data('variable-id') + '/typeahead' + '?query=%QUERY' + "&sheet_authentication_token=#{($('#sheet_authentication_token').val() || '')}"
    )
  )
  updateAllVariables()
  updateCalculatedVariables()
  checkAllRanges()
  $("span[rel~=tooltip], label[rel~=tooltip]").tooltip( trigger: 'hover' )
  $("span[rel~=popover], label[rel~=popover]").popover( trigger: 'hover' )
  loadAffix()
  $( ".grid_sortable" ).sortable({ axis: "y" })

@evaluateBranchingLogic = () ->
  $('[data-object~="evaluate-branching-logic"]').each( (index, element) ->
    if $(element).data('branching-logic') == ""
      branching_logic_result = true
    else
      try
        branching_logic_result = eval($(element).data('branching-logic'))
      catch error
        branching_logic_result = true

    if branching_logic_result
      # $(element).css('background', "#ccc")
    else
      $(element).hide()
      # $(element).css('background', "#0f0")
  )
  loadAffix()

@loadAffix = () ->
  $window = $(window)
  $body   = $(document.body)

  $body.scrollspy(
    target: '.bs-sidebar',
    offset: $('.navbar').outerHeight(true) + 10
  )

  $sideBar = $('.bs-sidebar')

  $sideBar.affix(
    offset:
      top: () ->
        offsetTop      = $('#main-bar').offset().top
        sideBarMargin  = parseInt($sideBar.children(0).css('margin-top'), 10)
        navOuterHeight = $('.navbar-fixed-top').height()

        return (this.top = offsetTop - navOuterHeight - sideBarMargin)
      bottom: () ->
        return (this.bottom = parseInt($(document.body).css('padding-bottom')))
  )


  # if $('.bs-sidebar').length > 0
  #   $('[data-spy~="affix"]').affix( offset: { top: $('.bs-sidebar').position().top - 40 } )

jQuery ->
  $("#sheet_design_id").on('change', () ->
    $.post(root_url + 'projects/' + $("#sheet_project_id").val() + '/designs/selection', $(this).serialize() + '&' + $("#sheet_subject_id").serialize(), null, "script")
    false
  )

  $("#sheet_subject_id").on('change', () ->
    $.post(root_url + 'projects/' + $("#sheet_project_id").val() + '/sheets/project_selection', $("sheet_design_id").serialize() + $("#hidden_sheet_id").serialize() + '&' + $("#sheet_subject_id").serialize() + '&' + $("#sheet_design_id").serialize(), null, "script")
    false
  )

  $(document)
    .on('click', '[data-object~="export"]', () ->
      url = $($(this).data('target')).attr('action') + '.' + $(this).data('format') + '?' + $($(this).data('target')).serialize()
      if $(this).data('page') == 'blank'
        window.open(url)
      else
        window.location = url
      false
    )
    .on('click', "[data-link]", (e) ->
      if nonStandardClick(e)
        window.open($(this).data("link"))
        return false
      else
        window.location = $(this).data("link")
    )
    .on('click', '[data-object~="export-data"]', () ->
      $('[data-dismiss~=alert]').click()
      form = $(this).data('target')
      $.get($(form).attr("action"), $(form).serialize() + '&export=1', null, "script")
      $(this).attr('disabled', 'disabled')
      false
    )

  initializeSheet()
