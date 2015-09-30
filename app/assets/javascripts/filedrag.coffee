@isNotInternetExplorer = () ->
  ua = window.navigator.userAgent
  msie = ua.indexOf("MSIE ")
  # If Internet Explorer, return version number
  if (msie > 0 || !!navigator.userAgent.match(/Trident.*rv\:11\./))
    # parseInt(ua.substring(msie + 5, ua.indexOf(".", msie)))
    return false
  else # If another browser
    return true

@fileDragReady = () ->
  if window.FormData != undefined and isNotInternetExplorer()
    $("#filedrag").show()

$(document)
  .on('dragenter', '[data-object~="dropfile"]', (e) ->
    e.stopPropagation()
    e.preventDefault()
  )
  .on('dragover', '[data-object~="dropfile"]', (e) ->
    e.stopPropagation()
    e.preventDefault()
  )
  .on('drop', '[data-object~="dropfile"]', (e) ->
    e.stopPropagation()
    e.preventDefault()

    event = e.originalEvent || e
    data = new FormData()
    $.each(event.dataTransfer.files, (index, file) ->
      data.append 'attachments[]', file
    )

    project = $(this).data('project')
    adverse_event = $(this).data('adverse-event')

    file_count = event.dataTransfer.files.length

    if file_count == 1
      plural = ''
    else
      plural = 's'

    $(this).html("Uploading #{file_count} file#{plural}...")
    $this = $(this)
    $.ajax(
      url: "#{root_url}projects/#{project}/adverse-events/#{adverse_event}/files/upload.js"
      type: 'POST'
      data: data         # The form with the file inputs.
      processData: false # Using FormData, no need to process data.
      contentType: false
    ).done( () ->
      console.log("Success: Attachments uploaded!")
    ).fail( () ->
      url = "#{root_url}projects/#{project}/adverse-events/#{adverse_event}/files/new"
      $this.html("An error occurred, the attachments could not be uploaded!<br /><br />Please try again or <a href=\"#{url}\">upload the files</a> manually.")
    )
  )
