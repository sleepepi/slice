$(document)
  .on("dragenter", "[data-object~=generic-dropfile]", (e) ->
    $(this).addClass("upload-hover")
    e.stopPropagation()
    e.preventDefault()
  )
  .on("dragleave", "[data-object~=generic-dropfile]", (e) ->
    relatedTarget = e.relatedTarget || e.toElement
    if $(relatedTarget).closest("[data-object~=generic-dropfile]").length == 0
      $(this).removeClass("upload-hover")
    e.stopPropagation()
    e.preventDefault()
  )
  .on("dragover", "[data-object~=generic-dropfile]", (e) ->
    e.stopPropagation()
    e.preventDefault()
  )
  .on("drop", "[data-object~=generic-dropfile]", (e) ->
    $(this).removeClass("upload-hover")
    e.stopPropagation()
    e.preventDefault()

    event = e.originalEvent || e
    data = new FormData()
    $.each(event.dataTransfer.files, (index, file) ->
      data.append "files[]", file
    )

    $this = $(this)
    $uploadContainer = $("[data-object~=generic-dropfile]")
    $percentbar = $("[data-object~=generic-upload-bar]")
    $uploadError = $("[data-object~=generic-upload-error]")

    $uploadContainer.addClass("upload-started")
    $percentbar.css("width", "0%")
    $percentbar.removeClass("upload-success upload-failure")
    $uploadError.html("")

    $.ajax(
      url: $this.data("upload-url")
      type: "POST"
      data: data         # The form with the file inputs.
      processData: false # Using FormData, no need to process data.
      contentType: false
      xhr: ->
        myXhr = $.ajaxSettings.xhr()
        if myXhr.upload
          myXhr.upload.addEventListener("progress", (e) ->
            if e.lengthComputable
              done = e.loaded
              total = e.total
              calculated_percent = Math.round(done / total * 100)
              if done == total
                $percentbar.css("width", "100%")
              else
                $percentbar.css("width", "#{calculated_percent}%")
          )
        myXhr
    ).done(->
      $percentbar.addClass("upload-success")
      $uploadContainer.removeClass("upload-started")
    ).fail( (jqXHR, textStatus, errorThrown) ->
      $percentbar.addClass("upload-failure")
      if jqXHR.status == 413
        $uploadError.html("Upload exceeds maximum file size limit.")
      else
        $uploadError.html("#{errorThrown}")
      $uploadContainer.removeClass("upload-started")
      false
    )
  )
