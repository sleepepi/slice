@showContourModal = () ->
  $("#contour-backdrop, .contour-modal-wrapper").show()
  # $('html, body').animate({ scrollTop: $(".contour-modal-wrapper").offset().top - 80 }, 'fast');

@hideContourModal = () ->
  $("#contour-backdrop, .contour-modal-wrapper").hide()

@color_group = (group_name) ->
  $("input[name='" + group_name + "']:checked").parent().addClass("selected")
  $("input[name='" + group_name + "']:not(:checked)").parent().removeClass("selected")

@browserSupportsPushState =
  window.history and window.history.pushState and window.history.replaceState and window.history.state != undefined

@initializeTypeahead = () ->
  $('[data-object~="typeahead"]').each( () ->
    $this = $(this)
    $this.typeahead(
      local: $this.data('local')
    )
  )

@setAllAuditActionsVisibility = () ->
  $('[data-object~="audit-row"]').each( (index, element) ->
    display = false

    $.each($(element).data('all-audit-actions'), (aindex, action) ->
      display = true if $("#audit-row_#{action}").is(':checked')
    )
    if display
      $(element).show()
    else
      $(element).hide()
  )

@ready = () ->
  contourReady()
  initializeTypeahead()
  $("span[rel~=tooltip], button[rel~=tooltip]").tooltip( trigger: 'hover' )
  window.$isDirty = false
  msg = "You haven't saved your changes."
  window.onbeforeunload = (el) -> return msg if window.$isDirty

jQuery ->
  $(document)
    .on('click', '[data-object~="remove"]', () ->
      plural = if $(this).data('count') == 1 then '' else 's'
      if $(this).data('count') in [0, undefined] or ($(this).data('count') and confirm('Removing this option will PERMANENTLY ERASE DATA you have collected. Are you sure you want to RESET responses that used this option from ' + $(this).data('count') + ' sheet' + plural +  '?'))
        $($(this).data('target')).remove()
        false
      else
        false
    )
    .on('click', '[data-object~="modal-show"]', () ->
      $($(this).data('target')).modal({ dynamic: true });
      false
    )
    .on('click', '[data-object~="modal-hide"]', () ->
      $($(this).data('target')).modal('hide');
      false
    )
    .on('click', "#contour-backdrop", (e) ->
      hideContourModal() if e.target.id = "contour-backdrop"
    )
    .on('click', '[data-object~="show-contour-modal"]', () ->
      showContourModal()
      false
    )
    .on('click', '[data-object~="hide-contour-modal"]', () ->
      hideContourModal()
      false
    )
    .on('click', '[data-object~="submit"]', () ->
      $($(this).data('target')).submit()
      false
    )
    .on('click', '[data-object~="reset-filters"]', () ->
      $('[data-object~="filter"]').val('')
      $('[data-object~="filter-html"]').html('')
      $('#variable-type-all').button('toggle')
      $('#statuses_valid').parent().addClass('active')
      $('#statuses_test').parent().removeClass('active')
      $('#statuses_test').prop('checked', false)
      $('#statuses_valid').prop('checked', true)
      $($(this).data('target')).submit()
      false
    )
    .on('click', '[data-object~="suppress-click"]', () ->
      false
    )
    .on('mouseenter', '[data-object~="hover-show"]', () ->
      return false unless document.documentElement.ontouchstart == undefined
      $('[data-object~="hover-show"]').each( (index, element) ->
        $($(element).data('target')).hide()
      )
      $($(this).data('target')).show()
    )
    .on('mouseleave', '[data-object~="hover-show"]', () ->
      $($(this).data('target')).hide()
    )
    .on('click', '[data-object~="set-audit-row"]', () ->
      if $(this).find('input').is(':checked')
        $(this).find('input').prop('checked', false)
      else
        $(this).find('input').prop('checked', true)

      value = $(this).find('input').attr('value')
      if $(this).hasClass("active")
        $("[data-audit-row~='#{value}']").hide()
      else
        $("[data-audit-row~='#{value}']").show()
      setAllAuditActionsVisibility()
    )
    .on('focus', "select[rel~=tooltip], input[rel~=tooltip], textarea[rel~=tooltip]", () ->
      $(this).tooltip( trigger: 'focus' )
    )
    .on('focus', "[rel~=tooltip]", () ->
      $(this).tooltip( trigger: 'hover' )
    )
    .on('focus', "[rel~=popover]", () ->
      $(this).popover( offset: 10, trigger: 'focus' )
    )
    .ready( () ->
      if $("#sheet_design_id").val() == ''
        $("#sheet_design_id").focus()
      else
        $("#sheet_subject_id").focus()
      if $("#global-search").val() != ''
        $("#global-search").focus()
    )
    .on('click', '#global-search', (e) ->
      e.stopPropagation()
      false
    )
    .on('change', '.checkbox input:checkbox', () ->
      color_group($(this).attr('name'))
    )

    .keydown( (e) ->
      # p will enter the search box, Esc will exit
      if e.which == 80 and not $("input, textarea, select, a").is(":focus")
        $("#global-search").focus()
        e.preventDefault()
        return
      $("#global-search").blur() if $("#global-search").is(':focus') and e.which == 27
      if $("#contour-backdrop").is(':visible')
        hideContourModal()               if e.which == 27
      if $("#interactive_design_modal").is(':visible')
        hideInteractiveDesignModal()     if e.which == 27
      if e.which == 77 and not $("input, textarea, select, a").is(":focus")
        if $('#preview-mode').length == 1 and $('#edit-mode').length == 1 and $('#edit-mode').parent().hasClass('active')
          $('#preview-mode').click()
        else
          $('#edit-mode').click()
        e.preventDefault()
        return
    )
    .on('click', '[data-object~="settings-save"]', () ->
      window.$isDirty = false
      $($(this).data('target')).submit()
      false
    )
    .on('click', '[data-object~="kill-event"]', (e) ->
      e.stopPropagation()
      false
    )

  $("#global-search").typeahead(
    remote: root_url + 'search?q=%QUERY'
  )

  $(document).on('typeahead:selected', "#global-search", (event, datum) ->
    $(this).val(datum['value'])
    $("#global-search-form").submit()
  )
  .on('keydown', "#global-search", (e) ->
    $("#global-search-form").submit() if e.which == 13
  )

  $(document).on('change', ':input', () ->
    if $("#isdirty").val() == '1'
      window.$isDirty = true
  )

$(document).ready(ready)
$(document).on('page:load', ready)
