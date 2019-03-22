@numberOfHardAndSoftLineBreaks = (element) ->
  mWidth = 25/3
  lineWidth = $(element).innerWidth()
  string = $(element).val()
  array = string.split("\n")
  lineBreaks = array.length # Hard Breaks
  $.each(array, (index, line) ->
    lineBreaks += Math.floor((mWidth * line.length) / lineWidth) # Soft Wraps
  )
  return lineBreaks

$(document)
  .on("input", "[data-object~=expandable-text-area]", (e) ->
    numberOfLineBreaks = numberOfHardAndSoftLineBreaks($(this))
    if numberOfLineBreaks > 25
      $(this).attr("rows", 25)
    else if numberOfLineBreaks > $(this).data("default-rows")
      $(this).attr("rows", numberOfLineBreaks)
    else
      $(this).attr("rows", $(this).data("default-rows"))
  )
