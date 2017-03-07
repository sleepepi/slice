@signaturesReady = ->
  $("[data-object~='signature']").each( (index, element) ->
    sig = $($(this).data('signature-target')).val() if $($(this).data('signature-target')).val()
    $(this).signaturePad(
      drawOnly: true
      lineWidth: 0
      validateFields: false
      canvas: $(this)
      output: $($(this).data('signature-target'))
      bgColour: $(this).css('background-color') || "#ffffff"
      penColour: $(this).css('color') || "#145394"
    ).regenerate(sig)
  )
  $("[data-object~='signature-display']").each( (index, element) ->
    sig = $(this).data('signature-string')
    $(this).signaturePad(
      displayOnly: true
      canvas: $(this)
      bgColour: $(this).css('background-color') || "#ffffff"
      penColour: $(this).css('color') || "#145394"
    ).regenerate(sig)
  )
  false

$(document)
  .on('click', '[data-object~="clear-signature"]', ->
    target_name = $(this).data("target-name")
    clearClassStyles(target_name)
    $("##{target_name}").val("")
    $("##{target_name}").blur()
    signaturesReady()
    false
  )
