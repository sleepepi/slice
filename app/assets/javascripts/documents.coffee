# This function removes the display of an existing file on documents/form when
# specifying a new file to attach.
$(document)
  .on('change', '#document_file', () ->
    $("#existing-file").remove()
  )
