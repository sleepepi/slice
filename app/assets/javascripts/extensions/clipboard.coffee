@clipboardReady = ->
  unless typeof Clipboard is 'undefined' or !Clipboard.isSupported()
    clipboard = new Clipboard('[data-clipboard-target],[data-clipboard-text]')
    clipboard.on('success', (e) ->
      $(e.trigger).tooltip('show')
      setTimeout(
        -> $(e.trigger).tooltip('destroy'),
        1000
      )
      e.clearSelection()
    )
