@clipboardReady = ->
  unless typeof ClipboardJS is 'undefined' or !ClipboardJS.isSupported()
    clipboard = new ClipboardJS('[data-clipboard-target],[data-clipboard-text]')
    clipboard.on('success', (e) ->
      $(e.trigger).tooltip('show')
      setTimeout(
        -> $(e.trigger).tooltip('dispose'),
        1000
      )
      e.clearSelection()
    )
