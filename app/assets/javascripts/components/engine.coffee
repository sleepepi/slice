@engineReady = ->
  expressionsReady()

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

@sendExpression = (element, params) ->
  consoleAndScreen $(element).val()
  params = { expressions: $(element).val() }
  $("#run-ms").html("...")
  $("#subjects-count").html("<i class=\"d-inline-block fas fa-circle-notch fa-spin\"></i>")
  $.post($(element).data("url"), params, null, "script")

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
