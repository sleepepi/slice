@themes = ->
  [
    "default"
    "night"
    "underwater"
    "love"
    "royal"
    "spring"
    # "fall"
    "winter"
  ]

@changeTheme = (theme) ->
  $("body").data("theme", theme)
  body_classes = themes().map (t) -> "theme-#{t}-bg"
  menu_classes = themes().map (t) -> "menu-#{t}"
  footer_classes = themes().map (t) -> "footer-#{t}"
  $(".theme-bg").removeClass(body_classes.join(" ")).addClass("theme-#{theme}-bg")
  $(".navbar-custom").removeClass(menu_classes.join(" ")).addClass("menu-#{theme}")
  $(".footer-container").removeClass(footer_classes.join(" ")).addClass("footer-#{theme}")

@randomTheme = ->
  index = Math.floor(Math.random() * themes().length)
  changeTheme(themes()[index])

@themesReady = ->
  if $("[data-object~=random-theme]").length > 0
    interval = setInterval( ->
      randomTheme()
    , 1000 * 1) # In one second
    removeInterval = ->
      clearInterval(interval)
      $(document).off("turbolinks:load", removeInterval)
    $(document).on("turbolinks:load", removeInterval)
