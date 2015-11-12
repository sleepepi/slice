@color_group = (group_name) ->
  $("input[name='" + group_name + "']:not(:checked)").parent().removeClass('selected')
  $("input[name='" + group_name + "']:checked").parent().addClass('selected')

@initializeTypeahead = () ->
  $('[data-object~="typeahead"]').each( () ->
    $this = $(this)
    $this.typeahead(
      local: $this.data('local')
    )
  )

@setFocusToField = (element_id) ->
  val = $(element_id).val()
  $(element_id).focus().val('').val(val)

@initializeTooltip = () ->
  return unless document.documentElement.ontouchstart == undefined
  $("[rel~=tooltip]").tooltip(trigger: 'hover')

@globalReady = () ->
  initializeTypeahead()
  initializeTooltip()
  window.$isDirty = false
  $("#global-search").typeahead(
    remote: root_url + 'search?q=%QUERY'
  )
  # setFocusToField("#search")
  Turbolinks.enableProgressBar()
  # disableRequestCaching will be available with Turbolinks 3.0+
  Turbolinks.disableRequestCaching() if Turbolinks.disableRequestCaching?

# These functions get called on initial page visit and on turbolink page changes
@turbolinksReady = () ->
  contourReady()
  globalReady()
  designsReady()
  domainsReady()
  filtersReady()
  reportsReady()
  sheetsReady()
  variablesReady()
  signaturesReady()
  subjectsReady()
  projectsReady()
  eventsReady()
  randomizationsReady()
  usersReady()
  fileDragReady()

# These functions only get called on the initial page visit (no turbolinks)
@initialLoadReady = () ->
  turbolinksReady()
  timeoutReady()

$(window).onbeforeunload = () -> return "You haven't saved your changes." if window.$isDirty
$(document).ready(initialLoadReady)
$(document)
  .on('page:load', turbolinksReady)
  .on('page:before-change', -> confirm("You haven't saved your changes.") if window.$isDirty)
  .on('click', '[data-object~="remove"]', () ->
    plural = if $(this).data('count') == 1 then '' else 's'
    if $(this).data('count') in [0, undefined] or ($(this).data('count') and confirm('Removing this option will PERMANENTLY ERASE DATA you have collected. Are you sure you want to RESET responses that used this option from ' + $(this).data('count') + ' sheet' + plural +  '?'))
      $($(this).data('target')).remove()
      false
    else
      false
  )
  .on('click', '[data-object~="modal-show"]', () ->
    $($(this).data('target')).modal({ dynamic: true })
    false
  )
  .on('click', '[data-object~="modal-hide"]', () ->
    $($(this).data('target')).modal('hide')
    false
  )
  .on('click', '[data-object~="submit"]', () ->
    $($(this).data('target')).submit()
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
    if $("#interactive_design_modal").is(':visible')
      hideInteractiveDesignModal()     if e.which == 27
    if e.which == 77 and not $("input, textarea, select, a").is(":focus")
      if $('#preview-mode').length == 1 and $('#edit-mode').length == 1 and $('#edit-mode').parent().hasClass('active')
        $('#preview-mode').click()
      else
        $('#edit-mode').click()
      e.preventDefault()
      return
    # Key is 'w'
    if e.which == 87 and not $("input, textarea, select, a").is(":focus")
      $('.container').toggleClass('wide-container')
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
  .on('click', '[data-object~="toggle-visibility"]', () ->
    $($(this).data('target')).toggle()
    false
  )
  .on('typeahead:selected', "#global-search", (event, datum) ->
    $(this).val(datum['value'])
    $("#global-search-form").submit()
  )
  .on('keydown', "#global-search", (e) ->
    $("#global-search-form").submit() if e.which == 13
  )
  .on('typeahead:selected', "#subject-search", (event, datum) ->
    $(this).val(datum['value'])
    $("#subject-search-form").submit()
  )
  .on('keydown', "#subject-search", (e) ->
    $("#subject-search-form").submit() if e.which == 13
  )
  .on('change', ':input', () ->
    if $("#isdirty").val() == '1'
      window.$isDirty = true
  )
  .on('click', '[data-object~="toggle-delete-buttons"]', () ->
    $($(this).data('target-show')).show()
    $($(this).data('target-hide')).hide()
    false
  )
