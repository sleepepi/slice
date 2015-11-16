$(document)
  .on('keyup', '[data-object~="create-slug"]', () ->
    new_value = $(this).val().trim().replace(/[^a-zA-Z0-9]/g, '-').toLowerCase()
    new_value = new_value.replace(/-{2,}/g, '-').replace(/-$/, '')
    $($(this).data('target')).val(new_value)
  )
