jQuery ->
  $(document)
    .on('click', '[data-object~="remove"]', () ->
      plural = if $(this).data('count') == 1 then '' else 's'
      if $(this).data('count') in [0, undefined] or ($(this).data('count') and confirm('Removing this option will PERMANENTLY ERASE DATA you have collected. Are you sure you want to RESET responses that used this option from ' + $(this).data('count') + ' sheet' + plural +  '?'))
        $('#' + $(this).data('target')).remove()
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
    .on('click', '[data-object~="submit"]', () ->
      $($(this).data('target')).submit()
      false
    )
    .on('click', '[data-object~="reset-filters"]', () ->
      $('[data-object~="filter"]').val('')
      $('[data-object~="filter-html"]').html('')
      $('#variable-type-all').button('toggle')
      $('[data-object~="set-statuses"]').removeClass('active')
      $('#statuses_pending, #statuses_test').val('')
      $('#statuses_valid').val('valid')
      $('[data-object~="set-statuses"][data-value="valid"]').addClass('active')
      $($(this).data('target')).submit()
      false
    )
    .on('click', '[data-object~="suppress-click"]', () ->
      false
    )
    .on('mouseenter', '[data-object~="hover-show"]', () ->
      $($(this).data('target')).show()
      false
    )
    .on('mouseleave', '[data-object~="hover-show"]', () ->
      $($(this).data('target')).hide()
      false
    )
    .on('click', '[data-object~="set-audit-row"]', () ->
      if $(this).hasClass("active")
        $('[data-audit-row~="'+$(this).data('value')+'"]').show()
      else
        $('[data-audit-row~="'+$(this).data('value')+'"]').hide()
      false
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
    )

  # $("[rel~=popover]").popover( offset: 10, trigger: 'focus' )
  $("span[rel~=tooltip]").tooltip( trigger: 'hover' )

  window.$isDirty = false
  msg = 'You haven\'t saved your changes.'

  $(document).on('change', ':input', () ->
    if $("#isdirty").val() == '1'
      window.$isDirty = true
  )

  $(document).ready( () ->
    window.onbeforeunload = (el) ->
      if window.$isDirty
        return msg
  )

  # $(".datepicker").datepicker( "option", "onClose", (dateText, inst) -> $(this).focus() )

  # alert $('[data-spy~="affix"]').parent().offset().top - 42

  $('[data-spy~="affix"]').affix( offset: { top: 223 } ) # 223

  $('[data-object~="typeaheadmap"]').each( () ->
    $this = $(this)
    $this.typeaheadmap( source: $this.data('source'), "key": "key", "value": "value" )
  )


