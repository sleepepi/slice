@expressionsReady = ->
  $("[data-object~=expressions-textcomplete]").each( ->
    $this = $(this)
    $this.textcomplete(
      [
        {
          match: /(^|\s)([a-zA-Z]\w*)$/
          search: (term, callback) ->
            $.getJSON("#{$this.data("textcomplete-url")}", { search: term })
              .done((resp) -> callback(resp))
              .fail(-> callback([]))
          replace: (value) ->
            return "$1#{value}"
          cache: true
        }
      ]
    )
  )

@consoleAndScreen = (value) ->
  console.log value
  $("#debug-console").prepend("#{value}<br>")

@drawSobjectsTable = (sobjects) ->
  result = "<table class=\"table table-striped table-borderless\">"
  result += "<thead><tr>"
  result += "<th>Subject ID</th>"
  if sobjects[0]?
    for key, value of sobjects[0].values
      result += "<th>#{key}</th>" unless key[0] == "_"
  result += "</tr></thead><tbody>"
  for sobject in sobjects
    result += "<tr>"
    result += "<td>#{sobject.subject_id}</td>"
    for key, value of sobject.values
      result += "<td>#{value}</td>" unless key[0] == "_"
    result += "</tr>"
  result += "</tbody></table>"
  result

@engineOutput = (data) ->
  $("#current-space").html(data.expressions)
  $("#current-tokens").html("")
  for token in data.tokens
    $("#current-tokens").append(drawToken(token))
  $("#subjects-count").html(data.subjects_count)
  $("#run-ms").html("#{data.run_ms}ms")

  $("#sobjects-table").html(drawSobjectsTable(data.sobjects))


@sendExpression = (element, params) ->
  consoleAndScreen $(element).val()

  params = { expressions: $(element).val() }

  $("#run-ms").html("...")
  $("#subjects-count").html("<i class=\"d-inline-block fas fa-circle-notch fa-spin\"></i>")

  $.ajax(
    url: "#{$(element).data("url")}"
    type: "POST"
    dataType: "json"
    data: params
  ).done( (data) ->
    engineOutput(data)
  ).fail( (jqXHR, textStatus, errorThrown) ->
    console.log("FAIL: #{textStatus} #{errorThrown}")
  )

@clearExistingTimeouts = (element) ->
  if element.data("timeouts")?
    for timeout in element.data("timeouts")
      clearTimeout(timeout)
  element.data("timeouts", [])

$(document)
  .on("keyup", "[data-object~=expressions-input]", (event) ->
    return if event.which in [9, 12, 16, 17, 18, 20, 27, 33, 34, 35, 36, 37, 38, 39, 40, 91, 93]
    # consoleAndScreen event.which
    $this = $(this)
    clearExistingTimeouts($this)
    timeout = setTimeout(sendExpression.bind(null, $this), 250 * 1)
    $this.data("timeouts").push(timeout)
  )
