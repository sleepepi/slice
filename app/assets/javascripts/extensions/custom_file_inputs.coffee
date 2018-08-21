# Overwrites text with filename for BS4 custom-file fields in
# app/views/forms/[horizontal|vertical]/_file_field.html.haml
# when files are selected.
$(document)
  .on("change", ".custom-file-input", ->
    fileNameStart = $(this).val().lastIndexOf("\\")
    fileName = $(this).val().substr(fileNameStart + 1);
    text = if fileName then fileName else "Choose file"
    $(this).closest(".custom-file").find(".custom-file-label").text(text)
  )
